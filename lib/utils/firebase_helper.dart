// lib/utils/firebase_helper.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseHelper {
  // Singleton instance
  static final FirebaseHelper _instance = FirebaseHelper._internal();
  factory FirebaseHelper() => _instance;
  FirebaseHelper._internal();

  // Initialize Firebase
  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp();
      debugPrint('Firebase initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  // Sync user data between SharedPreferences and Firebase Auth
  static Future<void> syncUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUserId = prefs.getString('id');
      final currentUser = FirebaseAuth.instance.currentUser;

      // If we're logged in to Firebase but not in SharedPreferences
      if (currentUser != null && savedUserId == null) {
        await prefs.setString('id', currentUser.uid);
        debugPrint('User ID stored in SharedPreferences');
      }
      // If we're logged in to SharedPreferences but not in Firebase
      else if (savedUserId != null && currentUser == null) {
        // This is a complex situation - you might need to re-authenticate
        debugPrint(
            'Warning: User ID in SharedPreferences but not in Firebase Auth');
      }
    } catch (e) {
      debugPrint('Error syncing user data: $e');
    }
  }

  // Check if Firestore collections are properly set up
  static Future<void> setupFirestoreCollections() async {
    try {
      // We don't need to explicitly create collections in Firestore
      // They are created automatically when the first document is added
      // But we can add a test document to verify access

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        // Create a test document for the current user
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .set({
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        debugPrint('Firestore collections verified');
      }
    } catch (e) {
      debugPrint('Error setting up Firestore collections: $e');
      // Handle based on error message
      if (e.toString().contains('permission-denied')) {
        debugPrint('Security rules may be preventing access');
      }
    }
  }

  // Helper for fetching user profile information
  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (doc.exists) {
        return doc.data();
      } else {
        debugPrint('User profile not found for ID: $userId');
        return null;
      }
    } catch (e) {
      debugPrint('Error fetching user profile: $e');
      return null;
    }
  }

  // Test Firebase connection
  static Future<bool> testConnection() async {
    try {
      // Test Firestore connection
      final testRef = FirebaseFirestore.instance.collection('_test').doc();
      await testRef.set({'timestamp': FieldValue.serverTimestamp()});
      await testRef.delete(); // Clean up

      // If we get here, the connection works
      debugPrint('Firebase connection test passed');
      return true;
    } catch (e) {
      debugPrint('Firebase connection test failed: $e');
      return false;
    }
  }
}
