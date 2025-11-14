import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

/// Helper class for data encryption and security
class SecurityHelper {
  static const String _keyPrefix = 'encrypted_';
  static const String _saltKey = 'app_salt_key';
  
  /// Generate a secure key from device info
  static Future<String> _generateKey() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? salt = prefs.getString(_saltKey);
      
      if (salt == null) {
        // Generate new salt
        final random = Random.secure();
        salt = base64Encode(List<int>.generate(32, (i) => random.nextInt(256)));
        await prefs.setString(_saltKey, salt);
      }
      
      // Use salt to create key (in production, use proper key derivation)
      final bytes = utf8.encode(salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      if (kDebugMode) {
        print('Error generating key: $e');
      }
      // Fallback key (not secure, but better than nothing)
      return 'default_key_${DateTime.now().millisecondsSinceEpoch}';
    }
  }
  
  /// Simple encryption (XOR cipher) - For production, use proper encryption like AES
  static Future<String> encrypt(String plainText) async {
    try {
      if (plainText.isEmpty) return '';
      
      final key = await _generateKey();
      final keyBytes = utf8.encode(key);
      final textBytes = utf8.encode(plainText);
      
      final encrypted = <int>[];
      for (int i = 0; i < textBytes.length; i++) {
        encrypted.add(textBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64Encode(encrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Error encrypting: $e');
      }
      return plainText; // Return plain text on error
    }
  }
  
  /// Simple decryption
  static Future<String> decrypt(String encryptedText) async {
    try {
      if (encryptedText.isEmpty) return '';
      
      final key = await _generateKey();
      final keyBytes = utf8.encode(key);
      final encrypted = base64Decode(encryptedText);
      
      final decrypted = <int>[];
      for (int i = 0; i < encrypted.length; i++) {
        decrypted.add(encrypted[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Error decrypting: $e');
      }
      return encryptedText; // Return encrypted text on error
    }
  }
  
  /// Save encrypted token
  static Future<void> saveEncryptedToken(String key, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = await encrypt(token);
      await prefs.setString('$_keyPrefix$key', encrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving encrypted token: $e');
      }
    }
  }
  
  /// Get decrypted token
  static Future<String?> getEncryptedToken(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encrypted = prefs.getString('$_keyPrefix$key');
      if (encrypted == null) return null;
      
      return await decrypt(encrypted);
    } catch (e) {
      if (kDebugMode) {
        print('Error getting encrypted token: $e');
      }
      return null;
    }
  }
  
  /// Hash password (SHA-256)
  static String hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Verify password hash
  static bool verifyPassword(String password, String hash) {
    return hashPassword(password) == hash;
  }
  
  /// Clear all encrypted data
  static Future<void> clearEncryptedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final encryptedKeys = keys.where((key) => key.startsWith(_keyPrefix));
      
      for (final key in encryptedKeys) {
        await prefs.remove(key);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing encrypted data: $e');
      }
    }
  }
}

