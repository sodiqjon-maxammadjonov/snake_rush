import 'package:flutter/widgets.dart';

class Dimensions {
  final double width;
  final double height;
  final bool isLandscape;

  late final DeviceType deviceType;
  late final double scale;
  late final double maxContentWidth;

  Dimensions(BuildContext context)
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height,
        isLandscape = MediaQuery.of(context).size.width > MediaQuery.of(context).size.height {

    if (width >= 1366) {
      deviceType = DeviceType.largeTablet; // iPad Pro Landscape
      scale = 1.6;
      maxContentWidth = 1200;
    } else if (width >= 1024) {
      deviceType = DeviceType.tablet; // iPad Landscape
      scale = 1.4;
      maxContentWidth = 900;
    } else if (width >= 896) {
      deviceType = DeviceType.largeMobile; // iPhone Pro Max Landscape
      scale = 1.2;
      maxContentWidth = width * 0.9;
    } else {
      deviceType = DeviceType.mobile; // Small phones
      scale = 1.0;
      maxContentWidth = width * 0.95;
    }
  }

  bool get isTablet => deviceType == DeviceType.tablet || deviceType == DeviceType.largeTablet;
  bool get isMobile => !isTablet;

  double get titleLarge => _scale(24);
  double get title => _scale(20);
  double get subtitle => _scale(18);
  double get body => _scale(14);
  double get bodySmall => _scale(12);
  double get caption => _scale(10);
  double get button => _scale(16);

  double get iconSmall => _scale(18);
  double get iconMedium => _scale(22);
  double get iconLarge => _scale(28);
  double get iconHuge => _scale(48);

  double get spaceTiny => _scale(3);
  double get spaceSmall => _scale(6);
  double get spaceMedium => _scale(10);
  double get space => _scale(14);
  double get spaceLarge => _scale(20);
  double get spaceXLarge => _scale(28);
  double get spaceHuge => _scale(40);

  double get paddingScreen => isTablet ? _scale(32) : _scale(16);
  double get paddingCard => _scale(12);
  double get paddingButton => _scale(10);

  double get buttonHeight => _scale(48);
  double get buttonHeightSmall => _scale(40);
  double get buttonWidth => isTablet ? _scale(240) : width * 0.35;

  double get cardHeight => _scale(70);
  double get cardHeightSmall => _scale(60);

  double get backButtonSize => _scale(40);

  double get radiusSmall => _scale(6);
  double get radiusMedium => _scale(10);
  double get radius => _scale(14);
  double get radiusLarge => _scale(18);
  double get radiusXLarge => _scale(22);

  double get borderThin => 1.0;
  double get borderMedium => 1.5;
  double get borderThick => 2.0;

  double _scale(double value) => value * scale;
}

enum DeviceType {
  mobile,
  largeMobile,
  tablet,
  largeTablet,
}