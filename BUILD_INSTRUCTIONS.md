# DaudOS - APK Build Instructions

This guide will help you build the DaudOS APK on your local machine.

---

## 🛠️ **Prerequisites**

### **Required Software**
1. **Flutter SDK** (3.0 or later)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH environment variable

2. **Android Studio** (Latest version)
   - Download from: https://developer.android.com/studio
   - Install Android SDK and build tools
   - Accept all SDK licenses

3. **Java Development Kit (JDK 17)**
   - Download OpenJDK 17 from: https://adoptium.net/
   - Set JAVA_HOME environment variable

4. **Git** (for version control)
   - Download from: https://git-scm.com/

### **System Requirements**
- **Windows**: Windows 10 (64-bit) or later
- **macOS**: macOS 10.14 or later
- **Linux**: Ubuntu 18.04 or later
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 10GB free space for Android SDK and tools

---

## 🚀 **Step-by-Step Build Process**

### **Step 1: Environment Setup**

1. **Install Flutter**:
   ```bash
   # Verify Flutter installation
   flutter doctor
   
   # Accept Android licenses
   flutter doctor --android-licenses
   ```

2. **Configure Android Studio**:
   - Open Android Studio
   - Go to SDK Manager
   - Install Android SDK Platform 29 or later
   - Install Android SDK Build-Tools 30.0.3 or later

### **Step 2: Project Setup**

1. **Extract Project Files**:
   - Extract the DaudOS project to your desired location
   - Open terminal/command prompt in the project directory

2. **Install Dependencies**:
   ```bash
   cd daudos
   flutter pub get
   ```

3. **Verify Project**:
   ```bash
   flutter analyze
   ```

### **Step 3: Firebase Configuration**

1. **Create Firebase Project**:
   - Go to https://console.firebase.google.com/
   - Create a new project named "DaudOS"
   - Enable Firestore Database
   - Enable Authentication (Email/Password)

2. **Configure Android App**:
   - Add Android app to Firebase project
   - Package name: `com.daudos.app`
   - Download `google-services.json`
   - Place it in `android/app/` directory

3. **Update Firebase Options**:
   - Replace the placeholder values in `lib/firebase_options.dart`
   - Use your actual Firebase project configuration

### **Step 4: Build Configuration**

1. **Check Android Configuration**:
   ```bash
   flutter doctor
   ```
   Ensure all checkmarks are green for Android toolchain.

2. **Clean Previous Builds**:
   ```bash
   flutter clean
   flutter pub get
   ```

### **Step 5: Build APK**

#### **Option A: Debug APK (for testing)**
```bash
flutter build apk --debug
```

#### **Option B: Release APK (for production)**
```bash
flutter build apk --release
```

#### **Option C: Split APKs (smaller file sizes)**
```bash
flutter build apk --split-per-abi
```

### **Step 6: Locate Built APK**

Built APKs will be located in:
```
build/app/outputs/flutter-apk/
├── app-release.apk (universal APK)
├── app-arm64-v8a-release.apk (64-bit ARM)
├── app-armeabi-v7a-release.apk (32-bit ARM)
└── app-x86_64-release.apk (64-bit x86)
```

---

## 🔧 **Troubleshooting**

### **Common Issues and Solutions**

#### **1. Flutter Doctor Issues**
```bash
# If Android toolchain is not detected
flutter config --android-sdk /path/to/android/sdk

# If licenses are not accepted
flutter doctor --android-licenses
```

#### **2. Gradle Build Failures**
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

#### **3. Firebase Configuration Errors**
- Ensure `google-services.json` is in `android/app/` directory
- Verify package name matches in Firebase console
- Check that Firebase services are enabled

#### **4. Dependency Conflicts**
```bash
# Update dependencies
flutter pub upgrade

# Reset pub cache if needed
flutter pub cache repair
```

#### **5. NDK License Issues**
```bash
# Accept all SDK licenses
sdkmanager --licenses

# Or in Android Studio:
# SDK Manager → SDK Tools → Accept all licenses
```

### **Build Optimization Tips**

#### **Reduce APK Size**
1. **Enable R8 Code Shrinking**:
   Add to `android/app/build.gradle`:
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
           proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
       }
   }
   ```

2. **Split APKs by Architecture**:
   ```bash
   flutter build apk --split-per-abi
   ```

3. **Remove Unused Resources**:
   ```bash
   flutter build apk --tree-shake-icons
   ```

#### **Performance Optimization**
1. **Profile Mode Build** (for testing performance):
   ```bash
   flutter build apk --profile
   ```

2. **Analyze Bundle Size**:
   ```bash
   flutter build apk --analyze-size
   ```

---

## 📱 **Testing the APK**

### **Install on Android Device**

1. **Enable Developer Options**:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Install APK**:
   ```bash
   # Via ADB
   adb install build/app/outputs/flutter-apk/app-release.apk
   
   # Or transfer APK to device and install manually
   ```

3. **Test Core Features**:
   - Dashboard mood tracking
   - Mind Gym breathing exercise
   - Task creation and completion
   - Goals and habits tracking
   - Settings configuration

### **Emulator Testing**

1. **Create Android Emulator**:
   - Open Android Studio
   - AVD Manager → Create Virtual Device
   - Choose Pixel 4 or similar
   - API Level 29 or higher

2. **Run on Emulator**:
   ```bash
   flutter run
   ```

---

## 🔐 **App Signing (for Production)**

### **Generate Signing Key**
```bash
keytool -genkey -v -keystore ~/daudos-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias daudos
```

### **Configure Signing**
1. Create `android/key.properties`:
   ```properties
   storePassword=your_store_password
   keyPassword=your_key_password
   keyAlias=daudos
   storeFile=/path/to/daudos-key.jks
   ```

2. Update `android/app/build.gradle`:
   ```gradle
   android {
       signingConfigs {
           release {
               keyAlias keystoreProperties['keyAlias']
               keyPassword keystoreProperties['keyPassword']
               storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
               storePassword keystoreProperties['storePassword']
           }
       }
       buildTypes {
           release {
               signingConfig signingConfigs.release
           }
       }
   }
   ```

### **Build Signed APK**
```bash
flutter build apk --release
```

---

## 📊 **Build Verification**

### **APK Analysis**
```bash
# Check APK size and contents
flutter build apk --analyze-size

# Verify APK structure
aapt dump badging build/app/outputs/flutter-apk/app-release.apk
```

### **Performance Testing**
```bash
# Build profile version for performance testing
flutter build apk --profile

# Run performance tests
flutter drive --target=test_driver/app.dart
```

---

## 🆘 **Getting Help**

### **Official Resources**
- **Flutter Documentation**: https://flutter.dev/docs
- **Android Developer Guide**: https://developer.android.com/guide
- **Firebase Documentation**: https://firebase.google.com/docs

### **Community Support**
- **Flutter Community**: https://flutter.dev/community
- **Stack Overflow**: Tag questions with `flutter` and `android`
- **GitHub Issues**: Report bugs in the Flutter repository

### **Build Logs**
If you encounter issues, check:
- Flutter build logs in terminal
- Android Studio build output
- Gradle build logs in `android/` directory

---

**Happy Building! 🚀**

*The DaudOS app is ready to empower Daud's entrepreneurial journey!*

