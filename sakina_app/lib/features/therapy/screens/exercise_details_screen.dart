import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_model.dart';
import '../providers/therapy_provider.dart';
import '../../../widgets/loading_button.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;
  final String programId;
  final String sessionId;

  const ExerciseDetailsScreen({
    super.key,
    required this.exercise,
    required this.programId,
    required this.sessionId,
  });

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _notesController.text = widget.exercise.userNotes ?? '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.title),
        actions: [
          if (!widget.exercise.isCompleted)
            TextButton(
              onPressed: _isLoading ? null : _completeExercise,
              child: const Text(
                'إكمال',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'التفاصيل'),
            Tab(text: 'التعليمات'),
            Tab(text: 'ملاحظاتي'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          _buildInstructionsTab(),
          _buildNotesTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildDescriptionCard(),
          const SizedBox(height: 16),
          _buildObjectivesCard(),
        ],
      ),
    );
  }

  Widget _buildInstructionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.list_alt,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'تعليمات التمرين',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...widget.exercise.instructions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final instruction = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              instruction,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ),
          if (widget.exercise.tips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'نصائح مفيدة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ...widget.exercise.tips.map((tip) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 6,
                              color: AppTheme.warningColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.note_alt_outlined,
                        color: AppTheme.primaryColor,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'ملاحظاتي الشخصية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اكتب ملاحظاتك وتجربتك مع هذا التمرين',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      hintText: 'اكتب ملاحظاتك هنا...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 8,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveNotes,
                      child: const Text('حفظ الملاحظات'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.exercise.isCompleted && widget.exercise.completedAt != null) ...[
            const SizedBox(height: 16),
            Card(
              color: AppTheme.successColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppTheme.successColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'تم إكمال التمرين',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.successColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تاريخ الإكمال: ${_formatDate(widget.exercise.completedAt!)}',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: widget.exercise.isCompleted
          ? AppTheme.successColor.withOpacity(0.1)
          : AppTheme.primaryColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              widget.exercise.isCompleted
                  ? Icons.check_circle
                  : Icons.play_circle_outline,
              color: widget.exercise.isCompleted
                  ? AppTheme.successColor
                  : AppTheme.primaryColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.isCompleted ? 'مكتمل' : 'جاهز للبدء',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: widget.exercise.isCompleted
                          ? AppTheme.successColor
                          : AppTheme.primaryColor,
                    ),
                  ),
                  if (widget.exercise.isCompleted &&
                      widget.exercise.completedAt != null)
                    Text(
                      'تم الإكمال في ${_formatDate(widget.exercise.completedAt!)}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'معلومات التمرين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.timer,
                    'المدة',
                    '${widget.exercise.duration} دقيقة',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.category,
                    'النوع',
                    _getExerciseTypeText(widget.exercise.type),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.trending_up,
                    'المستوى',
                    _getDifficultyText(widget.exercise.difficulty),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.repeat,
                    'التكرار',
                    widget.exercise.isRepeatable ? 'يمكن تكراره' : 'مرة واحدة',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.description,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'وصف التمرين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.exercise.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectivesCard() {
    if (widget.exercise.objectives.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.flag,
                  color: AppTheme.primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'أهداف التمرين',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.exercise.objectives.map((objective) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 20,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(width: 8),
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
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    if (widget.exercise.isCompleted) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor,
              width: 1,
            ),
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppTheme.successColor,
            ),
            SizedBox(width: 8),
            Text(
              'تم إكمال التمرين بنجاح',
              style: TextStyle(
                color: AppTheme.successColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderColor,
            width: 1,
          ),
        ),
      ),
      child: LoadingButton(
        onPressed: _completeExercise,
        isLoading: _isLoading,
        text: 'إكمال التمرين',
        icon: Icons.check,
      ),
    );
  }

  Future<void> _completeExercise() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<TherapyProvider>(context, listen: false)
          .completeExercise(
        widget.programId,
        widget.sessionId,
        widget.exercise.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إكمال التمرين بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: $e'),
            backgroundColor: Colors.red,
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

  Future<void> _saveNotes() async {
    try {
      await Provider.of<TherapyProvider>(context, listen: false)
          .saveExerciseNotes(
        widget.programId,
        widget.sessionId,
        widget.exercise.id,
        _notesController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ الملاحظات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في حفظ الملاحظات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
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
        return 'وعي تام';
      case ExerciseType.relaxation:
        return 'استرخاء';
      case ExerciseType.cognitive:
        return 'معرفي';
      case ExerciseType.behavioral:
        return 'سلوكي';
      case ExerciseType.physical:
        return 'جسدي';
    }
  }

  String _getDifficultyText(ExerciseDifficulty difficulty) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'مبتدئ';
      case ExerciseDifficulty.intermediate:
        return 'متوسط';
      case ExerciseDifficulty.advanced:
        return 'متقدم';
    }
  }
}