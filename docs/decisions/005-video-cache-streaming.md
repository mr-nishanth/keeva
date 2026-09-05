# ADR 005: On-Demand Video Cache Streaming for Playback

## Context
Status videos must be viewable in the app's media viewer.
When feeding a SAF `content://` URI directly into Flutter's `video_player` (which relies on Android ExoPlayer under the hood), video playback often exhibits serious issues:
- Seeking / scrubbing fails or restarts from the beginning because many DocumentProviders do not support arbitrary byte-range seek requests over ContentResolver pipes.
- Backgrounding or task switching can cause the ContentResolver pipe to drop, crashing playback.
- Buffering latency is higher than local file playback.

## Decision
Implement an on-demand video caching strategy in native Kotlin (`VideoCacheManager`):
1. When the user taps a video item in the grid to open the viewer, Flutter invokes `prepareVideo(id)`.
2. `VideoCacheManager` checks if `context.cacheDir/videos/<docIdHash>.mp4` already exists and matches file size.
3. If not cached, it streams bytes from SAF `InputStream` to the cache file on `Dispatchers.IO`. Status videos are short (30–60s max, typically 1–10 MB), copying in < 100 ms on modern UFS storage.
4. Returns the local filesystem path to Flutter.
5. Flutter `video_player` initializes using `VideoPlayerController.file(File(path))`.
6. Cache eviction: Bounded FIFO quota (50 MB limit).

## Status
Accepted.

## Consequences
- **Positive:** 100% reliable hardware-accelerated video decoding. Instantaneous seek-bar scrubbing. Audio-video synchronization. No SAF pipe disconnection errors.
- **Negative:** Small temporary disk usage in app cache (bounded to 50 MB max).
