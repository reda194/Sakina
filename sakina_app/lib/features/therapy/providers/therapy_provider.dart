import 'package:flutter/foundation.dart';
import '../../../models/therapy_program_model.dart';

class TherapyProvider with ChangeNotifier {
  List<TherapyProgramModel> _programs = [];
  List<TherapyProgramModel> _myPrograms = [];
  TherapyAssessmentModel? _currentAssessment;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<TherapyProgramModel> get programs => _programs;
  List<TherapyProgramModel> get myPrograms => _myPrograms;
  TherapyAssessmentModel? get currentAssessment => _currentAssessment;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TherapyProgramModel> get inProgressPrograms =>
      _myPrograms.where((p) => p.status == TherapyProgramStatus.inProgress).toList();

  List<TherapyProgramModel> get completedPrograms =>
      _myPrograms.where((p) => p.status == TherapyProgramStatus.completed).toList();

  List<TherapyProgramModel> get recommendedPrograms =>
      _programs.where((p) => _isRecommendedForUser(p)).toList();

  // Load all available therapy programs
  Future<void> loadPrograms() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      _programs = _getMockPrograms();
      _error = null;
    } catch (e) {
      _error = 'فشل في تحميل البرامج: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load user's enrolled programs
  Future<void> loadMyPrograms() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 800));
      _myPrograms = _getMockMyPrograms();
      _error = null;
    } catch (e) {
      _error = 'فشل في تحميل برامجي: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Start a therapy program
  Future<void> startProgram(String programId) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final program = _programs.firstWhere((p) => p.id == programId);
      final startedProgram = program.copyWith(
        status: TherapyProgramStatus.inProgress,
        startedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _myPrograms.add(startedProgram);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في بدء البرنامج: $e';
      _setLoading(false);
    }
    _setLoading(false);
  }

  // Complete a therapy session
  Future<void> completeSession(String programId, String sessionId, {
    double? rating,
    String? notes,
  }) async {
    try {
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex == -1) return;

      final program = _myPrograms[programIndex];
      final sessionIndex = program.sessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex == -1) return;

      // Update session
      final updatedSession = program.sessions[sessionIndex].copyWith(
        isCompleted: true,
        completedAt: DateTime.now(),
        userRating: rating,
        userNotes: notes,
        updatedAt: DateTime.now(),
      );

      final updatedSessions = List<TherapySessionModel>.from(program.sessions);
      updatedSessions[sessionIndex] = updatedSession;

      // Calculate new progress
      final completedSessionsCount = updatedSessions.where((s) => s.isCompleted).length;
      final newProgress = completedSessionsCount / program.totalSessions;
      final newCurrentSessionIndex = program.currentSessionIndex + 1;

      // Update program
      final updatedProgram = program.copyWith(
        sessions: updatedSessions,
        currentSessionIndex: newCurrentSessionIndex,
        progress: newProgress,
        status: newProgress >= 1.0 
            ? TherapyProgramStatus.completed 
            : TherapyProgramStatus.inProgress,
        completedAt: newProgress >= 1.0 ? DateTime.now() : null,
        updatedAt: DateTime.now(),
      );

      _myPrograms[programIndex] = updatedProgram;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في إكمال الجلسة: $e';
      notifyListeners();
    }
  }

  // Pause a program
  Future<void> pauseProgram(String programId) async {
    try {
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex == -1) return;

      final updatedProgram = _myPrograms[programIndex].copyWith(
        status: TherapyProgramStatus.paused,
        updatedAt: DateTime.now(),
      );

      _myPrograms[programIndex] = updatedProgram;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في إيقاف البرنامج مؤقتاً: $e';
      notifyListeners();
    }
  }

  // Resume a program
  Future<void> resumeProgram(String programId) async {
    try {
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex == -1) return;

      final updatedProgram = _myPrograms[programIndex].copyWith(
        status: TherapyProgramStatus.inProgress,
        updatedAt: DateTime.now(),
      );

      _myPrograms[programIndex] = updatedProgram;
      notifyListeners();
    } catch (e) {
      _error = 'فشل في استئناف البرنامج: $e';
      notifyListeners();
    }
  }

  // Load initial assessment
  Future<void> loadAssessment() async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _currentAssessment = _getMockAssessment();
      _error = null;
    } catch (e) {
      _error = 'فشل في تحميل التقييم: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Submit assessment
  Future<List<String>> submitAssessment(Map<String, String> answers) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Simple recommendation logic based on answers
      final recommendations = _generateRecommendations(answers);
      
      if (_currentAssessment != null) {
        _currentAssessment = TherapyAssessmentModel(
          id: _currentAssessment!.id,
          userId: _currentAssessment!.userId,
          title: _currentAssessment!.title,
          description: _currentAssessment!.description,
          questions: _currentAssessment!.questions,
          results: answers,
          recommendedPrograms: recommendations,
          isCompleted: true,
          completedAt: DateTime.now(),
          createdAt: _currentAssessment!.createdAt,
          updatedAt: DateTime.now(),
        );
      }
      
      _error = null;
      return recommendations;
    } catch (e) {
      _error = 'فشل في إرسال التقييم: $e';
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Get program by ID
  TherapyProgramModel? getProgramById(String id) {
    try {
      return _programs.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get my program by ID
  TherapyProgramModel? getMyProgramById(String id) {
    try {
      return _myPrograms.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filter programs by type
  List<TherapyProgramModel> getProgramsByType(TherapyProgramType type) {
    return _programs.where((p) => p.type == type).toList();
  }

  // Filter programs by level
  List<TherapyProgramModel> getProgramsByLevel(TherapyProgramLevel level) {
    return _programs.where((p) => p.level == level).toList();
  }

  // Search programs
  List<TherapyProgramModel> searchPrograms(String query) {
    if (query.isEmpty) return _programs;
    
    final lowercaseQuery = query.toLowerCase();
    return _programs.where((p) => 
      p.title.toLowerCase().contains(lowercaseQuery) ||
      p.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  // Save session notes
  Future<void> saveSessionNotes(
    String programId,
    String sessionId,
    String notes,
  ) async {
    try {
      _setLoading(true);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex != -1) {
        final sessionIndex = _myPrograms[programIndex]
            .sessions
            .indexWhere((s) => s.id == sessionId);
        if (sessionIndex != -1) {
          final updatedSession = _myPrograms[programIndex].sessions[sessionIndex].copyWith(
            userNotes: notes,
            updatedAt: DateTime.now(),
          );
          
          final updatedSessions = List<TherapySessionModel>.from(_myPrograms[programIndex].sessions);
          updatedSessions[sessionIndex] = updatedSession;
          
          _myPrograms[programIndex] = _myPrograms[programIndex].copyWith(
            sessions: updatedSessions,
            updatedAt: DateTime.now(),
          );
          
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'فشل في حفظ الملاحظات: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Complete exercise
  Future<void> completeExercise(
    String programId,
    String sessionId,
    String exerciseId, {
    Map<String, dynamic>? userResponse,
  }) async {
    try {
      _setLoading(true);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex != -1) {
        final sessionIndex = _myPrograms[programIndex]
            .sessions
            .indexWhere((s) => s.id == sessionId);
        if (sessionIndex != -1) {
          final exerciseIndex = _myPrograms[programIndex]
              .sessions[sessionIndex]
              .exercises
              .indexWhere((e) => e.id == exerciseId);
          if (exerciseIndex != -1) {
            final exercises = List<TherapyExerciseModel>.from(
                _myPrograms[programIndex].sessions[sessionIndex].exercises);
            final currentExercise = exercises[exerciseIndex];
            exercises[exerciseIndex] = currentExercise.copyWith(
              isCompleted: true,
              completedAt: DateTime.now(),
              updatedAt: DateTime.now(),
              userResponse: userResponse ?? currentExercise.userResponse,
            );
            
            final updatedSession = _myPrograms[programIndex].sessions[sessionIndex].copyWith(
              exercises: exercises,
              updatedAt: DateTime.now(),
            );
            
            final updatedSessions = List<TherapySessionModel>.from(_myPrograms[programIndex].sessions);
            updatedSessions[sessionIndex] = updatedSession;
            
            _myPrograms[programIndex] = _myPrograms[programIndex].copyWith(
              sessions: updatedSessions,
              updatedAt: DateTime.now(),
            );
            
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _error = 'فشل في إكمال التمرين: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Save exercise notes
  Future<void> saveExerciseNotes(
    String programId,
    String sessionId,
    String exerciseId,
    String notes,
  ) async {
    try {
      _setLoading(true);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      final programIndex = _myPrograms.indexWhere((p) => p.id == programId);
      if (programIndex != -1) {
        final sessionIndex = _myPrograms[programIndex]
            .sessions
            .indexWhere((s) => s.id == sessionId);
        if (sessionIndex != -1) {
          final exerciseIndex = _myPrograms[programIndex]
              .sessions[sessionIndex]
              .exercises
              .indexWhere((e) => e.id == exerciseId);
          if (exerciseIndex != -1) {
            final exercises = List<TherapyExerciseModel>.from(
                _myPrograms[programIndex].sessions[sessionIndex].exercises);
            exercises[exerciseIndex] = exercises[exerciseIndex].copyWith(
              userNotes: notes,
              updatedAt: DateTime.now(),
            );
            
            final updatedSession = _myPrograms[programIndex].sessions[sessionIndex].copyWith(
              exercises: exercises,
              updatedAt: DateTime.now(),
            );
            
            final updatedSessions = List<TherapySessionModel>.from(_myPrograms[programIndex].sessions);
            updatedSessions[sessionIndex] = updatedSession;
            
            _myPrograms[programIndex] = _myPrograms[programIndex].copyWith(
              sessions: updatedSessions,
              updatedAt: DateTime.now(),
            );
            
            notifyListeners();
          }
        }
      }
    } catch (e) {
      _error = 'فشل في حفظ ملاحظات التمرين: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  bool _isRecommendedForUser(TherapyProgramModel program) {
    // Simple logic - in real app this would be based on user assessment
    return program.rating >= 4.0 && !program.isPremium;
  }

  List<String> _generateRecommendations(Map<String, String> answers) {
    final recommendations = <String>[];
    
    // Simple recommendation logic
    if (answers.containsValue('قلق') || answers.containsValue('توتر')) {
      recommendations.add('anxiety_program');
      recommendations.add('mindfulness_program');
    }
    
    if (answers.containsValue('اكتئاب') || answers.containsValue('حزن')) {
      recommendations.add('depression_program');
      recommendations.add('cbt_program');
    }
    
    if (answers.containsValue('نوم') || answers.containsValue('أرق')) {
      recommendations.add('sleep_program');
    }
    
    if (answers.containsValue('علاقات') || answers.containsValue('اجتماعي')) {
      recommendations.add('relationships_program');
    }
    
    // Default recommendations if none match
    if (recommendations.isEmpty) {
      recommendations.addAll(['cbt_program', 'mindfulness_program']);
    }
    
    return recommendations;
  }

  // Mock data methods
  List<TherapyProgramModel> _getMockPrograms() {
    final now = DateTime.now();
    
    return [
      TherapyProgramModel(
        id: 'cbt_program',
        title: 'العلاج السلوكي المعرفي',
        description: 'برنامج شامل للعلاج السلوكي المعرفي مصمم خصيصاً للثقافة السعودية',
        detailedDescription: 'يهدف هذا البرنامج إلى مساعدتك في فهم العلاقة بين الأفكار والمشاعر والسلوكيات، وتطوير مهارات التعامل مع التحديات النفسية بطريقة صحية وفعالة.',
        type: TherapyProgramType.cbt,
        level: TherapyProgramLevel.beginner,
        durationWeeks: 12,
        totalSessions: 24,
        objectives: [
          'فهم أساسيات العلاج السلوكي المعرفي',
          'تحديد الأفكار السلبية وتحديها',
          'تطوير مهارات التعامل مع الضغوط',
          'بناء عادات صحية يومية',
        ],
        benefits: [
          'تحسن في المزاج والحالة النفسية',
          'زيادة الثقة بالنفس',
          'مهارات أفضل في حل المشكلات',
          'تقليل القلق والتوتر',
        ],
        imageUrl: 'assets/images/cbt_program.svg',
        isPremium: false,
        rating: 4.8,
        reviewsCount: 156,
        sessions: _getMockSessions('cbt_program'),
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now,
      ),
      TherapyProgramModel(
        id: 'anxiety_program',
        title: 'إدارة القلق والتوتر',
        description: 'برنامج متخصص لتعلم تقنيات إدارة القلق والتوتر',
        detailedDescription: 'برنامج مكثف يركز على تعليم تقنيات فعالة للتعامل مع القلق والتوتر، بما في ذلك تمارين التنفس والاسترخاء والتأمل.',
        type: TherapyProgramType.anxiety,
        level: TherapyProgramLevel.beginner,
        durationWeeks: 8,
        totalSessions: 16,
        objectives: [
          'فهم طبيعة القلق وأسبابه',
          'تعلم تقنيات التنفس العميق',
          'ممارسة تمارين الاسترخاء',
          'تطوير استراتيجيات التعامل مع المواقف المثيرة للقلق',
        ],
        benefits: [
          'تقليل مستويات القلق والتوتر',
          'تحسن في جودة النوم',
          'زيادة الشعور بالهدوء والاسترخاء',
          'مهارات أفضل في التعامل مع الضغوط',
        ],
        imageUrl: 'assets/images/anxiety_program.svg',
        isPremium: false,
        rating: 4.6,
        reviewsCount: 89,
        sessions: _getMockSessions('anxiety_program'),
        createdAt: now.subtract(const Duration(days: 25)),
        updatedAt: now,
      ),
      TherapyProgramModel(
        id: 'mindfulness_program',
        title: 'اليقظة الذهنية والتأمل',
        description: 'تعلم تقنيات اليقظة الذهنية والتأمل لتحسين الصحة النفسية',
        detailedDescription: 'برنامج يركز على تطوير مهارات اليقظة الذهنية والتأمل، مما يساعد على تحسين التركيز وتقليل التوتر وزيادة الوعي الذاتي.',
        type: TherapyProgramType.mindfulness,
        level: TherapyProgramLevel.beginner,
        durationWeeks: 6,
        totalSessions: 12,
        objectives: [
          'فهم مفهوم اليقظة الذهنية',
          'تعلم تقنيات التأمل الأساسية',
          'ممارسة التأمل اليومي',
          'تطبيق اليقظة الذهنية في الحياة اليومية',
        ],
        benefits: [
          'تحسن في التركيز والانتباه',
          'تقليل التوتر والقلق',
          'زيادة الوعي الذاتي',
          'تحسن في جودة الحياة',
        ],
        imageUrl: 'assets/images/mindfulness_program.svg',
        isPremium: true,
        rating: 4.9,
        reviewsCount: 203,
        sessions: _getMockSessions('mindfulness_program'),
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now,
      ),
      TherapyProgramModel(
        id: 'depression_program',
        title: 'التعامل مع الاكتئاب',
        description: 'برنامج شامل للتعامل مع أعراض الاكتئاب وتحسين المزاج',
        detailedDescription: 'برنامج متخصص يهدف إلى مساعدة الأشخاص الذين يعانون من أعراض الاكتئاب، من خلال تقنيات العلاج السلوكي المعرفي وأنشطة تحسين المزاج.',
        type: TherapyProgramType.depression,
        level: TherapyProgramLevel.intermediate,
        durationWeeks: 16,
        totalSessions: 32,
        objectives: [
          'فهم طبيعة الاكتئاب وأعراضه',
          'تحديد الأفكار السلبية وتغييرها',
          'تطوير أنشطة ممتعة ومفيدة',
          'بناء شبكة دعم اجتماعي',
        ],
        benefits: [
          'تحسن في المزاج والطاقة',
          'زيادة الدافعية والاهتمام',
          'تحسن في العلاقات الاجتماعية',
          'مهارات أفضل في التعامل مع التحديات',
        ],
        imageUrl: 'assets/images/depression_program.svg',
        isPremium: true,
        rating: 4.7,
        reviewsCount: 124,
        sessions: _getMockSessions('depression_program'),
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now,
      ),
      TherapyProgramModel(
        id: 'sleep_program',
        title: 'تحسين جودة النوم',
        description: 'برنامج لتحسين عادات النوم وعلاج الأرق',
        detailedDescription: 'برنامج متخصص في تحسين جودة النوم من خلال تعلم عادات النوم الصحية وتقنيات الاسترخاء قبل النوم.',
        type: TherapyProgramType.sleep,
        level: TherapyProgramLevel.beginner,
        durationWeeks: 4,
        totalSessions: 8,
        objectives: [
          'فهم أهمية النوم الصحي',
          'تطوير روتين نوم منتظم',
          'تعلم تقنيات الاسترخاء قبل النوم',
          'تحسين بيئة النوم',
        ],
        benefits: [
          'تحسن في جودة النوم',
          'زيادة الطاقة خلال النهار',
          'تحسن في المزاج والتركيز',
          'تقليل التعب والإرهاق',
        ],
        imageUrl: 'assets/images/sleep_program.svg',
        isPremium: false,
        rating: 4.5,
        reviewsCount: 67,
        sessions: _getMockSessions('sleep_program'),
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now,
      ),
      TherapyProgramModel(
        id: 'relationships_program',
        title: 'تحسين العلاقات',
        description: 'برنامج لتطوير مهارات التواصل وتحسين العلاقات',
        detailedDescription: 'برنامج يركز على تطوير مهارات التواصل الفعال وبناء علاقات صحية مع الآخرين، سواء في العمل أو الحياة الشخصية.',
        type: TherapyProgramType.relationships,
        level: TherapyProgramLevel.intermediate,
        durationWeeks: 10,
        totalSessions: 20,
        objectives: [
          'تطوير مهارات التواصل الفعال',
          'فهم ديناميكيات العلاقات',
          'تعلم حل النزاعات بطريقة صحية',
          'بناء الثقة والاحترام المتبادل',
        ],
        benefits: [
          'تحسن في العلاقات الشخصية',
          'مهارات أفضل في التواصل',
          'زيادة الثقة في التفاعلات الاجتماعية',
          'تقليل النزاعات والمشاكل',
        ],
        imageUrl: 'assets/images/relationships_program.svg',
        isPremium: true,
        rating: 4.4,
        reviewsCount: 45,
        sessions: _getMockSessions('relationships_program'),
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now,
      ),
    ];
  }

  List<TherapyProgramModel> _getMockMyPrograms() {
    final programs = _getMockPrograms();
    final now = DateTime.now();
    
    return [
      programs[0].copyWith(
        status: TherapyProgramStatus.inProgress,
        startedAt: now.subtract(const Duration(days: 14)),
        currentSessionIndex: 5,
        progress: 0.2,
      ),
      programs[1].copyWith(
        status: TherapyProgramStatus.completed,
        startedAt: now.subtract(const Duration(days: 60)),
        completedAt: now.subtract(const Duration(days: 4)),
        currentSessionIndex: 16,
        progress: 1.0,
      ),
    ];
  }

  List<TherapySessionModel> _getMockSessions(String programId) {
    final now = DateTime.now();
    
    return List.generate(8, (index) {
      return TherapySessionModel(
        id: '${programId}_session_${index + 1}',
        programId: programId,
        sessionNumber: index + 1,
        title: 'الجلسة ${index + 1}',
        description: 'وصف الجلسة ${index + 1}',
        content: 'محتوى الجلسة ${index + 1}',
        exercises: _getMockExercises('${programId}_session_${index + 1}'),
        estimatedDuration: const Duration(minutes: 45),
        learningObjectives: [
          'هدف تعليمي 1',
          'هدف تعليمي 2',
          'هدف تعليمي 3',
        ],
        resources: [
          'مصدر 1',
          'مصدر 2',
        ],
        createdAt: now.subtract(Duration(days: 30 - index)),
        updatedAt: now,
      );
    });
  }

  List<TherapyExerciseModel> _getMockExercises(String sessionId) {
    final now = DateTime.now();
    
    return [
      TherapyExerciseModel(
        id: '${sessionId}_exercise_1',
        sessionId: sessionId,
        title: 'تمرين التفكير',
        description: 'تمرين لتحليل الأفكار السلبية',
        instructions: 'اكتب أفكارك السلبية وحللها',
        type: ExerciseType.cognitive,
        estimatedDuration: const Duration(minutes: 15),
        questions: [
          'ما هي الأفكار السلبية التي تراودك؟',
          'ما هي الأدلة على صحة هذه الأفكار؟',
          'ما هي الأدلة ضد هذه الأفكار؟',
        ],
        createdAt: now,
        updatedAt: now,
      ),
      TherapyExerciseModel(
        id: '${sessionId}_exercise_2',
        sessionId: sessionId,
        title: 'تمرين التنفس',
        description: 'تمرين للاسترخاء والتهدئة',
        instructions: 'مارس تمرين التنفس العميق لمدة 10 دقائق',
        type: ExerciseType.breathing,
        estimatedDuration: const Duration(minutes: 10),
        questions: [
          'كيف شعرت قبل التمرين؟',
          'كيف شعرت بعد التمرين؟',
          'هل لاحظت أي تغيير في مستوى التوتر؟',
        ],
        createdAt: now,
        updatedAt: now,
      ),
    ];
  }

  TherapyAssessmentModel _getMockAssessment() {
    final now = DateTime.now();
    
    return TherapyAssessmentModel(
      id: 'initial_assessment',
      userId: 'user_123',
      title: 'التقييم الأولي للصحة النفسية',
      description: 'تقييم شامل لتحديد احتياجاتك وتوصية البرامج المناسبة',
      questions: [
        const AssessmentQuestionModel(
          id: 'q1',
          question: 'كيف تصف حالتك النفسية العامة؟',
          type: 'multiple_choice',
          options: ['ممتازة', 'جيدة', 'متوسطة', 'سيئة', 'سيئة جداً'],
        ),
        const AssessmentQuestionModel(
          id: 'q2',
          question: 'ما مدى شعورك بالقلق في الأسبوع الماضي؟',
          type: 'scale',
          minValue: 1,
          maxValue: 10,
        ),
        const AssessmentQuestionModel(
          id: 'q3',
          question: 'هل تواجه صعوبة في النوم؟',
          type: 'yes_no',
        ),
        const AssessmentQuestionModel(
          id: 'q4',
          question: 'ما هي أكبر التحديات التي تواجهها؟',
          type: 'multiple_choice',
          options: ['القلق', 'الاكتئاب', 'التوتر', 'مشاكل النوم', 'العلاقات', 'ضغوط العمل'],
        ),
        const AssessmentQuestionModel(
          id: 'q5',
          question: 'هل سبق لك تجربة العلاج النفسي؟',
          type: 'yes_no',
        ),
        const AssessmentQuestionModel(
          id: 'q6',
          question: 'ما هي أهدافك من استخدام هذا التطبيق؟',
          type: 'text',
        ),
      ],
      recommendedPrograms: [],
      createdAt: now,
      updatedAt: now,
    );
  }
}