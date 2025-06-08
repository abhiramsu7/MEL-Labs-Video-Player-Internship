// lib/main.dart
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async'; // Required for Timer
import 'package:intl/intl.dart'; // Required for date formatting
import 'package:screenshot_callback/screenshot_callback.dart'; // Required for screenshot detection
import 'package:flutter_application_1/settings_screen.dart'; // Import settings screen (ENSURE THIS PATH MATCHES YOUR PROJECT NAME)

void main() {
  runApp(const MyApp());
}

// MyApp is now a StatefulWidget to manage global state like username and security settings
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _username = "Intern User"; // Default username for watermarking
  int _screenshotAttemptCount = 0; // Counter for screenshot attempts across sessions
  bool _isScreenshotProtectionEnabled = true; // Global toggle for screenshot protection

  // This function will be passed to VideoPlayerScreen to update attempts from there
  void _updateScreenshotAttempts(int count) {
    setState(() {
      _screenshotAttemptCount = count;
    });
  }

  // This function will be passed to SettingsScreen to save username
  void _saveUsername(String newName) {
    setState(() {
      _username = newName;
    });
  }

  // This function will be passed to SettingsScreen to toggle protection
  void _toggleScreenshotProtection(bool enabled) {
    setState(() {
      _isScreenshotProtectionEnabled = enabled;
    });
  }

  // This function will be passed to SettingsScreen to clear attempts
  void _clearScreenshotAttempts() {
    setState(() {
      _screenshotAttemptCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEL Labs Video Player',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Initial Route is the Home Screen
      home: HomeScreen(
        username: _username,
        screenshotAttemptCount: _screenshotAttemptCount,
        isScreenshotProtectionEnabled: _isScreenshotProtectionEnabled,
        updateScreenshotAttempts: _updateScreenshotAttempts,
        onSaveUsername: _saveUsername,
        onToggleScreenshotProtection: _toggleScreenshotProtection,
        onClearScreenshotAttempts: _clearScreenshotAttempts,
      ),
    );
  }
}

// Home Screen Widget
class HomeScreen extends StatelessWidget {
  final String username;
  final int screenshotAttemptCount;
  final bool isScreenshotProtectionEnabled;
  final Function(int) updateScreenshotAttempts;
  final Function(String) onSaveUsername;
  final Function(bool) onToggleScreenshotProtection;
  final VoidCallback onClearScreenshotAttempts;


  const HomeScreen({
    Key? key,
    required this.username,
    required this.screenshotAttemptCount,
    required this.isScreenshotProtectionEnabled,
    required this.updateScreenshotAttempts,
    required this.onSaveUsername,
    required this.onToggleScreenshotProtection,
    required this.onClearScreenshotAttempts,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MEL Labs Home'),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(
                    initialUsername: username,
                    initialScreenshotProtectionEnabled: isScreenshotProtectionEnabled,
                    screenshotAttemptCount: screenshotAttemptCount,
                    onSaveUsername: onSaveUsername,
                    onToggleScreenshotProtection: onToggleScreenshotProtection,
                    onClearScreenshotAttempts: onClearScreenshotAttempts,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to MEL Labs Video Player!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      username: username,
                      updateScreenshotAttempts: updateScreenshotAttempts,
                      isScreenshotProtectionEnabled: isScreenshotProtectionEnabled,
                      // --- ADDED THIS LINE HERE ---
                      screenshotAttemptCount: screenshotAttemptCount,
                      // ----------------------------
                    ),
                  ),
                );
              },
              child: const Text('Start Video Playback'),
            ),
            const SizedBox(height: 20),
            // Display security status on home screen
            Text('Screenshot Protection: ${isScreenshotProtectionEnabled ? "ON" : "OFF"}'),
            Text('Screenshot Attempts (Current Session): $screenshotAttemptCount'),
          ],
        ),
      ),
    );
  }
}

