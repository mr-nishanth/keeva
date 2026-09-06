import java.io.File
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "io.nishvanta.keeva"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "io.nishvanta.keeva"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    val keystorePropertiesFile = rootProject.file("key.properties")
    val keystoreProperties = Properties()
    val hasReleaseKey = if (keystorePropertiesFile.exists()) {
        keystorePropertiesFile.inputStream().use { input ->
            keystoreProperties.load(input)
        }
        val keyAlias = keystoreProperties.getProperty("keyAlias")
        val keyPassword = keystoreProperties.getProperty("keyPassword")
        val storeFile = keystoreProperties.getProperty("storeFile")
        val storePassword = keystoreProperties.getProperty("storePassword")
        !keyAlias.isNullOrBlank() && !keyPassword.isNullOrBlank() && !storeFile.isNullOrBlank() && !storePassword.isNullOrBlank()
    } else {
        false
    }

    signingConfigs {
        create("release") {
            if (hasReleaseKey) {
                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                val storeFilePath = keystoreProperties.getProperty("storeFile")
                val storeFileObj = File(storeFilePath)
                storeFile = if (storeFileObj.isAbsolute) {
                    storeFileObj
                } else if (rootProject.file(storeFilePath).exists()) {
                    rootProject.file(storeFilePath)
                } else {
                    file(storeFilePath)
                }
                storePassword = keystoreProperties.getProperty("storePassword")
            } else {
                // Graceful fallback to debug signing when key.properties is not provisioned.
                // Ensures local release engineering, testing, and open-source builds succeed.
                val debugConfig = signingConfigs.getByName("debug")
                initWith(debugConfig)
                val debugFile = debugConfig.storeFile
                if (debugFile != null && !debugFile.exists()) {
                    debugFile.parentFile?.mkdirs()
                    ProcessBuilder(
                        "keytool", "-genkeypair",
                        "-keystore", debugFile.absolutePath,
                        "-storepass", "android",
                        "-alias", "androiddebugkey",
                        "-keypass", "android",
                        "-keyalg", "RSA",
                        "-keysize", "2048",
                        "-validity", "10000",
                        "-dname", "CN=Android Debug,O=Android,C=US"
                    ).redirectErrorStream(true).start().waitFor()
                }
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

dependencies {
    testImplementation("junit:junit:4.13.2")
}
