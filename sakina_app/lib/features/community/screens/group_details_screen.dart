import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import '../../../widgets/loading_button.dart';

class GroupDetailsScreen extends StatefulWidget {
  final SupportGroupModel group;

  const GroupDetailsScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      provider.loadGroupPosts(widget.group.id);
      provider.loadGroupMembers(widget.group.id);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildGroupHeader(),
              ),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'share':
                        _shareGroup();
                        break;
                      case 'report':
                        _reportGroup();
                        break;
                      case 'leave':
                        _leaveGroup();
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
                          Text('مشاركة المجموعة'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.report, color: AppTheme.errorColor),
                          SizedBox(width: 8),
                          Text('الإبلاغ عن المجموعة'),
                        ],
                      ),
                    ),
                    if (widget.group.isJoined)
                      const PopupMenuItem(
                        value: 'leave',
                        child: Row(
                          children: [
                            Icon(Icons.exit_to_app, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('مغادرة المجموعة'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(
                TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'المنشورات'),
                    Tab(text: 'الأعضاء'),
                  ],
                ),
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildOverviewTab(),
            _buildPostsTab(),
            _buildMembersTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildGroupHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _getGroupTypeColor(widget.group.type).withOpacity(0.8),
            _getGroupTypeColor(widget.group.type),
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
              Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _getGroupTypeIcon(widget.group.type),
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getGroupTypeText(widget.group.type),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.white.withOpacity(0.9),
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${widget.group.membersCount} عضو',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 16),
                            if (widget.group.privacy == GroupPrivacy.private)
                              Icon(
                                Icons.lock,
                                color: Colors.white.withOpacity(0.9),
                                size: 16,
                              ),
                          ],
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

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildRulesSection(),
          const SizedBox(height: 24),
          _buildTagsSection(),
          const SizedBox(height: 24),
          _buildStatsSection(),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
            const Text(
              'وصف المجموعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.group.description,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRulesSection() {
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
                  Icons.rule,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'قوانين المجموعة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...widget.group.rules.rules.asMap().entries.map((entry) {
              final index = entry.key;
              final rule = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTagsSection() {
    if (widget.group.tags.isEmpty) return const SizedBox.shrink();

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
            const Text(
              'المواضيع',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.group.tags.map((tag) {
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

  Widget _buildStatsSection() {
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
            const Text(
              'إحصائيات المجموعة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    Icons.people,
                    'الأعضاء',
                    widget.group.membersCount.toString(),
                    AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.article,
                    'المنشورات',
                    widget.group.postsCount.toString(),
                    AppTheme.successColor,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    Icons.calendar_today,
                    'تم الإنشاء',
                    _formatDate(widget.group.createdAt),
                    AppTheme.textSecondary,
                  ),
                ),
              ],
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
            fontSize: 18,
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
        ),
      ],
    );
  }

  Widget _buildPostsTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final posts = provider.getGroupPosts(widget.group.id);

        if (provider.isLoading && posts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.article_outlined,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد منشورات بعد',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'كن أول من ينشر في هذه المجموعة',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _buildPostCard(post, provider);
          },
        );
      },
    );
  }

  Widget _buildPostCard(CommunityPostModel post, CommunityProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Icon(
                    post.isAnonymous ? Icons.person : Icons.account_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatTime(post.createdAt),
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
            const SizedBox(height: 12),
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                InkWell(
                  onTap: () => provider.likePost(post.id),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        post.isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 16,
                        color: post.isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        post.likesCount.toString(),
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.commentsCount.toString(),
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

  Widget _buildMembersTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final members = provider.getGroupMembers(widget.group.id);

        if (provider.isLoading && members.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا يوجد أعضاء',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return _buildMemberCard(member);
          },
        );
      },
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: const Icon(
            Icons.account_circle,
            color: AppTheme.primaryColor,
          ),
        ),
        title: Text(
          member['name'] ?? 'عضو',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'انضم ${_formatDate(DateTime.parse(member['joinedAt']))}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: member['isAdmin'] == true
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مشرف',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildBottomActions() {
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
        child: widget.group.isJoined
            ? Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to create post in group
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('إنشاء منشور'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _leaveGroup,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                      side: const BorderSide(color: AppTheme.errorColor),
                    ),
                    child: const Text('مغادرة'),
                  ),
                ],
              )
            : LoadingButton(
                onPressed: _isLoading ? null : _joinGroup,
                isLoading: _isLoading,
                child: const Text('انضمام للمجموعة'),
              ),
      ),
    );
  }

  Future<void> _joinGroup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      await provider.joinGroup(widget.group.id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم الانضمام للمجموعة بنجاح'),
            backgroundColor: AppTheme.successColor,
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
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('مغادرة المجموعة'),
        content: Text('هل أنت متأكد من رغبتك في مغادرة مجموعة "${widget.group.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final provider = Provider.of<CommunityProvider>(context, listen: false);
              provider.leaveGroup(widget.group.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مغادرة المجموعة'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('مغادرة'),
          ),
        ],
      ),
    );
  }

  void _shareGroup() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المشاركة قيد التطوير'),
      ),
    );
  }

  void _reportGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن المجموعة'),
        content: const Text('هل أنت متأكد من رغبتك في الإبلاغ عن هذه المجموعة؟'),
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
                  content: Text('تم الإبلاغ عن المجموعة'),
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
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else if (difference.inDays < 30) {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    } else if (difference.inDays < 365) {
      return 'منذ ${(difference.inDays / 30).floor()} شهر';
    } else {
      return 'منذ ${(difference.inDays / 365).floor()} سنة';
    }
  }

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.support:
        return Icons.favorite;
      case GroupType.therapy:
        return Icons.psychology;
      case GroupType.meditation:
        return Icons.self_improvement;
      case GroupType.anxiety:
        return Icons.sentiment_very_dissatisfied;
      case GroupType.depression:
        return Icons.sentiment_dissatisfied;
      case GroupType.addiction:
        return Icons.block;
      case GroupType.relationships:
        return Icons.people;
      case GroupType.parenting:
        return Icons.family_restroom;
      case GroupType.grief:
        return Icons.sentiment_neutral;
      case GroupType.trauma:
        return Icons.healing;
      case GroupType.general:
        return Icons.forum;
    }
  }

  Color _getGroupTypeColor(GroupType type) {
    switch (type) {
      case GroupType.support:
        return AppTheme.errorColor;
      case GroupType.therapy:
        return AppTheme.primaryColor;
      case GroupType.meditation:
        return AppTheme.successColor;
      case GroupType.anxiety:
        return AppTheme.warningColor;
      case GroupType.depression:
        return Colors.blue;
      case GroupType.addiction:
        return Colors.red;
      case GroupType.relationships:
        return Colors.pink;
      case GroupType.parenting:
        return Colors.green;
      case GroupType.grief:
        return Colors.grey;
      case GroupType.trauma:
        return Colors.purple;
      case GroupType.general:
        return AppTheme.textSecondary;
    }
  }

  String _getGroupTypeText(GroupType type) {
    switch (type) {
      case GroupType.support:
        return 'دعم عام';
      case GroupType.therapy:
        return 'علاج نفسي';
      case GroupType.meditation:
        return 'تأمل';
      case GroupType.anxiety:
        return 'القلق';
      case GroupType.depression:
        return 'الاكتئاب';
      case GroupType.addiction:
        return 'الإدمان';
      case GroupType.relationships:
        return 'العلاقات';
      case GroupType.parenting:
        return 'الأبوة والأمومة';
      case GroupType.grief:
        return 'الحزن والفقدان';
      case GroupType.trauma:
        return 'الصدمات';
      case GroupType.general:
        return 'عام';
    }
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}