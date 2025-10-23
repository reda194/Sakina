import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../models/community_model.dart';
import '../providers/community_provider.dart';
import 'group_details_screen.dart';
import 'create_group_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).loadGroups();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المجموعات'),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'الكل'),
            Tab(text: 'مجموعاتي'),
            Tab(text: 'المقترحة'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_searchQuery.isNotEmpty) _buildSearchHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAllGroupsTab(),
                _buildMyGroupsTab(),
                _buildSuggestedGroupsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateGroupScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              'نتائج البحث عن: "$_searchQuery"',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAllGroupsTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (provider.error != null) {
          return _buildErrorWidget(provider.error!, () => provider.loadGroups());
        }

        final groups = _filterGroups(provider.groups);

        if (groups.isEmpty) {
          return _buildEmptyWidget(
            Icons.group,
            _searchQuery.isNotEmpty
                ? 'لا توجد مجموعات تطابق البحث'
                : 'لا توجد مجموعات متاحة',
            _searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'كن أول من ينشئ مجموعة',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadGroups(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return _buildGroupCard(group, provider);
            },
          ),
        );
      },
    );
  }

  Widget _buildMyGroupsTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final myGroups = provider.groups
            .where((group) => group.isJoined)
            .toList();

        final filteredGroups = _filterGroups(myGroups);

        if (filteredGroups.isEmpty) {
          return _buildEmptyWidget(
            Icons.group_outlined,
            _searchQuery.isNotEmpty
                ? 'لا توجد مجموعات تطابق البحث'
                : 'لم تنضم لأي مجموعة بعد',
            _searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'انضم للمجموعات للتفاعل مع الآخرين',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            final group = filteredGroups[index];
            return _buildGroupCard(group, provider);
          },
        );
      },
    );
  }

  Widget _buildSuggestedGroupsTab() {
    return Consumer<CommunityProvider>(
      builder: (context, provider, child) {
        final suggestedGroups = provider.groups
            .where((group) => !group.isJoined)
            .take(10)
            .toList();

        final filteredGroups = _filterGroups(suggestedGroups);

        if (filteredGroups.isEmpty) {
          return _buildEmptyWidget(
            Icons.lightbulb_outline,
            _searchQuery.isNotEmpty
                ? 'لا توجد مجموعات مقترحة تطابق البحث'
                : 'لا توجد مجموعات مقترحة',
            _searchQuery.isNotEmpty
                ? 'جرب البحث بكلمات مختلفة'
                : 'تحقق لاحقاً من المجموعات الجديدة',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredGroups.length,
          itemBuilder: (context, index) {
            final group = filteredGroups[index];
            return _buildGroupCard(group, provider, showSuggestionBadge: true);
          },
        );
      },
    );
  }

  Widget _buildGroupCard(
    SupportGroupModel group,
    CommunityProvider provider, {
    bool showSuggestionBadge = false,
  }) {
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
              builder: (context) => GroupDetailsScreen(group: group),
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getGroupTypeColor(group.type).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getGroupTypeIcon(group.type),
                      color: _getGroupTypeColor(group.type),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                group.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (showSuggestionBadge) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.warningColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'مقترحة',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.warningColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getPrivacyIcon(group.privacy),
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPrivacyText(group.privacy),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.people,
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${group.membersCount} عضو',
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                group.description,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (group.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: group.tags.take(3).map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(8),
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
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'آخر نشاط: ${_formatTime(group.lastActivity)}',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildJoinButton(group, provider),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(SupportGroupModel group, CommunityProvider provider) {
    if (group.isJoined) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.successColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.successColor.withOpacity(0.3),
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check,
              size: 14,
              color: AppTheme.successColor,
            ),
            SizedBox(width: 4),
            Text(
              'منضم',
              style: TextStyle(
                color: AppTheme.successColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return InkWell(
      onTap: () => provider.joinGroup(group.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              size: 14,
              color: Colors.white,
            ),
            SizedBox(width: 4),
            Text(
              'انضمام',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error, VoidCallback onRetry) {
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
            error,
            style: const TextStyle(
              color: AppTheme.errorColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('البحث في المجموعات'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'ابحث عن مجموعة...',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context);
            setState(() {
              _searchQuery = value.trim();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _searchQuery = _searchController.text.trim();
              });
            },
            child: const Text('بحث'),
          ),
        ],
      ),
    );
  }

  List<SupportGroupModel> _filterGroups(List<SupportGroupModel> groups) {
    if (_searchQuery.isEmpty) return groups;
    
    return groups.where((group) {
      return group.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             group.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             group.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
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

  IconData _getGroupTypeIcon(GroupType type) {
    switch (type) {
      case GroupType.support:
        return Icons.favorite;
      case GroupType.therapy:
        return Icons.psychology;
      case GroupType.meditation:
        return Icons.self_improvement;
      case GroupType.discussion:
        return Icons.forum;
      case GroupType.crisis:
        return Icons.warning_amber; // Safe fallback for all SDK versions
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
      case GroupType.selfCare:
        return Icons.spa;
      case GroupType.general:
        return Icons.forum;
      case GroupType.stress:
        return Icons.warning;
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
      case GroupType.discussion:
        return Colors.blue;
      case GroupType.crisis:
        return Colors.red;
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
      case GroupType.selfCare:
        return Colors.teal;
      case GroupType.general:
        return AppTheme.textSecondary;
      case GroupType.stress:
        return Colors.deepOrange;
    }
  }

  IconData _getPrivacyIcon(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return Icons.public;
      case GroupPrivacy.private:
        return Icons.lock;
      case GroupPrivacy.secret:
        return Icons.visibility_off;
    }
  }

  String _getPrivacyText(GroupPrivacy privacy) {
    switch (privacy) {
      case GroupPrivacy.public:
        return 'عامة';
      case GroupPrivacy.private:
        return 'خاصة';
      case GroupPrivacy.secret:
        return 'سرية';
    }
  }
}