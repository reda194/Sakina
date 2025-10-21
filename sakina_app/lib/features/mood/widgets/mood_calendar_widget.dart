import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../models/mood_entry.dart';
import '../../../core/themes/app_theme.dart';

class MoodCalendarWidget extends StatefulWidget {
  final List<MoodEntry> moodEntries;
  final Function(DateTime)? onDateSelected;

  const MoodCalendarWidget({
    super.key,
    required this.moodEntries,
    this.onDateSelected,
  });

  @override
  State<MoodCalendarWidget> createState() => _MoodCalendarWidgetState();
}

class _MoodCalendarWidgetState extends State<MoodCalendarWidget>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  final Map<DateTime, List<MoodEntry>> _moodEvents = {};
  MoodEntry? _selectedDayMood;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _setupAnimations();
    _organizeMoodEvents();
    _updateSelectedDayMood();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  void _organizeMoodEvents() {
    _moodEvents.clear();
    for (var entry in widget.moodEntries) {
      final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      if (_moodEvents[date] != null) {
        _moodEvents[date]!.add(entry);
      } else {
        _moodEvents[date] = [entry];
      }
    }
  }

  void _updateSelectedDayMood() {
    if (_selectedDay != null) {
      final selectedDate = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
      _selectedDayMood = _moodEvents[selectedDate]?.first;
    }
  }

  @override
  void didUpdateWidget(MoodCalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moodEntries != widget.moodEntries) {
      _organizeMoodEvents();
      _updateSelectedDayMood();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCalendarCard(),
            const SizedBox(height: 16),
            if (_selectedDayMood != null)
              _buildSelectedDayDetails(),
            const SizedBox(height: 16),
            _buildMoodLegend(),
            const SizedBox(height: 16),
            _buildMoodStatistics(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calendar header
          Row(
            children: [
              const Icon(
                Icons.calendar_month,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'تقويم المزاج',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              
              // Format toggle
              GestureDetector(
                onTap: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.twoWeeks
                        : CalendarFormat.month;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _calendarFormat == CalendarFormat.month ? 'شهر' : 'أسبوعين',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Calendar
          TableCalendar<MoodEntry>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            startingDayOfWeek: StartingDayOfWeek.saturday,
            
            // Styling
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              weekendTextStyle: TextStyle(color: Colors.red[400]),
              holidayTextStyle: TextStyle(color: Colors.red[400]),
              
              // Today styling
              todayDecoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              
              // Selected day styling
              selectedDecoration: const BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              
              // Marker styling
              markerDecoration: const BoxDecoration(
                color: Colors.transparent,
              ),
            ),
            
            // Header styling
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left),
              rightChevronIcon: Icon(Icons.chevron_right),
            ),
            
            // Day builder for custom mood indicators
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, false);
              },
              todayBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, true, false);
              },
              selectedBuilder: (context, day, focusedDay) {
                return _buildDayCell(day, false, true);
              },
            ),
            
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                _updateSelectedDayMood();
                widget.onDateSelected?.call(selectedDay);
              }
            },
            
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isToday, bool isSelected) {
    final events = _getEventsForDay(day);
    final moodEntry = events.isNotEmpty ? events.first : null;
    
    Color? backgroundColor;
    Color? borderColor;
    Color textColor = Colors.black87;
    
    if (isSelected) {
      backgroundColor = AppTheme.primaryColor;
      textColor = Colors.white;
    } else if (isToday) {
      backgroundColor = AppTheme.primaryColor.withOpacity(0.3);
      borderColor = AppTheme.primaryColor;
    } else if (moodEntry != null) {
      backgroundColor = _getMoodColor(moodEntry.mood.toInt()).withOpacity(0.3);
      borderColor = _getMoodColor(moodEntry.mood.toInt());
    }
    
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: textColor,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          // Mood indicator
          if (moodEntry != null)
            Positioned(
              bottom: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _getMoodColor(moodEntry.mood.toInt()),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayDetails() {
    if (_selectedDayMood == null) return const SizedBox.shrink();

    final mood = _selectedDayMood!;
    final moodData = _getMoodData(mood.mood.toInt());
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            moodData['color'].withOpacity(0.1),
            moodData['color'].withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: moodData['color'].withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                moodData['icon'],
                color: moodData['color'],
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'مزاج ${_selectedDay!.day}/${_selectedDay!.month}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                moodData['name'],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: moodData['color'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Factors
          Row(
            children: [
              _buildFactorChip('طاقة', mood.energyLevel ?? 3, Colors.green),
              const SizedBox(width: 8),
              _buildFactorChip('نوم', mood.sleepQuality ?? 3, Colors.blue),
              const SizedBox(width: 8),
              _buildFactorChip('توتر', mood.anxietyLevel ?? 3, Colors.orange),
            ],
          ),
          
          if (mood.triggers?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: mood.triggers!.map((factor) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    factor,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          
          if (mood.note?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                mood.note!,
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFactorChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مفتاح الألوان',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildLegendItem('ممتاز', Colors.green),
              _buildLegendItem('جيد', Colors.lightGreen),
              _buildLegendItem('عادي', Colors.grey),
              _buildLegendItem('سيء', Colors.orange),
              _buildLegendItem('سيء جداً', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodStatistics() {
    final currentMonth = DateTime(_focusedDay.year, _focusedDay.month);
    final monthEntries = widget.moodEntries.where((entry) {
      return entry.timestamp.year == currentMonth.year &&
             entry.timestamp.month == currentMonth.month;
    }).toList();
    
    if (monthEntries.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'لا توجد بيانات لهذا الشهر',
            style: TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }
    
    final averageMood = monthEntries.map((e) => e.mood.numericValue).reduce((a, b) => a + b) / monthEntries.length;
    final bestDay = monthEntries.reduce((a, b) => a.mood > b.mood ? a : b);
    final worstDay = monthEntries.reduce((a, b) => a.mood < b.mood ? a : b);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'إحصائيات الشهر',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildStatItem(
                'متوسط المزاج',
                averageMood.toStringAsFixed(1),
                Icons.trending_up,
                _getMoodColor(averageMood.round()),
              ),
              _buildStatItem(
                'أيام التتبع',
                '${monthEntries.length}',
                Icons.calendar_today,
                Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildStatItem(
                'أفضل يوم',
                '${bestDay.timestamp.day}/${bestDay.timestamp.month}',
                Icons.sentiment_very_satisfied,
                Colors.green,
              ),
              _buildStatItem(
                'أصعب يوم',
                '${worstDay.timestamp.day}/${worstDay.timestamp.month}',
                Icons.sentiment_dissatisfied,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<MoodEntry> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _moodEvents[normalizedDay] ?? [];
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.lightGreen;
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _getMoodData(int mood) {
    final moods = {
      1: {
        'name': 'سيء جداً',
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.red,
      },
      2: {
        'name': 'سيء',
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orange,
      },
      3: {
        'name': 'عادي',
        'icon': Icons.sentiment_neutral,
        'color': Colors.grey,
      },
      4: {
        'name': 'جيد',
        'icon': Icons.sentiment_satisfied,
        'color': Colors.lightGreen,
      },
      5: {
        'name': 'ممتاز',
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.green,
      },
    };
    
    return moods[mood] ?? moods[3]!;
  }
}