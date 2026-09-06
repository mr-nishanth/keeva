package io.nishvanta.keeva.status

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Build
import android.util.Log
import java.io.File
import java.io.FileOutputStream
import java.io.IOException
import java.security.MessageDigest

/**
 * Handles native background bitmap downsampling and LRU disk caching
 * for status images and videos. Target thumbnail dimension is ~256x256.
 * Cache quota: 100 MB maximum, pruned to 80 MB on overflow.
 */
class ThumbnailManager(private val context: Context) {

    companion object {
        private const val TAG = "ThumbnailManager"
        private const val THUMBNAIL_DIR = "thumbnails"
        const val TARGET_SIZE = 256
        const val MAX_CACHE_BYTES = 100 * 1024 * 1024L // 100 MB
        const val PRUNE_TARGET_BYTES = 80 * 1024 * 1024L // 80 MB

        fun calculateInSampleSize(
            actualWidth: Int,
            actualHeight: Int,
            reqWidth: Int,
            reqHeight: Int
        ): Int {
            var inSampleSize = 1
            if (actualHeight > reqHeight || actualWidth > reqWidth) {
                val halfHeight = actualHeight / 2
                val halfWidth = actualWidth / 2
                while ((halfHeight / inSampleSize) >= reqHeight && (halfWidth / inSampleSize) >= reqWidth) {
                    inSampleSize *= 2
                }
            }
            return inSampleSize.coerceAtLeast(1)
        }

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

    private val thumbnailDir: File by lazy {
        File(context.cacheDir, THUMBNAIL_DIR).apply {
            if (!exists()) {
                mkdirs()
            }
        }
    }

    /**
     * Retrieves or generates a downsampled ~256x256 thumbnail for the given document URI.
     * Returns the absolute path to the local cached WebP/JPEG file.
     */
    fun getThumbnail(
        id: String,
        documentUri: Uri,
        isVideo: Boolean,
        targetWidth: Int = TARGET_SIZE,
        targetHeight: Int = TARGET_SIZE
    ): String {
        val cacheKey = "${getSafeCacheKey(id)}.webp"
        val cachedFile = File(thumbnailDir, cacheKey)

        // Return cached thumbnail if it exists and has content
        if (cachedFile.exists() && cachedFile.length() > 0) {
            cachedFile.setLastModified(System.currentTimeMillis())
            return cachedFile.absolutePath
        }

        // Generate downsampled thumbnail
        val bitmap = if (isVideo) {
            decodeVideoThumbnail(documentUri, targetWidth, targetHeight)
        } else {
            decodeImageThumbnail(documentUri, targetWidth, targetHeight)
        } ?: throw IOException("Failed to decode thumbnail bitmap for $documentUri")

        // Save to cache
        val tempFile = File(thumbnailDir, "$cacheKey.tmp")
        try {
            FileOutputStream(tempFile).use { outStream ->
                val format = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    Bitmap.CompressFormat.WEBP_LOSSY
                } else {
                    @Suppress("DEPRECATION")
                    Bitmap.CompressFormat.WEBP
                }
                val compressed = bitmap.compress(format, 85, outStream)
                if (!compressed) {
                    // Fallback to JPEG if WebP compression fails
                    bitmap.compress(Bitmap.CompressFormat.JPEG, 85, outStream)
                }
                outStream.flush()
            }

            if (!tempFile.renameTo(cachedFile)) {
                // If rename failed, copy manually
                tempFile.copyTo(cachedFile, overwrite = true)
                tempFile.delete()
            }

            cachedFile.setLastModified(System.currentTimeMillis())
            pruneCacheIfNeeded()

            return cachedFile.absolutePath
        } catch (e: Exception) {
            if (tempFile.exists()) tempFile.delete()
            throw e
        } finally {
            bitmap.recycle()
        }
    }

    private fun decodeImageThumbnail(documentUri: Uri, reqWidth: Int, reqHeight: Int): Bitmap? {
        val pfd = context.contentResolver.openFileDescriptor(documentUri, "r")
            ?: return null

        return pfd.use { descriptor ->
            val fileDescriptor = descriptor.fileDescriptor

            // Step 1: Decode dimensions only
            val options = BitmapFactory.Options().apply {
                inJustDecodeBounds = true
            }
            BitmapFactory.decodeFileDescriptor(fileDescriptor, null, options)

            if (options.outWidth <= 0 || options.outHeight <= 0) {
                return null
            }

            // Step 2: Calculate sample size
            options.inSampleSize = calculateInSampleSize(
                options.outWidth,
                options.outHeight,
                reqWidth,
                reqHeight
            )
            options.inJustDecodeBounds = false
            options.inPreferredConfig = Bitmap.Config.RGB_565

            // Step 3: Decode downsampled bitmap
            BitmapFactory.decodeFileDescriptor(fileDescriptor, null, options)
        }
    }

    private fun decodeVideoThumbnail(documentUri: Uri, reqWidth: Int, reqHeight: Int): Bitmap? {
        val pfd = context.contentResolver.openFileDescriptor(documentUri, "r")
            ?: return null

        return pfd.use { descriptor ->
            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(descriptor.fileDescriptor)
                // Retrieve frame at 0 microseconds
                val frame = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
                    retriever.getScaledFrameAtTime(
                        0,
                        MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
                        reqWidth,
                        reqHeight
                    )
                } else {
                    retriever.getFrameAtTime(0, MediaMetadataRetriever.OPTION_CLOSEST_SYNC)
                }

                if (frame != null && (frame.width > reqWidth * 1.5 || frame.height > reqHeight * 1.5)) {
                    val scaled = Bitmap.createScaledBitmap(frame, reqWidth, reqHeight, true)
                    frame.recycle()
                    scaled
                } else {
                    frame
                }
            } catch (e: Exception) {
                Log.w(TAG, "Failed to retrieve video frame from $documentUri", e)
                null
            } finally {
                try {
                    retriever.release()
                } catch (_: Exception) {}
            }
        }
    }

    /**
     * Bounded LRU cache pruning. When thumbnail cache exceeds 100 MB,
     * files are deleted in ascending lastModified order until total size drops to <= 80 MB.
     */
    fun pruneCacheIfNeeded() {
        val files = thumbnailDir.listFiles() ?: return
        var totalBytes = files.sumOf { it.length() }

        if (totalBytes > MAX_CACHE_BYTES) {
            val sortedFiles = files.sortedBy { it.lastModified() }
            for (file in sortedFiles) {
                val fileLen = file.length()
                if (file.delete()) {
                    totalBytes -= fileLen
                    if (totalBytes <= PRUNE_TARGET_BYTES) {
                        break
                    }
                }
            }
            Log.d(TAG, "Pruned thumbnail cache down to ${totalBytes / (1024 * 1024)} MB")
        }
    }

    /**
     * Purges all cached thumbnails. Does NOT touch saved media in Gallery.
     */
    fun clearCache(): Long {
        val files = thumbnailDir.listFiles() ?: return 0L
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
     * Returns the current total size of thumbnail cache in bytes.
     */
    fun getCacheSizeBytes(): Long {
        val files = thumbnailDir.listFiles() ?: return 0L
        return files.sumOf { it.length() }
    }
}
