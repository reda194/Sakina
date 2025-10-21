import 'package:flutter/material.dart';
import 'dart:io';

/// Utility class for responsive design and device-specific adaptations
class ResponsiveUtils {
  // Screen size breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  // Device type detection
  static bool get isIOS => Platform.isIOS;
  static bool get isAndroid => Platform.isAndroid;

  /// Get device type based on screen width
  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (width < tabletBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }

  /// Check if device is mobile
  static bool isMobile(BuildContext context) {
    return getDeviceType(context) == DeviceType.mobile;
  }

  /// Check if device is tablet
  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  /// Check if device is desktop
  static bool isDesktop(BuildContext context) {
    return getDeviceType(context) == DeviceType.desktop;
  }

  /// Get responsive padding based on device type
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return const EdgeInsets.all(16.0);
      case DeviceType.tablet:
        return const EdgeInsets.all(24.0);
      case DeviceType.desktop:
        return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive font size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = _getScaleFactor(screenWidth);
    return baseSize * scaleFactor;
  }

  /// Get scale factor based on screen width
  static double _getScaleFactor(double screenWidth) {
    if (screenWidth < 350) {
      return 0.85; // Small phones
    } else if (screenWidth < 400) {
      return 0.9; // Regular phones
    } else if (screenWidth < 600) {
      return 1.0; // Large phones
    } else if (screenWidth < 900) {
      return 1.1; // Tablets
    } else {
      return 1.2; // Desktop
    }
  }

  /// Get responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSize;
      case DeviceType.tablet:
        return baseSize * 1.2;
      case DeviceType.desktop:
        return baseSize * 1.4;
    }
  }

  /// Get responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseSpacing;
      case DeviceType.tablet:
        return baseSpacing * 1.5;
      case DeviceType.desktop:
        return baseSpacing * 2.0;
    }
  }

  /// Get responsive card width
  static double getResponsiveCardWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
        return screenWidth - 32; // Full width with padding
      case DeviceType.tablet:
        return screenWidth * 0.8; // 80% of screen width
      case DeviceType.desktop:
        return 400; // Fixed width for desktop
    }
  }

  /// Get responsive grid columns
  static int getResponsiveGridColumns(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 2;
      case DeviceType.tablet:
        return 3;
      case DeviceType.desktop:
        return 4;
    }
  }

  /// Get device-specific app bar height
  static double getAppBarHeight(BuildContext context) {
    if (isIOS) {
      return 44.0; // iOS standard
    } else {
      return 56.0; // Android standard
    }
  }

  /// Get device-specific bottom navigation height
  static double getBottomNavHeight(BuildContext context) {
    if (isIOS) {
      return 83.0; // iOS with safe area
    } else {
      return 80.0; // Android standard
    }
  }

  /// Get safe area padding
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }

  /// Check if device has notch (iPhone X and newer)
  static bool hasNotch(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    return padding.top > 24; // Standard status bar height is 24
  }

  /// Get responsive border radius
  static BorderRadius getResponsiveBorderRadius(BuildContext context, double baseRadius) {
    final deviceType = getDeviceType(context);
    double radius;
    
    switch (deviceType) {
      case DeviceType.mobile:
        radius = baseRadius;
        break;
      case DeviceType.tablet:
        radius = baseRadius * 1.2;
        break;
      case DeviceType.desktop:
        radius = baseRadius * 1.4;
        break;
    }
    
    return BorderRadius.circular(radius);
  }

  /// Get responsive elevation
  static double getResponsiveElevation(BuildContext context, double baseElevation) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return baseElevation;
      case DeviceType.tablet:
        return baseElevation * 1.2;
      case DeviceType.desktop:
        return baseElevation * 1.5;
    }
  }

  /// Get responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 48.0;
      case DeviceType.tablet:
        return 52.0;
      case DeviceType.desktop:
        return 56.0;
    }
  }

  /// Get responsive text field height
  static double getResponsiveTextFieldHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return 56.0;
      case DeviceType.tablet:
        return 60.0;
      case DeviceType.desktop:
        return 64.0;
    }
  }
}

/// Device type enumeration
enum DeviceType {
  mobile,
  tablet,
  desktop,
}

/// Extension for responsive design
extension ResponsiveExtension on BuildContext {
  /// Get screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Get device type
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  
  /// Check if mobile
  bool get isMobile => ResponsiveUtils.isMobile(this);
  
  /// Check if tablet
  bool get isTablet => ResponsiveUtils.isTablet(this);
  
  /// Check if desktop
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  
  /// Get responsive padding
  EdgeInsets get responsivePadding => ResponsiveUtils.getResponsivePadding(this);
  
  /// Get responsive font size
  double responsiveFontSize(double baseSize) => ResponsiveUtils.getResponsiveFontSize(this, baseSize);
  
  /// Get responsive icon size
  double responsiveIconSize(double baseSize) => ResponsiveUtils.getResponsiveIconSize(this, baseSize);
  
  /// Get responsive spacing
  double responsiveSpacing(double baseSpacing) => ResponsiveUtils.getResponsiveSpacing(this, baseSpacing);
}