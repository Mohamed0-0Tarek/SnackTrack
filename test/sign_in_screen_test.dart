import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:snacktrack/controllers/auth_controller.dart';
import 'package:snacktrack/models/user_model.dart';
import 'package:snacktrack/services/firebase_auth_service.dart';
import 'package:snacktrack/views/auth/sign_in_screen.dart';

class FakeFirebaseAuthService extends FirebaseAuthService {
  @override
  Stream<User?> get authStateChanges => Stream.value(null);

  @override
  Future<UserModel> fetchUserProfile(User user) async {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? 'Test User',
      email: user.email ?? '',
      avatarUrl: user.photoURL ?? '',
      token: '',
      activeStreak: 0,
      entries: 0,
      bio: '',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: '1:123:ios:test',
        messagingSenderId: '123',
        projectId: 'test-project',
      ),
    );
  });

  testWidgets('sign-in screen renders text fields without layout assertion', (
    WidgetTester tester,
  ) async {
    final authController = AuthController(FakeFirebaseAuthService());

    await tester.pumpWidget(
      ChangeNotifierProvider<AuthController>.value(
        value: authController,
        child: const MaterialApp(home: SignInScreen()),
      ),
    );

    await tester.pump();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
