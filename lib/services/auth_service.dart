import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Authenticates an existing user via Firebase Auth and retrieves their profile from Firestore.
  Future<UserModel?> login(String email, String password) async {
    try {
      // 1. Sign in via Firebase Authentication
      final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('User tracking initialization failed.');

      // 2. Fetch the corresponding profile metadata from Cloud Firestore
      final DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (doc.exists && doc.data() != null) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        
        // Extract the raw verification token if required by downstream network interceptors
        final String? token = await firebaseUser.getIdToken();
        data['token'] = token;
        data['id'] = firebaseUser.uid;

        return UserModel.fromJson(data);
      } else {
        // Fallback case: If Firestore record is missing, construct a structural fallback profile
        final String? token = await firebaseUser.getIdToken();
        return UserModel(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'SnackTrack User',
          email: firebaseUser.email ?? email,
          avatarUrl: firebaseUser.photoURL ?? '',
          token: token ?? '',
          activeStreak: 0,
          entries: 0,
          bio: '',
        );
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during sign-in: ${e.toString()}');
    }
  }

  /// Registers a new user account, provisions a default profile configuration in Firestore.
  Future<UserModel?> signup(String name, String email, String password) async {
    try {
      // 1. Create account credential in Firebase Auth
      final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? firebaseUser = credential.user;
      if (firebaseUser == null) throw Exception('User account setup aborted.');

      // 2. Set the display name directly on the Auth instance
      await firebaseUser.updateDisplayName(name);

      // Get authorization token verification string
      final String? token = await firebaseUser.getIdToken();

      // 3. Initialize user data record maps matching requirements schema
      final Map<String, dynamic> initialUserData = {
        'id': firebaseUser.uid,
        'name': name,
        'email': email,
        'avatarUrl': '',
        'activeStreak': 0,
        'entries': 0,
        'bio': 'Initial dynamic metabolic tracking active.',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Commit document mapping into users collection path
      await _firestore.collection('users').doc(firebaseUser.uid).set(initialUserData);

      // Append temporary operational authorization validation token 
      initialUserData['token'] = token ?? '';

      return UserModel.fromJson(initialUserData);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('An unexpected error occurred during profile initialization: ${e.toString()}');
    }
  }

  /// Fully invalidates local authentication persistence states safely.
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to terminate session safely: ${e.toString()}');
    }
  }

  /// Maps cryptic Firebase technical error codes to user-friendly status responses.
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No registered account found matching that email address.';
      case 'wrong-password':
        return 'Incorrect password. Please verify your credentials and try again.';
      case 'email-already-in-use':
        return 'This email address is already registered to another account.';
      case 'invalid-email':
        return 'The format of the email address provided is invalid.';
      case 'weak-password':
        return 'The password security strength is insufficient. Use a stronger value.';
      case 'user-disabled':
        return 'This account access privileges have been administratively suspended.';
      case 'operation-not-allowed':
        return 'Email/Password authentication method configuration is disabled.';
      case 'network-request-failed':
        return 'Network latency failure. Verify internet connectivity and try again.';
      default:
        return e.message ?? 'An unknown server authentication failure transpired.';
    }
  }
}