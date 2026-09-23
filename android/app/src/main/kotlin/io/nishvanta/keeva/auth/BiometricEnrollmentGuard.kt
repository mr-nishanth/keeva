package io.nishvanta.keeva.auth

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyPermanentlyInvalidatedException
import android.security.keystore.KeyProperties
import android.security.keystore.UserNotAuthenticatedException
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.security.GeneralSecurityException
import java.security.InvalidKeyException
import java.security.KeyStore
import java.security.UnrecoverableKeyException
import javax.crypto.Cipher
import javax.crypto.KeyGenerator
import javax.crypto.SecretKey

/**
 * Binds biometric unlock to the current Android biometric enrollment.
 *
 * This class does not capture or match fingerprint or face samples. It creates
 * an Android Keystore key with [KeyGenParameterSpec.setInvalidatedByBiometricEnrollment].
 * A later [Cipher.init] throws [KeyPermanentlyInvalidatedException] when
 * enrollment changes, which tells Keeva to require the password again.
 *
 * The key requires a class-3 biometric. Devices that only have class-2 face
 * unlock can still use BiometricPrompt through `local_auth`, but [bind] returns
 * null because the Keystore cannot bind that enrollment.
 */
class BiometricEnrollmentGuard private constructor(
    private val channel: MethodChannel,
) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "bind" -> result.success(bind())
            "check" -> {
                val token = call.argument<String>("token")
                result.success(check(token))
            }
            "clear" -> {
                clear()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun bind(): String? {
        clear()
        return try {
            generateKey()
            BOUND
        } catch (_: GeneralSecurityException) {
            // No class-3 biometric is enrolled, or the keystore rejected the key.
            // The biometric prompt can still run; enrollment changes cannot be bound.
            null
        } catch (_: RuntimeException) {
            null
        }
    }

    private fun check(token: String?): String {
        val keyStore = keyStore() ?: return STATUS_UNAVAILABLE
        val hasKey = try {
            keyStore.containsAlias(KEY_ALIAS)
        } catch (_: Exception) {
            return STATUS_UNAVAILABLE
        }
        if (!hasKey) {
            return if (token.isNullOrEmpty()) STATUS_UNSUPPORTED else STATUS_CHANGED
        }
        return try {
            val key = keyStore.getKey(KEY_ALIAS, null) as? SecretKey
                ?: return STATUS_CHANGED
            val cipher = Cipher.getInstance(TRANSFORMATION)
            cipher.init(Cipher.ENCRYPT_MODE, key)
            STATUS_UNCHANGED
        } catch (error: Exception) {
            statusForKeyException(error)
        }
    }

    private fun clear() {
        val keyStore = keyStore() ?: return
        try {
            if (keyStore.containsAlias(KEY_ALIAS)) {
                keyStore.deleteEntry(KEY_ALIAS)
            }
        } catch (_: Exception) {
            // Best-effort. Sign-out still deletes the secure-store flag.
        }
    }

    private fun generateKey() {
        val keyGenerator = KeyGenerator.getInstance(KeyProperties.KEY_ALGORITHM_AES, ANDROID_KEYSTORE)
        val builder = KeyGenParameterSpec.Builder(
            KEY_ALIAS,
            KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT,
        )
            .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
            .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
            .setKeySize(256)
            .setUserAuthenticationRequired(true)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            builder.setInvalidatedByBiometricEnrollment(true)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            builder.setUserAuthenticationParameters(0, KeyProperties.AUTH_BIOMETRIC_STRONG)
        } else {
            @Suppress("DEPRECATION")
            builder.setUserAuthenticationValidityDurationSeconds(-1)
        }
        keyGenerator.init(builder.build())
        keyGenerator.generateKey()
    }

    private fun keyStore(): KeyStore? {
        return try {
            KeyStore.getInstance(ANDROID_KEYSTORE).apply { load(null) }
        } catch (_: Exception) {
            null
        }
    }

    companion object {
        const val CHANNEL_NAME = "io.nishvanta.keeva/biometric_guard"
        private const val ANDROID_KEYSTORE = "AndroidKeyStore"
        private const val KEY_ALIAS = "keeva.auth.biometric.enrollment"
        private const val TRANSFORMATION = "AES/GCM/NoPadding"
        private const val BOUND = "bound"
        private const val STATUS_UNCHANGED = "unchanged"
        private const val STATUS_CHANGED = "changed"
        private const val STATUS_UNAVAILABLE = "unavailable"
        private const val STATUS_UNSUPPORTED = "unsupported"

        fun register(messenger: BinaryMessenger) {
            val channel = MethodChannel(messenger, CHANNEL_NAME)
            channel.setMethodCallHandler(BiometricEnrollmentGuard(channel))
        }

        /**
         * Maps a keystore failure to an enrollment status.
         *
         * [UserNotAuthenticatedException] means the key is still valid and
         * simply needs a biometric prompt. [KeyPermanentlyInvalidatedException]
         * means enrollment changed.
         */
        internal fun statusForKeyException(error: Exception): String {
            return when (error) {
                is UserNotAuthenticatedException -> STATUS_UNCHANGED
                is KeyPermanentlyInvalidatedException -> STATUS_CHANGED
                is UnrecoverableKeyException -> STATUS_CHANGED
                is InvalidKeyException -> STATUS_CHANGED
                else -> STATUS_UNAVAILABLE
            }
        }
    }
}
