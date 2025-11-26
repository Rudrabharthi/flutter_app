// authentication_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../services/database_service.dart';
import '../services/navigation_service.dart';
import '../models/chat_user.dart';

class AuthenticationProvider extends ChangeNotifier {
  late final FirebaseAuth _auth;
  late final NavigationService _navigationService;
  late final DatabaseService _databaseService;

  ChatUser? user; // nullable

  AuthenticationProvider() {
    _auth = FirebaseAuth.instance;
    _navigationService = GetIt.instance.get<NavigationService>();
    _databaseService = GetIt.instance.get<DatabaseService>();

    _auth.authStateChanges().listen((firebaseUser) async {
      // If NOT logged in → go to login and stop
      if (firebaseUser == null) {
        user = null;
        if (_navigationService.getCurrentRoute() != '/login') {
          _navigationService.removeAndNavigateToRoute('/login');
        }
        notifyListeners();
        return;
      }

      // From here we KNOW firebaseUser is not null
      try {
        // update last seen – should not throw, but we guard anyway
        await _databaseService.updateUserLastSeenTime(firebaseUser.uid);
      } catch (e) {
        debugPrint('updateUserLastSeenTime error: $e');
        // not fatal, just log
      }

      try {
        final snapshot = await _databaseService.getUser(firebaseUser.uid);

        if (!snapshot.exists) {
          debugPrint('User doc does NOT exist for uid: ${firebaseUser.uid}');
          // Do NOT crash – just send back to login
          _navigationService.removeAndNavigateToRoute('/login');
          return;
        }

        final data = snapshot.data() as Map<String, dynamic>?;

        if (data == null) {
          debugPrint('User data is null for uid: ${firebaseUser.uid}');
          _navigationService.removeAndNavigateToRoute('/login');
          return;
        }

        // Build ChatUser safely with fallbacks
        user = ChatUser.fromJSON({
          'uid': firebaseUser.uid,
          'name': data['name'] ?? '',
          'email': data['email'] ?? '',
          'last_active': data['last_active'],
          'image': data['image'] ?? '',
        });

        notifyListeners();
        _navigationService.removeAndNavigateToRoute('/home');
      } catch (e) {
        // Any exception in Firestore / parsing lands here instead of crashing
        debugPrint('Error in authStateChanges listener: $e');
        _navigationService.removeAndNavigateToRoute('/login');
      }
    });
  }

  Future<void> loginUsingEmailAndPassword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint("Error logging user into Firebase: ${e.code}");
    } catch (e) {
      debugPrint('loginUsingEmailAndPassword error: $e');
    }
  }

  Future<String?> registerUserUsingEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final credentials = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credentials.user?.uid;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error registering user: ${e.code}");
    } catch (e) {
      debugPrint('registerUserUsingEmailAndPassword error: $e');
    }
    return null;
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('logout error: $e');
    }
  }
}