// VideoPlayerScreen now accepts parameters from HomeScreen
class VideoPlayerScreen extends StatefulWidget {
  final String username; // Username for watermark
  final Function(int) updateScreenshotAttempts; // Callback to update global count
  final bool isScreenshotProtectionEnabled; // Protection status from MyApp
  final int screenshotAttemptCount; // <--- ADDED THIS LINE HERE

  const VideoPlayerScreen({
    Key? key,
    required this.username,
    required this.updateScreenshotAttempts,
    required this.isScreenshotProtectionEnabled,
    required this.screenshotAttemptCount, // <--- ADDED THIS LINE HERE
  }) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  double _currentSliderValue = 0.0;
  bool _isFullScreen = false;

  // Watermarking variables
  String _currentTimestamp = "";
  Timer? _watermarkTimer;

  // Screenshot protection variables
  late ScreenshotCallback _screenshotCallback;
  int _localScreenshotAttemptCount = 0; // Local counter for this video session

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(
      'assets/my_video.mp4', // Your local video file
    );

    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      _controller.addListener(() {
        if (_controller.value.isPlaying || _controller.value.isBuffering || _controller.value.isInitialized) {
          setState(() {
            _currentSliderValue = _controller.value.position.inMilliseconds.toDouble();
          });
        }
      });
      _startWatermarkTimer();
      _updateWatermark();
    });

    _currentSliderValue = 0.0;
    // Initialize local count from global count passed from MyApp
    _localScreenshotAttemptCount = widget.screenshotAttemptCount; // This line is now correct

    _screenshotCallback = ScreenshotCallback();
    _screenshotCallback.addListener(() {
      if (widget.isScreenshotProtectionEnabled) { // Use the enabled status from MyApp
        _handleScreenshotAttempt();
      }
    });
  }

  void _startWatermarkTimer() {
    _watermarkTimer?.cancel();
    _watermarkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _updateWatermark();
    });
  }

  void _updateWatermark() {
    setState(() {
      _currentTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    });
  }

  void _handleScreenshotAttempt() {
    setState(() {
      _localScreenshotAttemptCount++; // Increment local count
    });
    widget.updateScreenshotAttempts(_localScreenshotAttemptCount); // Update the global count in MyApp

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Screenshot detected! Attempt: $_localScreenshotAttemptCount'),
        duration: const Duration(seconds: 3),
      ),
    );

    if (_controller.value.isPlaying) {
      _controller.pause();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _watermarkTimer?.cancel();
    _screenshotCallback.dispose();
    super.dispose();
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isFullScreen ? null : AppBar(
        title: const Text('Secure Video Player'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                'Protection: ${widget.isScreenshotProtectionEnabled ? "ON" : "OFF"}', // Display status
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: <Widget>[
          // Video Player
          GestureDetector(
            onTap: () {
              // Handle tap
            },
            child: Center(
              child: FutureBuilder(
                future: _initializeVideoPlayerFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    );
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
              ),
            ),
          ),

          // Watermark Overlay
          if (_currentTimestamp.isNotEmpty)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: Opacity(
                  opacity: 0.6,
                  child: Text(
                    '${widget.username} - $_currentTimestamp', // Username from MyApp + Current Timestamp
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      backgroundColor: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Video Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Slider(
                    value: _currentSliderValue,
                    min: 0.0,
                    max: _controller.value.duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      setState(() { _currentSliderValue = value; });
                    },
                    onChangeEnd: (value) {
                      _controller.seekTo(Duration(milliseconds: value.toInt()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_printDuration(_controller.value.position), style: const TextStyle(color: Colors.white)),
                      IconButton(
                        icon: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying ? _controller.pause() : _controller.play();
                          });
                        },
                      ),
                      Text(_printDuration(_controller.value.duration), style: const TextStyle(color: Colors.white)),
                       IconButton(
                        icon: Icon(
                          _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                        ),
                        onPressed: () {
                            setState(() {
                                _isFullScreen = !_isFullScreen;
                            });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}