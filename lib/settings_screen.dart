// lib/settings_screen.dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final String initialUsername; // Initial username passed from MyApp
  final bool initialScreenshotProtectionEnabled; // Initial protection status
  final int screenshotAttemptCount; // Current screenshot count

  final Function(String) onSaveUsername; // Callback to save username in MyApp
  final Function(bool) onToggleScreenshotProtection; // Callback to toggle protection
  final VoidCallback onClearScreenshotAttempts; // Callback to clear attempts

  const SettingsScreen({
    Key? key,
    required this.initialUsername,
    required this.initialScreenshotProtectionEnabled,
    required this.screenshotAttemptCount,
    required this.onSaveUsername,
    required this.onToggleScreenshotProtection,
    required this.onClearScreenshotAttempts,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _usernameController; // Controller for username input
  late bool _screenshotProtectionEnabled; // Local state for the switch

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.initialUsername); // Set initial text
    _screenshotProtectionEnabled = widget.initialScreenshotProtectionEnabled; // Set initial switch state
  }

  @override
  void dispose() {
    _usernameController.dispose(); // Dispose the text controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Watermark Text Configuration
            Text('Watermark Settings', style: Theme.of(context).textTheme.headlineSmall),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username for Watermark',
                hintText: 'Enter your name or ID',
                border: OutlineInputBorder(), // Add a border for better UI
              ),
              onChanged: (text) {
                widget.onSaveUsername(text); // Call the callback to update username in MyApp
              },
            ),
            const SizedBox(height: 30), // Spacing

            // Security Settings Section
            Text('Security Settings', style: Theme.of(context).textTheme.headlineSmall),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Screenshot Protection'),
                Switch(
                  value: _screenshotProtectionEnabled,
                  onChanged: (value) {
                    setState(() {
                      _screenshotProtectionEnabled = value; // Update local switch state
                    });
                    widget.onToggleScreenshotProtection(value); // Call callback to update global state in MyApp
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Screenshot Attempts Display and Clear Button
            Text('Screenshot Attempts (Current Session): ${widget.screenshotAttemptCount}'),
            ElevatedButton(
              onPressed: () {
                widget.onClearScreenshotAttempts(); // Call callback to clear attempts in MyApp
                // Optionally show a confirmation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Screenshot attempts cleared!')),
                );
              },
              child: const Text('Clear Attempts'),
            ),
            const SizedBox(height: 30),

            // You can add other settings here if needed
          ],
        ),
      ),
    );
  }
}