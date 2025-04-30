import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:nutricare_agents/firebase_options.dart';

/// Lớp dịch vụ Firebase cung cấp các phương thức để tương tác với Firebase
/// bao gồm Authentication, Firestore và Storage
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Firebase instances
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;
  late final FirebaseStorage _storage;
  late final GoogleSignIn _googleSignIn;
  bool _initialized = false;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Khởi tạo Firebase
  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Khởi tạo các instance sau khi Firebase đã được khởi tạo
      final instance = FirebaseService._instance;
      instance._auth = FirebaseAuth.instance;
      instance._firestore = FirebaseFirestore.instance;
      instance._storage = FirebaseStorage.instance;
      instance._googleSignIn = GoogleSignIn();
      instance._initialized = true;
      
      if (kDebugMode) {
        print('Firebase đã được khởi tạo thành công');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi khởi tạo Firebase: $e');
      }
      rethrow;
    }
  }

  /// Kiểm tra xem Firebase đã được khởi tạo chưa
  void _checkInitialized() {
    if (!_initialized) {
      throw Exception('Firebase chưa được khởi tạo. Hãy gọi FirebaseService.initialize() trước.');
    }
  }

  /// AUTHENTICATION METHODS

  /// Đăng ký tài khoản mới với email và mật khẩu
  Future<UserCredential> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Kiểm tra xem Firebase đã được khởi tạo chưa
      if (!_initialized) {
        if (kDebugMode) {
          print('Firebase chưa được khởi tạo. Đang thử khởi tạo lại...');
        }
        
        // Thử khởi tạo lại Firebase
        try {
          await FirebaseService.initialize();
        } catch (initError) {
          if (kDebugMode) {
            print('Không thể khởi tạo Firebase: $initError');
          }
          throw Exception('Firebase chưa được khởi tạo. Hãy khởi động lại ứng dụng và thử lại.');
        }
      }
      
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Cập nhật tên hiển thị
      await userCredential.user?.updateDisplayName(displayName);
      
      // Tạo document người dùng trong Firestore
      await _createUserDocument(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng ký: $e');
      }
      rethrow;
    }
  }

  /// Đăng nhập với email và mật khẩu
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Kiểm tra xem Firebase đã được khởi tạo chưa
      if (!_initialized) {
        if (kDebugMode) {
          print('Firebase chưa được khởi tạo. Đang thử khởi tạo lại...');
        }
        
        // Thử khởi tạo lại Firebase
        try {
          await FirebaseService.initialize();
        } catch (initError) {
          if (kDebugMode) {
            print('Không thể khởi tạo Firebase: $initError');
          }
          throw Exception('Firebase chưa được khởi tạo. Hãy khởi động lại ứng dụng và thử lại.');
        }
      }
      
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng nhập: $e');
      }
      rethrow;
    }
  }

  /// Đăng nhập với Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Kiểm tra xem Firebase đã được khởi tạo chưa
      if (!_initialized) {
        if (kDebugMode) {
          print('Firebase chưa được khởi tạo. Đang thử khởi tạo lại...');
        }
        
        // Thử khởi tạo lại Firebase
        try {
          await FirebaseService.initialize();
        } catch (initError) {
          if (kDebugMode) {
            print('Không thể khởi tạo Firebase: $initError');
          }
          throw Exception('Firebase chưa được khởi tạo. Hãy khởi động lại ứng dụng và thử lại.');
        }
      }
      
      // Bắt đầu quá trình đăng nhập với Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return null; // Người dùng hủy đăng nhập
      }
      
      // Lấy thông tin xác thực từ request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Tạo credential cho Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Đăng nhập vào Firebase với credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Kiểm tra xem người dùng đã có trong Firestore chưa
      final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
      
      if (!userDoc.exists) {
        await _createUserDocument(userCredential.user!);
      }
      
      return userCredential;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng nhập với Google: $e');
      }
      rethrow;
    }
  }

  /// Đăng xuất
  Future<void> signOut() async {
    _checkInitialized();
    try {
      await _googleSignIn.signOut(); // Đăng xuất khỏi Google nếu đã đăng nhập
      await _auth.signOut();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi đăng xuất: $e');
      }
      rethrow;
    }
  }

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordResetEmail(String email) async {
    _checkInitialized();
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi gửi email đặt lại mật khẩu: $e');
      }
      rethrow;
    }
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
        
        // Cập nhật thông tin trong Firestore
        await _firestore.collection('users').doc(user.uid).update({
          if (displayName != null) 'displayName': displayName,
          if (photoURL != null) 'photoURL': photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi cập nhật thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  /// FIRESTORE METHODS

  /// Tạo document người dùng trong Firestore
  Future<void> _createUserDocument(User user) async {
    _checkInitialized();
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? '',
        'photoURL': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'preferences': {
          'dietaryRestrictions': [],
          'allergies': [],
          'favoriteIngredients': [],
          'dislikedIngredients': [],
          'healthGoals': [],
        },
      });
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tạo document người dùng: $e');
      }
      rethrow;
    }
  }

  /// Lấy thông tin người dùng từ Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        return doc.data();
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy thông tin người dùng: $e');
      }
      rethrow;
    }
  }

  /// Cập nhật sở thích dinh dưỡng của người dùng
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'preferences': preferences,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi cập nhật sở thích người dùng: $e');
      }
      rethrow;
    }
  }

  /// Lưu thực đơn vào Firestore
  Future<String> saveMenu({
    required String menuType, // 'daily' hoặc 'weekly'
    required Map<String, dynamic> menuData,
    String? name,
  }) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      final docRef = _firestore.collection('users').doc(user.uid)
          .collection('menus').doc();
      
      await docRef.set({
        'id': docRef.id,
        'userId': user.uid,
        'menuType': menuType,
        'name': name ?? 'Thực đơn ${DateTime.now().toIso8601String()}',
        'data': menuData,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lưu thực đơn: $e');
      }
      rethrow;
    }
  }

  /// Lấy danh sách thực đơn của người dùng
  Future<List<Map<String, dynamic>>> getUserMenus({
    String? menuType,
    int limit = 10,
  }) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      Query query = _firestore.collection('users').doc(user.uid)
          .collection('menus')
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (menuType != null) {
        query = query.where('menuType', isEqualTo: menuType);
      }
      
      final snapshot = await query.get();
      
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy danh sách thực đơn: $e');
      }
      rethrow;
    }
  }

  /// Xóa thực đơn
  Future<void> deleteMenu(String menuId) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      await _firestore.collection('users').doc(user.uid)
          .collection('menus').doc(menuId).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xóa thực đơn: $e');
      }
      rethrow;
    }
  }

  /// Lưu món ăn yêu thích
  Future<void> saveFavoriteItem(Map<String, dynamic> itemData) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      final docRef = _firestore.collection('users').doc(user.uid)
          .collection('favorites').doc(itemData['name']);
      
      await docRef.set({
        'userId': user.uid,
        'data': itemData,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lưu món ăn yêu thích: $e');
      }
      rethrow;
    }
  }

  /// Xóa món ăn yêu thích
  Future<void> removeFavoriteItem(String itemName) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      await _firestore.collection('users').doc(user.uid)
          .collection('favorites').doc(itemName).delete();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xóa món ăn yêu thích: $e');
      }
      rethrow;
    }
  }

  /// Lấy danh sách món ăn yêu thích
  Future<List<Map<String, dynamic>>> getFavoriteItems() async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      final snapshot = await _firestore.collection('users').doc(user.uid)
          .collection('favorites')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()['data'] as Map<String, dynamic>).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi lấy danh sách món ăn yêu thích: $e');
      }
      rethrow;
    }
  }

  /// STORAGE METHODS

  /// Tải lên hình ảnh
  Future<String> uploadImage(dynamic imageFile, String path) async {
    _checkInitialized();
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }
      
      final ref = _storage.ref().child(path);
      late final UploadTask uploadTask;
      
      if (kIsWeb) {
        // Xử lý cho web platform
        if (imageFile is List<int>) {
          uploadTask = ref.putData(Uint8List.fromList(imageFile));
        } else {
          throw Exception('Định dạng file không hỗ trợ trên web');
        }
      } else {
        // Xử lý cho mobile platform
        if (imageFile is File) {
          uploadTask = ref.putFile(imageFile);
        } else {
          throw Exception('Định dạng file không hỗ trợ trên mobile');
        }
      }
      
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi tải lên hình ảnh: $e');
      }
      rethrow;
    }
  }

  /// Xóa hình ảnh
  Future<void> deleteImage(String url) async {
    _checkInitialized();
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      if (kDebugMode) {
        print('Lỗi xóa hình ảnh: $e');
      }
      rethrow;
    }
  }
}
