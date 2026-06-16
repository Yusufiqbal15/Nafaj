import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final GoogleSignIn? _googleSignIn = kIsWeb ? null : GoogleSignIn();

  static String _getCollection(String role) {
    if (role == 'vendor') return 'vendors';
    if (role == 'driver') return 'drivers';
    return 'users';
  }

  // Register with Email and Password
  static Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String role, // 'vendor', 'driver', 'user'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Base document stored for every role
        Map<String, dynamic> data = {
          'uid': userCredential.user!.uid,
          'email': email,
          'role': role,
          'authProvider': 'email',
          'isActive': true,
          'walletBalance': 0.0,
          'createdAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        };

        if (additionalData != null) {
          data.addAll(additionalData);
        }

        String collectionName = _getCollection(role);
        await _firestore
            .collection(collectionName)
            .doc(userCredential.user!.uid)
            .set(data);
      }

      return userCredential;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }

  // Login with Email and Password
  static Future<UserCredential?> loginWithEmail({
    required String email,
    required String password,
    required String expectedRole,
  }) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        String collectionName = _getCollection(expectedRole);
        DocumentSnapshot doc = await _firestore
            .collection(collectionName)
            .doc(userCredential.user!.uid)
            .get();
        if (!doc.exists) {
          String? actualRole =
              await getUserRole(userCredential.user!.uid);
          await _auth.signOut();
          if (actualRole != null) {
            throw Exception(
                'Access Denied. This account is registered as a $actualRole.');
          }
          throw Exception(
              'Access Denied. You are not a registered $expectedRole.');
        }

        // Update last login timestamp
        await _firestore
            .collection(collectionName)
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': FieldValue.serverTimestamp()});
      }

      return userCredential;
    } catch (e) {
      print('Login Error: \$e');
      rethrow;
    }
  }

  // Sign in with Google
  static Future<UserCredential?> signInWithGoogle({
    required String defaultRole,
  }) async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // On Web, use Firebase Auth's built-in API which handles everything under the hood
        GoogleAuthProvider authProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(authProvider);
      } else {
        // Trigger the authentication flow for Android/iOS
        final GoogleSignInAccount? googleUser = await _googleSignIn?.signIn();

        if (googleUser == null) {
          return null; // User canceled the sign-in
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google [UserCredential]
        userCredential = await _auth.signInWithCredential(credential);
      }

      if (userCredential.user != null) {
        String collectionName = _getCollection(defaultRole);
        String uid = userCredential.user!.uid;
        
        // Before creating a new document, check if this UID exists in ANY other role collection
        if (defaultRole != 'vendor') {
          DocumentSnapshot vendorDoc = await _firestore.collection('vendors').doc(uid).get();
          if (vendorDoc.exists) {
            await _auth.signOut();
            throw Exception('Access Denied. This account is already registered as a vendor.');
          }
        }
        
        if (defaultRole != 'driver') {
          DocumentSnapshot driverDoc = await _firestore.collection('drivers').doc(uid).get();
          if (driverDoc.exists) {
            await _auth.signOut();
            throw Exception('Access Denied. This account is already registered as a driver.');
          }
        }
        
        if (defaultRole != 'user') {
          DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
          if (userDoc.exists) {
            await _auth.signOut();
            throw Exception('Access Denied. This account is already registered as a user.');
          }
        }

        // Now that we know they don't belong to another role, check their expected collection
        DocumentSnapshot doc =
            await _firestore.collection(collectionName).doc(uid).get();

        if (!doc.exists) {
          // Fresh Google sign-in → create full profile
          await _firestore.collection(collectionName).doc(uid).set({
            'uid': uid,
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'role': defaultRole,
            'authProvider': 'google',
            'isActive': true,
            'walletBalance': 0.0,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
          });
        } else {
          // Existing user → just update last login
          await _firestore.collection(collectionName).doc(uid).update({
            'lastLoginAt': FieldValue.serverTimestamp(),
            if (userCredential.user!.photoURL != null)
              'photoURL': userCredential.user!.photoURL,
            if (userCredential.user!.displayName != null)
              'displayName': userCredential.user!.displayName,
          });
        }
      }

      return userCredential;
    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Log Out
  static Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn?.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      print('Sign Out Error: $e');
    }
  }

  // Get current user role by checking which Firestore collection they belong to
  static Future<String?> getUserRole(String uid) async {
    try {
      // Check drivers first
      DocumentSnapshot doc =
          await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists) return 'driver';

      // Check vendors
      doc = await _firestore.collection('vendors').doc(uid).get();
      if (doc.exists) return 'vendor';

      // Check users
      doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return 'user';
    } catch (e) {
      print('Get Role Error: $e');
    }
    return null;
  }

  /// Returns the named route for the given role.
  static String getDashboardRoute(String? role) {
    switch (role) {
      case 'driver':
        return '/driver_dashboard_animated_3d';
      case 'vendor':
        return '/vendor_dashboard';
      default:
        return '/nafaj_marketplace_home';
    }
  }
}
