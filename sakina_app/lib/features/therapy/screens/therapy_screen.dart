import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/therapy_program_model.dart';
import '../providers/therapy_provider.dart';
import 'therapy_program_details_screen.dart';
import 'assessment_screen.dart';
import 'my_programs_screen.dart';

class TherapyScreen extends StatefulWidget {
  const TherapyScreen({super.key});

  @override
  State<TherapyScreen> createState() => _TherapyScreenState();
}

class _TherapyScreenState extends State<TherapyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TherapyProvider>(context, listen: false);
    await Future.wait([
      provider.loadPrograms(),
      provider.loadMyPrograms(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('برامج العلاج'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'البرامج المتاحة'),
            Tab(text: 'برامجي'),
            Tab(text: 'التقييم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAvailableProgramsTab(),
          _buildMyProgramsTab(),
          _buildAssessmentTab(),
        ],
      ),
    );
  }

  Widget _buildAvailableProgramsTab() {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                Text(
                  provider.error!,
                  style: const TextStyle(
                    color: AppTheme.errorColor,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (provider.programs.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                SizedBox(height: 16),
                Text(
                  'لا توجد برامج متاحة حالياً',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.recommendedPrograms.isNotEmpty) ...[
                  _buildSectionHeader('البرامج الموصى بها'),
                  const SizedBox(height: 12),
                  _buildProgramsList(provider.recommendedPrograms),
                  const SizedBox(height: 24),
                ],
                _buildSectionHeader('جميع البرامج'),
                const SizedBox(height: 12),
                _buildProgramsList(provider.programs),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMyProgramsTab() {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.myPrograms.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'لم تبدأ أي برنامج بعد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ابدأ رحلتك العلاجية من خلال اختيار برنامج مناسب',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    _tabController.animateTo(0);
                  },
                  child: const Text('استكشف البرامج'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.inProgressPrograms.isNotEmpty) ...[
                  _buildSectionHeader('البرامج الجارية'),
                  const SizedBox(height: 12),
                  _buildMyProgramsList(provider.inProgressPrograms),
                  const SizedBox(height: 24),
                ],
                if (provider.completedPrograms.isNotEmpty) ...[
                  _buildSectionHeader('البرامج المكتملة'),
                  const SizedBox(height: 12),
                  _buildMyProgramsList(provider.completedPrograms),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssessmentTab() {
    return Consumer<TherapyProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                              Icons.assessment,
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
                                  'التقييم الأولي',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'احصل على توصيات مخصصة',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'أجب على بعض الأسئلة البسيطة لنتمكن من توصية البرامج العلاجية الأنسب لحالتك واحتياجاتك الشخصية.',
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AssessmentScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'بدء التقييم',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _buildAssessmentBenefits(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildProgramsList(List<TherapyProgramModel> programs) {
    return Column(
      children: programs.map((program) => _buildProgramCard(program)).toList(),
    );
  }

  Widget _buildMyProgramsList(List<TherapyProgramModel> programs) {
    return Column(
      children: programs.map((program) => _buildMyProgramCard(program)).toList(),
    );
  }

  Widget _buildProgramCard(TherapyProgramModel program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TherapyProgramDetailsScreen(
                program: program,
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProgramIcon(program.type),
                      color: AppTheme.primaryColor,
                      size: 28,
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
                                program.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (program.isPremium)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'مميز',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          program.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.schedule,
                    '${program.durationWeeks} أسبوع',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.play_lesson,
                    '${program.totalSessions} جلسة',
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.signal_cellular_alt,
                    _getLevelText(program.level),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.star,
                    color: AppTheme.warningColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    program.rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${program.reviewsCount})',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyProgramCard(TherapyProgramModel program) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyProgramsScreen(
                program: program,
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
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getProgramIcon(program.type),
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program.title,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(program.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getStatusText(program.status),
                            style: TextStyle(
                              color: _getStatusColor(program.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'التقدم',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '${(program.progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: program.progress,
                    backgroundColor: AppTheme.backgroundColor,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${program.currentSessionIndex} من ${program.totalSessions} جلسة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
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

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentBenefits() {
    final benefits = [
      {
        'icon': Icons.psychology,
        'title': 'تحليل شخصي',
        'description': 'تحليل شامل لحالتك النفسية واحتياجاتك',
      },
      {
        'icon': Icons.recommend,
        'title': 'توصيات مخصصة',
        'description': 'برامج علاجية مصممة خصيصاً لك',
      },
      {
        'icon': Icons.track_changes,
        'title': 'متابعة التقدم',
        'description': 'تتبع تطورك وتحسنك عبر الزمن',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'فوائد التقييم',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...benefits.map((benefit) => Padding(
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
                  benefit['icon'] as IconData,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      benefit['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      benefit['description'] as String,
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
        )),
      ],
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
        return 'متوقف';
    }
  }
}
