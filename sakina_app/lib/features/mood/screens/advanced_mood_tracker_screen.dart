import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/themes/app_theme.dart';
import '../providers/mood_provider.dart';
import '../../../models/mood_entry.dart';
import '../widgets/mood_insights_widget.dart';
import '../widgets/mood_calendar_widget.dart';

class AdvancedMoodTrackerScreen extends StatefulWidget {
  const AdvancedMoodTrackerScreen({super.key});

  @override
  State<AdvancedMoodTrackerScreen> createState() => _AdvancedMoodTrackerScreenState();
}

class _AdvancedMoodTrackerScreenState extends State<AdvancedMoodTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  int _selectedMood = 3;
  int _energyLevel = 3;
  int _sleepQuality = 3;
  int _stressLevel = 3;
  final List<String> _selectedFactors = [];
  String _notes = '';
  
  final PageController _pageController = PageController();
  final int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('تتبع المزاج المتقدم'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.add_circle_outline), text: 'تسجيل'),
            Tab(icon: Icon(Icons.timeline), text: 'التقدم'),
            Tab(icon: Icon(Icons.calendar_month), text: 'التقويم'),
            Tab(icon: Icon(Icons.insights), text: 'الرؤى'),
          ],
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildTrackingTab(),
            _buildProgressTab(),
            _buildCalendarTab(),
            _buildInsightsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCurrentMoodCard(),
          const SizedBox(height: 16),
          _buildMoodSelector(),
          const SizedBox(height: 16),
          _buildFactorsSection(),
          const SizedBox(height: 16),
          _buildNotesSection(),
          const SizedBox(height: 24),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildCurrentMoodCard() {
    final moodData = _getMoodData(_selectedMood);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
        children: [
          Icon(
            moodData['icon'],
            size: 60,
            color: moodData['color'],
          ),
          const SizedBox(height: 12),
          Text(
            moodData['name'],
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: moodData['color'],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            moodData['description'],
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
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
            'كيف تشعر الآن؟',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mood scale
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final moodValue = index + 1;
              final moodData = _getMoodData(moodValue);
              final isSelected = _selectedMood == moodValue;
              
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = moodValue),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? moodData['color'].withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? Border.all(color: moodData['color'])
                        : null,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        moodData['icon'],
                        size: isSelected ? 32 : 28,
                        color: moodData['color'],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        moodData['name'],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: moodData['color'],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection() {
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
            'العوامل المؤثرة',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Energy Level
          _buildFactorSlider(
            'مستوى الطاقة',
            Icons.battery_charging_full,
            _energyLevel,
            Colors.green,
            (value) => setState(() => _energyLevel = value),
          ),
          const SizedBox(height: 16),
          
          // Sleep Quality
          _buildFactorSlider(
            'جودة النوم',
            Icons.bedtime,
            _sleepQuality,
            Colors.blue,
            (value) => setState(() => _sleepQuality = value),
          ),
          const SizedBox(height: 16),
          
          // Stress Level
          _buildFactorSlider(
            'مستوى التوتر',
            Icons.psychology,
            _stressLevel,
            Colors.orange,
            (value) => setState(() => _stressLevel = value),
          ),
          const SizedBox(height: 20),
          
          // Activity factors
          const Text(
            'الأنشطة والعوامل',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildActivityFactors(),
        ],
      ),
    );
  }

  Widget _buildFactorSlider(
    String title,
    IconData icon,
    int value,
    Color color,
    Function(int) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              _getFactorLabel(value),
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        Row(
          children: List.generate(5, (index) {
            final isSelected = index < value;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index + 1),
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color 
                        : color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildActivityFactors() {
    final factors = [
      {'name': 'تمرين رياضي', 'icon': Icons.fitness_center, 'color': Colors.red},
      {'name': 'تأمل', 'icon': Icons.self_improvement, 'color': Colors.purple},
      {'name': 'وقت مع الأصدقاء', 'icon': Icons.people, 'color': Colors.blue},
      {'name': 'عمل', 'icon': Icons.work, 'color': Colors.orange},
      {'name': 'طبيعة', 'icon': Icons.nature, 'color': Colors.green},
      {'name': 'قراءة', 'icon': Icons.book, 'color': Colors.brown},
      {'name': 'موسيقى', 'icon': Icons.music_note, 'color': Colors.pink},
      {'name': 'طعام صحي', 'icon': Icons.restaurant, 'color': Colors.teal},
    ];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: factors.map((factor) {
        final isSelected = _selectedFactors.contains(factor['name']);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedFactors.remove(factor['name']);
              } else {
                _selectedFactors.add(factor['name'] as String);
              }
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? (factor['color'] as Color).withOpacity(0.2)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: isSelected 
                  ? Border.all(color: factor['color'] as Color)
                  : Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  factor['icon'] as IconData,
                  size: 16,
                  color: factor['color'] as Color,
                ),
                const SizedBox(width: 6),
                Text(
                  factor['name'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: factor['color'] as Color,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNotesSection() {
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
            'ملاحظات إضافية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          TextField(
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'اكتب أي ملاحظات أو تفاصيل إضافية عن مزاجك اليوم...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTheme.primaryColor),
              ),
            ),
            onChanged: (value) => _notes = value,
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saveMoodEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'حفظ تسجيل المزاج',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMoodTrendChart(moodProvider),
              const SizedBox(height: 16),
              _buildFactorsTrendChart(moodProvider),
              const SizedBox(height: 16),
              _buildWeeklyProgress(moodProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalendarTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return MoodCalendarWidget(
          moodEntries: moodProvider.moodEntries,
          onDateSelected: (date) {
            // Show mood details for selected date
          },
        );
      },
    );
  }

  Widget _buildInsightsTab() {
    return Consumer<MoodProvider>(
      builder: (context, moodProvider, child) {
        return MoodInsightsWidget(
          moodEntries: moodProvider.moodEntries,
        );
      },
    );
  }

  Widget _buildMoodTrendChart(MoodProvider moodProvider) {
    final entries = moodProvider.moodEntries.take(7).toList();
    
    return Container(
      height: 200,
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
            'اتجاه المزاج - آخر 7 أيام',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final days = ['س', 'أ', 'ث', 'أ', 'خ', 'ج', 'س'];
                        if (value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(7, (index) {
                      final mood = index < entries.length 
                          ? entries[index].mood.toDouble()
                          : 3.0;
                      return FlSpot(index.toDouble(), mood);
                    }),
                    isCurved: true,
                    color: AppTheme.primaryColor,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppTheme.primaryColor,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsTrendChart(MoodProvider moodProvider) {
    return Container(
      height: 200,
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
            'العوامل المؤثرة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: Row(
              children: [
                _buildFactorBar('طاقة', Colors.green, 0.8),
                _buildFactorBar('نوم', Colors.blue, 0.6),
                _buildFactorBar('توتر', Colors.orange, 0.4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorBar(String label, Color color, double value) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 20,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: value,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgress(MoodProvider moodProvider) {
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
            'التقدم الأسبوعي',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              _buildProgressItem('متوسط المزاج', '4.2', Icons.mood, Colors.green),
              _buildProgressItem('أيام التتبع', '6/7', Icons.calendar_today, Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              _buildProgressItem('تحسن', '+15%', Icons.trending_up, Colors.orange),
              _buildProgressItem('الهدف', '85%', Icons.flag, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String label, String value, IconData icon, Color color) {
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getMoodData(int mood) {
    final moods = {
      1: {
        'name': 'سيء جداً',
        'icon': Icons.sentiment_very_dissatisfied,
        'color': Colors.red,
        'description': 'أشعر بحالة سيئة جداً',
      },
      2: {
        'name': 'سيء',
        'icon': Icons.sentiment_dissatisfied,
        'color': Colors.orange,
        'description': 'أشعر بحالة سيئة',
      },
      3: {
        'name': 'عادي',
        'icon': Icons.sentiment_neutral,
        'color': Colors.grey,
        'description': 'أشعر بحالة عادية',
      },
      4: {
        'name': 'جيد',
        'icon': Icons.sentiment_satisfied,
        'color': Colors.lightGreen,
        'description': 'أشعر بحالة جيدة',
      },
      5: {
        'name': 'ممتاز',
        'icon': Icons.sentiment_very_satisfied,
        'color': Colors.green,
        'description': 'أشعر بحالة ممتازة',
      },
    };
    
    return moods[mood] ?? moods[3]!;
  }

  String _getFactorLabel(int value) {
    final labels = ['ضعيف', 'منخفض', 'متوسط', 'جيد', 'ممتاز'];
    return labels[value - 1];
  }

  void _saveMoodEntry() {
    final entry = MoodEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user', // TODO: Get from auth provider
      mood: MoodType.fromNumeric(_selectedMood),
      energyLevel: _energyLevel,
      sleepQuality: _sleepQuality,
      anxietyLevel: _stressLevel,
      triggers: _selectedFactors,
      note: _notes,
      timestamp: DateTime.now(),
    );
    
    Provider.of<MoodProvider>(context, listen: false).addMoodEntry(entry);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ تسجيل المزاج بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Reset form
    setState(() {
      _selectedMood = 3;
      _energyLevel = 3;
      _sleepQuality = 3;
      _stressLevel = 3;
      _selectedFactors.clear();
      _notes = '';
    });
  }
}