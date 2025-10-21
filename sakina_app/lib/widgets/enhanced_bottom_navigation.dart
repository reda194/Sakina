import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/themes/app_theme.dart';
import '../core/utils/responsive_utils.dart';
import 'responsive_widget.dart';

class EnhancedBottomNavigation extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<EnhancedBottomNavItem> items;

  const EnhancedBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  State<EnhancedBottomNavigation> createState() => _EnhancedBottomNavigationState();
}

class _EnhancedBottomNavigationState extends State<EnhancedBottomNavigation>
    with TickerProviderStateMixin {
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _animationControllers = List.generate(
      widget.items.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 200),
        vsync: this,
      ),
    );

    _scaleAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
    }).toList();

    _fadeAnimations = _animationControllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeInOut),
      );
    }).toList();

    // Animate the initially selected item
    if (widget.currentIndex < _animationControllers.length) {
      _animationControllers[widget.currentIndex].forward();
    }
  }

  @override
  void didUpdateWidget(EnhancedBottomNavigation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      // Reset previous animation
      if (oldWidget.currentIndex < _animationControllers.length) {
        _animationControllers[oldWidget.currentIndex].reverse();
      }
      // Start new animation
      if (widget.currentIndex < _animationControllers.length) {
        _animationControllers[widget.currentIndex].forward();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: const [
          BoxShadow(
            color: AppTheme.shadowMedium,
            blurRadius: 20.0,
            spreadRadius: 0,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topLeft,
          topRight: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0).topRight,
        ),
      ),
      child: SafeArea(
        child: Container(
          height: ResponsiveUtils.getBottomNavHeight(context),
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
            vertical: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              return _buildNavItem(index);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final item = widget.items[index];
    final isSelected = widget.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          widget.onTap(index);
          _animateSelection(index);
        },
        child: AnimatedBuilder(
          animation: Listenable.merge([
            _scaleAnimations[index],
            _fadeAnimations[index],
          ]),
          builder: (context, child) {
            return Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 12.0),
                vertical: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
              ),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 20.0),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8.0,
                          spreadRadius: 2.0,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: isSelected ? _scaleAnimations[index].value : 1.0,
                    child: Stack(
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? Colors.white : AppTheme.textLight,
                          size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                        ),
                        if (item.badge != null)
                          Positioned(
                            right: -2,
                            top: -2,
                            child: item.badge!,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: isSelected ? null : 0,
                    child: isSelected
                        ? FadeTransition(
                            opacity: _fadeAnimations[index],
                            child: ResponsiveText(
                              item.label,
                              baseFontSize: 10.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.center,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _animateSelection(int index) {
    // Add haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate the selected item
    _animationControllers[index].forward().then((_) {
      _animationControllers[index].reverse();
    });
  }
}

class EnhancedBottomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final Widget? badge;
  final Color? color;

  const EnhancedBottomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    this.badge,
    this.color,
  });
}

// Badge widgets for notifications
class NotificationBadge extends StatelessWidget {
  final int count;
  final Color? color;
  final double? size;

  const NotificationBadge({
    super.key,
    required this.count,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    
    final badgeSize = size ?? ResponsiveUtils.getResponsiveIconSize(context, 16.0);
    
    return Container(
      width: badgeSize,
      height: badgeSize,
      decoration: BoxDecoration(
        color: color ?? AppTheme.errorColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
      ),
      child: Center(
        child: ResponsiveText(
          count > 99 ? '99+' : count.toString(),
          baseFontSize: 8.0,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DotBadge extends StatelessWidget {
  final Color? color;
  final double? size;

  const DotBadge({
    super.key,
    this.color,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    final dotSize = size ?? ResponsiveUtils.getResponsiveIconSize(context, 8.0);
    
    return Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: color ?? AppTheme.errorColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 1.0,
        ),
      ),
    );
  }
}

// Floating Bottom Navigation for special actions
class FloatingBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<EnhancedBottomNavItem> items;
  final VoidCallback? onCenterTap;
  final Widget? centerWidget;

  const FloatingBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
    this.onCenterTap,
    this.centerWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // Main navigation bar
        Container(
          margin: EdgeInsets.all(
            ResponsiveUtils.getResponsiveSpacing(context, 16.0),
          ),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 24.0),
            boxShadow: const [
              BoxShadow(
                color: AppTheme.shadowMedium,
                blurRadius: 20.0,
                spreadRadius: 0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Container(
              height: ResponsiveUtils.getBottomNavHeight(context) * 0.8,
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.getResponsiveSpacing(context, 20.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ...items.take(2).toList().asMap().entries.map((entry) {
                    return _buildFloatingNavItem(context, entry.key, entry.value);
                  }),
                  SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 60.0)),
                  ...items.skip(2).toList().asMap().entries.map((entry) {
                    final index = entry.key + 2;
                    return _buildFloatingNavItem(context, index, entry.value);
                  }),
                ],
              ),
            ),
          ),
        ),
        // Center floating action button
        if (centerWidget != null)
          Positioned(
            bottom: ResponsiveUtils.getResponsiveSpacing(context, 32.0),
            child: GestureDetector(
              onTap: onCenterTap,
              child: Container(
                width: ResponsiveUtils.getResponsiveIconSize(context, 56.0),
                height: ResponsiveUtils.getResponsiveIconSize(context, 56.0),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.4),
                      blurRadius: 12.0,
                      spreadRadius: 4.0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: centerWidget,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFloatingNavItem(BuildContext context, int index, EnhancedBottomNavItem item) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () => onTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(
          ResponsiveUtils.getResponsiveSpacing(context, 8.0),
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: ResponsiveUtils.getResponsiveBorderRadius(context, 12.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                Icon(
                  isSelected ? item.activeIcon ?? item.icon : item.icon,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
                  size: ResponsiveUtils.getResponsiveIconSize(context, 24.0),
                ),
                if (item.badge != null)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: item.badge!,
                  ),
              ],
            ),
            if (isSelected) ...[
              SizedBox(height: ResponsiveUtils.getResponsiveSpacing(context, 4.0)),
              ResponsiveText(
                item.label,
                baseFontSize: 10.0,
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ],
          ],
        ),
      ),
    );
  }
}