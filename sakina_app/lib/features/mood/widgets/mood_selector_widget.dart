import 'package:flutter/material.dart';
import '../../../models/mood_entry.dart';
import '../../../core/themes/app_theme.dart';

/// Extension to provide UI properties for MoodType enum
extension MoodTypeExtension on MoodType {
  /// Get the icon for this mood type
  IconData get icon {
    switch (this) {
      case MoodType.veryBad:
        return Icons.sentiment_very_dissatisfied;
      case MoodType.bad:
        return Icons.sentiment_dissatisfied;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.good:
        return Icons.sentiment_satisfied;
      case MoodType.excellent:
        return Icons.sentiment_very_satisfied;
    }
  }

  /// Get the color for this mood type
  Color get color {
    switch (this) {
      case MoodType.veryBad:
        return Colors.red;
      case MoodType.bad:
        return Colors.orange;
      case MoodType.neutral:
        return Colors.grey;
      case MoodType.good:
        return Colors.lightGreen;
      case MoodType.excellent:
        return Colors.green;
    }
  }

  /// Get the Arabic name for this mood type
  String get arabicName {
    switch (this) {
      case MoodType.veryBad:
        return 'سيء جداً';
      case MoodType.bad:
        return 'سيء';
      case MoodType.neutral:
        return 'عادي';
      case MoodType.good:
        return 'جيد';
      case MoodType.excellent:
        return 'ممتاز';
    }
  }

  /// Get the description for this mood type
  String get description {
    switch (this) {
      case MoodType.veryBad:
        return 'أشعر بحالة سيئة جداً';
      case MoodType.bad:
        return 'أشعر بحالة سيئة';
      case MoodType.neutral:
        return 'أشعر بحالة عادية';
      case MoodType.good:
        return 'أشعر بحالة جيدة';
      case MoodType.excellent:
        return 'أشعر بحالة ممتازة';
    }
  }
}

/// A reusable widget for selecting mood values
///
/// Provides an interactive UI for selecting from 5 mood options
/// with visual feedback, animations, and proper Arabic RTL support.
class MoodSelectorWidget extends StatelessWidget {
  /// The currently selected mood
  final MoodType selectedMood;

  /// Callback when a mood is selected
  final ValueChanged<MoodType> onMoodSelected;

  /// Whether to show mood labels below icons
  final bool showLabels;

  const MoodSelectorWidget({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowLight,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'كيف تشعر الآن؟',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          // Mood scale with 5 options
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: MoodType.values.map((mood) {
              final isSelected = selectedMood == mood;

              return _MoodOption(
                mood: mood,
                isSelected: isSelected,
                showLabel: showLabels,
                onTap: () {
                  // Haptic feedback
                  _triggerHapticFeedback();
                  onMoodSelected(mood);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _triggerHapticFeedback() {
    // Light haptic feedback on selection
    // Note: Requires import of 'package:flutter/services.dart' and HapticFeedback.lightImpact()
    // Commenting out for now as it's optional
    // HapticFeedback.lightImpact();
  }
}

/// Individual mood option widget with animation
class _MoodOption extends StatelessWidget {
  final MoodType mood;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _MoodOption({
    required this.mood,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'مزاج ${mood.arabicName}',
      selected: isSelected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(12),
          constraints: const BoxConstraints(
            minWidth: 48,
            minHeight: 48,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? mood.color.withOpacity(0.2)
                : AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: mood.color, width: 2)
                : Border.all(color: AppTheme.borderColor, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with scale animation
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  mood.icon,
                  size: isSelected ? 32 : 28,
                  color: mood.color,
                ),
              ),

              // Label (if enabled)
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  mood.arabicName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: mood.color,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
