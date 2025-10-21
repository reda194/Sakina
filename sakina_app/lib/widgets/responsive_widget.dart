import 'package:flutter/material.dart';
import '../core/utils/responsive_utils.dart';

/// A responsive widget that adapts its child based on screen size
class ResponsiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  final Widget? fallback;

  const ResponsiveWidget({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceType.tablet:
        return tablet ?? mobile ?? fallback ?? const SizedBox.shrink();
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile ?? fallback ?? const SizedBox.shrink();
    }
  }
}

/// A responsive builder widget that provides device type and constraints
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ResponsiveUtils.getDeviceType(context);
        return builder(context, deviceType, constraints);
      },
    );
  }
}

/// A responsive container that adapts its properties based on screen size
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final BoxDecoration? decoration;
  final AlignmentGeometry? alignment;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.decoration,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      margin: margin,
      width: width ?? ResponsiveUtils.getResponsiveCardWidth(context),
      height: height,
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }
}

/// A responsive text widget that adapts font size based on screen size
class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final TextStyle? style;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveFontSize = ResponsiveUtils.getResponsiveFontSize(context, baseFontSize);
    
    return Text(
      text,
      style: (style ?? const TextStyle()).copyWith(
        fontSize: responsiveFontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// A responsive card widget that adapts its properties based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.borderRadius,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final responsiveElevation = ResponsiveUtils.getResponsiveElevation(context, elevation ?? 2.0);
    final responsiveBorderRadius = ResponsiveUtils.getResponsiveBorderRadius(context, 16.0);
    
    Widget card = Card(
      color: color,
      elevation: responsiveElevation,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? responsiveBorderRadius,
      ),
      margin: margin ?? EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.getResponsiveSpacing(context, 16.0),
        vertical: ResponsiveUtils.getResponsiveSpacing(context, 8.0),
      ),
      child: Padding(
        padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
        child: child,
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? responsiveBorderRadius,
        child: card,
      );
    }

    return card;
  }
}

/// A responsive grid view that adapts column count based on screen size
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double childAspectRatio;
  final EdgeInsetsGeometry? padding;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.childAspectRatio = 1.0,
    this.padding,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final crossAxisCount = ResponsiveUtils.getResponsiveGridColumns(context);
    final responsiveSpacing = ResponsiveUtils.getResponsiveSpacing(context, 16.0);
    
    return GridView.count(
      crossAxisCount: crossAxisCount,
      childAspectRatio: childAspectRatio,
      padding: padding ?? ResponsiveUtils.getResponsivePadding(context),
      mainAxisSpacing: mainAxisSpacing ?? responsiveSpacing,
      crossAxisSpacing: crossAxisSpacing ?? responsiveSpacing,
      physics: physics,
      shrinkWrap: shrinkWrap,
      children: children,
    );
  }
}

/// A responsive button that adapts its size based on screen size
class ResponsiveButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonStyle? style;
  final Widget? icon;
  final bool isLoading;
  final bool isOutlined;

  const ResponsiveButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = ResponsiveUtils.getResponsiveButtonHeight(context);
    final responsivePadding = ResponsiveUtils.getResponsivePadding(context);
    final responsiveBorderRadius = ResponsiveUtils.getResponsiveBorderRadius(context, 12.0);
    
    Widget button;
    
    if (isOutlined) {
      button = OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: (style ?? OutlinedButton.styleFrom()).copyWith(
          minimumSize: WidgetStateProperty.all(Size(double.infinity, buttonHeight)),
          padding: WidgetStateProperty.all(responsivePadding),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: responsiveBorderRadius),
          ),
        ),
        child: _buildButtonChild(context),
      );
    } else {
      button = ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: (style ?? ElevatedButton.styleFrom()).copyWith(
          minimumSize: WidgetStateProperty.all(Size(double.infinity, buttonHeight)),
          padding: WidgetStateProperty.all(responsivePadding),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: responsiveBorderRadius),
          ),
        ),
        child: _buildButtonChild(context),
      );
    }

    return button;
  }

  Widget _buildButtonChild(BuildContext context) {
    if (isLoading) {
      return SizedBox(
        height: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
        width: ResponsiveUtils.getResponsiveIconSize(context, 20.0),
        child: const CircularProgressIndicator(
          strokeWidth: 2.0,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          SizedBox(width: ResponsiveUtils.getResponsiveSpacing(context, 8.0)),
          ResponsiveText(
            text,
            baseFontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ],
      );
    }

    return ResponsiveText(
      text,
      baseFontSize: 16.0,
      fontWeight: FontWeight.w600,
    );
  }
}

/// A responsive app bar that adapts its height based on device type
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool centerTitle;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.centerTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: ResponsiveText(
        title,
        baseFontSize: 20.0,
        fontWeight: FontWeight.w600,
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(ResponsiveUtils.isIOS ? 44.0 : 56.0);
}