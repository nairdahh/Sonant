// lib/services/user_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

class UserService {
  late final FirebaseFirestore _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserService() {
    if (kIsWeb) {
      _firestore = FirebaseFirestore.instanceFor(
        app: FirebaseFirestore.instance.app,
        databaseId: 'sonantdb',
      );
      _firestore.settings = const Settings(persistenceEnabled: false);
    } else {
      _firestore = FirebaseFirestore.instance;
    }
  }

  /// Creates a new user profile
  Future<void> createUserProfile({
    required String uid,
    required String email,
    required String displayName,
  }) async {
    try {
      final profile = UserProfile(
        uid: uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(profile.toMap());

      debugPrint('✅ User profile created: $displayName');
    } catch (e) {
      debugPrint('❌ Error creating user profile: $e');
      rethrow;
    }
  }

  /// Retrieves user profile
  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting user profile: $e');
      return null;
    }
  }

  /// Stream for user profile updates
  Stream<UserProfile?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!);
      }
      return null;
    });
  }

  /// Updates user display name
  Future<void> updateDisplayName(String uid, String displayName) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'displayName': displayName});

      await _auth.currentUser?.updateDisplayName(displayName);

      debugPrint('✅ Display name updated: $displayName');
    } catch (e) {
      debugPrint('❌ Error updating display name: $e');
      rethrow;
    }
  }

  /// Updates last login timestamp
  Future<void> updateLastLogin(String uid) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .update({'lastLoginAt': FieldValue.serverTimestamp()});
    } catch (e) {
      debugPrint('❌ Error updating last login: $e');
    }
  }

  /// Checks if user has configured profile
  Future<bool> hasProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking profile: $e');
      return false;
    }
  }
}
