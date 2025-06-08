# MEL.Labs Mobile Video Player Assessment

**My Submission for the App Development Internship Task (May 2025)**

Hello there! This repository holds my submission for the MEL.Labs App Development Internship assessment. My goal was to build a foundational secure video player for mobile, focusing on getting the core features solid rather than adding every possible bells and whistle. It's been a challenging but rewarding experience!

## 1. Getting Started: How to Run This Project

Here's how you can get my video player up and running on your own machine. I've tried to make it as straightforward as possible!

### What You'll Need (Prerequisites):

* **Flutter SDK:** You'll need Flutter installed. The easiest way I found was using the VS Code Flutter extension's "Download SDK" feature. Just open VS Code, hit `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac), type "Flutter: New Project", choose "Application", and if Flutter isn't found, it'll prompt you to "Download SDK". It handles a lot of the setup magic!
* **Android Studio:** Even though we're coding in Flutter, Android Studio is super helpful because it brings along all the necessary Android SDKs, build tools, and lets you run emulators. Grab it from [developer.android.com/studio](https://developer.android.com/studio).
* **Android SDK Command-line Tools:** After Android Studio is installed, pop open its SDK Manager (usually via `Tools` > `SDK Manager` or "More Actions" on the welcome screen). Just make sure "Android SDK Command-line Tools" is checked under the "SDK Tools" tab.
* **Accept Android Licenses:** Open up your terminal (Command Prompt, PowerShell, or whatever you use) and run `flutter doctor --android-licenses`. You'll need to hit `y` and Enter a few times to agree to everything.
* **VS Code:** This is my editor of choice for Flutter. Get it from [code.visualstudio.com](https://code.visualstudio.com/).
* **Flutter VS Code Extension:** In VS Code, head over to the Extensions tab (`Ctrl+Shift+X`) and install the official "Flutter" extension (it's by Dart Code).
* **Git:** Essential for managing code. If you don't have it, get it from [git-scm.com/downloads](https://git-scm.com/downloads).

### Steps to Run My App:

1.  **Grab the Code:**
    git clone [YOUR_GITHUB_REPO_URL_HERE]
    cd flutter_application_1

2.  **Get the Dependencies:**
    flutter pub get
    This command pulls down all the little packages and tools my app needs to run.

3.  **Set Up Your Local Video:**
    * Create a folder called `assets` right inside the main `flutter_application_1` project directory.
    * Drop your MP4 video file (I used `my_video.mp4` for testing, but name yours whatever makes sense!) into this new `assets` folder.
    * **Crucially:** You need to tell Flutter about this video in `pubspec.yaml`. Open that file and look for the `flutter:` section. Make sure `assets: - assets/my_video.mp4` is there and correctly indented.
4.  **A Bit of Android Magic (Manual Patches I Had to Do!):**
    Building Android apps, especially with certain Flutter plugins, can sometimes require a little manual tweaking. I ran into a few common build issues, and here are the fixes I applied:
    * **For `AndroidManifest.xml`:** I added `android:usesCleartextTraffic="true"` to the `<application>` tag in `android/app/src/main/AndroidManifest.xml`. This helps if you're ever streaming videos over insecure HTTP (though I'm using a local video now!).
    * **For `android/app/build.gradle`:** I had to explicitly set the `ndkVersion` to `"27.0.12077973"` inside the `android { ... }` block of `android/app/build.gradle` to keep things happy with certain plugins.
    * **For `screenshot_callback` Plugin (This Was a Tricky One!):** The `screenshot_callback` plugin needed a direct patch in its cached build file. If you run into build errors related to "Namespace not specified" or JVM compatibility, you'll need to manually edit this file:
        
5.  **Clean Up (Good Practice):**
    flutter clean

6.  **Run the App!**
    * Make sure your Android phone is plugged in (with USB debugging ON!) or your Android Emulator is up and running from Android Studio.
    * In VS Code, check the bottom-right status bar to make sure your device is selected.
    * Then, just hit `F5` or click the green play button in the "Run and Debug" panel. Or, simply run this in your terminal:

        flutter run

---

## 2. What My App Does (Features Implemented)

I focused on hitting all the "Must Implement" points from the assessment, plus a few extras!

* **Custom Video Player:**
    * Plays local MP4 video files right from the app's assets.
    * I built basic controls: a clear Play/Pause button and a smooth seek bar for scrubbing through the video.
    * It shows you exactly where you are in the video with a current time display, alongside the total video duration.
    * There's a simple full-screen toggle that makes the app bar disappear for a more immersive view.
* **Dynamic Watermarking System:**
    * My favorite part! There's a text overlay on the video that shows a user's name (which you can change in settings!) and the current timestamp.
    * That timestamp isn't static; it refreshes every 30 seconds.
    * I've positioned it right in the center of the video. This makes it a real pain to try and crop out if someone were to illegally record the screen!
    * It's also semi-transparent, so it doesn't get in the way of actually watching the content.
* **Screenshot Protection (My Best Attempt!):**
    * The app is set up to try and detect when someone attempts to take a screenshot during video playback.
    * If detected, it pops up a warning message (a little `SnackBar` at the bottom of the screen).
    * It also automatically pauses the video when a screenshot is detected, which is a nice security touch.
    * I'm even logging how many times a screenshot is attempted and displaying that count right in the app.
* **Basic Security Indicators:**
    * You'll see a quick "Screenshot Protection: ON/OFF" status directly on the video player screen and the home screen.
    * There's a dedicated Settings screen where you can tweak the watermark username.
    * And yep, that screenshot attempt count is there too, and you can even reset it from the settings!
* **Clean & Mobile-Friendly UI:**
    * I designed a simple flow: a welcoming Home Screen, then into the Video Player, and a separate Settings screen.
    * Buttons are big enough for clumsy fingers, and you get clear visual feedback when you tap on something.


## 3. How to Test the Screenshot Detection (The Tricky Bit!)

Alright, so screenshot detection can be a bit finicky depending on the Android version and device. I've implemented the logic, but its real-world behavior can vary.

1.  **Get the app running:** Make sure my app is actively playing a video on your **physical Android device** (this works best!) or your emulator.
2.  **Take a screenshot:**
    * **On most Android phones:** Press your **Volume Down** button and **Power button** simultaneously.
    * **On Android Emulators:** There's usually a camera icon in the emulator's toolbar, or try `Ctrl+Shift+S` (Windows/Linux) or `Cmd+Shift+S` (Mac).
3.  **Look closely:** You should ideally see a small black pop-up (`SnackBar`) at the bottom of the screen that says "Screenshot detected! Attempt: [Count]".
4.  **Check the video:** The video should then pause.
5.  **Verify the count:** Go back to the Home Screen or pop into the Settings to see if the screenshot attempt count has gone up.

---

## 4. Known Limitations

Every project has its challenges, and here's what I'd flag for future work or things that might not be 100% perfect:

* **Screenshot Detection Reliability:** While I've implemented the detection, its ability to catch every single screenshot on every single Android device/OS version (especially newer ones like Android 11+) can be inconsistent. Android's security landscape is always evolving, which makes blanket detection tough. It's built to catch user-initiated screenshots, but might not prevent or detect sophisticated screen recording methods.
* **"True" Full-Screen Mode:** My full-screen toggle is a simple one (it hides the app bar). A really polished solution would involve managing device orientation and using native `SystemChrome` calls for a truly immersive, system-wide full-screen experience.
* **Playback Restrictions:** I focused on the "Must Implement" features, so advanced playback restrictions (like preventing fast-forward beyond 2x speed or limiting rewind) weren't added.
* **Basic Error Handling:** I have a loading indicator for the video, but more robust error handling for network issues (if streaming) or corrupted video files could be added.
* **No Persistent Settings:** Any changes you make in the Settings screen (like your username or the screenshot attempt count) will reset every time you close and reopen the app. I haven't implemented saving these settings yet.
