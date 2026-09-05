package com.example.whatsapp_status_saver.status

import android.content.Context
import android.net.Uri
import android.os.ParcelFileDescriptor
import android.provider.DocumentsContract
import android.util.Log
import java.io.File
import java.io.InputStream
import java.nio.charset.StandardCharsets
import java.util.concurrent.ConcurrentHashMap

data class StatusDocument(
    val id: String, // Opaque identifier across platform boundary
    val documentId: String, // Internal SAF document ID
    val displayName: String,
    val mimeType: String,
    val sizeBytes: Long,
    val lastModified: Long,
    val isVideo: Boolean,
    val documentUri: Uri,
    val isSaved: Boolean = false
) {
    fun toMap(): Map<String, Any> = mapOf(
        "id" to id,
        "fileName" to displayName,
        "displayName" to displayName, // Backward compatibility with POC
        "mimeType" to mimeType,
        "sizeBytes" to sizeBytes,
        "lastModified" to lastModified,
        "isVideo" to isVideo,
        "isSaved" to isSaved,
        "uri" to id // Backward compatibility: POC expects 'uri' property, returns opaque ID
    )
}

/**
 * Handles WhatsApp Status media discovery, projection querying,
 * opaque identifier creation, and safe stream access via ContentResolver.
 */
class StatusDocumentReader(private val context: Context) {

    companion object {
        private const val TAG = "StatusDocumentReader"
        private const val OPAQUE_ID_PREFIX = "stat_"

        private val PROJECTION = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
            DocumentsContract.Document.COLUMN_SIZE,
            DocumentsContract.Document.COLUMN_LAST_MODIFIED
        )

        /**
         * Encodes a SAF document ID into a URL-safe opaque identifier.
         */
        fun encodeOpaqueId(documentId: String): String {
            val bytes = documentId.toByteArray(StandardCharsets.UTF_8)
            val base64 = java.util.Base64.getUrlEncoder().withoutPadding().encodeToString(bytes)
            return "$OPAQUE_ID_PREFIX$base64"
        }

