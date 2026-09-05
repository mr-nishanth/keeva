package com.example.whatsapp_status_saver.status

import android.content.ContentValues
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import android.util.Log
import java.io.IOException

data class SaveResult(
    val success: Boolean,
    val mediaType: String,
    val displayName: String,
    val bytesSaved: Long,
    val publicCollection: String,
    val insertedUri: String? = null,
    val error: String? = null
) {
    fun toMap(): Map<String, Any?> = mapOf(
        "success" to success,
        "mediaType" to mediaType,
        "displayName" to displayName,
        "bytesSaved" to bytesSaved,
        "publicCollection" to publicCollection,
        "insertedUri" to insertedUri,
        "error" to error
    )
}

/**
 * Handles zero-permission saving of photos and videos to the device's public gallery
 * via MediaStore (API 29+) with atomic rollback on failure.
 */
class MediaStoreSaver(private val context: Context) {

    companion object {
        private const val TAG = "MediaStoreSaver"
        const val IMAGE_RELATIVE_PATH = "Pictures/SavedStatus/"
        const val VIDEO_RELATIVE_PATH = "Movies/SavedStatus/"
    }

    /**
     * Saves media from a source SAF Uri to MediaStore public collections.
     * Enforces atomic rollback: any failure deletes the target MediaStore row immediately.
     */
    fun saveMedia(
        sourceUri: Uri,
        displayName: String,
        mimeType: String,
        isVideo: Boolean
    ): SaveResult {
        val resolver = context.contentResolver
        val isVideoItem = isVideo || mimeType.startsWith("video/")
        val collectionUri = if (isVideoItem) {
            MediaStore.Video.Media.EXTERNAL_CONTENT_URI
        } else {
            MediaStore.Images.Media.EXTERNAL_CONTENT_URI
        }
        val relativePath = if (isVideoItem) VIDEO_RELATIVE_PATH else IMAGE_RELATIVE_PATH
        val mediaTypeLabel = if (isVideoItem) "video" else "image"

        val sanitizedDisplayName = sanitizeFileName(displayName, isVideoItem)
        val contentValues = ContentValues().apply {
            put(MediaStore.MediaColumns.DISPLAY_NAME, sanitizedDisplayName)
            put(MediaStore.MediaColumns.MIME_TYPE, mimeType)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.MediaColumns.RELATIVE_PATH, relativePath)
                put(MediaStore.MediaColumns.IS_PENDING, 1)
            }
        }

        var targetUri: Uri? = null

        try {
            // Stage 1: Create destination entry in MediaStore
            targetUri = resolver.insert(collectionUri, contentValues)
                ?: throw IOException("MediaStore.insert returned null for $collectionUri")

            // Stage 2 & 3: Open streams and copy bytes
            val inputStream = resolver.openInputStream(sourceUri)
                ?: throw IOException("Failed to open source stream for $sourceUri")

            var bytesCopied = 0L

            inputStream.use { input ->
                val outputStream = resolver.openOutputStream(targetUri)
                    ?: throw IOException("Failed to open destination stream for $targetUri")

                outputStream.use { output ->
                    bytesCopied = input.copyTo(output)
                    output.flush()
                }
            }

            if (bytesCopied == 0L) {
                throw IOException("Source stream contained 0 bytes; aborting save to avoid empty gallery file.")
            }

            // Stage 4: Finalize by clearing IS_PENDING
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                contentValues.clear()
                contentValues.put(MediaStore.MediaColumns.IS_PENDING, 0)
                resolver.update(targetUri, contentValues, null, null)
            }

            Log.d(TAG, "Saved $mediaTypeLabel successfully: $sanitizedDisplayName ($bytesCopied bytes) -> $targetUri")

            return SaveResult(
                success = true,
                mediaType = mediaTypeLabel,
                displayName = sanitizedDisplayName,
                bytesSaved = bytesCopied,
                publicCollection = relativePath,
                insertedUri = targetUri.toString()
            )

        } catch (e: Exception) {
            Log.e(TAG, "Failed to save status media: ${e.message}. Performing atomic rollback...", e)

            // Atomic rollback: clean up orphaned destination row immediately
            if (targetUri != null) {
                try {
                    resolver.delete(targetUri, null, null)
                    Log.d(TAG, "Atomic rollback complete: deleted $targetUri")
                } catch (deleteEx: Exception) {
                    Log.w(TAG, "Rollback delete failed for $targetUri", deleteEx)
                }
            }

            return SaveResult(
                success = false,
                mediaType = mediaTypeLabel,
                displayName = sanitizedDisplayName,
                bytesSaved = 0L,
                publicCollection = relativePath,
                error = e.message ?: e.toString()
            )
        }
    }

    private fun sanitizeFileName(originalName: String, isVideo: Boolean): String {
        val clean = originalName.trim().ifEmpty { "status_${System.currentTimeMillis()}" }
        val defaultExt = if (isVideo) ".mp4" else ".jpg"

        return if (isVideo) {
            if (clean.endsWith(".mp4", ignoreCase = true)) clean else "$clean$defaultExt"
        } else {
            if (clean.endsWith(".jpg", ignoreCase = true) ||
                clean.endsWith(".jpeg", ignoreCase = true) ||
                clean.endsWith(".png", ignoreCase = true) ||
                clean.endsWith(".webp", ignoreCase = true)
            ) {
                clean
            } else {
                "$clean$defaultExt"
            }
        }
    }
}
