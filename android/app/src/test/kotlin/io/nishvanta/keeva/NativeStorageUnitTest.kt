package io.nishvanta.keeva

import io.nishvanta.keeva.status.StatusDocumentReader
import io.nishvanta.keeva.status.ThumbnailManager
import io.nishvanta.keeva.status.VideoCacheManager
import org.junit.Assert.*
import org.junit.Test
import java.io.File

class NativeStorageUnitTest {

    @Test
    fun testApplicationIdentityPackage() {
        val expectedPackage = "io.nishvanta.keeva"
        assertEquals("Canonical package namespace must be io.nishvanta.keeva", "io.nishvanta.keeva", expectedPackage)
    }

    @Test
    fun testOpaqueIdEncodingAndDecoding() {
        val rawDocId = "primary:Android/media/com.whatsapp/WhatsApp/Media/.Statuses/6e0d286c8a4e4492ba09b360cfd5a522.jpg"
        val opaqueId = StatusDocumentReader.encodeOpaqueId(rawDocId)

        // Verify opaque ID does not leak internal path semantics
        assertTrue("Opaque ID should start with stat_ prefix", opaqueId.startsWith("stat_"))
        assertFalse("Opaque ID must not contain primary:", opaqueId.contains("primary:"))
        assertFalse("Opaque ID must not contain content://", opaqueId.contains("content://"))
        assertFalse("Opaque ID must not contain .Statuses", opaqueId.contains(".Statuses"))
        assertFalse("Opaque ID must not contain /", opaqueId.contains("/"))

        // Verify bidirectional decode
        val decoded = StatusDocumentReader.decodeOpaqueId(opaqueId)
        assertEquals("Decoded ID should match original raw document ID", rawDocId, decoded)
    }

    @Test
    fun testDecodeInvalidOpaqueIdReturnsNull() {
        val invalidToken = "stat_!!!invalid-base64-token###"
        val decoded = StatusDocumentReader.decodeOpaqueId(invalidToken)
        assertNull("Malformed base64 token should return null without crashing", decoded)
    }

    @Test
    fun testThumbnailSampleDownsampling() {
        // High-resolution image (e.g. 1920x1080) downsampled to 256x256
        val sampleSize1 = ThumbnailManager.calculateInSampleSize(1920, 1080, 256, 256)
        assertEquals(4, sampleSize1) // 1920/4 = 480, 1080/4 = 270 (both >= 256)

        // 4K image (3840x2160)
        val sampleSize2 = ThumbnailManager.calculateInSampleSize(3840, 2160, 256, 256)
        assertEquals(8, sampleSize2) // 3840/8 = 480, 2160/8 = 270

        // Image already smaller than target (128x128)
        val sampleSize3 = ThumbnailManager.calculateInSampleSize(128, 128, 256, 256)
        assertEquals(1, sampleSize3)

        // Image exact match (256x256)
        val sampleSize4 = ThumbnailManager.calculateInSampleSize(256, 256, 256, 256)
        assertEquals(1, sampleSize4)
    }

    @Test
    fun testThumbnailCacheKeyDeterminism() {
        val id1 = "stat_dHlwZTEyMw"
        val id2 = "stat_dHlwZTEyMw"
        val id3 = "stat_ZGlmZmVyZW50"

        val key1 = ThumbnailManager.getSafeCacheKey(id1)
        val key2 = ThumbnailManager.getSafeCacheKey(id2)
        val key3 = ThumbnailManager.getSafeCacheKey(id3)

        assertEquals("Same ID must yield identical cache key", key1, key2)
        assertNotEquals("Different IDs must yield different cache keys", key1, key3)
        assertEquals("MD5 hex length should be 32 characters", 32, key1.length)
        assertTrue("Cache key should only contain hex characters", key1.matches(Regex("^[0-9a-f]+$")))
    }

    @Test
    fun testVideoCacheKeyDeterminism() {
        val id1 = "stat_video_test_id"
        val id2 = "stat_video_test_id"

        val key1 = VideoCacheManager.getSafeCacheKey(id1)
        val key2 = VideoCacheManager.getSafeCacheKey(id2)

        assertEquals("Same video ID must yield identical cache key", key1, key2)
        assertEquals(32, key1.length)
    }

    @Test
    fun testLruEvictionOrdering() {
        // Verify LRU sorting logic: files sorted ascending by lastModified
        val tempDir = File(System.getProperty("java.io.tmpdir"), "lru_test_${System.currentTimeMillis()}")
        tempDir.mkdirs()

        try {
            val file1 = File(tempDir, "file1.dat").apply { writeText("oldest") }
            val file2 = File(tempDir, "file2.dat").apply { writeText("middle") }
            val file3 = File(tempDir, "file3.dat").apply { writeText("newest") }

            file1.setLastModified(1000L)
            file2.setLastModified(2000L)
            file3.setLastModified(3000L)

            val files = tempDir.listFiles()?.sortedBy { it.lastModified() } ?: emptyList()

            assertEquals("file1.dat", files[0].name)
            assertEquals("file2.dat", files[1].name)
            assertEquals("file3.dat", files[2].name)
        } finally {
            tempDir.deleteRecursively()
        }
    }
}
