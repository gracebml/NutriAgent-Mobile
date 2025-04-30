import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutricare_agents/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Streams the current user's auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Create user profile in Firestore
  Future<void> createUserDocument(User user, {String? name}) async {
    // Reference to the user document
    DocumentReference userRef = _firestore.collection('users').doc(user.uid);

    try {
      // Check if user document already exists
      DocumentSnapshot doc = await userRef.get();
      
      if (!doc.exists) {
        // User information to save
        UserModel newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '', // Ensure email is not null
          displayName: name ?? user.displayName ?? 'User', // Use provided name or fallback
          photoURL: user.photoURL,
          createdAt: DateTime.now(),
        );
        
        // Save to Firestore
        await userRef.set(newUser.toMap());
        debugPrint('User document created successfully');
      } else {
        debugPrint('User document already exists');
      }
    } catch (e) {
      debugPrint('Error creating user document: $e');
      throw Exception('Lỗi tạo document người dùng: $e');
    }
  }

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Make sure email and password are not null or empty
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email hoặc mật khẩu không được để trống');
      }
      
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user exists
      if (userCredential.user == null) {
        throw Exception('Không thể đăng nhập, vui lòng thử lại');
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with email and password: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  // Sign up with email and password
  Future<UserCredential> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String name
  ) async {
    try {
      // Make sure all fields are not null or empty
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        throw Exception('Tất cả các trường đều phải được điền');
      }
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Check if user was created
      if (userCredential.user == null) {
        throw Exception('Không thể tạo tài khoản, vui lòng thử lại');
      }
      
      // Update display name
      await userCredential.user!.updateDisplayName(name);
      
      // Create user document in Firestore
      await createUserDocument(userCredential.user!, name: name);
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing up with email and password: $e');
      rethrow; // Re-throw to handle in UI
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Start the interactive sign-in process
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      // If user canceled the sign-in flow, return null
      if (googleUser == null) return null;
      
      // Obtain auth details from request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credentials
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in to Firebase with credentials
      UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // Create user document if it doesn't exist
      if (userCredential.user != null) {
        await createUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      throw Exception('Lỗi đăng nhập với Google: $e');
    }
  }

  // Initialize the auth service
  Future<void> init() async {
    // Any initialization logic can go here
    debugPrint('AuthService initialized');
  }

  // Sign in with Facebook
  Future<UserCredential?> signInWithFacebook() async {
    // This is a placeholder for Facebook authentication
    // Implementation would depend on the facebook_auth package
    throw UnimplementedError('Facebook authentication not implemented yet');
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        throw Exception('Email không được để trống');
      }
      
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error resetting password: $e');
      rethrow; // Re-throw to handle in UI
    }
  }
}
