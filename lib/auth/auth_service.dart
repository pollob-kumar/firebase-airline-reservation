import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Login
  Future<UserModel?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _firestoreService.getUser(result.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyLoginError(e));
    } catch (e) {
      throw Exception('Login failed. Please try again.');
    }
  }

  // Registration
  Future<UserModel?> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      UserModel newUser = UserModel(
        uid: result.user!.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        balance: 0.0,
        createdAt: DateTime.now(),
      );

      await _firestoreService.createUser(newUser);
      await _firestoreService.createAdminNotification(
        title: 'New user registration',
        message: '${name.isNotEmpty ? name : email} created a $role account.',
        type: 'new_user',
      );
      return newUser;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e));
    } catch (e) {
      throw Exception('Registration failed. Please try again.');
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> updateDisplayName(String name) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated.');
    }
    await user.updateDisplayName(name);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not authenticated.');
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  String _friendlyAuthError(FirebaseAuthException error) {
    final code = error.code.toLowerCase();
    switch (code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
        return 'Wrong email or password';
      case 'wrong-password':
        return 'Wrong password. Please try again.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'operation-not-allowed':
        return 'This operation is not allowed. Please contact support.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  String _friendlyLoginError(FirebaseAuthException error) {
    final code = error.code.toLowerCase();
    switch (code) {
      case 'invalid-credential':
      case 'invalid-login-credentials':
      case 'wrong-password':
      case 'user-not-found':
        return 'Wrong email or password. Please try again.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Login failed. Please try again.';
    }
  }
}
