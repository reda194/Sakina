import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';

class MoodTrackerCard extends StatefulWidget {
  const MoodTrackerCard({super.key});

  @override
  State<MoodTrackerCard> createState() => _MoodTrackerCardState();
}

class _MoodTrackerCardState extends State<MoodTrackerCard> {
  int? _selectedMood;

  final List<MoodOption> _moods = [
    MoodOption(
      emoji: '😊',
      label: 'ممتاز',
      color: AppTheme.moodExcellent,
      value: 5,
    ),
    MoodOption(
      emoji: '🙂',
      label: 'جيد',
      color: AppTheme.moodGood,
      value: 4,
    ),
    MoodOption(
      emoji: '😐',
      label: 'عادي',
      color: AppTheme.moodNeutral,
      value: 3,
    ),
    MoodOption(
      emoji: '😔',
      label: 'سيء',
      color: AppTheme.moodBad,
      value: 2,
    ),
    MoodOption(
      emoji: '😢',
      label: 'سيء جداً',
      color: AppTheme.moodTerrible,
      value: 1,
    ),
  ];

  void _saveMood() {
    if (_selectedMood != null) {
      // TODO: Save mood to database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حفظ حالتك المزاجية'),
          backgroundColor: AppTheme.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      setState(() {
        _selectedMood = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor.withOpacity(0.8),
            AppTheme.primaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'كيف تشعر الآن؟',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'سجل مزاجك اليومي',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              if (_selectedMood != null)
                ElevatedButton(
                  onPressed: _saveMood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  child: const Text('حفظ'),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _moods.map((mood) {
              final isSelected = _selectedMood == mood.value;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood.value;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(isSelected ? 12 : 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withOpacity(0.3)
                        : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withOpacity(0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        mood.emoji,
                        style: TextStyle(
                          fontSize: isSelected ? 32 : 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSelected ? 12 : 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class MoodOption {
  final String emoji;
  final String label;
  final Color color;
  final int value;

  MoodOption({
    required this.emoji,
    required this.label,
    required this.color,
    required this.value,
  });
}
