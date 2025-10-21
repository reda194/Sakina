import 'package:flutter/material.dart';
import '../../../core/themes/app_theme.dart';

class MoodFactorsWidget extends StatefulWidget {
  final List<String> selectedFactors;
  final Function(List<String>) onFactorsChanged;
  final bool isExpanded;

  const MoodFactorsWidget({
    super.key,
    required this.selectedFactors,
    required this.onFactorsChanged,
    this.isExpanded = false,
  });

  @override
  State<MoodFactorsWidget> createState() => _MoodFactorsWidgetState();
}

class _MoodFactorsWidgetState extends State<MoodFactorsWidget>
    with TickerProviderStateMixin {
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late Animation<double> _expandAnimation;
  late Animation<double> _pulseAnimation;
  
  final List<MoodFactor> _allFactors = [
    // Positive factors
    const MoodFactor(
      id: 'exercise',
      name: 'تمارين رياضية',
      icon: Icons.fitness_center,
      color: Colors.green,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'good_sleep',
      name: 'نوم جيد',
      icon: Icons.bedtime,
      color: Colors.blue,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'social_time',
      name: 'وقت اجتماعي',
      icon: Icons.people,
      color: Colors.purple,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'meditation',
      name: 'تأمل',
      icon: Icons.self_improvement,
      color: Colors.teal,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'good_weather',
      name: 'طقس جميل',
      icon: Icons.wb_sunny,
      color: Colors.orange,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'achievement',
      name: 'إنجاز',
      icon: Icons.emoji_events,
      color: Colors.amber,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'healthy_food',
      name: 'طعام صحي',
      icon: Icons.restaurant,
      color: Colors.lightGreen,
      category: 'إيجابي',
    ),
    const MoodFactor(
      id: 'music',
      name: 'موسيقى',
      icon: Icons.music_note,
      color: Colors.indigo,
      category: 'إيجابي',
    ),
    
    // Negative factors
    const MoodFactor(
      id: 'stress',
      name: 'ضغط نفسي',
      icon: Icons.psychology,
      color: Colors.red,
      category: 'سلبي',
    ),
    const MoodFactor(
      id: 'poor_sleep',
      name: 'نوم سيء',
      icon: Icons.bedtime_off,
      color: Colors.deepOrange,
      category: 'سلبي',
    ),
    const MoodFactor(
      id: 'work_pressure',
      name: 'ضغط العمل',
      icon: Icons.work,
      color: Colors.brown,
      category: 'سلبي',
    ),
    MoodFactor(
      id: 'conflict',
      name: 'خلاف',
      icon: Icons.warning,
      color: Colors.red[700]!,
      category: 'سلبي',
    ),
    MoodFactor(
      id: 'loneliness',
      name: 'وحدة',
      icon: Icons.person_off,
      color: Colors.grey[600]!,
      category: 'سلبي',
    ),
    const MoodFactor(
      id: 'bad_weather',
      name: 'طقس سيء',
      icon: Icons.cloud,
      color: Colors.blueGrey,
      category: 'سلبي',
    ),
    const MoodFactor(
      id: 'health_issue',
      name: 'مشكلة صحية',
      icon: Icons.local_hospital,
      color: Colors.pink,
      category: 'سلبي',
    ),
    MoodFactor(
      id: 'financial_worry',
      name: 'قلق مالي',
      icon: Icons.attach_money,
      color: Colors.red[800]!,
      category: 'سلبي',
    ),
    
    // Neutral factors
    const MoodFactor(
      id: 'routine_day',
      name: 'يوم عادي',
      icon: Icons.schedule,
      color: Colors.grey,
      category: 'محايد',
    ),
    const MoodFactor(
      id: 'travel',
      name: 'سفر',
      icon: Icons.flight,
      color: Colors.cyan,
      category: 'محايد',
    ),
    const MoodFactor(
      id: 'new_experience',
      name: 'تجربة جديدة',
      icon: Icons.explore,
      color: Colors.deepPurple,
      category: 'محايد',
    ),
  ];
  
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'إيجابي', 'سلبي', 'محايد'];
  
  List<MoodFactor> get _filteredFactors {
    if (_selectedCategory == 'الكل') {
      return _allFactors;
    }
    return _allFactors.where((factor) => factor.category == _selectedCategory).toList();
  }

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    if (widget.isExpanded) {
      _expandController.forward();
    }
    
    _pulseController.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(MoodFactorsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _expandController.forward();
      } else {
        _expandController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _expandController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 16),
          _buildCategoryFilter(),
          const SizedBox(height: 16),
          _buildSelectedFactors(),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                const SizedBox(height: 16),
                _buildFactorGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.selectedFactors.isNotEmpty ? _pulseAnimation.value : 1.0,
              child: Icon(
                Icons.psychology,
                color: widget.selectedFactors.isNotEmpty 
                    ? AppTheme.primaryColor 
                    : Colors.grey,
                size: 24,
              ),
            );
          },
        ),
        const SizedBox(width: 8),
        const Text(
          'العوامل المؤثرة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        
        // Selected count
        if (widget.selectedFactors.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${widget.selectedFactors.length} محدد',
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _categories.map((category) {
            final isSelected = _selectedCategory == category;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.primaryColor 
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSelectedFactors() {
    if (widget.selectedFactors.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3), style: BorderStyle.solid),
        ),
        child: const Text(
          'لم يتم تحديد أي عوامل بعد',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.selectedFactors.map((factorId) {
        final factor = _allFactors.firstWhere((f) => f.id == factorId);
        return _buildSelectedFactorChip(factor);
      }).toList(),
    );
  }

  Widget _buildSelectedFactorChip(MoodFactor factor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: factor.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: factor.color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            factor.icon,
            size: 16,
            color: factor.color,
          ),
          const SizedBox(width: 6),
          Text(
            factor.name,
            style: TextStyle(
              color: factor.color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              final newFactors = List<String>.from(widget.selectedFactors)
                ..remove(factor.id);
              widget.onFactorsChanged(newFactors);
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: factor.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _filteredFactors.length,
      itemBuilder: (context, index) {
        final factor = _filteredFactors[index];
        final isSelected = widget.selectedFactors.contains(factor.id);
        
        return GestureDetector(
          onTap: () {
            List<String> newFactors = List<String>.from(widget.selectedFactors);
            if (isSelected) {
              newFactors.remove(factor.id);
            } else {
              newFactors.add(factor.id);
            }
            widget.onFactorsChanged(newFactors);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? factor.color.withOpacity(0.2) 
                  : Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? factor.color 
                    : Colors.grey.withOpacity(0.2),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    factor.icon,
                    color: isSelected ? factor.color : Colors.grey[600],
                    size: 24,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  factor.name,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? factor.color : Colors.grey[700],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Selection indicator
                if (isSelected)
                  Container(
                    margin: const EdgeInsets.only(top: 2),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: factor.color,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MoodFactor {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String category;

  const MoodFactor({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.category,
  });
}