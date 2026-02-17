/// Google OAuth 2.0 Client IDs for sign-in.
/// Set these in Firebase Console → Project settings → General → Your apps,
/// or in Google Cloud Console → APIs & Services → Credentials.
class FirebaseClientIds {
  FirebaseClientIds._();

  /// Web OAuth client ID used by backend token verification (GOOGLE_CLIENT_ID).
  static const String googleWebClientId =
      '195661435923-avfj1k990abgp3nftqka2kcs63ta6qgc.apps.googleusercontent.com';

  /// Optional iOS OAuth client ID.
  /// If empty, plugin will try to read from GoogleService-Info.plist.
  static const String googleIosClientId = '';
}
