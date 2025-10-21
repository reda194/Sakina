import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import 'create_post_screen.dart';
import 'post_details_screen.dart';
import 'groups_screen.dart';
import 'success_stories_screen.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadPosts();
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
      appBar: AppBar(
        title: const Text('المجتمع'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'الرئيسية'),
            Tab(text: 'المجموعات'),
            Tab(text: 'قصص النجاح'),
            Tab(text: 'المحفوظات'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildHomeTab(),
          const GroupsScreen(),
          const SuccessStoriesScreen(),
          _buildBookmarksTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePostScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHomeTab() {
    return Consumer<CommunityProvider>(
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
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadPosts(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadPosts(),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildQuickStats(provider),
              ),
              SliverToBoxAdapter(
                child: _buildPostTypeFilters(),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = provider.posts[index];
                    return _buildPostCard(post, provider);
                  },
                  childCount: provider.posts.length,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickStats(CommunityProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.article,
            'المنشورات',
            provider.posts.length.toString(),
          ),
          _buildStatItem(
            Icons.group,
            'المجموعات',
            provider.groups.length.toString(),
          ),
          _buildStatItem(
            Icons.star,
            'قصص النجاح',
            provider.stories.length.toString(),
          ),
        ],
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
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPostTypeFilters() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('الكل', null),
          _buildFilterChip('دعم', PostType.support),
          _buildFilterChip('أسئلة', PostType.question),
          _buildFilterChip('احتفال', PostType.celebration),
          _buildFilterChip('موارد', PostType.resource),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PostType? type) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: false, // TODO: Implement filter state
        onSelected: (selected) {
          // TODO: Implement filtering
        },
      ),
    );
  }

  Widget _buildPostCard(CommunityPostModel post, CommunityProvider provider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailsScreen(post: post),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostHeader(post),
              const SizedBox(height: 12),
              _buildPostContent(post),
              const SizedBox(height: 12),
              _buildPostTags(post),
              const SizedBox(height: 12),
              _buildPostActions(post, provider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(CommunityPostModel post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: post.authorAvatar != null
              ? ClipOval(
                  child: Image.network(
                    post.authorAvatar!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  post.isAnonymous ? Icons.person : Icons.account_circle,
                  color: AppTheme.primaryColor,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    post.authorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (post.isAnonymous) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.textSecondary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'مجهول',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
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
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: _getPostTypeColor(post.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPostTypeIcon(post.type),
                size: 12,
                color: _getPostTypeColor(post.type),
              ),
              const SizedBox(width: 4),
              Text(
                _getPostTypeText(post.type),
                style: TextStyle(
                  fontSize: 10,
                  color: _getPostTypeColor(post.type),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPostContent(CommunityPostModel post) {
    return Text(
      post.content,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPostTags(CommunityPostModel post) {
    if (post.tags.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: post.tags.take(3).map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.3),
            ),
          ),
          child: Text(
            '#$tag',
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.primaryColor,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPostActions(CommunityPostModel post, CommunityProvider provider) {
    return Row(
      children: [
        InkWell(
          onTap: () => provider.likePost(post.id),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                post.isLiked ? Icons.favorite : Icons.favorite_border,
                size: 18,
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
              size: 18,
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
        const SizedBox(width: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.share_outlined,
              size: 18,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              post.sharesCount.toString(),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () => provider.bookmarkPost(post.id),
          child: Icon(
            post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            size: 18,
            color: post.isBookmarked ? AppTheme.primaryColor : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBookmarksTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final bookmarkedPosts = provider.posts
            .where((post) => post.isBookmarked)
            .toList();

        if (bookmarkedPosts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.bookmark_border,
                  size: 64,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لا توجد منشورات محفوظة',
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
          itemCount: bookmarkedPosts.length,
          itemBuilder: (context, index) {
            final post = bookmarkedPosts[index];
            return _buildPostCard(post, provider);
          },
        );
      },
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث'),
        content: const TextField(
          decoration: InputDecoration(
            hintText: 'ابحث في المنشورات...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement search
            },
            child: const Text('بحث'),
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

  IconData _getPostTypeIcon(PostType type) {
    switch (type) {
      case PostType.text:
        return Icons.article;
      case PostType.question:
        return Icons.help;
      case PostType.support:
        return Icons.favorite;
      case PostType.celebration:
        return Icons.celebration;
      case PostType.resource:
        return Icons.library_books;
      case PostType.poll:
        return Icons.poll;
    }
  }

  Color _getPostTypeColor(PostType type) {
    switch (type) {
      case PostType.text:
        return AppTheme.textSecondary;
      case PostType.question:
        return AppTheme.infoColor;
      case PostType.support:
        return AppTheme.errorColor;
      case PostType.celebration:
        return AppTheme.successColor;
      case PostType.resource:
        return AppTheme.warningColor;
      case PostType.poll:
        return AppTheme.primaryColor;
    }
  }

  String _getPostTypeText(PostType type) {
    switch (type) {
      case PostType.text:
        return 'نص';
      case PostType.question:
        return 'سؤال';
      case PostType.support:
        return 'دعم';
      case PostType.celebration:
        return 'احتفال';
      case PostType.resource:
        return 'مورد';
      case PostType.poll:
        return 'استطلاع';
    }
  }
}
