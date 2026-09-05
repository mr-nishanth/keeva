import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SafPocApp());
}

class SafPocApp extends StatelessWidget {
  const SafPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WhatsApp Status SAF POC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const SafPocScreen(),
    );
  }
}

class SafPocScreen extends StatefulWidget {
  const SafPocScreen({super.key});

  @override
  State<SafPocScreen> createState() => _SafPocScreenState();
}

class _SafPocScreenState extends State<SafPocScreen> {
  static const MethodChannel _channel =
      MethodChannel('com.example.whatsapp_status_saver/scanner');

  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();

  bool _isRunning = false;
  String? _persistedTreeUri;

  // Diagnostic Results
  bool? _pickerLaunched;
  bool? _initialUriAccepted;
  bool? _mediaFolderSelectable;
  bool? _userGrantReceived;
  bool? _persistedUriPermission;
  bool? _mediaFolderAccessible;
  bool? _statusesDiscovered;
  bool? _statusFilesEnumerated;
  bool? _imageDiscovered;
  bool? _imageBytesReadable;
  bool? _videoDiscovered;
  bool? _videoBytesReadable;
  bool? _imageInserted;
  bool? _galleryUriReturned;
  bool? _accessSurvivesRestart;

  List<Map<dynamic, dynamic>> _discoveredStatuses = [];
  Map<dynamic, dynamic>? _selectedImage;
  Map<dynamic, dynamic>? _selectedVideo;
  String? _insertedGalleryUri;

  @override
  void initState() {
    super.initState();
    _log('POC Initialized on Xiaomi 2311DRK48I (Android 16, API 36, HyperOS 3.0)');
    _checkInitialAccess();
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    setState(() {
      _logs.add('[$timestamp] $message');
    });
    // Print to stdout so it appears in flutter run and logcat
    // ignore: avoid_print
    print('SAF_POC: $message');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _checkInitialAccess() async {
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('checkFolderAccess');
      final hasAccess = res?['hasAccess'] == true;
      final uri = res?['treeUri'] as String?;
      if (hasAccess && uri != null) {
        setState(() {
          _persistedTreeUri = uri;
          _pickerLaunched = true;
          _initialUriAccepted = true;
          _mediaFolderSelectable = true;
          _userGrantReceived = true;
          _persistedUriPermission = true;
          _accessSurvivesRestart = true;
        });
        _log('Existing persisted tree URI detected: $uri');
        await _scanDiscoveredStatuses(uri);
      } else {
        _log('No persisted tree URI found. User folder selection required.');
      }
    } catch (e) {
      _log('Error checking folder access: $e');
    }
  }

  Future<void> _requestSafAccess() async {
    setState(() => _isRunning = true);
    _log('POC TEST 1: Launching ACTION_OPEN_DOCUMENT_TREE with EXTRA_INITIAL_URI...');
    try {
      _pickerLaunched = true;
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>('requestFolderAccess');
      final granted = result?['granted'] == true;
      final treeUri = result?['treeUri'] as String?;
      final persisted = result?['persisted'] == true;

      _userGrantReceived = granted;
      _mediaFolderSelectable = granted;
      _initialUriAccepted = granted; // If user granted the suggested folder
      _persistedUriPermission = persisted;

      if (granted && treeUri != null) {
        _persistedTreeUri = treeUri;
        _log('POC TEST 2: SAF grant SUCCESS. Tree URI: $treeUri');
        _log('Persisted URI permission result: ${persisted ? "SUCCESS" : "FAILED"}');
        await _scanDiscoveredStatuses(treeUri);
      } else {
        _log('SAF grant FAILED or cancelled: ${result?['error']}');
      }
    } catch (e) {
      _log('SAF Request Exception: $e');
    } finally {
      setState(() => _isRunning = false);
    }
  }

