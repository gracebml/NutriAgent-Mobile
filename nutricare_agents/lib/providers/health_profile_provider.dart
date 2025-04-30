import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutricare_agents/models/health_profile.dart';

class HealthProfileProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  HealthProfileModel? _healthProfile;
  bool _isLoading = false;
  String? _error;
  
  // Step tracking for multi-step form
  int _currentStep = 0;
  Set<int> _completedSteps = {};
  
  // Getters
  HealthProfileModel? get healthProfile => _healthProfile;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentStep => _currentStep;
  Set<int> get completedSteps => _completedSteps;
  
  // Initialize with a blank profile for the current user
  void initBlankProfile() {
    final user = _auth.currentUser;
    if (user == null) {
      _error = "Vui lòng đăng nhập để truy cập thông tin sức khỏe";
      notifyListeners();
      return;
    }
    
    _healthProfile = HealthProfileModel(
      userId: user.uid,
      name: user.displayName ?? 'User',
    );
    notifyListeners();
  }
  
  // Load health profile from Firestore
  Future<void> loadHealthProfile() async {
    final user = _auth.currentUser;
    if (user == null) {
      _error = "Vui lòng đăng nhập để truy cập thông tin sức khỏe";
      notifyListeners();
      return;
    }
    
    setLoading(true);
    
    try {
      // Query Firestore for the health profile of the current user
      final querySnapshot = await _firestore
        .collection('healthProfiles')
        .where('userId', isEqualTo: user.uid)
        .limit(1)
        .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        // Profile exists, load it
        _healthProfile = HealthProfileModel.fromFirestore(querySnapshot.docs.first);
        _error = null;
        
        // Calculate which steps are completed based on the loaded profile
        _updateCompletedSteps();
      } else {
        // No profile found, create a blank one
        initBlankProfile();
      }
    } catch (e) {
      _error = "Không thể tải thông tin sức khỏe: ${e.toString()}";
      debugPrint("Error loading health profile: $e");
    } finally {
      setLoading(false);
    }
  }
  
  // Save health profile to Firestore
  Future<bool> saveHealthProfile() async {
    if (_healthProfile == null) {
      _error = "Không có thông tin sức khỏe để lưu";
      notifyListeners();
      return false;
    }
    
    final user = _auth.currentUser;
    if (user == null) {
      _error = "Vui lòng đăng nhập để lưu thông tin sức khỏe";
      notifyListeners();
      return false;
    }
    
    setLoading(true);
    
    try {
      // Update timestamp before saving
      _healthProfile = _healthProfile!.copyWith(
        lastUpdated: DateTime.now(),
      );
      
      if (_healthProfile!.id != null) {
        // Update existing document
        await _firestore
          .collection('healthProfiles')
          .doc(_healthProfile!.id)
          .update(_healthProfile!.toMap());
      } else {
        // Create new document
        final docRef = await _firestore
          .collection('healthProfiles')
          .add(_healthProfile!.toMap());
        
        // Update the profile with the new ID
        _healthProfile = _healthProfile!.copyWith(id: docRef.id);
      }
      
      _error = null;
      return true;
    } catch (e) {
      _error = "Không thể lưu thông tin sức khỏe: ${e.toString()}";
      debugPrint("Error saving health profile: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // Delete health profile
  Future<bool> deleteHealthProfile() async {
    if (_healthProfile?.id == null) {
      _error = "Không tìm thấy thông tin sức khỏe để xóa";
      notifyListeners();
      return false;
    }
    
    setLoading(true);
    
    try {
      await _firestore
        .collection('healthProfiles')
        .doc(_healthProfile!.id)
        .delete();
      
      initBlankProfile();
      _error = null;
      return true;
    } catch (e) {
      _error = "Không thể xóa thông tin sức khỏe: ${e.toString()}";
      debugPrint("Error deleting health profile: $e");
      return false;
    } finally {
      setLoading(false);
    }
  }
  
  // Update health profile fields
  void updateProfile({
    String? name,
    int? age,
    Gender? gender,
    double? height,
    double? weight,
    ActivityLevel? activityLevel,
    String? allergies,
    String? dietaryRestrictions,
    String? preferences,
    String? medicalConditions,
    String? goals,
  }) {
    if (_healthProfile == null) {
      initBlankProfile();
    }
    
    _healthProfile = _healthProfile!.copyWith(
      name: name,
      age: age,
      gender: gender,
      height: height,
      weight: weight,
      activityLevel: activityLevel,
      allergies: allergies,
      dietaryRestrictions: dietaryRestrictions,
      preferences: preferences,
      medicalConditions: medicalConditions,
      goals: goals,
    );
    
    _updateCompletedSteps();
    notifyListeners();
  }
  
  // Helper function to set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Multi-step form navigation
  void goToStep(int step) {
    _currentStep = step;
    notifyListeners();
  }
  
  void nextStep() {
    if (_validateCurrentStep()) {
      _completedSteps.add(_currentStep);
      _currentStep++;
      notifyListeners();
    }
  }
  
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }
  
  // Validation for current step
  bool _validateCurrentStep() {
    if (_healthProfile == null) return false;
    
    switch (_currentStep) {
      case 0: // Personal Information
        return _healthProfile!.name.isNotEmpty;
      case 1: // Body Metrics
        return true; // Optional fields
      case 2: // Activity Level
        return true; // Optional field
      case 3: // Nutritional Information
        return true; // Optional fields
      case 4: // Health & Goals
        return true; // Optional fields
      default:
        return true;
    }
  }
  
  // Update completed steps based on profile data
  void _updateCompletedSteps() {
    _completedSteps = {};
    
    if (_healthProfile == null) return;
    
    // Check each step for completion
    if (_healthProfile!.name.isNotEmpty) {
      _completedSteps.add(0);
    }
    
    if (_healthProfile!.height != null || _healthProfile!.weight != null) {
      _completedSteps.add(1);
    }
    
    if (_healthProfile!.activityLevel != null) {
      _completedSteps.add(2);
    }
    
    if (_healthProfile!.allergies != null || 
        _healthProfile!.dietaryRestrictions != null || 
        _healthProfile!.preferences != null) {
      _completedSteps.add(3);
    }
    
    if (_healthProfile!.medicalConditions != null || _healthProfile!.goals != null) {
      _completedSteps.add(4);
    }
  }
  
  // Clear any error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Reset everything (for logout)
  void reset() {
    _healthProfile = null;
    _error = null;
    _isLoading = false;
    _currentStep = 0;
    _completedSteps = {};
    notifyListeners();
  }
}