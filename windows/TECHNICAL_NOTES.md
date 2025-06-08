# Technical Notes: MEL.Labs Video Player Assessment

## 1. My Architectural Choices

When building this app, I tried to stick to standard Flutter best practices for organizing the code and managing the app's "state" (data that changes).

* **`MyApp` (My Global Brain!):** I set `MyApp` up as a `StatefulWidget`. This basically means it's the central hub for any data that needs to be shared across different parts of the app, like the user's name for the watermark, the screenshot count, or whether protection is on/off. It then passes this info down to the other screens.
* **`HomeScreen` (The Welcome Mat):** This is a simple `StatelessWidget`. It just shows the initial welcome, a quick glance at the security status, and buttons to jump into the video player or settings.
* **`VideoPlayerScreen` (The Main Show!):** This is where most of the action happens, so it's a `StatefulWidget`. It handles everything related to the video itself: controlling playback, displaying the video, managing the seek bar, and integrating the watermarking and screenshot detection logic. It gets its shared data (like the username) from `MyApp`.
* **`SettingsScreen` (The Control Panel):** Another `StatefulWidget` where users can tweak things. It pulls the current settings (like username) from `MyApp` and then uses "callbacks" (functions passed down from `MyApp`) to send updates back up when changes are made.
* **Navigation:** I used Flutter's built-in `Navigator.push` and `MaterialPageRoute` for smooth transitions between screens. It's the standard way to move around in a Flutter app.
* **UI Building Blocks:** Flutter's UI is all about composing small "widgets." I used a lot of standard ones like `Scaffold` (the basic page layout), `AppBar` (the top bar), `Stack` (for layering video, watermark, and controls), `Slider` (for seeking), and `Text` for displaying information.
* **Handling Waiting (Asynchronous Operations):** When the video player needs to initialize (like buffering the video), that takes a moment. I used a `FutureBuilder` to show a little loading spinner until the video is ready, so the user knows something's happening.

## 2. My Security Approach

Here's how I tackled the security features for the video player:

* **Dynamic Watermarking:**
    * I layered a `Text` widget right over the playing video using a `Stack`. This text combines the user's name (pulled from the settings) with a live, updating timestamp.
    * To make it semi-transparent, I wrapped the text in an `Opacity` widget with an `opacity` of 0.6 – visible but not too distracting.
    * I made sure it's dead center of the screen using `Positioned.fill` and `Align`. This makes it super hard for anyone trying to crop it out if they record the screen illegally.
    * The "dynamic" part comes from a `Timer.periodic`. Every 30 seconds, it triggers an update to the timestamp, so it's always current. I used the `intl` package to format the date and time nicely.
* **Screenshot Detection:**
    * For detecting screenshots on Android, I integrated the `screenshot_callback` Flutter package. This package is designed to listen for those system-level screenshot events.
    * When a screenshot is detected, my `_handleScreenshotAttempt()` method kicks in:
        * It bumps up a counter (`_screenshotAttemptCount`) that you can see in the app.
        * A quick warning pops up at the bottom of the screen (a `SnackBar`) saying "Screenshot detected!".
        * Crucially, if the video is playing, it automatically pauses (`_controller.pause()`) – a neat little security measure.
    * You can even turn this screenshot protection on or off in the Settings screen, and its current status is always displayed.

## 3. What I'd Love to Improve (Given More Time)

Developing this project under time constraints meant prioritizing, but here are some areas I'd definitely dig into if I had more time:

* **Bulletproof Screenshot/Screen Recording Prevention:** While detection is good, preventing it altogether is better. For Android, I'd explore using `WindowManager.LayoutParams.FLAG_SECURE` (often via the `flutter_windowmanager` package). This makes the app's content appear black in screenshots or recordings. I'd also research iOS-specific APIs for more robust prevention there.
* **Smarter Watermarking:** I'd love to make the watermark move around subtly (randomized positions) to make it even harder for digital removal tools. More customization options (font, size, color) would be cool too.
* **Saving My Settings!:** Right now, if you change your username or reset the screenshot count, it all vanishes when you close the app. I'd add persistent storage using something like `shared_preferences` or a local database (like `Hive` or `sqflite`) to remember your settings.
* **Flexible Video Choices:** Instead of just playing `my_video.mp4` from assets, I'd implement a file picker (`file_picker` package) so users could choose any video from their device. Plus, adding robust support for streaming from secure online URLs with proper error messages for network hiccups.
* **Better Error Handling:** While I have a loading spinner, I'd build out more detailed error messages if a video file is corrupted or if there are streaming issues.
* **Playback Restrictions:** The assessment mentioned these as secondary features. If I had time, I'd add logic to prevent fast-forwarding beyond 2x speed or limit rewinds to short increments.
* **Polish the UI/UX:** I'd add smoother animations for the video controls (making them fade in/out), and refine the full-screen experience with proper device orientation handling. Maybe even a little in-app tutorial.