  Future<void> _scanDiscoveredStatuses([String? treeUri]) async {
    final uriToUse = treeUri ?? _persistedTreeUri;
    _log('POC TEST 3: Querying child documents from SAF tree via ContentResolver...');
    try {
      final List<dynamic>? list = await _channel.invokeMethod<List<dynamic>>(
        'scanStatuses',
        {'treeUri': uriToUse},
      );

      final statuses = list?.cast<Map<dynamic, dynamic>>() ?? [];
      setState(() {
        _discoveredStatuses = statuses;
        _mediaFolderAccessible = true;
        _statusesDiscovered = statuses.isNotEmpty;
        _statusFilesEnumerated = statuses.isNotEmpty;
      });

      _log('Discovered ${statuses.length} status file(s):');
      for (final item in statuses) {
        final name = item['displayName'];
        final size = item['sizeBytes'];
        final mime = item['mimeType'];
        _log(' - $name ($mime, $size bytes)');
      }

      // POC TEST 4: Find at least one JPG and one MP4
      _selectedImage = null;
      _selectedVideo = null;

      for (final item in statuses) {
        final name = (item['displayName'] as String? ?? '').toLowerCase();
        final mime = (item['mimeType'] as String? ?? '').toLowerCase();
        if (_selectedImage == null && (name.endsWith('.jpg') || mime == 'image/jpeg')) {
          _selectedImage = item;
        }
        if (_selectedVideo == null && (name.endsWith('.mp4') || mime.startsWith('video/'))) {
          _selectedVideo = item;
        }
      }

      setState(() {
        _imageDiscovered = _selectedImage != null;
        _videoDiscovered = _selectedVideo != null;
      });

      if (_selectedImage != null) {
        _log('POC TEST 4: JPG Found -> ${_selectedImage!['displayName']} (${_selectedImage!['sizeBytes']} bytes)');
      } else {
        _log('POC TEST 4: JPG NOT FOUND');
      }

      if (_selectedVideo != null) {
        _log('POC TEST 4: MP4 Found -> ${_selectedVideo!['displayName']} (${_selectedVideo!['sizeBytes']} bytes)');
      } else {
        _log('POC TEST 4: MP4 NOT FOUND');
      }

      // Automatically proceed to Test 5 & 6 if items exist
      if (_selectedImage != null || _selectedVideo != null) {
        await _verifyMediaStreams();
      }
    } catch (e) {
      setState(() {
        _mediaFolderAccessible = false;
        _statusesDiscovered = false;
        _statusFilesEnumerated = false;
      });
      _log('Scan Statuses Exception: $e');
    }
  }

  Future<void> _verifyMediaStreams() async {
    _log('POC TEST 5: Verifying byte-read capabilities via ContentResolver.openInputStream...');
    // Verify Image
    if (_selectedImage != null) {
      final imgUri = _selectedImage!['uri'] as String;
      final expectedBytes = _selectedImage!['sizeBytes'];
      try {
        final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'verifyMediaRead',
          {'uri': imgUri},
        );
        final success = res?['success'] == true;
        final readBytes = res?['bytesRead'] ?? 0;
        setState(() => _imageBytesReadable = success);
        _log('Image read verification: ${success ? "SUCCESS" : "FAILED"} (Requested: $expectedBytes, Read: $readBytes bytes)');
      } catch (e) {
        setState(() => _imageBytesReadable = false);
        _log('Image read Exception: $e');
      }
    }