        /**
         * Decodes an opaque identifier back into the original SAF document ID.
         */
        fun decodeOpaqueId(opaqueId: String): String? {
            return try {
                val cleanToken = if (opaqueId.startsWith(OPAQUE_ID_PREFIX)) {
                    opaqueId.substring(OPAQUE_ID_PREFIX.length)
                } else {
                    opaqueId
                }
                val bytes = java.util.Base64.getUrlDecoder().decode(cleanToken)
                String(bytes, StandardCharsets.UTF_8)
            } catch (e: Exception) {
                null
            }
        }
    }

    // In-memory registry for fast resolution of opaque ID -> StatusDocument
    private val documentCache = ConcurrentHashMap<String, StatusDocument>()

    /**
     * Enumerates status files from the specified .Statuses document ID within the tree URI.
     */
    fun scanStatuses(treeUri: Uri, statusesDocId: String): List<StatusDocument> {
        val resultList = mutableListOf<StatusDocument>()
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, statusesDocId)

        val savedPrefs = context.getSharedPreferences("keeva_saved_status", Context.MODE_PRIVATE)
        val picturesDir = File(android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_PICTURES), "SavedStatus")
        val moviesDir = File(android.os.Environment.getExternalStoragePublicDirectory(android.os.Environment.DIRECTORY_MOVIES), "SavedStatus")

        try {
            context.contentResolver.query(childrenUri, PROJECTION, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
                val sizeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_SIZE)
                val modCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_LAST_MODIFIED)

                while (cursor.moveToNext()) {
                    val docId = cursor.getString(idCol) ?: continue
                    val name = cursor.getString(nameCol) ?: ""
                    val mime = cursor.getString(mimeCol) ?: ""
                    val size = if (cursor.isNull(sizeCol)) 0L else cursor.getLong(sizeCol)
                    val lastMod = if (cursor.isNull(modCol)) 0L else cursor.getLong(modCol)

                    // Skip directories and sentinel files
                    if (name.equals(".nomedia", ignoreCase = true) ||
                        mime == DocumentsContract.Document.MIME_TYPE_DIR
                    ) {
                        continue
                    }

                    val isVideo = mime.startsWith("video/") || name.endsWith(".mp4", ignoreCase = true)
                    val isImage = mime.startsWith("image/") ||
                            name.endsWith(".jpg", ignoreCase = true) ||
                            name.endsWith(".jpeg", ignoreCase = true) ||
                            name.endsWith(".png", ignoreCase = true) ||
                            name.endsWith(".webp", ignoreCase = true)

                    // Filter out unsupported non-media entries
                    if (!isVideo && !isImage) {
                        continue
                    }

                    val normalizedMime = when {
                        mime.isNotEmpty() -> mime
                        isVideo -> "video/mp4"
                        name.endsWith(".png", ignoreCase = true) -> "image/png"
                        name.endsWith(".webp", ignoreCase = true) -> "image/webp"
                        else -> "image/jpeg"
                    }

                    val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                    val opaqueId = encodeOpaqueId(docId)
                    val isSaved = savedPrefs.getBoolean(opaqueId, false) ||
                            savedPrefs.getBoolean(name, false) ||
                            (if (isVideo) File(moviesDir, name).exists() else File(picturesDir, name).exists())

                    val statusDoc = StatusDocument(
                        id = opaqueId,
                        documentId = docId,
                        displayName = name,
                        mimeType = normalizedMime,
                        sizeBytes = size,
                        lastModified = lastMod,
                        isVideo = isVideo,
                        documentUri = docUri,
                        isSaved = isSaved
                    )

                    documentCache[opaqueId] = statusDoc
                    resultList.add(statusDoc)
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to scan statuses for treeUri: $treeUri, docId: $statusesDocId", e)
            throw e
        }

        return resultList
    }

    /**
     * Resolves an opaque identifier back to its native SAF Document URI.
     */
    fun resolveDocumentUri(opaqueOrRawId: String, fallbackTreeUri: Uri? = null): Uri? {
        // 1. Check in-memory registry
        documentCache[opaqueOrRawId]?.let { return it.documentUri }

        // 2. If already a content:// URI string (backward compatibility)
        if (opaqueOrRawId.startsWith("content://")) {
            return try {
                Uri.parse(opaqueOrRawId)
            } catch (_: Exception) {
                null
            }
        }

        // 3. Decode opaque identifier
        val docId = decodeOpaqueId(opaqueOrRawId) ?: opaqueOrRawId
        val treeUri = fallbackTreeUri ?: findPersistedTreeUri()

        return if (treeUri != null && docId.isNotEmpty()) {
            DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
        } else {
            null
        }
    }

    /**
     * Retrieves cached StatusDocument metadata by opaque ID.
     */
    fun getCachedDocument(opaqueId: String): StatusDocument? = documentCache[opaqueId]

    /**
     * Safely opens an InputStream from ContentResolver for the document URI.
     */
    fun openInputStream(documentUri: Uri): InputStream? {
        return try {
            context.contentResolver.openInputStream(documentUri)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open InputStream for $documentUri", e)
            null
        }
    }

    /**
     * Safely opens a ParcelFileDescriptor from ContentResolver for the document URI.
     */
    fun openFileDescriptor(documentUri: Uri, mode: String = "r"): ParcelFileDescriptor? {
        return try {
            context.contentResolver.openFileDescriptor(documentUri, mode)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to open FileDescriptor for $documentUri", e)
            null
        }
    }

    private fun findPersistedTreeUri(): Uri? {
        return try {
            context.contentResolver.persistedUriPermissions
                .firstOrNull { it.isReadPermission && DocumentsContract.isTreeUri(it.uri) }?.uri
        } catch (_: Exception) {
            null
        }
    }
}
