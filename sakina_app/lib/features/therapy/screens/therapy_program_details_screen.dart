import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_program_model.dart';
import '../providers/therapy_provider.dart';
import 'my_programs_screen.dart';

class TherapyProgramDetailsScreen extends StatefulWidget {
  final TherapyProgramModel program;

  const TherapyProgramDetailsScreen({
    super.key,
    required this.program,
  });

  @override
  State<TherapyProgramDetailsScreen> createState() =>
      _TherapyProgramDetailsScreenState();
}

class _TherapyProgramDetailsScreenState
    extends State<TherapyProgramDetailsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.program.title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProgramHeader(),
            const SizedBox(height: 24),
            _buildProgramInfo(),
            const SizedBox(height: 24),
            _buildDescription(),
            const SizedBox(height: 24),
            _buildObjectives(),
            const SizedBox(height: 24),
            _buildSessions(),
            const SizedBox(height: 24),
            _buildRequirements(),
            const SizedBox(height: 24),
            _buildReviews(),
            const SizedBox(height: 100), // Space for floating button
          ],
        ),
      ),
      floatingActionButton: _buildStartButton(),
    );
  }

  Widget _buildProgramHeader() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                _getProgramIcon(widget.program.type),
                color: AppTheme.primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              widget.program.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.star,
                  color: AppTheme.warningColor,
                  size: 20,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.program.rating.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${widget.program.reviewsCount} تقييم)',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            if (widget.program.isPremium) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'برنامج مميز',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgramInfo() {
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
              'معلومات البرنامج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.schedule,
                    'المدة',
                    '${widget.program.durationWeeks} أسبوع',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.play_lesson,
                    'الجلسات',
                    '${widget.program.totalSessions} جلسة',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    Icons.signal_cellular_alt,
                    'المستوى',
                    _getLevelText(widget.program.level),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    Icons.category,
                    'النوع',
                    _getTypeText(widget.program.type),
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
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
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
              'وصف البرنامج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.program.description,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectives() {
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
              'أهداف البرنامج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.program.objectives.map(
              (objective) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
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

  Widget _buildSessions() {
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
                Text(
                  'جلسات البرنامج',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.program.sessions.length} جلسة',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...widget.program.sessions.take(3).map(
              (session) => _buildSessionItem(session),
            ),
            if (widget.program.sessions.length > 3) ...[
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'و ${widget.program.sessions.length - 3} جلسة أخرى...',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSessionItem(TherapySessionModel session) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                session.sessionNumber.toString(),
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
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
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.durationMinutes} دقيقة',
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

  Widget _buildRequirements() {
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
              'متطلبات البرنامج',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...widget.program.requirements.map(
              (requirement) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.successColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        requirement,
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

  Widget _buildReviews() {
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
                Text(
                  'التقييمات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to reviews screen
                  },
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  widget.program.rating.toString(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: List.generate(
                        5,
                        (index) => Icon(
                          index < widget.program.rating.floor()
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.warningColor,
                          size: 16,
                        ),
                      ),
                    ),
                    Text(
                      '${widget.program.reviewsCount} تقييم',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        final isEnrolled = provider.myPrograms
            .any((p) => p.id == widget.program.id);

        return FloatingActionButton.extended(
          onPressed: _isLoading
              ? null
              : () async {
                  if (isEnrolled) {
                    // Navigate to my programs screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyProgramsScreen(
                          program: widget.program,
                        ),
                      ),
                    );
                    return;
                  }

                  setState(() {
                    _isLoading = true;
                  });

                  try {
                    await provider.startProgram(widget.program.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم بدء البرنامج بنجاح'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                      
                      // Navigate to my programs screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyProgramsScreen(
                            program: widget.program,
                          ),
                        ),
                      );
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
                },
          icon: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(isEnrolled ? Icons.play_arrow : Icons.add),
          label: Text(
            isEnrolled ? 'متابعة البرنامج' : 'بدء البرنامج',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  IconData _getProgramIcon(TherapyProgramType type) {
    switch (type) {
      case TherapyProgramType.cbt:
        return Icons.psychology;
      case TherapyProgramType.mindfulness:
        return Icons.self_improvement;
      case TherapyProgramType.anxiety:
        return Icons.healing;
      case TherapyProgramType.depression:
        return Icons.mood;
      case TherapyProgramType.stress:
        return Icons.spa;
      case TherapyProgramType.relationships:
        return Icons.people;
      case TherapyProgramType.selfEsteem:
        return Icons.favorite;
      case TherapyProgramType.sleep:
        return Icons.bedtime;
      case TherapyProgramType.addiction:
        return Icons.block;
      case TherapyProgramType.trauma:
        return Icons.shield;
    }
  }

  String _getLevelText(TherapyProgramLevel level) {
    switch (level) {
      case TherapyProgramLevel.beginner:
        return 'مبتدئ';
      case TherapyProgramLevel.intermediate:
        return 'متوسط';
      case TherapyProgramLevel.advanced:
        return 'متقدم';
    }
  }

  String _getTypeText(TherapyProgramType type) {
    switch (type) {
      case TherapyProgramType.cbt:
        return 'علاج سلوكي معرفي';
      case TherapyProgramType.mindfulness:
        return 'اليقظة الذهنية';
      case TherapyProgramType.anxiety:
        return 'علاج القلق';
      case TherapyProgramType.depression:
        return 'علاج الاكتئاب';
      case TherapyProgramType.stress:
        return 'إدارة التوتر';
      case TherapyProgramType.relationships:
        return 'العلاقات';
      case TherapyProgramType.selfEsteem:
        return 'تقدير الذات';
      case TherapyProgramType.sleep:
        return 'تحسين النوم';
      case TherapyProgramType.addiction:
        return 'علاج الإدمان';
      case TherapyProgramType.trauma:
        return 'علاج الصدمات';
    }
  }
}