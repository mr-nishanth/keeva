package com.example.whatsapp_status_saver

import android.app.Activity
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.DocumentsContract
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.whatsapp_status_saver/scanner"
    private val REQUEST_CODE_SAF_TREE = 4201

    private var pendingSafResult: MethodChannel.Result? = null
    private val ioExecutor = Executors.newFixedThreadPool(2)
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "checkFolderAccess" -> {
                        checkFolderAccess(result)
                    }
                    "requestFolderAccess" -> {
                        requestFolderAccess(result)
                    }
                    "scanStatuses" -> {
                        val treeUriString = call.argument<String>("treeUri")
                        ioExecutor.execute {
                            scanStatuses(treeUriString, result)
                        }
                    }
                    "verifyMediaRead" -> {
                        val uriString = call.argument<String>("uri")
                        if (uriString == null) {
                            result.error("INVALID_ARG", "URI is required", null)
                            return@setMethodCallHandler
                        }
                        ioExecutor.execute {
                            verifyMediaRead(uriString, result)
                        }
                    }
                    "saveTestImage" -> {
                        val uriString = call.argument<String>("uri")
                        val displayName = call.argument<String>("displayName") ?: "status_test.jpg"
                        if (uriString == null) {
                            result.error("INVALID_ARG", "URI is required", null)
                            return@setMethodCallHandler
                        }
                        ioExecutor.execute {
                            saveTestImage(uriString, displayName, result)
                        }
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }

    private fun checkFolderAccess(result: MethodChannel.Result) {
        try {
            val persistedPerms = contentResolver.persistedUriPermissions
            // Find a persisted tree permission that has read permission
            val match = persistedPerms.firstOrNull { it.isReadPermission }
            if (match != null) {
                result.success(
                    mapOf(
                        "hasAccess" to true,
                        "treeUri" to match.uri.toString()
                    )
                )
            } else {
                result.success(
                    mapOf(
                        "hasAccess" to false,
                        "treeUri" to null
                    )
                )
            }
        } catch (e: Exception) {
            result.error("CHECK_FAILED", e.message, null)
        }
    }

    private fun requestFolderAccess(result: MethodChannel.Result) {
        if (pendingSafResult != null) {
            result.error("ALREADY_PENDING", "Another SAF request is active", null)
            return
        }
        pendingSafResult = result

        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                            Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
                )
                // Suggested target: Android/media/com.whatsapp/WhatsApp/Media
                val initialUri = DocumentsContract.buildDocumentUri(
                    "com.android.externalstorage.documents",
                    "primary:Android/media/com.whatsapp/WhatsApp/Media"
                )
                putExtra(DocumentsContract.EXTRA_INITIAL_URI, initialUri)
            }
            startActivityForResult(intent, REQUEST_CODE_SAF_TREE)
        } catch (e: Exception) {
            pendingSafResult = null
            result.error("LAUNCH_FAILED", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode == REQUEST_CODE_SAF_TREE) {
            val channelResult = pendingSafResult ?: return
            pendingSafResult = null

            if (resultCode == Activity.RESULT_OK && data != null && data.data != null) {
                val treeUri = data.data!!
                val rawFlags = data.flags
                try {
                    // Take persistable read permission only as requested
                    contentResolver.takePersistableUriPermission(
                        treeUri,
                        Intent.FLAG_GRANT_READ_URI_PERMISSION
                    )
                    channelResult.success(
                        mapOf(
                            "granted" to true,
                            "treeUri" to treeUri.toString(),
                            "flags" to rawFlags,
                            "persisted" to true
                        )
                    )
                } catch (e: Exception) {
                    channelResult.success(
                        mapOf(
                            "granted" to true,
                            "treeUri" to treeUri.toString(),
                            "flags" to rawFlags,
                            "persisted" to false,
                            "error" to "Failed to persist URI permission: ${e.message}"
                        )
                    )
                }
            } else {
                channelResult.success(
                    mapOf(
                        "granted" to false,
                        "error" to "User cancelled or no URI returned (resultCode: $resultCode)"
                    )
                )
            }
        }
    }

    private fun scanStatuses(treeUriString: String?, result: MethodChannel.Result) {
        try {
            val effectiveTreeUri = if (!treeUriString.isNullOrEmpty()) {
                Uri.parse(treeUriString)
            } else {
                val match = contentResolver.persistedUriPermissions.firstOrNull { it.isReadPermission }
                match?.uri ?: run {
                    mainHandler.post {
                        result.error("NO_TREE_URI", "No tree URI provided or persisted", null)
                    }
                    return
                }
            }

            val treeDocId = DocumentsContract.getTreeDocumentId(effectiveTreeUri)
            val projection = arrayOf(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
                DocumentsContract.Document.COLUMN_MIME_TYPE,
                DocumentsContract.Document.COLUMN_SIZE,
                DocumentsContract.Document.COLUMN_LAST_MODIFIED
            )

            // Attempt 1: Direct child documents URI using target docId
            // If user granted WhatsApp/Media, .Statuses is "treeDocId/.Statuses"
            val targetDocId = when {
                treeDocId.endsWith("/.Statuses") -> treeDocId
                treeDocId.endsWith("/Media") || treeDocId.endsWith("WhatsApp/Media") -> "$treeDocId/.Statuses"
                treeDocId.endsWith("com.whatsapp") -> "$treeDocId/WhatsApp/Media/.Statuses"
                else -> "$treeDocId/.Statuses"
            }

            var statusesChildrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
                effectiveTreeUri,
                targetDocId
            )

            var items = queryChildren(effectiveTreeUri, statusesChildrenUri, projection)

            // Fallback attempt: If direct query returned 0 items or failed, traverse children from treeDocId
            if (items.isEmpty()) {
                val foundStatusesDocId = findStatusesFolderRecursively(effectiveTreeUri, treeDocId, 0)
                if (foundStatusesDocId != null) {
                    statusesChildrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(
                        effectiveTreeUri,
                        foundStatusesDocId
                    )
                    items = queryChildren(effectiveTreeUri, statusesChildrenUri, projection)
                }
            }

            mainHandler.post {
                result.success(items)
            }
        } catch (e: Exception) {
            mainHandler.post {
                result.error("SCAN_FAILED", e.message, null)
            }
        }
    }

    private fun queryChildren(
        treeUri: Uri,
        childrenUri: Uri,
        projection: Array<String>
    ): List<Map<String, Any>> {
        val list = mutableListOf<Map<String, Any>>()
        try {
            contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)
                val sizeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_SIZE)
                val modCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_LAST_MODIFIED)

                while (cursor.moveToNext()) {
                    val docId = cursor.getString(idCol)
                    val name = cursor.getString(nameCol) ?: ""
                    val mime = cursor.getString(mimeCol) ?: ""
                    val size = if (cursor.isNull(sizeCol)) 0L else cursor.getLong(sizeCol)
                    val lastMod = if (cursor.isNull(modCol)) 0L else cursor.getLong(modCol)

                    // Skip sentinel .nomedia or subdirectories
                    if (name == ".nomedia" || mime == DocumentsContract.Document.MIME_TYPE_DIR) {
                        continue
                    }

                    val docUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId)
                    val isVideo = mime.startsWith("video/") || name.endsWith(".mp4", ignoreCase = true)

                    list.add(
                        mapOf(
                            "documentId" to docId,
                            "displayName" to name,
                            "mimeType" to mime,
                            "sizeBytes" to size,
                            "lastModified" to lastMod,
                            "uri" to docUri.toString(),
                            "isVideo" to isVideo
                        )
                    )
                }
            }
        } catch (_: Exception) {
            // Handled by caller fallback
        }
        return list
    }

    private fun findStatusesFolderRecursively(treeUri: Uri, currentDocId: String, depth: Int): String? {
        if (depth > 4) return null
        val childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, currentDocId)
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE
        )
        try {
            contentResolver.query(childrenUri, projection, null, null, null)?.use { cursor ->
                val idCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DOCUMENT_ID)
                val nameCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_DISPLAY_NAME)
                val mimeCol = cursor.getColumnIndexOrThrow(DocumentsContract.Document.COLUMN_MIME_TYPE)

                val subDirs = mutableListOf<String>()
                while (cursor.moveToNext()) {
                    val docId = cursor.getString(idCol)
                    val name = cursor.getString(nameCol) ?: ""
                    val mime = cursor.getString(mimeCol) ?: ""

                    if (name.equals(".Statuses", ignoreCase = true)) {
                        return docId
                    }
                    if (mime == DocumentsContract.Document.MIME_TYPE_DIR) {
                        subDirs.add(docId)
                    }
                }

                for (subId in subDirs) {
                    val found = findStatusesFolderRecursively(treeUri, subId, depth + 1)
                    if (found != null) return found
                }
            }
        } catch (_: Exception) {
            return null
        }
        return null
    }

    private fun verifyMediaRead(uriString: String, result: MethodChannel.Result) {
        try {
            val uri = Uri.parse(uriString)
            var totalBytesRead = 0L
            val buffer = ByteArray(16384)

            val inputStream = contentResolver.openInputStream(uri)
            if (inputStream == null) {
                mainHandler.post {
                    result.success(
                        mapOf(
                            "success" to false,
                            "bytesRead" to 0L,
                            "error" to "openInputStream returned null for $uriString"
                        )
                    )
                }
                return
            }

            inputStream.use { stream ->
                var read: Int
                while (stream.read(buffer).also { read = it } != -1) {
                    totalBytesRead += read
                }
            }

            mainHandler.post {
                result.success(
                    mapOf(
                        "success" to true,
                        "bytesRead" to totalBytesRead
                    )
                )
            }
        } catch (e: Exception) {
            mainHandler.post {
                result.success(
                    mapOf(
                        "success" to false,
                        "bytesRead" to 0L,
                        "error" to (e.message ?: e.toString())
                    )
                )
            }
        }
    }

    private fun saveTestImage(uriString: String, displayName: String, result: MethodChannel.Result) {
        try {
            val sourceUri = Uri.parse(uriString)
            val contentValues = ContentValues().apply {
                put(MediaStore.Images.Media.DISPLAY_NAME, displayName)
                put(MediaStore.Images.Media.MIME_TYPE, "image/jpeg")
                put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/StatusSaverPOC/")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }

            val targetUri = contentResolver.insert(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                contentValues
            )

            if (targetUri == null) {
                mainHandler.post {
                    result.success(
                        mapOf(
                            "success" to false,
                            "error" to "MediaStore.insert returned null"
                        )
                    )
                }
                return
            }

            var bytesCopied = 0L
            val inputStream = contentResolver.openInputStream(sourceUri)
            val outputStream = contentResolver.openOutputStream(targetUri)

            if (inputStream == null || outputStream == null) {
                mainHandler.post {
                    result.success(
                        mapOf(
                            "success" to false,
                            "error" to "Could not open streams: input=$inputStream, output=$outputStream"
                        )
                    )
                }
                return
            }

            inputStream.use { input ->
                outputStream.use { output ->
                    bytesCopied = input.copyTo(output)
                }
            }

            // Finalize IS_PENDING = 0
            contentValues.clear()
            contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
            contentResolver.update(targetUri, contentValues, null, null)

            mainHandler.post {
                result.success(
                    mapOf(
                        "success" to true,
                        "insertedUri" to targetUri.toString(),
                        "bytesCopied" to bytesCopied
                    )
                )
            }
        } catch (e: Exception) {
            mainHandler.post {
                result.success(
                    mapOf(
                        "success" to false,
                        "error" to (e.message ?: e.toString())
                    )
                )
            }
        }
    }
}
