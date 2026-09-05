/// Application-wide constants for Keeva.
///
/// Contains only genuine application-wide and platform configuration values.
/// UI colors, spacing, typography, and animation tokens are reserved for Phase 2E.
abstract final class AppConstants {
  /// Application display name.
  static const String appName = 'Keeva';

  /// Primary MethodChannel identifier for native status discovery and media saving.
  static const String scannerChannelName =
      'com.example.whatsapp_status_saver/scanner';

  /// Android package name for standard WhatsApp.
  static const String whatsappStandardPackage = 'com.whatsapp';

  /// Android package name for WhatsApp Business.
  static const String whatsappBusinessPackage = 'com.whatsapp.w4b';

  /// Default thumbnail dimension (width & height in pixels) for native downsampling.
  static const int defaultThumbnailDimension = 256;

  /// High-resolution preview dimensions for full-screen photo viewing.
  static const int highResPreviewWidth = 1440;
  static const int highResPreviewHeight = 2560;
}
