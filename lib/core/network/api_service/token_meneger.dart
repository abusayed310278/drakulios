import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static const _storage = FlutterSecureStorage();

  // ---------------- KEYS ----------------
  static const _accessTokenKey = "access_token";
  static const _refreshKey = "refresh_key";
  static const _roleKey = "role";
  static const _emailKey = "email";
  static const _uidKey = "uid";
  static const _userNameKey = "userName";
  static const _tierCongratsPrefix = "tier_congrats_";
  static const _professionalApprovedShownKey = "professional_approved_shown";
  static const _chatSecureSeenPrefix = "chat_secure_seen_";
  static const _rememberMeKey = "remember_me";
  static const _rememberEmailKey = "remember_email";
  static const _rememberPasswordKey = "remember_password";

  // NEW
  static const _serviceTypeKey = "service_type";

  // ---------------- SAVE ALL (matches your screenshot call) ----------------
  static Future<void> save({
    required String access,
    required String refresh,
    String? uid,
    String? userName,
    String? userEmail,
    String? userRole,
    String? serviceType,
  }) async {
    debugPrint("✅ Saving access token: $access");
    debugPrint("✅ Saving refresh token: $refresh");

    if (access.trim().isNotEmpty) {
      await _storage.write(key: _accessTokenKey, value: access);
    }
    if (refresh.trim().isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refresh);
    }

    if (uid != null) {
      await _storage.write(key: _uidKey, value: uid);
    }
    if (userName != null) {
      await _storage.write(key: _userNameKey, value: userName);
    }
    if (userEmail != null) {
      await _storage.write(key: _emailKey, value: userEmail);
    }
    if (userRole != null) {
      await _storage.write(key: _roleKey, value: userRole);
    }
    if (serviceType != null) {
      await _storage.write(key: _serviceTypeKey, value: serviceType);
    }
  }

  // ---------------- TOKENS ----------------
  static Future<void> saveToken({
    required String accessToken,
    required String refreshToken,
  }) async {
    if (accessToken.trim().isNotEmpty) {
      await _storage.write(key: _accessTokenKey, value: accessToken);
    }
    if (refreshToken.trim().isNotEmpty) {
      await _storage.write(key: _refreshKey, value: refreshToken);
    }
  }

  static Future<void> accessToken(String token) async {
    debugPrint("Saving token is $token");
    if (token.trim().isNotEmpty) {
      await _storage.write(key: _accessTokenKey, value: token);
    }
  }

  static Future<void> refreshToken(String token) async {
    if (token.trim().isNotEmpty) {
      await _storage.write(key: _refreshKey, value: token);
    }
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshKey);
  }

  static Future<void> clearToken() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshKey);
  }

  // ---------------- USER DATA ----------------
  static Future<void> saveRole(String role) async {
    await _storage.write(key: _roleKey, value: role);
  }

  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  static Future<void> clearRole() async {
    await _storage.delete(key: _roleKey);
  }

  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<void> clearEmail() async {
    await _storage.delete(key: _emailKey);
  }

  static Future<void> saveUid(String uid) async {
    await _storage.write(key: _uidKey, value: uid);
  }

  static Future<String?> getUid() async {
    return await _storage.read(key: _uidKey);
  }

  static Future<String?> getUidFromToken() async {
    final token = await getToken();
    if (token == null || token.trim().isEmpty) return null;
    final parts = token.split('.');
    if (parts.length < 2) return null;
    try {
      final normalized = base64Url.normalize(parts[1]);
      final payload =
          jsonDecode(utf8.decode(base64Url.decode(normalized))) as Map;
      final uid =
          payload['_id'] ??
          payload['id'] ??
          payload['userId'] ??
          payload['sub'];
      if (uid == null) return null;
      return uid.toString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUid() async {
    await _storage.delete(key: _uidKey);
  }

  static Future<void> saveUserName(String userName) async {
    await _storage.write(key: _userNameKey, value: userName);
  }

  static Future<String?> getUserName() async {
    return await _storage.read(key: _userNameKey);
  }

  static Future<void> clearUserName() async {
    await _storage.delete(key: _userNameKey);
  }

  // ---------------- SERVICE TYPE ----------------
  static Future<void> saveServiceType(String serviceType) async {
    await _storage.write(key: _serviceTypeKey, value: serviceType);
  }

  static Future<String?> getServiceType() async {
    return await _storage.read(key: _serviceTypeKey);
  }

  static Future<void> clearServiceType() async {
    await _storage.delete(key: _serviceTypeKey);
  }

  // ---------------- LOGIN CHECK ----------------
  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    if (token == null) return false;
    if (token.trim().isEmpty) return false;
    return true;
  }

  // ---------------- CLEAR ALL ----------------
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ---------------- PROFESSIONAL APPROVAL (one-time) ----------------
  static Future<void> setProfessionalApprovedShown() async {
    await _storage.write(key: _professionalApprovedShownKey, value: "1");
  }

  static Future<bool> isProfessionalApprovedShown() async {
    final v = await _storage.read(key: _professionalApprovedShownKey);
    return v == "1";
  }

  // ---------------- TIER CONGRATS (one-time) ----------------
  static Future<void> setTierCongratsShown(String tierLabel) async {
    await _storage.write(key: "$_tierCongratsPrefix$tierLabel", value: "1");
  }

  static Future<bool> isTierCongratsShown(String tierLabel) async {
    final v = await _storage.read(key: "$_tierCongratsPrefix$tierLabel");
    return v == "1";
  }

  // ---------------- CHAT SECURE CARD (one-time per peer) ----------------
  static String _chatSecureKey(String peerId) =>
      "$_chatSecureSeenPrefix${peerId.trim()}";

  static Future<void> setChatSecureSeen(String peerId) async {
    final id = peerId.trim();
    if (id.isEmpty) return;
    await _storage.write(key: _chatSecureKey(id), value: "1");
  }

  static Future<bool> isChatSecureSeen(String peerId) async {
    final id = peerId.trim();
    if (id.isEmpty) return false;
    final v = await _storage.read(key: _chatSecureKey(id));
    return v == "1";
  }

  // ---------------- REMEMBER ME ----------------
  static Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value ? "1" : "0");
  }

  static Future<bool> isRememberMeEnabled() async {
    final v = await _storage.read(key: _rememberMeKey);
    return v == "1";
  }

  static Future<void> saveRememberedCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _rememberEmailKey, value: email.trim());
    await _storage.write(key: _rememberPasswordKey, value: password);
  }

  static Future<String?> getRememberedEmail() async {
    return _storage.read(key: _rememberEmailKey);
  }

  static Future<String?> getRememberedPassword() async {
    return _storage.read(key: _rememberPasswordKey);
  }

  static Future<void> clearRememberedCredentials() async {
    await _storage.delete(key: _rememberEmailKey);
    await _storage.delete(key: _rememberPasswordKey);
  }
}

