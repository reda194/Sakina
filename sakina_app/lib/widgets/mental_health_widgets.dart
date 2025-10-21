import 'package:flutter/material.dart';
import '../core/themes/app_theme.dart';
import '../core/utils/responsive_utils.dart';
import 'responsive_widget.dart';

/// Enhanced mood selector widget with beautiful animations
class EnhancedMoodSelector extends StatefulWidget {
  final int selectedMood;
  final Function(int) onMoodSelected;
  final bool showLabels;
  final double size;

  const EnhancedMoodSelector({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
    this.showLabels = true,
    this.size = 60.0,
  });

  @override
  State<EnhancedMoodSelector> createState() => _EnhancedMoodSelectorState();
}

class _EnhancedMoodSelectorState extends State<EnhancedMoodSelector>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final moodValue = index + 1;
              final isSelected = widget.selectedMood == moodValue;
              
              return GestureDetector(
                onTap: () {
                  widget.onMoodSelected(moodValue);
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                },
                child: AnimatedBuilder(
                  animation: _scaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: isSelected ? _scaleAnimation.value : 1.0,
                      child: _buildMoodIcon(context, moodValue, isSelected),
                    );
                  },
                ),
              );
            }),
          ),
          if (widget.showLabels) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _getMoodLabels(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMoodIcon(BuildContext context, int moodValue, bool isSelected) {
    final size = ResponsiveUtils.getResponsiveIconSize(context, widget.size);
    final color = _getMoodColor(moodValue);
    final emoji = _getMoodEmoji(moodValue);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 3.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 24.0),
          ),
        ),
      ),
    );
  }

  Color _getMoodColor(int mood) {
    switch (mood) {
      case 1:
        return AppTheme.moodTerrible;
      case 2:
        return AppTheme.moodBad;
      case 3:
        return AppTheme.moodNeutral;
      case 4:
        return AppTheme.moodGood;
      case 5:
        return AppTheme.moodExcellent;
      default:
        return Colors.grey;
    }
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  List<Widget> _getMoodLabels(BuildContext context) {
    final labels = ['سيء جداً', 'سيء', 'عادي', 'جيد', 'ممتاز'];
    return labels.map((label) {
      return ResponsiveText(
        label,
        baseFontSize: 10.0,
        color: AppTheme.textSecondary,
        textAlign: TextAlign.center,
      );
    }).toList();
  }
}

/// Beautiful feature card with gradient background
class FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final bool isActive;
  final Widget? badge;

  const FeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.color,
    this.isActive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;
    
    return ResponsiveCard(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cardColor.withOpacity(0.1),
              cardColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 16.0),
          border: Border.all(
            color: isActive ? cardColor : Colors.transparent,
            width: 2.0,
          ),
        ),
        child: Padding(
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(
                      ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                    ),
                    decoration: BoxDecoration(
                      color: cardColor.withOpacity(0.2),
                      borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
                    ),
                    child: Icon(
                      icon,
                      color: cardColor,
                      size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                    ),
                  ),
                  const Spacer(),
                  if (badge != null) badge!,
                ],
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 16.0)),
              ResponsiveText(
                title,
                baseFontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
              ResponsiveText(
                subtitle,
                baseFontSize: 12.0,
                color: AppTheme.textSecondary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Progress indicator with beautiful animations
class AnimatedProgressIndicator extends StatefulWidget {
  final double progress;
  final Color? color;
  final Color? backgroundColor;
  final double height;
  final String? label;

  const AnimatedProgressIndicator({
    super.key,
    required this.progress,
    this.color,
    this.backgroundColor,
    this.height = 8.0,
    this.label,
  });

  @override
  State<AnimatedProgressIndicator> createState() => _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.progress != widget.progress) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.progress,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          ResponsiveText(
            widget.label!,
            baseFontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
        ],
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(widget.height / 2),
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _animation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.color ?? AppTheme.primaryColor,
                        (widget.color ?? AppTheme.primaryColor).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(widget.height / 2),
                    boxShadow: [
                      BoxShadow(
                        color: (widget.color ?? AppTheme.primaryColor).withOpacity(0.3),
                        blurRadius: 4.0,
                        spreadRadius: 1.0,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Statistics card with beautiful design
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? color;
  final String? trend;
  final bool isPositiveTrend;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.color,
    this.trend,
    this.isPositiveTrend = true,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = color ?? AppTheme.primaryColor;
    
    return ResponsiveCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: cardColor,
                size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
              ),
              const Spacer(),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 4.0),
                  ),
                  decoration: BoxDecoration(
                    color: isPositiveTrend
                        ? AppTheme.successColor.withOpacity(0.1)
                        : AppTheme.errorColor.withOpacity(0.1),
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositiveTrend ? Icons.trending_up : Icons.trending_down,
                        color: isPositiveTrend ? AppTheme.successColor : AppTheme.errorColor,
                        size: ResponsiveUtils.getResponsiveIconSize(context, 12.0),
                      ),
                      SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 2.0)),
                      ResponsiveText(
                        trend!,
                        baseFontSize: 10.0,
                        color: isPositiveTrend ? AppTheme.successColor : AppTheme.errorColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 12.0)),
          ResponsiveText(
            value,
            baseFontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
          SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
          ResponsiveText(
            title,
            baseFontSize: 12.0,
            color: AppTheme.textSecondary,
          ),
          if (subtitle != null) ...[
            SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 2.0)),
            ResponsiveText(
              subtitle!,
              baseFontSize: 10.0,
              color: AppTheme.textLight,
            ),
          ],
        ],
      ),
    );
  }
}

/// Beautiful floating action button with gradient
class GradientFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Gradient? gradient;
  final double? elevation;

  const GradientFloatingActionButton({
    super.key,
    this.onPressed,
    required this.child,
    this.gradient,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? AppTheme.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: child,
      ),
    );
  }
}

/// Custom bottom navigation bar with beautiful design
class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowMedium,
            blurRadius: 10.0,
            spreadRadius: 0,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: ResponsiveUtils.getBottomNavHeight(context),
          padding: ResponsiveUtils.getResponsivePadding(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final isSelected = currentIndex == index;
              final item = items[index];
              
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
                    vertical: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconTheme(
                        data: IconThemeData(
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
                          size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                        ),
                        child: isSelected
                            ? item.activeIcon
                            : item.icon,
                      ),
                      if (isSelected && item.label != null) ...[
                        SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
                        ResponsiveText(
                          item.label!,
                          baseFontSize: 12.0,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}