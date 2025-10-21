import 'package:flutter/material.dart';

class ToolsProvider extends ChangeNotifier {
  bool _isLoading = false;
  List<Tool> _tools = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Tool> get tools => _tools;
  String? get errorMessage => _errorMessage;

  Future<void> loadTools() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // محاكاة تحميل الأدوات
      await Future.delayed(const Duration(seconds: 1));

      _tools = [
        Tool(
          id: '1',
          name: 'تمارين التنفس',
          description: 'تقنيات التنفس العميق للاسترخاء',
          icon: Icons.air,
          category: 'استرخاء',
          duration: 10,
          difficulty: 'سهل',
        ),
        Tool(
          id: '2',
          name: 'التأمل اليومي',
          description: 'جلسات تأمل يومية للهدوء الداخلي',
          icon: Icons.self_improvement,
          category: 'تأمل',
          duration: 15,
          difficulty: 'متوسط',
        ),
        Tool(
          id: '3',
          name: 'يوميات الامتنان',
          description: 'اكتب ما تشعر بالامتنان له يومياً',
          icon: Icons.favorite,
          category: 'كتابة',
          duration: 5,
          difficulty: 'سهل',
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'حدث خطأ في تحميل الأدوات';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class Tool {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final String category;
  final int duration;
  final String difficulty;

  Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    required this.duration,
    required this.difficulty,
  });
}
