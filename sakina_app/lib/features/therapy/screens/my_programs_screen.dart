import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_program_model.dart';
import '../providers/therapy_provider.dart';
import 'session_details_screen.dart';

class MyProgramsScreen extends StatefulWidget {
  final TherapyProgramModel program;

  const MyProgramsScreen({
    super.key,
    required this.program,
  });

  @override
  State<MyProgramsScreen> createState() => _MyProgramsScreenState();
}

class _MyProgramsScreenState extends State<MyProgramsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: Text(widget.program.title),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'نظرة عامة'),
            Tab(text: 'الجلسات'),
            Tab(text: 'التمارين'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              _handleMenuAction(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'pause',
                child: Row(
                  children: [
                    Icon(Icons.pause),
                    SizedBox(width: 8),
                    Text('إيقاف مؤقت'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'restart',
                child: Row(
                  children: [
                    Icon(Icons.restart_alt),
                    SizedBox(width: 8),
                    Text('إعادة البدء'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildSessionsTab(),
          _buildExercisesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressCard(),
          const SizedBox(height: 16),
          _buildStatsCard(),
          const SizedBox(height: 16),
          _buildNextSessionCard(),
          const SizedBox(height: 16),
          _buildRecentActivityCard(),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تقدمك في البرنامج',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getStatusText(widget.program.status),
                        style: TextStyle(
                          color: _getStatusColor(widget.program.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(widget.program.progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: widget.program.progress,
              backgroundColor: AppTheme.backgroundColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الجلسة ${widget.program.currentSessionIndex}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${widget.program.totalSessions} جلسة',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'إحصائيات',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.calendar_today,
                    'أيام متتالية',
                    '7',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.timer,
                    'إجمالي الوقت',
                    '${widget.program.currentSessionIndex * 30} دقيقة',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.check_circle,
                    'جلسات مكتملة',
                    '${widget.program.currentSessionIndex}',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.fitness_center,
                    'تمارين مكتملة',
                    '${widget.program.exercises.where((e) => e.isCompleted).length}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNextSessionCard() {
    if (widget.program.currentSessionIndex >= widget.program.sessions.length) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(
                Icons.celebration,
                color: AppTheme.successColor,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'تهانينا! لقد أكملت البرنامج',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final nextSession = widget.program.sessions[widget.program.currentSessionIndex];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SessionDetailsScreen(
                session: nextSession,
                program: widget.program,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'الجلسة التالية',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        nextSession.sessionNumber.toString(),
                        style: const TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nextSession.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${nextSession.durationMinutes} دقيقة',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'النشاط الأخير',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              _buildActivityItem(
                Icons.play_circle,
                'أكملت الجلسة ${widget.program.currentSessionIndex}',
                'منذ يومين',
              ),
              _buildActivityItem(
                Icons.fitness_center,
                'أكملت تمرين التنفس',
                'منذ 3 أيام',
              ),
              _buildActivityItem(
                Icons.note_add,
                'أضفت ملاحظة جديدة',
                'منذ أسبوع',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.program.sessions.length,
      itemBuilder: (context, index) {
        final session = widget.program.sessions[index];
        final isCompleted = index < widget.program.currentSessionIndex;
        final isCurrent = index == widget.program.currentSessionIndex;
        final isLocked = index > widget.program.currentSessionIndex;

        return _buildSessionCard(session, isCompleted, isCurrent, isLocked);
      },
    );
  }

  Widget _buildSessionCard(
    TherapySessionModel session,
    bool isCompleted,
    bool isCurrent,
    bool isLocked,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrent ? 2 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isCurrent
            ? const BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: isLocked
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SessionDetailsScreen(
                      session: session,
                      program: widget.program,
                    ),
                  ),
                );
              },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successColor.withOpacity(0.1)
                      : isCurrent
                          ? AppTheme.primaryColor.withOpacity(0.1)
                          : AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          color: AppTheme.successColor,
                          size: 24,
                        )
                      : isLocked
                          ? const Icon(
                              Icons.lock,
                              color: AppTheme.textSecondary,
                              size: 20,
                            )
                          : Text(
                              session.sessionNumber.toString(),
                              style: TextStyle(
                                color: isCurrent
                                    ? AppTheme.primaryColor
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isLocked
                            ? AppTheme.textSecondary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${session.durationMinutes} دقيقة',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'الحالية',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLocked)
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExercisesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.program.exercises.length,
      itemBuilder: (context, index) {
        final exercise = widget.program.exercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(TherapyExerciseModel exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to exercise details
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: exercise.isCompleted
                      ? AppTheme.successColor.withOpacity(0.1)
                      : AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getExerciseIcon(exercise.type),
                  color: exercise.isCompleted
                      ? AppTheme.successColor
                      : AppTheme.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            exercise.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (exercise.isCompleted)
                          const Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.description,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exercise.durationMinutes} دقيقة',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getExerciseTypeColor(exercise.type).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _getExerciseTypeText(exercise.type),
                            style: TextStyle(
                              color: _getExerciseTypeColor(exercise.type),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final provider = Provider.of<TherapyProvider>(context, listen: false);

    switch (action) {
      case 'pause':
        provider.pauseProgram(widget.program.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إيقاف البرنامج مؤقتاً'),
            backgroundColor: AppTheme.warningColor,
          ),
        );
        break;
      case 'restart':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('إعادة بدء البرنامج'),
            content: const Text(
              'هل أنت متأكد من رغبتك في إعادة بدء البرنامج من البداية؟ سيتم فقدان التقدم الحالي.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  provider.restartProgram(widget.program.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم إعادة بدء البرنامج'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                },
                child: const Text('إعادة البدء'),
              ),
            ],
          ),
        );
        break;
    }
  }

  Color _getStatusColor(TherapyProgramStatus status) {
    switch (status) {
      case TherapyProgramStatus.notStarted:
        return AppTheme.textSecondary;
      case TherapyProgramStatus.inProgress:
        return AppTheme.infoColor;
      case TherapyProgramStatus.completed:
        return AppTheme.successColor;
      case TherapyProgramStatus.paused:
        return AppTheme.warningColor;
    }
  }

  String _getStatusText(TherapyProgramStatus status) {
    switch (status) {
      case TherapyProgramStatus.notStarted:
        return 'لم يبدأ';
      case TherapyProgramStatus.inProgress:
        return 'جاري';
      case TherapyProgramStatus.completed:
        return 'مكتمل';
      case TherapyProgramStatus.paused:
        return 'متوقف مؤقتاً';
    }
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.breathing:
        return Icons.air;
      case ExerciseType.meditation:
        return Icons.self_improvement;
      case ExerciseType.journaling:
        return Icons.edit_note;
      case ExerciseType.mindfulness:
        return Icons.psychology;
      case ExerciseType.relaxation:
        return Icons.spa;
      case ExerciseType.cognitive:
        return Icons.lightbulb;
      case ExerciseType.reading:
        return Icons.menu_book;
      case ExerciseType.writing:
        return Icons.edit;
      case ExerciseType.behavioral:
        return Icons.track_changes;
      case ExerciseType.reflection:
        return Icons.visibility;
      case ExerciseType.physical:
        return Icons.fitness_center;
    }
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.breathing:
        return AppTheme.infoColor;
      case ExerciseType.meditation:
        return AppTheme.primaryColor;
      case ExerciseType.journaling:
        return AppTheme.warningColor;
      case ExerciseType.mindfulness:
        return AppTheme.successColor;
      case ExerciseType.relaxation:
        return Colors.purple;
      case ExerciseType.cognitive:
        return Colors.orange;
      case ExerciseType.reading:
        return Colors.blue;
      case ExerciseType.writing:
        return AppTheme.warningColor;
      case ExerciseType.behavioral:
        return Colors.green;
      case ExerciseType.reflection:
        return Colors.indigo;
      case ExerciseType.physical:
        return Colors.red;
    }
  }

  String _getExerciseTypeText(ExerciseType type) {
    switch (type) {
      case ExerciseType.breathing:
        return 'تنفس';
      case ExerciseType.meditation:
        return 'تأمل';
      case ExerciseType.journaling:
        return 'كتابة';
      case ExerciseType.mindfulness:
        return 'يقظة';
      case ExerciseType.relaxation:
        return 'استرخاء';
      case ExerciseType.cognitive:
        return 'معرفي';
      case ExerciseType.reading:
        return 'قراءة';
      case ExerciseType.writing:
        return 'كتابة';
      case ExerciseType.behavioral:
        return 'سلوكي';
      case ExerciseType.reflection:
        return 'تأمل';
      case ExerciseType.physical:
        return 'جسدي';
    }
  }
}