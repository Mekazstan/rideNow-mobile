import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:permission_handler/permission_handler.dart';

/// Smile ID WebView Widget with callback handling
class SmileIDWebView extends StatefulWidget {
  final String url;
  final String jobId;
  final String userId;
  final Function(Map<String, dynamic>) onSuccess;
  final Function(String) onError;
  final VoidCallback? onCancel;

  const SmileIDWebView({
    super.key,
    required this.url,
    required this.jobId,
    required this.userId,
    required this.onSuccess,
    required this.onError,
    this.onCancel,
  });

  @override
  State<SmileIDWebView> createState() => _SmileIDWebViewState();
}

class _SmileIDWebViewState extends State<SmileIDWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  double _loadingProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInit();
  }

  Future<void> _requestPermissionsAndInit() async {
    // Request hardware permissions before opening WebView
    try {
      await [Permission.camera, Permission.microphone].request();
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
    _initializeWebView();
  }

  void _initializeWebView() {
    final controller = WebViewController();
    _controller = controller;

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setUserAgent(
        "Mozilla/5.0 (Linux; Android 12; Pixel 6 Build/SD1A.210817.036; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/114.0.5735.196 Mobile Safari/537.36",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) setState(() => _isLoading = true);
            _checkForCompletionOrError(url);
          },
          onPageFinished: (String url) {
            if (mounted) setState(() => _isLoading = false);
            _checkForCompletionOrError(url);
            _injectJavaScriptListener();
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
            if (error.errorType != WebResourceErrorType.unsupportedScheme) {
              widget.onError('Web error: ${error.description}');
            }
          },
        ),
      )
      ..addJavaScriptChannel(
        'SmileIDFlutter',
        onMessageReceived: (JavaScriptMessage message) {
          _handleJavaScriptMessage(message.message);
        },
      );

    // Configure Android-specific WebView settings
    if (controller.platform is AndroidWebViewController) {
      final androidController = controller.platform as AndroidWebViewController;

      // Enable WebView debugging for better error visibility
      AndroidWebViewController.enableDebugging(true);

      // Allow media playback without user gesture
      androidController.setMediaPlaybackRequiresUserGesture(false);

      // Handle geolocation permissions
      androidController.setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (request) async {
          debugPrint('🌍 Geolocation permission requested: ${request.origin}');
          return const GeolocationPermissionsResponse(
            allow: true,
            retain: true,
          );
        },
      );

      // Handle hardware permission requests (camera, microphone)
      // Using dynamic to bypass type-checking issues while maintaining functionality
      try {
        (androidController as dynamic).setPermissionRequestCallback((
          request,
        ) async {
          debugPrint('🔍 Android Permission Request: ${request.types}');
          debugPrint('   Resources: ${request.resources}');

          // Grant all requested permissions
          await request.grant();
          debugPrint('✅ Permissions granted');
        });
      } catch (e) {
        debugPrint('⚠️ Could not set Android permission callback: $e');
      }
    }

    _loadSmileLinkDirect();
  }

  Future<void> _loadSmileLinkDirect() async {
    debugPrint('🚀 Loading Smile Link Directly: ${widget.url}');

    // Using headers to explicitly allow sensors and camera
    // This is the most reliable way to handle Permissions-Policy in modern Chromium
    await _controller.loadRequest(
      Uri.parse(widget.url),
      headers: {
        'Permissions-Policy':
            'camera=*, microphone=*, accelerometer=*, gyroscope=*, magnetometer=*, fullscreen=*',
        'Feature-Policy':
            'camera *; microphone *; accelerometer *; gyroscope *; magnetometer *; fullscreen *',
      },
    );
  }

  void _injectJavaScriptListener() {
    // Inject comprehensive camera and permission monitoring
    _controller.runJavaScript('''
      (function() {
        console.log('📱 Smile ID Flutter Bridge Initialized');
        
        // Monitor permissions API
        if (navigator.permissions && navigator.permissions.query) {
          navigator.permissions.query({name: 'camera'}).then(function(result) {
            console.log('📸 Camera permission state:', result.state);
            result.onchange = function() {
              console.log('📸 Camera permission changed to:', this.state);
            };
          }).catch(function(err) {
            console.log('⚠️ Could not query camera permission:', err);
          });
        }
        
        // Override getUserMedia to log all attempts
        if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
          const originalGetUserMedia = navigator.mediaDevices.getUserMedia.bind(navigator.mediaDevices);
          navigator.mediaDevices.getUserMedia = function(constraints) {
            console.log('📸 getUserMedia called with:', JSON.stringify(constraints));
            return originalGetUserMedia(constraints)
              .then(function(stream) {
                console.log('✅ Camera stream obtained successfully');
                console.log('   Active:', stream.active);
                console.log('   Tracks:', stream.getTracks().length);
                return stream;
              })
              .catch(function(error) {
                console.error('❌ getUserMedia error:', error.name, '-', error.message);
                console.error('   Error details:', JSON.stringify(error));
                
                // Send error to Flutter for debugging
                if (window.SmileIDFlutter) {
                  window.SmileIDFlutter.postMessage(JSON.stringify({
                    type: 'camera_error',
                    error: error.name,
                    message: error.message
                  }));
                }
                throw error;
              });
          };
        }
        
        // Log feature policy support
        if (document.featurePolicy) {
          console.log('✅ Feature Policy supported');
          console.log('   Camera allowed:', document.featurePolicy.allowsFeature('camera'));
          console.log('   Microphone allowed:', document.featurePolicy.allowsFeature('microphone'));
        } else {
          console.log('⚠️ Feature Policy not supported');
        }
        
        console.log('✅ All monitoring scripts injected');
      })();
    ''');
  }

  void _checkForCompletionOrError(String url) {
    // Check if URL indicates success
    if (url.contains('success') || url.contains('complete')) {
      _handleSuccess(url);
    }
    // Check if URL indicates error
    else if (url.contains('error') || url.contains('failed')) {
      _handleError(url);
    }
    // Check if user cancelled
    else if (url.contains('cancel')) {
      _handleCancel();
    }
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = json.decode(message);

      // Handle camera errors
      if (data['type'] == 'camera_error') {
        final errorName = data['error'] ?? 'Unknown';
        final errorMessage = data['message'] ?? 'Camera access failed';

        debugPrint('📸 Camera Error from JS: $errorName - $errorMessage');

        // Show user-friendly error
        String userMessage;
        if (errorName == 'NotAllowedError' ||
            errorName == 'PermissionDeniedError') {
          userMessage =
              'Camera permission was denied. Please allow camera access in your browser settings.';
        } else if (errorName == 'NotFoundError') {
          userMessage = 'No camera was found on this device.';
        } else if (errorName == 'NotReadableError') {
          userMessage =
              'Camera is being used by another app. Please close other camera apps.';
        } else {
          userMessage = 'Camera error: $errorMessage';
        }

        widget.onError(userMessage);
        return;
      }

      // Handle verification status
      if (data['status'] == 'success' || data['success'] == true) {
        widget.onSuccess(data);
        Navigator.of(context).pop(true);
      } else if (data['status'] == 'error' || data['error'] != null) {
        widget.onError(data['message'] ?? 'Verification failed');
        Navigator.of(context).pop(false);
      } else if (data['status'] == 'cancel') {
        _handleCancel();
      }
    } catch (e) {
      debugPrint('Error parsing JavaScript message: $e');
    }
  }

  void _handleSuccess(String url) {
    // Extract parameters from URL if needed
    final uri = Uri.parse(url);
    final params = uri.queryParameters;

    widget.onSuccess({
      'success': true,
      'job_id': widget.jobId,
      'user_id': widget.userId,
      'url_params': params,
    });

    // Don't auto-close, wait for explicit success message
  }

  void _handleError(String url) {
    final uri = Uri.parse(url);
    final errorMessage =
        uri.queryParameters['message'] ?? 'Verification failed';

    widget.onError(errorMessage);

    // Show error dialog
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Verification Failed'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(false); // Close webview
                },
                child: const Text('Close'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _controller.reload(); // Retry
                },
                child: const Text('Retry'),
              ),
            ],
          ),
    );
  }

  void _handleCancel() {
    widget.onCancel?.call();
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Show confirmation dialog before closing
        final shouldPop = await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Cancel Verification?'),
                content: const Text(
                  'Are you sure you want to cancel the verification process?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Continue'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
        );

        if (shouldPop == true) {
          _handleCancel();
        }

        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Identity Verification'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldClose = await showDialog<bool>(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Cancel Verification?'),
                      content: const Text(
                        'Are you sure you want to cancel the verification process?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
              );

              if (shouldClose == true && mounted) {
                _handleCancel();
              }
            },
          ),
          bottom:
              _isLoading
                  ? PreferredSize(
                    preferredSize: const Size.fromHeight(4.0),
                    child: LinearProgressIndicator(
                      value: _loadingProgress,
                      backgroundColor: Colors.grey[200],
                    ),
                  )
                  : null,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading verification...'),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
