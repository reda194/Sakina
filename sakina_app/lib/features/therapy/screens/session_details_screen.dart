import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_program_model.dart';
import '../../../widgets/loading_button.dart';
import '../providers/therapy_provider.dart';

class SessionDetailsScreen extends StatefulWidget {
  final TherapySessionModel session;
  final TherapyProgramModel program;

  const SessionDetailsScreen({
    super.key,
    required this.session,
    required this.program,
  });

  @override
  State<SessionDetailsScreen> createState() => _SessionDetailsScreenState();
}

class _SessionDetailsScreenState extends State<SessionDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSessionNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadSessionNotes() {
    // Load existing notes for this session
    _notesController.text = widget.session.notes ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.session.isCompleted;
    final canStart = widget.program.currentSessionIndex == widget.session.sessionNumber - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text('الجلسة ${widget.session.sessionNumber}'),
        centerTitle: true,
        actions: [
          if (isCompleted)
            IconButton(
              icon: const Icon(Icons.check_circle, color: AppTheme.successColor),
              onPressed: () {},
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildContentTab(),
                _buildExercisesTab(),
                _buildNotesTab(),
              ],
            ),
          ),
          _buildBottomSection(canStart, isCompleted),
        ],
      ),
      bottomNavigationBar: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            icon: Icon(Icons.article),
            text: 'المحتوى',
          ),
          Tab(
            icon: Icon(Icons.fitness_center),
            text: 'التمارين',
          ),
          Tab(
            icon: Icon(Icons.note),
            text: 'الملاحظات',
          ),
        ],
      ),
    );
  }

  Widget _buildContentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSessionHeader(),
          const SizedBox(height: 24),
          _buildObjectivesSection(),
          const SizedBox(height: 24),
          _buildContentSection(),
          const SizedBox(height: 24),
          _buildKeyPointsSection(),
        ],
      ),
    );
  }

  Widget _buildSessionHeader() {
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
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.session.sessionNumber.toString(),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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
                        widget.session.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.session.durationMinutes} دقيقة',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.session.description,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesSection() {
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
            Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'أهداف الجلسة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.session.objectives.map(
              (objective) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 8),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        objective,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection() {
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
            Row(
              children: [
                const Icon(
                  Icons.menu_book,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'محتوى الجلسة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.session.content.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الجزء ${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              widget.session.content[index],
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.session.content.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppTheme.primaryColor
                        : AppTheme.textSecondary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyPointsSection() {
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
            Row(
              children: [
                const Icon(
                  Icons.lightbulb,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'النقاط الرئيسية',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.session.keyPoints.map(
              (point) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.star,
                      color: AppTheme.warningColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        point,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExercisesTab() {
    final sessionExercises = widget.program.exercises
        .where((exercise) => exercise.sessionId == widget.session.id)
        .toList();

    if (sessionExercises.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد تمارين لهذه الجلسة',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sessionExercises.length,
      itemBuilder: (context, index) {
        final exercise = sessionExercises[index];
        return _buildExerciseCard(exercise);
      },
    );
  }

  Widget _buildExerciseCard(TherapyExerciseModel exercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          _startExercise(exercise);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
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
              const SizedBox(height: 12),
              Text(
                exercise.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: exercise.isCompleted
                          ? null
                          : () => _startExercise(exercise),
                      icon: Icon(
                        exercise.isCompleted ? Icons.check : Icons.play_arrow,
                        size: 16,
                      ),
                      label: Text(
                        exercise.isCompleted ? 'مكتمل' : 'بدء التمرين',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  if (exercise.isCompleted) ...[
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => _repeatExercise(exercise),
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text(
                        'إعادة',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ملاحظاتك الشخصية',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اكتب ملاحظاتك وأفكارك حول هذه الجلسة',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _notesController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'اكتب ملاحظاتك هنا...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveNotes,
              icon: const Icon(Icons.save),
              label: const Text('حفظ الملاحظات'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool canStart, bool isCompleted) {
    if (isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: AppTheme.successColor.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'تم إكمال الجلسة',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (widget.session.completedAt != null)
                    Text(
                      'أكملت في ${_formatDate(widget.session.completedAt!)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: () => _reviewSession(),
              child: const Text('مراجعة'),
            ),
          ],
        ),
      );
    }

    if (!canStart) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.textSecondary.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.lock,
              color: AppTheme.textSecondary,
              size: 24,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'يجب إكمال الجلسات السابقة أولاً',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: AppTheme.textSecondary.withOpacity(0.2),
          ),
        ),
      ),
      child: LoadingButton(
        text: 'بدء الجلسة',
        onPressed: _startSession,
        isLoading: _isLoading,
      ),
    );
  }

  void _startSession() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<TherapyProvider>(context, listen: false);
      await provider.completeSession(
        widget.program.id,
        widget.session.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال الجلسة بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startExercise(TherapyExerciseModel exercise) {
    // Navigate to exercise screen or show exercise dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(exercise.description),
            const SizedBox(height: 16),
            Text(
              'المدة: ${exercise.estimatedDuration.inMinutes} دقيقة',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completeExercise(exercise);
            },
            child: const Text('بدء'),
          ),
        ],
      ),
    );
  }

  void _completeExercise(TherapyExerciseModel exercise) async {
    try {
      final provider = Provider.of<TherapyProvider>(context, listen: false);
      await provider.completeExercise(
        widget.program.id,
        widget.session.id,
        exercise.id,
        userResponse: const {},
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال التمرين بنجاح'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        setState(() {}); // Refresh the UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _repeatExercise(TherapyExerciseModel exercise) {
    _startExercise(exercise);
  }

  void _saveNotes() {
    // Save notes to the session
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ الملاحظات'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }

  void _reviewSession() {
    // Show session review dialog or navigate to review screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مراجعة الجلسة'),
        content: const Text('هل تريد مراجعة محتوى الجلسة مرة أخرى؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _tabController.animateTo(0); // Go to content tab
            },
            child: const Text('مراجعة'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.reading:
        return Icons.menu_book;
      case ExerciseType.writing:
        return Icons.edit;
      case ExerciseType.behavioral:
        return Icons.psychology;
      case ExerciseType.reflection:
        return Icons.insights;
      case ExerciseType.journaling:
        return Icons.book;
      case ExerciseType.relaxation:
        return Icons.spa;
      case ExerciseType.physical:
        return Icons.fitness_center;
      case ExerciseType.breathing:
        return Icons.air;
      case ExerciseType.meditation:
        return Icons.self_improvement;
      case ExerciseType.cognitive:
        return Icons.lightbulb;
      case ExerciseType.mindfulness:
        return Icons.self_improvement;
    }
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.reading:
        return Colors.indigo;
      case ExerciseType.writing:
        return AppTheme.secondaryColor;
      case ExerciseType.breathing:
        return AppTheme.infoColor;
      case ExerciseType.meditation:
        return AppTheme.primaryColor;
      case ExerciseType.cognitive:
        return Colors.orange;
      case ExerciseType.behavioral:
        return Colors.teal;
      case ExerciseType.mindfulness:
        return AppTheme.successColor;
      case ExerciseType.reflection:
        return Colors.blueGrey;
      case ExerciseType.journaling:
        return AppTheme.warningColor;
      case ExerciseType.relaxation:
        return Colors.purple;
      case ExerciseType.physical:
        return Colors.redAccent;
    }
  }

  String _getExerciseTypeText(ExerciseType type) {
    switch (type) {
      case ExerciseType.reading:
        return 'قراءة';
      case ExerciseType.writing:
        return 'كتابة';
      case ExerciseType.breathing:
        return 'تنفس';
      case ExerciseType.meditation:
        return 'تأمل';
      case ExerciseType.cognitive:
        return 'معرفي';
      case ExerciseType.behavioral:
        return 'سلوكي';
      case ExerciseType.mindfulness:
        return 'يقظة';
      case ExerciseType.reflection:
        return 'تأمل ذاتي';
      case ExerciseType.journaling:
        return 'مذكرات';
      case ExerciseType.relaxation:
        return 'استرخاء';
      case ExerciseType.physical:
        return 'بدني';
    }
  }
}