import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import '../../../widgets/loading_button.dart';

class PostDetailsScreen extends StatefulWidget {
  final CommunityPostModel post;

  const PostDetailsScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false)
          .loadComments(widget.post.id);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنشور'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _sharePost(),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'report':
                  _reportPost();
                  break;
                case 'block':
                  _blockUser();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'report',
                child: Row(
                  children: [
                    Icon(Icons.report, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('الإبلاغ عن المنشور'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'block',
                child: Row(
                  children: [
                    Icon(Icons.block, color: AppTheme.errorColor),
                    SizedBox(width: 8),
                    Text('حظر المستخدم'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildPostCard(),
                  const Divider(height: 1),
                  _buildCommentsSection(),
                ],
              ),
            ),
          ),
          _buildCommentInput(),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        // Find the updated post from provider
        final updatedPost = provider.posts
            .firstWhere(
              (p) => p.id == widget.post.id,
              orElse: () => widget.post,
            );

        return Card(
          margin: const EdgeInsets.all(16),
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPostHeader(updatedPost),
                const SizedBox(height: 16),
                _buildPostContent(updatedPost),
                if (updatedPost.mood != null) ...[
                  const SizedBox(height: 12),
                  _buildMoodChip(updatedPost.mood!),
                ],
                if (updatedPost.tags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildPostTags(updatedPost),
                ],
                const SizedBox(height: 16),
                _buildPostActions(updatedPost, provider),
                const SizedBox(height: 8),
                _buildPostStats(updatedPost),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostHeader(CommunityPostModel post) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
          child: post.authorAvatar != null
              ? ClipOval(
                  child: Image.network(
                    post.authorAvatar!,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  post.isAnonymous ? Icons.person : Icons.account_circle,
                  color: AppTheme.primaryColor,
                  size: 28,
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
                      fontSize: 16,
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
              const SizedBox(height: 4),
              Text(
                _formatTime(post.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: _getPostTypeColor(post.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getPostTypeIcon(post.type),
                size: 16,
                color: _getPostTypeColor(post.type),
              ),
              const SizedBox(width: 6),
              Text(
                _getPostTypeText(post.type),
                style: TextStyle(
                  fontSize: 12,
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
        fontSize: 16,
        height: 1.6,
      ),
    );
  }

  Widget _buildMoodChip(PostMood mood) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _getMoodColor(mood).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getMoodColor(mood).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getMoodEmoji(mood),
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 6),
          Text(
            _getMoodText(mood),
            style: TextStyle(
              fontSize: 14,
              color: _getMoodColor(mood),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostTags(CommunityPostModel post) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: post.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
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
              fontSize: 12,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500,
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
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  post.isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: post.isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post.likesCount.toString(),
                  style: TextStyle(
                    color: post.isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.comment_outlined,
                size: 20,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                post.commentsCount.toString(),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () => _sharePost(),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.share_outlined,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  post.sharesCount.toString(),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: () => provider.bookmarkPost(post.id),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              post.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              size: 20,
              color: post.isBookmarked ? AppTheme.primaryColor : AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPostStats(CommunityPostModel post) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.favorite,
            '${post.likesCount} إعجاب',
            AppTheme.errorColor,
          ),
          _buildStatItem(
            Icons.comment,
            '${post.commentsCount} تعليق',
            AppTheme.infoColor,
          ),
          _buildStatItem(
            Icons.share,
            '${post.sharesCount} مشاركة',
            AppTheme.successColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final comments = provider.getCommentsForPost(widget.post.id);

        if (provider.isLoading && comments.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.comment_outlined,
                    size: 48,
                    color: AppTheme.textSecondary.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'لا توجد تعليقات بعد',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'كن أول من يعلق على هذا المنشور',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'التعليقات (${comments.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              itemBuilder: (context, index) {
                final comment = comments[index];
                return _buildCommentCard(comment, provider);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentCard(CommentModel comment, CommunityProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
            child: comment.authorAvatar != null
                ? ClipOval(
                    child: Image.network(
                      comment.authorAvatar!,
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    comment.isAnonymous ? Icons.person : Icons.account_circle,
                    color: AppTheme.primaryColor,
                    size: 20,
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
                      comment.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (comment.isAnonymous) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.textSecondary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مجهول',
                          style: TextStyle(
                            fontSize: 8,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      _formatTime(comment.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      onTap: () => provider.likeComment(comment.id),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            comment.isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: comment.isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            comment.likesCount.toString(),
                            style: TextStyle(
                              color: comment.isLiked ? AppTheme.errorColor : AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // TODO: Implement reply functionality
                      },
                      child: const Text(
                        'رد',
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildCommentInput() {
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'اكتب تعليقاً...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _addComment(),
            ),
          ),
          const SizedBox(width: 8),
          LoadingButton(
            onPressed: _isLoading ? null : _addComment,
            isLoading: _isLoading,
            text: 'إرسال',
          ),
        ],
      ),
    );
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<CommunityProvider>(context, listen: false);
      
      await provider.addComment(
        postId: widget.post.id,
        content: content,
        isAnonymous: false,
      );
      _commentController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم إضافة التعليق بنجاح'),
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

  void _sharePost() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ميزة المشاركة قيد التطوير'),
      ),
    );
  }

  void _reportPost() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('الإبلاغ عن المنشور'),
        content: const Text('هل أنت متأكد من رغبتك في الإبلاغ عن هذا المنشور؟'),
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
                  content: Text('تم الإبلاغ عن المنشور'),
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

  void _blockUser() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حظر المستخدم'),
        content: Text('هل أنت متأكد من رغبتك في حظر ${widget.post.authorName}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حظر ${widget.post.authorName}'),
                  backgroundColor: AppTheme.errorColor,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('حظر'),
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

  String _getMoodEmoji(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return '😊';
      case PostMood.sad:
        return '😢';
      case PostMood.anxious:
        return '😰';
      case PostMood.angry:
        return '😠';
      case PostMood.excited:
        return '🤗';
      case PostMood.grateful:
        return '🙏';
      case PostMood.hopeful:
        return '🌟';
      case PostMood.frustrated:
        return '😤';
      case PostMood.peaceful:
        return '😌';
      case PostMood.overwhelmed:
        return '😵';
    }
  }

  String _getMoodText(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return 'سعيد';
      case PostMood.sad:
        return 'حزين';
      case PostMood.anxious:
        return 'قلق';
      case PostMood.angry:
        return 'غاضب';
      case PostMood.excited:
        return 'متحمس';
      case PostMood.grateful:
        return 'ممتن';
      case PostMood.hopeful:
        return 'متفائل';
      case PostMood.frustrated:
        return 'محبط';
      case PostMood.peaceful:
        return 'هادئ';
      case PostMood.overwhelmed:
        return 'مرهق';
    }
  }

  Color _getMoodColor(PostMood mood) {
    switch (mood) {
      case PostMood.happy:
        return AppTheme.successColor;
      case PostMood.sad:
        return Colors.blue;
      case PostMood.anxious:
        return AppTheme.warningColor;
      case PostMood.angry:
        return AppTheme.errorColor;
      case PostMood.excited:
        return Colors.purple;
      case PostMood.grateful:
        return Colors.green;
      case PostMood.hopeful:
        return AppTheme.primaryColor;
      case PostMood.frustrated:
        return Colors.orange;
      case PostMood.peaceful:
        return Colors.teal;
      case PostMood.overwhelmed:
        return Colors.grey;
    }
  }
}