// import 'package:flutter/cupertino.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// class TokenManager {
//   static const _storage = FlutterSecureStorage();
//   static const _accessTokenKey = "access_token";
//   static const _refreshKey = "refresh_key";
//   static const _role = "role";

//   static Future<void> saveToken(
//       {required String accessToken, required String refreshToken}) async {
//     await _storage.write(key: _accessTokenKey, value: accessToken);
//     await _storage.write(key: _refreshKey, value: refreshToken);
//   }

//   static Future<void> accessToken(String token) async {
//     debugPrint("Saving token is $token");
//     await _storage.write(key: _accessTokenKey, value: token);
//   }

//   static Future<String?> getEmail() async {
//     return _storage.read(key: "email"); // ✅ must be saved at login time
//   }

//   static Future<void> saveRole(String token) async {
//     await _storage.write(key: _role, value: token);
//   }

//   static Future<void> refreshToken(String token) async {
//     await _storage.write(key: _refreshKey, value: token);
//   }

//   static Future<String?> getToken() async {
//     return await _storage.read(key: _accessTokenKey);
//   }

//   static Future<String?> getRefreshToken() async {
//     return await _storage.read(key: _refreshKey);
//   }

//   static Future<void> clearToken() async {
//     await _storage.delete(key: _accessTokenKey);
//     await _storage.delete(key: _refreshKey);
//   }

// /*
//   static Future<bool> isLoggedIn() async {
//     final token = await _storage.read(key: _accessTokenKey);
//     return token != null && token.isNotEmpty;
//   }*/

//   static Future<bool> isLoggedIn() async {
//     final token = await _storage.read(key: _accessTokenKey);
//     if (token == null) return false;
//     if (token.trim().isEmpty) return false;
//     return true;
//   }

//   //  NEW
//   static const _serviceTypeKey = "service_type";

//   //  ---------------- SERVICE TYPE ----------------
//   static Future<void> saveServiceType(String serviceType) async {
//     await _storage.write(key: _serviceTypeKey, value: serviceType);
//   }

//   static Future<String?> getServiceType() async {
//     return await _storage.read(key: _serviceTypeKey);
//   }

//   static Future<void> clearServiceType() async {
//     await _storage.delete(key: _serviceTypeKey);
//   }

//   static Future<String?> getRole() async {
//     return await _storage.read(key: _role);
//   }

//   static Future<void> clearRole() async {
//     await _storage.delete(key: _role);
//   }
// }
