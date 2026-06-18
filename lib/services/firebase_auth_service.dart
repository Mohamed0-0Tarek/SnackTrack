import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

/// Firebase-backed auth service.
///
/// Replaces the old `auth_service.dart`. The key addition versus the old
/// version is [authStateChanges] — this is what lets the app know "is
/// someone logged in" from Firebase itself, instead of inferring it from
/// whatever's sitting in [AuthController.user] after a manual sign-in call.
/// Splash screen and the GoRouter redirect both key off this stream now.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Fires whenever Firebase's local auth session changes — on cold start
  /// (if a session was persisted), on sign-in, and on sign-out.
  /// `null` means logged out, non-null means logged in.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Current Firebase user, if any. Synchronous — useful for one-off reads
  /// (e.g. "what's my uid right now") where you don't want to await a stream.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Fetches the Firestore profile document for a given Firebase [user].
  /// Used both at sign-in time and when restoring a session from the stream.
  Future<UserModel> fetchUserProfile(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = user.uid;
      // Token kept for backward-compat with UserModel.toJson/fromJson
      // shape, but nothing should rely on it for auth checks anymore.
      data['token'] = await user.getIdToken() ?? '';
      return UserModel.fromJson(data);
    }

    // Fallback: Firestore doc missing (e.g. doc creation failed after
    // signup). Build a minimal profile from the Firebase Auth record so
    // the app doesn't crash — onboarding will fill in the rest.
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'SnackTrack User',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
      token: await user.getIdToken() ?? '',
      activeStreak: 0,
      entries: 0,
      bio: '',
    );
  }

  Future<UserModel> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Sign-in failed unexpectedly.');
      return fetchUserProfile(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<UserModel> signUp(String name, String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Account creation failed unexpectedly.');

      await user.updateDisplayName(name);

      final initialData = {
        'id': user.uid,
        'name': name,
        'email': email,
        'avatarUrl': '',
        'activeStreak': 0,
        'entries': 0,
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('users').doc(user.uid).set(initialData);

      return fetchUserProfile(user);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    }
  }

  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  bool get isEmailVerified => _firebaseAuth.currentUser?.emailVerified ?? false;

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No registered account found matching that email address.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect password. Please verify your credentials and try again.';
      case 'email-already-in-use':
        return 'This email address is already registered to another account.';
      case 'invalid-email':
        return 'The format of the email address provided is invalid.';
      case 'weak-password':
        return 'The password security strength is insufficient. Use a stronger value.';
      case 'user-disabled':
        return 'This account access has been suspended.';
      case 'operation-not-allowed':
        return 'Email/Password authentication is currently disabled.';
      case 'network-request-failed':
        return 'Network error. Verify internet connectivity and try again.';
      default:
        return e.message ?? 'An unknown authentication error occurred.';
    }
  }
}
