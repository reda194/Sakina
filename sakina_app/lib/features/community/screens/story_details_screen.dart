import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';

class StoryDetailsScreen extends StatefulWidget {
  final SuccessStoryModel story;

  const StoryDetailsScreen({
    super.key,
    required this.story,
  });

  @override
  State<StoryDetailsScreen> createState() => _StoryDetailsScreenState();
}

class _StoryDetailsScreenState extends State<StoryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      provider.incrementStoryViews(widget.story.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: _buildContent(),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getCategoryColor(widget.story.category),
                _getCategoryColor(widget.story.category).withOpacity(0.8),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getCategoryText(widget.story.category),
                      style: TextStyle(
                        color: _getCategoryColor(widget.story.category),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.story.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Icon(
                          widget.story.isAnonymous
                              ? Icons.person
                              : Icons.account_circle,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.story.authorName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatTime(widget.story.createdAt),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
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
        ),
      ),
      actions: [
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                _shareStory();
                break;
              case 'report':
                _reportStory();
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share),
                  SizedBox(width: 8),
                  Text('مشاركة القصة'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'report',
              child: Row(
                children: [
                  Icon(Icons.report, color: AppTheme.errorColor),
                  SizedBox(width: 8),
                  Text('الإبلاغ عن القصة'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummarySection(),
          const SizedBox(height: 24),
          _buildStoryContent(),
          const SizedBox(height: 24),
          _buildStatsSection(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 24),
          _buildRelatedStories(),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
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
            const Row(
              children: [
                Icon(
                  Icons.summarize,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'ملخص القصة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.story.summary,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryContent() {
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
            const Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'القصة كاملة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              widget.story.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.8,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                Icons.favorite,
                'الإعجابات',
                widget.story.likesCount.toString(),
                AppTheme.errorColor,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.visibility,
                'المشاهدات',
                widget.story.viewsCount.toString(),
                AppTheme.primaryColor,
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppTheme.primaryColor.withOpacity(0.2),
            ),
            Expanded(
              child: _buildStatItem(
                Icons.calendar_today,
                'تاريخ النشر',
                _formatDate(widget.story.createdAt),
                AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
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
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTagsSection() {
    if (widget.story.tags.isEmpty) return const SizedBox.shrink();

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
            const Row(
              children: [
                Icon(
                  Icons.tag,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'الكلمات المفتاحية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.story.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '#$tag',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedStories() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final relatedStories = provider.getRelatedSuccessStories(
          widget.story.id,
          widget.story.category,
        );

        if (relatedStories.isEmpty) {
          return const SizedBox.shrink();
        }

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
                const Row(
                  children: [
                    Icon(
                      Icons.recommend,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'قصص مشابهة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...relatedStories.take(3).map((story) {
                  return _buildRelatedStoryItem(story);
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRelatedStoryItem(SuccessStoryModel story) {
    return InkWell(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => StoryDetailsScreen(story: story),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getCategoryColor(story.category).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories,
                color: _getCategoryColor(story.category),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    story.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    story.summary,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            border: Border(
              top: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => provider.likeSuccessStory(widget.story.id),
                    icon: Icon(
                      widget.story.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.story.isLiked
                          ? Colors.white
                          : AppTheme.errorColor,
                    ),
                    label: Text(
                      widget.story.isLiked ? 'تم الإعجاب' : 'أعجبني',
                      style: TextStyle(
                        color: widget.story.isLiked
                            ? Colors.white
                            : AppTheme.errorColor,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.story.isLiked
                          ? AppTheme.errorColor
                          : Colors.transparent,
                      foregroundColor: widget.story.isLiked
                          ? Colors.white
                          : AppTheme.errorColor,
                      side: const BorderSide(
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _shareStory,
                  icon: const Icon(Icons.share),
                  label: const Text('مشاركة'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _shareStory() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المشاركة قيد التطوير'),
      ),
    );
  }

  void _reportStory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن القصة'),
        content: const Text('هل أنت متأكد من رغبتك في الإبلاغ عن هذه القصة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم الإبلاغ عن القصة'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('إبلاغ'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _getCategoryText(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return 'التعافي';
      case StoryCategory.therapy:
        return 'العلاج';
      case StoryCategory.relationships:
        return 'العلاقات';
      case StoryCategory.career:
        return 'المهنة';
      case StoryCategory.personal:
        return 'شخصي';
      case StoryCategory.health:
        return 'الصحة';
      case StoryCategory.education:
        return 'التعليم';
      case StoryCategory.family:
        return 'الأسرة';
      case StoryCategory.selfCare:
        return 'العناية بالذات';
    }
  }

  Color _getCategoryColor(StoryCategory category) {
    switch (category) {
      case StoryCategory.recovery:
        return AppTheme.successColor;
      case StoryCategory.therapy:
        return AppTheme.primaryColor;
      case StoryCategory.relationships:
        return Colors.pink;
      case StoryCategory.career:
        return Colors.orange;
      case StoryCategory.personal:
        return Colors.purple;
      case StoryCategory.health:
        return Colors.green;
      case StoryCategory.education:
        return Colors.blue;
      case StoryCategory.family:
        return Colors.teal;
      case StoryCategory.selfCare:
        return Colors.indigo;
    }
  }
}