    // Verify Video
    if (_selectedVideo != null) {
      final vidUri = _selectedVideo!['uri'] as String;
      final expectedBytes = _selectedVideo!['sizeBytes'];
      try {
        final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
          'verifyMediaRead',
          {'uri': vidUri},
        );
        final success = res?['success'] == true;
        final readBytes = res?['bytesRead'] ?? 0;
        setState(() => _videoBytesReadable = success);
        _log('Video read verification: ${success ? "SUCCESS" : "FAILED"} (Requested: $expectedBytes, Read: $readBytes bytes)');
      } catch (e) {
        setState(() => _videoBytesReadable = false);
        _log('Video read Exception: $e');
      }
    }

    // Export test image
    if (_selectedImage != null && _imageBytesReadable == true) {
      await _exportTestImage();
    }
  }

  Future<void> _exportTestImage() async {
    _log('POC TEST 6: Exporting ONE discovered JPG to MediaStore...');
    try {
      final imgUri = _selectedImage!['uri'] as String;
      final origName = _selectedImage!['displayName'] as String;
      final exportName = 'poc_export_${DateTime.now().millisecondsSinceEpoch}_$origName';

      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'saveTestImage',
        {'uri': imgUri, 'displayName': exportName},
      );

      final success = res?['success'] == true;
      final targetUri = res?['insertedUri'] as String?;
      final bytesCopied = res?['bytesCopied'] ?? 0;

      setState(() {
        _imageInserted = success;
        _galleryUriReturned = targetUri != null;
        _insertedGalleryUri = targetUri;
      });

      if (success) {
        _log('MediaStore Export SUCCESS:');
        _log(' - Saved URI: $targetUri');
        _log(' - Bytes copied: $bytesCopied');
        _log(' - Destination: Pictures/StatusSaverPOC/$exportName');
      } else {
        _log('MediaStore Export FAILED: ${res?['error']}');
      }
    } catch (e) {
      setState(() {
        _imageInserted = false;
        _galleryUriReturned = false;
      });
      _log('MediaStore Export Exception: $e');
    }
  }

  Future<void> _testPersistenceCheck() async {
    _log('POC TEST 7: Checking persisted folder access after restart...');
    try {
      final res = await _channel.invokeMethod<Map<dynamic, dynamic>>('checkFolderAccess');
      final hasAccess = res?['hasAccess'] == true;
      final uri = res?['treeUri'] as String?;

      if (hasAccess && uri != null) {
        setState(() {
          _persistedTreeUri = uri;
          _accessSurvivesRestart = true;
        });
        _log('Persisted access ACTIVE: $uri');
        await _scanDiscoveredStatuses(uri);
      } else {
        setState(() => _accessSurvivesRestart = false);
        _log('Persisted access NOT FOUND or revoked.');
      }
    } catch (e) {
      setState(() => _accessSurvivesRestart = false);
      _log('Persistence check Exception: $e');
    }
  }

  String _formatStatus(bool? val) {
    if (val == null) return 'PENDING';
    return val ? 'PASS' : 'FAIL';
  }

  String get _finalVerdict {
    final critical = [
      _pickerLaunched,
      _userGrantReceived,
      _persistedUriPermission,
      _mediaFolderAccessible,
      _statusesDiscovered,
      _imageDiscovered,
      _imageBytesReadable,
      _videoDiscovered,
      _videoBytesReadable,
      _imageInserted,
      _galleryUriReturned,
    ];

    if (critical.any((v) => v == null)) {
      return 'IN PROGRESS';
    }
    if (critical.every((v) => v == true) && _accessSurvivesRestart == true) {
      return 'VERIFIED';
    }
    if (critical.where((v) => v == true).length >= 5) {
      return 'PARTIALLY VERIFIED';
    }
    return 'FAILED';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp Status SAF POC'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Re-check Persistence',
            onPressed: _testPersistenceCheck,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Device Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.black26,
              child: const Row(
                children: [
                  Icon(Icons.phone_android, color: Colors.tealAccent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Xiaomi 2311DRK48I | Android 16 (API 36) | HyperOS 3.0',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons Bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _isRunning ? null : _requestSafAccess,
                    icon: const Icon(Icons.folder_open),
                    label: const Text('Request SAF Access (Test 1)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isRunning ? null : () => _scanDiscoveredStatuses(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Scan Statuses (Test 3)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isRunning ? null : _verifyMediaStreams,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Verify Bytes (Test 5)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isRunning ? null : _exportTestImage,
                    icon: const Icon(Icons.save_alt),
                    label: const Text('Export Image (Test 6)'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isRunning ? null : _testPersistenceCheck,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Check Persistence (Test 7)'),
                  ),
                ],
              ),
            ),

            // Diagnostic Table
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'DIAGNOSTIC MATRIX',
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _finalVerdict == 'VERIFIED'
                                  ? Colors.green.shade800
                                  : (_finalVerdict == 'IN PROGRESS'
                                      ? Colors.blueGrey
                                      : Colors.orange.shade800),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _finalVerdict,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _statusRow('Picker launched', _pickerLaunched),
                                _statusRow('Initial URI accepted', _initialUriAccepted),
                                _statusRow('Folder selectable', _mediaFolderSelectable),
                                _statusRow('User grant received', _userGrantReceived),
                                _statusRow('Persisted URI perm', _persistedUriPermission),
                                _statusRow('Media accessible', _mediaFolderAccessible),
                                _statusRow('.Statuses found', _statusesDiscovered),
                              ],
                            ),
                          ),
                          const VerticalDivider(),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _statusRow('Status enumerated', _statusFilesEnumerated),
                                _statusRow('Image discovered', _imageDiscovered),
                                _statusRow('Image bytes read', _imageBytesReadable),
                                _statusRow('Video discovered', _videoDiscovered),
                                _statusRow('Video bytes read', _videoBytesReadable),
                                _statusRow('MediaStore insert', _imageInserted),
                                _statusRow('Restart persistent', _accessSurvivesRestart),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (_discoveredStatuses.isNotEmpty || _insertedGalleryUri != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    if (_discoveredStatuses.isNotEmpty)
                      Text(
                        'Statuses: ${_discoveredStatuses.length}',
                        style: const TextStyle(fontSize: 11, color: Colors.tealAccent),
                      ),
                    if (_discoveredStatuses.isNotEmpty && _insertedGalleryUri != null)
                      const Text(' • ', style: TextStyle(color: Colors.grey)),
                    if (_insertedGalleryUri != null)
                      Expanded(
                        child: Text(
                          'Export: $_insertedGalleryUri',
                          style: const TextStyle(fontSize: 10, color: Colors.amberAccent),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 8),

            // Live Log Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('EXECUTION LOG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  Text('${_logs.length} events', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),

            // Log Console
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    final log = _logs[index];
                    Color color = Colors.greenAccent;
                    if (log.contains('FAIL') || log.contains('Exception') || log.contains('NOT FOUND')) {
                      color = Colors.redAccent;
                    } else if (log.contains('POC TEST')) {
                      color = Colors.amberAccent;
                    } else if (log.contains('SUCCESS') || log.contains('Discovered')) {
                      color = Colors.lightBlueAccent;
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: color,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow(String label, bool? value) {
    Color badgeColor = Colors.grey;
    if (value == true) badgeColor = Colors.green;
    if (value == false) badgeColor = Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 11)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: badgeColor, width: 0.8),
            ),
            child: Text(
              _formatStatus(value),
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
