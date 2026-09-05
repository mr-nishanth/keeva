package com.example.whatsapp_status_saver.status

import android.content.Context
import android.net.Uri
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.security.MessageDigest

/**
 * Manages on-demand video streaming cache to allow smooth, hardware-accelerated
 * seeking in video playback without SAF ContentResolver pipe buffer stalls.
 * Cache quota: 100 MB maximum, pruned to 75 MB on overflow.
 */
class VideoCacheManager(private val context: Context) {

    companion object {
        private const val TAG = "VideoCacheManager"
        private const val VIDEO_CACHE_DIR = "videos"
        const val MAX_CACHE_BYTES = 100 * 1024 * 1024L // 100 MB
        const val PRUNE_TARGET_BYTES = 75 * 1024 * 1024L // 75 MB

        fun getSafeCacheKey(input: String): String {
            return try {
                val digest = MessageDigest.getInstance("MD5")
                val hashBytes = digest.digest(input.toByteArray(Charsets.UTF_8))
                hashBytes.joinToString("") { "%02x".format(it) }
            } catch (_: Exception) {
                input.hashCode().toString()
            }
        }
    }

    private val videoDir: File by lazy {
        File(context.cacheDir, VIDEO_CACHE_DIR).apply {
            if (!exists()) {
                mkdirs()
            }
        }
    }

    /**
     * Prepares a video status for playback by streaming its bytes to a local cache file.
     * Verifies cached entries before reuse.
     * Returns the absolute path of the cached MP4 file.
     */
    fun prepareVideo(id: String, documentUri: Uri, expectedSizeBytes: Long = 0L): String {
        val cacheKey = "${getSafeCacheKey(id)}.mp4"
        val targetFile = File(videoDir, cacheKey)

        // 1. Check if valid cached copy already exists
        if (targetFile.exists() && targetFile.length() > 0) {
            val length = targetFile.length()
            val matchesExpected = expectedSizeBytes <= 0L || length == expectedSizeBytes
            if (matchesExpected) {
                targetFile.setLastModified(System.currentTimeMillis())
                return targetFile.absolutePath
            } else {
                Log.w(TAG, "Cached video size mismatch (cached: $length, expected: $expectedSizeBytes). Re-caching...")
                targetFile.delete()
            }
        }

        // 2. Pre-prune if incoming video would exceed max cache size
        val incomingSize = if (expectedSizeBytes > 0L) expectedSizeBytes else 5 * 1024 * 1024L
        ensureSpaceFor(incomingSize)

        // 3. Stream from SAF ContentResolver to local temporary cache file
        val tempFile = File(videoDir, "$cacheKey.tmp")
        try {
            val inputStream = context.contentResolver.openInputStream(documentUri)
                ?: throw IOException("Failed to open InputStream for video: $documentUri")

            var bytesCopied = 0L
            inputStream.use { input ->
                FileOutputStream(tempFile).use { output ->
                    bytesCopied = input.copyTo(output)
                    output.flush()
                }
            }

            if (bytesCopied == 0L) {
                throw IOException("0 bytes streamed for video: $documentUri")
            }

            // Atomically rename temp file to target cache file
            if (!tempFile.renameTo(targetFile)) {
                tempFile.copyTo(targetFile, overwrite = true)
                tempFile.delete()
            }

            targetFile.setLastModified(System.currentTimeMillis())
            pruneCacheIfNeeded()

            return targetFile.absolutePath

        } catch (e: Exception) {
            if (tempFile.exists()) tempFile.delete()
            throw e
        }
    }

    private fun ensureSpaceFor(requiredBytes: Long) {
        val files = videoDir.listFiles() ?: return
        var currentBytes = files.sumOf { it.length() }

        if (currentBytes + requiredBytes > MAX_CACHE_BYTES) {
            val sortedFiles = files.sortedBy { it.lastModified() }
            for (file in sortedFiles) {
                val len = file.length()
                if (file.delete()) {
                    currentBytes -= len
                    if (currentBytes + requiredBytes <= PRUNE_TARGET_BYTES) {
                        break
                    }
                }
            }
        }
    }

    /**
     * Bounded LRU eviction. When total video cache exceeds 100 MB,
     * files are deleted in ascending lastModified order until total size drops to <= 75 MB.
     */
    fun pruneCacheIfNeeded() {
        val files = videoDir.listFiles() ?: return
        var totalBytes = files.sumOf { it.length() }

        if (totalBytes > MAX_CACHE_BYTES) {
            val sortedFiles = files.sortedBy { it.lastModified() }
            for (file in sortedFiles) {
                val len = file.length()
                if (file.delete()) {
                    totalBytes -= len
                    if (totalBytes <= PRUNE_TARGET_BYTES) {
                        break
                    }
                }
            }
            Log.d(TAG, "Pruned video cache down to ${totalBytes / (1024 * 1024)} MB")
        }
    }

    /**
     * Clears all cached videos. Does NOT touch saved media in Gallery.
     */
    fun clearCache(): Long {
        val files = videoDir.listFiles() ?: return 0L
        var freedBytes = 0L
        for (file in files) {
            val len = file.length()
            if (file.delete()) {
                freedBytes += len
            }
        }
        return freedBytes
    }

    /**
     * Returns total bytes occupied by cached videos.
     */
    fun getCacheSizeBytes(): Long {
        val files = videoDir.listFiles() ?: return 0L
        return files.sumOf { it.length() }
    }
}
