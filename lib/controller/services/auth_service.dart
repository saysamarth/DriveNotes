import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const _scopes = [
    'https://www.googleapis.com/auth/drive.file',
    'https://www.googleapis.com/auth/drive.appdata',
  ];

  static const _storageKey = 'drive_notes_credentials';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  Future<auth.AccessCredentials?> getSavedCredentials() async {
    final stored = await _secureStorage.read(key: _storageKey);
    if (stored == null) return null;
    try {
      final json = jsonDecode(stored) as Map<String, dynamic>;
      final expiry = DateTime.parse(json['expiry'] as String).toUtc();
      if (expiry.isBefore(DateTime.now().toUtc())) {
        await _secureStorage.delete(key: _storageKey);
        return null;
      }

      return auth.AccessCredentials(
        auth.AccessToken(
          json['type'] as String,
          json['data'] as String,
          expiry,
        ),
        json['refreshToken'] as String?,
        _scopes,
      );
    } catch (e) {
      await _secureStorage.delete(key: _storageKey);
      return null;
    }
  }

  Future<void> _saveCredentials(auth.AccessCredentials credentials) async {
    final json = jsonEncode({
      'type': credentials.accessToken.type,
      'data': credentials.accessToken.data,
      'expiry': credentials.accessToken.expiry.toUtc().toIso8601String(),
      'refreshToken': credentials.refreshToken,
    });
    await _secureStorage.write(key: _storageKey, value: json);
  }

  Future<auth.AccessCredentials> signIn() async {
  try {
    debugPrint('Starting Google Sign-In...');
    await _googleSignIn.signOut();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw Exception('Authentication was canceled');
    }
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    if (googleAuth.accessToken == null) {
      throw Exception('Failed to obtain access token');
    }
    final expiry = DateTime.now().toUtc().add(const Duration(hours: 1));
    final credentials = auth.AccessCredentials(
      auth.AccessToken(
        'Bearer',
        googleAuth.accessToken!,
        expiry,
      ),
      googleAuth.idToken,
      _scopes,
    );
    await _saveCredentials(credentials);
    debugPrint('Authentication successful');
    return credentials;
  } catch (e) {
    debugPrint('Auth error: ${e.toString()}');
    throw Exception('Authentication failed: ${e.toString()}');
  }
}
  Future<void> signOut() async {
    await _secureStorage.delete(key: _storageKey);
    await _googleSignIn.signOut();
  }
}