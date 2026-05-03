import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_profile.dart';
import 'user_session_storage.dart';

class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();
  static const String _defaultAvatarBase64 =
      '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';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool get isSignedIn => _auth.currentUser != null;

  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    try {
      await credential.user?.sendEmailVerification();
    } on FirebaseAuthException {
      // Account creation should still succeed even if the first email send fails.
    }
    await UserSessionStorage.setLoggedIn(false);
    await UserSessionStorage.setNeedsProfileSetup(true);
    return credential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final isVerified = await isCurrentUserEmailVerified();
    await UserSessionStorage.setLoggedIn(isVerified);
    return credential;
  }

  Future<User?> reloadCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      await user.reload();
    } on FirebaseAuthException {
      return _auth.currentUser;
    }

    return _auth.currentUser;
  }

  Future<bool> isCurrentUserEmailVerified({bool reload = true}) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final user = reload ? await reloadCurrentUser() : currentUser;
    final isVerified = user?.emailVerified ?? currentUser.emailVerified;

    if (isVerified) {
      try {
        await (user ?? currentUser).getIdToken(true);
      } on FirebaseAuthException {
        // Fall back to the current auth state if token refresh fails.
      }
    }

    return isVerified;
  }

  Future<void> sendCurrentUserEmailVerification() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed in user',
      );
    }

    await user.sendEmailVerification();
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await UserSessionStorage.logout();
  }

  Future<void> saveProfile(UserProfileData profile) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No signed in user',
      );
    }

    final ensuredProfile = _withDefaultAvatar(profile);

    final data = {
      ...ensuredProfile.toJson(),
      'uid': user.uid,
      'email': user.email,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));

    await UserSessionStorage.saveProfile(ensuredProfile);
    await UserSessionStorage.setLoggedIn(true);
    await UserSessionStorage.setNeedsProfileSetup(false);
  }

  Future<UserProfileData?> fetchProfile({bool cache = true}) async {
    return fetchProfileWithOptions(cache: cache);
  }

  Future<UserProfileData?> fetchProfileWithOptions({
    bool cache = true,
    bool ignoreErrors = true,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final snapshot = await _firestore.collection('users').doc(user.uid).get();
      if (!snapshot.exists) return null;

      final data = snapshot.data();
      if (data == null) return null;

      final profile = UserProfileData.fromJson(data);
      if (cache) {
        await UserSessionStorage.saveProfile(profile);
        await UserSessionStorage.setLoggedIn(true);
        await UserSessionStorage.setNeedsProfileSetup(!profile.isComplete);
      }
      return profile;
    } on FirebaseException {
      if (ignoreErrors) {
        return null;
      }
      rethrow;
    }
  }

  Future<bool> resolveNeedsProfileSetup() async {
    try {
      final profile = await fetchProfileWithOptions(
        cache: true,
        ignoreErrors: false,
      );
      final needsProfileSetup = profile == null || !profile.isComplete;
      await UserSessionStorage.setNeedsProfileSetup(needsProfileSetup);
      return needsProfileSetup;
    } on FirebaseException {
      final cachedProfile = await UserSessionStorage.loadProfile();
      final needsProfileSetup = !cachedProfile.isComplete;
      await UserSessionStorage.setNeedsProfileSetup(needsProfileSetup);
      return needsProfileSetup;
    }
  }

  UserProfileData _withDefaultAvatar(UserProfileData profile) {
    final hasPhoto =
        profile.photoBase64 != null && profile.photoBase64!.isNotEmpty;
    if (hasPhoto) return profile;

    return UserProfileData(
      name: profile.name,
      gender: profile.gender,
      heightCm: profile.heightCm,
      weightKg: profile.weightKg,
      photoBase64: _defaultAvatarBase64,
    );
  }
}
