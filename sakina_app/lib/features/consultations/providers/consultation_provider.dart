import 'package:flutter/material.dart';
import '../../../models/consultation_model.dart';
import '../../../services/storage_service.dart';

class ConsultationProvider extends ChangeNotifier {
  final StorageService _storageService;
  
  List<ConsultationModel> _consultations = [];
  List<SpecialistModel> _specialists = [];
  bool _isLoading = false;
  String? _error;
  
  ConsultationProvider(this._storageService) {
    _loadConsultations();
    _loadSpecialists();
  }
  
  // Getters
  List<ConsultationModel> get consultations => _consultations;
  List<SpecialistModel> get specialists => _specialists;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  List<ConsultationModel> get upcomingConsultations {
    return _consultations
        .where((c) => c.status == ConsultationStatus.confirmed &&
                     c.scheduledDate.isAfter(DateTime.now()))
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
  }
  
  List<ConsultationModel> get pastConsultations {
    return _consultations
        .where((c) => c.status == ConsultationStatus.completed)
        .toList()
      ..sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));
  }
  
  List<SpecialistModel> get availableSpecialists {
    return _specialists.where((s) => s.isAvailable).toList();
  }
  
  // Load data
  Future<void> _loadConsultations() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final consultationsData = await _storageService.getList('consultations');
      _consultations = consultationsData
          .map((data) => ConsultationModel.fromJson(data))
          .toList();
      
      _error = null;
    } catch (e) {
      _error = 'خطأ في تحميل الاستشارات: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> _loadSpecialists() async {
    try {
      // Load mock specialists data
      _specialists = _getMockSpecialists();
      await _storageService.saveList('specialists', 
          _specialists.map((s) => s.toJson()).toList());
    } catch (e) {
      _error = 'خطأ في تحميل المختصين: $e';
    }
  }
  
  // Book consultation
  Future<bool> bookConsultation({
    required String specialistId,
    required DateTime scheduledDate,
    required Duration duration,
    required ConsultationType type,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final specialist = _specialists.firstWhere((s) => s.id == specialistId);
      
      final consultation = ConsultationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id', // Get from auth provider
        specialistId: specialistId,
        specialistName: specialist.name,
        specialistTitle: specialist.title,
        specialistImage: specialist.image,
        specialization: specialist.specialization,
        scheduledDate: scheduledDate,
        duration: duration,
        status: ConsultationStatus.pending,
        type: type,
        price: specialist.pricePerSession,
        notes: notes,
        createdAt: DateTime.now(),
      );
      
      _consultations.add(consultation);
      await _saveConsultations();
      
      _error = null;
      return true;
    } catch (e) {
      _error = 'خطأ في حجز الاستشارة: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Cancel consultation
  Future<bool> cancelConsultation(String consultationId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        _consultations[index] = ConsultationModel(
          id: _consultations[index].id,
          userId: _consultations[index].userId,
          specialistId: _consultations[index].specialistId,
          specialistName: _consultations[index].specialistName,
          specialistTitle: _consultations[index].specialistTitle,
          specialistImage: _consultations[index].specialistImage,
          specialization: _consultations[index].specialization,
          scheduledDate: _consultations[index].scheduledDate,
          duration: _consultations[index].duration,
          status: ConsultationStatus.cancelled,
          type: _consultations[index].type,
          price: _consultations[index].price,
          notes: _consultations[index].notes,
          sessionNotes: _consultations[index].sessionNotes,
          attachments: _consultations[index].attachments,
          createdAt: _consultations[index].createdAt,
          completedAt: _consultations[index].completedAt,
          rating: _consultations[index].rating,
          feedback: _consultations[index].feedback,
        );
        
        await _saveConsultations();
        _error = null;
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطأ في إلغاء الاستشارة: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Rate consultation
  Future<bool> rateConsultation(String consultationId, int rating, String? feedback) async {
    try {
      final index = _consultations.indexWhere((c) => c.id == consultationId);
      if (index != -1) {
        // Create updated consultation with rating
        final updatedConsultation = ConsultationModel(
          id: _consultations[index].id,
          userId: _consultations[index].userId,
          specialistId: _consultations[index].specialistId,
          specialistName: _consultations[index].specialistName,
          specialistTitle: _consultations[index].specialistTitle,
          specialistImage: _consultations[index].specialistImage,
          specialization: _consultations[index].specialization,
          scheduledDate: _consultations[index].scheduledDate,
          duration: _consultations[index].duration,
          status: _consultations[index].status,
          type: _consultations[index].type,
          price: _consultations[index].price,
          notes: _consultations[index].notes,
          sessionNotes: _consultations[index].sessionNotes,
          attachments: _consultations[index].attachments,
          createdAt: _consultations[index].createdAt,
          completedAt: _consultations[index].completedAt,
          rating: rating,
          feedback: feedback,
        );
        
        _consultations[index] = updatedConsultation;
        await _saveConsultations();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطأ في تقييم الاستشارة: $e';
      return false;
    }
  }
  
  // Save consultations to storage
  Future<void> _saveConsultations() async {
    await _storageService.saveList('consultations',
        _consultations.map((c) => c.toJson()).toList());
  }
  
  // Get specialist by ID
  SpecialistModel? getSpecialistById(String id) {
    try {
      return _specialists.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Filter specialists by specialization
  List<SpecialistModel> getSpecialistsBySpecialization(String specialization) {
    return _specialists
        .where((s) => s.specialization == specialization && s.isAvailable)
        .toList();
  }
  
  // Mock specialists data
  List<SpecialistModel> _getMockSpecialists() {
    return [
      SpecialistModel(
        id: '1',
        name: 'د. سارة أحمد',
        title: 'استشارية الطب النفسي',
        image: 'assets/images/specialist1.jpg',
        specialization: 'القلق والاكتئاب',
        description: 'متخصصة في علاج اضطرابات القلق والاكتئاب مع خبرة 15 عام',
        qualifications: ['دكتوراه في الطب النفسي', 'زمالة الطب النفسي الأمريكية'],
        experienceYears: 15,
        rating: 4.8,
        reviewsCount: 127,
        pricePerSession: 300.0,
        availableLanguages: ['العربية', 'الإنجليزية'],
        supportedTypes: [ConsultationType.video, ConsultationType.audio, ConsultationType.chat],
        isAvailable: true,
        nextAvailableSlot: 'غداً 2:00 م',
        workingHours: ['9:00 ص - 5:00 م'],
      ),
      SpecialistModel(
        id: '2',
        name: 'د. محمد الخالدي',
        title: 'مستشار نفسي',
        image: 'assets/images/specialist2.jpg',
        specialization: 'العلاج الأسري',
        description: 'خبير في العلاج الأسري والزواجي مع تركيز على الثقافة العربية',
        qualifications: ['ماجستير في علم النفس الإكلينيكي', 'دبلوم العلاج الأسري'],
        experienceYears: 12,
        rating: 4.7,
        reviewsCount: 89,
        pricePerSession: 250.0,
        availableLanguages: ['العربية'],
        supportedTypes: [ConsultationType.video, ConsultationType.inPerson],
        isAvailable: true,
        nextAvailableSlot: 'اليوم 7:00 م',
        workingHours: ['2:00 م - 10:00 م'],
      ),
      SpecialistModel(
        id: '3',
        name: 'د. فاطمة النور',
        title: 'أخصائية نفسية',
        image: 'assets/images/specialist3.jpg',
        specialization: 'اضطرابات الأكل',
        description: 'متخصصة في علاج اضطرابات الأكل والصورة الذاتية',
        qualifications: ['دكتوراه في علم النفس', 'شهادة في علاج اضطرابات الأكل'],
        experienceYears: 8,
        rating: 4.9,
        reviewsCount: 156,
        pricePerSession: 280.0,
        availableLanguages: ['العربية', 'الإنجليزية', 'الفرنسية'],
        supportedTypes: [ConsultationType.video, ConsultationType.audio, ConsultationType.chat],
        isAvailable: true,
        nextAvailableSlot: 'بعد غد 10:00 ص',
        workingHours: ['8:00 ص - 4:00 م'],
      ),
    ];
  }
  
  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Refresh data
  Future<void> refresh() async {
    await _loadConsultations();
    await _loadSpecialists();
  }
}