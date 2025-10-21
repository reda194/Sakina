import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/mood_entry.dart';
import '../providers/mood_provider.dart';
import '../../../widgets/loading_button.dart';

class MoodTrackerScreen extends StatefulWidget {
  const MoodTrackerScreen({super.key});

  @override
  State<MoodTrackerScreen> createState() => _MoodTrackerScreenState();
}

class _MoodTrackerScreenState extends State<MoodTrackerScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedPeriod = 0; // 0: Week, 1: Month, 2: Year

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع المزاج'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddMoodDialog(context),
          ),
        ],
      ),
      body: Consumer<MoodProvider>(
        builder: (context, moodProvider, child) {
          if (moodProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period Selector
                _buildPeriodSelector(),

                // Stats Cards
                _buildStatsCards(moodProvider),

                // Chart Section
                _buildChartSection(moodProvider),

                // Recent Entries
                _buildRecentEntries(moodProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('أسبوع')),
                ButtonSegment(value: 1, label: Text('شهر')),
                ButtonSegment(value: 2, label: Text('سنة')),
              ],
              selected: {_selectedPeriod},
              onSelectionChanged: (Set<int> selection) {
                setState(() {
                  _selectedPeriod = selection.first;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(MoodProvider moodProvider) {
    final entries = _getEntriesForPeriod(moodProvider);
    final averageMood = moodProvider.getAverageMood(entries);
    final trend = moodProvider.getMoodTrend();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'المتوسط',
              value: averageMood != null ? averageMood.toStringAsFixed(1) : '-',
              icon: Icons.trending_up,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'الاتجاه',
              value: trend,
              icon: Icons.timeline,
              color: _getTrendColor(trend),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'الإدخالات',
              value: entries.length.toString(),
              icon: Icons.edit_note,
              color: AppTheme.successColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(MoodProvider moodProvider) {
    final entries = _getEntriesForPeriod(moodProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اتجاه المزاج',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildLineChart(entries),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart(List<MoodEntry> entries) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('لا توجد بيانات كافية لعرض الرسم البياني'),
      );
    }

    final spots = entries.reversed.toList().asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.mood.toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= entries.length) return const Text('');
                final entry = entries.reversed.toList()[value.toInt()];
                return Text(
                  DateFormat('MM/dd').format(entry.timestamp),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 1:
                    return const Text('😢');
                  case 2:
                    return const Text('😔');
                  case 3:
                    return const Text('😐');
                  case 4:
                    return const Text('🙂');
                  case 5:
                    return const Text('😊');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: spots.length.toDouble() - 1,
        minY: 1,
        maxY: 5,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppTheme.primaryColor,
            barWidth: 3,
            isStrokeCapRound: true,
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
            belowBarData: BarAreaData(
              show: true,
              color: AppTheme.primaryColor.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentEntries(MoodProvider moodProvider) {
    final recentEntries = moodProvider.moodEntries.take(5).toList();

    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإدخالات الأخيرة',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...recentEntries.map((entry) => _buildEntryCard(entry)),
        ],
      ),
    );
  }

  Widget _buildEntryCard(MoodEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text(
            entry.moodEmoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.moodText,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  DateFormat('yyyy/MM/dd - HH:mm').format(entry.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                if (entry.note != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    entry.note!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MoodEntry> _getEntriesForPeriod(MoodProvider moodProvider) {
    switch (_selectedPeriod) {
      case 0:
        return moodProvider.weekEntries;
      case 1:
        return moodProvider.monthEntries;
      case 2:
        return moodProvider.moodEntries;
      default:
        return moodProvider.weekEntries;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'متحسن':
        return AppTheme.successColor;
      case 'متراجع':
        return AppTheme.errorColor;
      default:
        return AppTheme.warningColor;
    }
  }

  void _showAddMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddMoodDialog(),
    );
  }
}

class AddMoodDialog extends StatefulWidget {
  const AddMoodDialog({super.key});

  @override
  State<AddMoodDialog> createState() => _AddMoodDialogState();
}

class _AddMoodDialogState extends State<AddMoodDialog> {
  int? _selectedMood;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('كيف تشعر الآن؟'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mood selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMoodOption(1, '😢', 'سيء جداً'),
              _buildMoodOption(2, '😔', 'سيء'),
              _buildMoodOption(3, '😐', 'عادي'),
              _buildMoodOption(4, '🙂', 'جيد'),
              _buildMoodOption(5, '😊', 'ممتاز'),
            ],
          ),
          const SizedBox(height: 20),
          // Note input
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'ملاحظة (اختيارية)',
              hintText: 'كيف كان يومك؟',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء'),
        ),
        LoadingButton(
          text: 'حفظ',
          isLoading: false,
          width: 80,
          height: 40,
          onPressed: _selectedMood != null ? _saveMood : null,
        ),
      ],
    );
  }

  Widget _buildMoodOption(int value, String emoji, String label) {
    final isSelected = _selectedMood == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMood = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(isSelected ? 12 : 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              emoji,
              style: TextStyle(fontSize: isSelected ? 32 : 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _saveMood() async {
    if (_selectedMood == null) return;

    final moodProvider = Provider.of<MoodProvider>(context, listen: false);
    final entry = MoodEntry(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      mood: MoodType.fromNumeric(_selectedMood!),
      note: _noteController.text.isNotEmpty ? _noteController.text : null,
      timestamp: DateTime.now(),
      userId: 'current_user', // TODO: Get actual user ID
    );

    final success = await moodProvider.saveMoodEntry(entry);
    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ مزاجك بنجاح'),
          backgroundColor: AppTheme.successColor,
        ),
      );
    }
  }
}
