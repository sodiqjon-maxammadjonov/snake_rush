import 'package:flutter/widgets.dart';

class Dimensions {
  final double width;
  final double height;

  late final DeviceType deviceType;
  late final double scale;
  late final double maxContentWidth;

  Dimensions(BuildContext context)
      : width = MediaQuery.of(context).size.width,
        height = MediaQuery.of(context).size.height {

    if (width >= 1024) {
      deviceType = DeviceType.tablet;
      scale = 1.5;
      maxContentWidth = 800;
    } else if (width >= 768) {
      deviceType = DeviceType.smallTablet;
      scale = 1.3;
      maxContentWidth = 600;
    } else if (width >= 600) {
      deviceType = DeviceType.largeMobile;
      scale = 1.15;
      maxContentWidth = width;
    } else {
      deviceType = DeviceType.mobile;
      scale = 1.0;
      maxContentWidth = width;
    }
  }

  bool get isTablet => deviceType == DeviceType.tablet || deviceType == DeviceType.smallTablet;
  bool get isMobile => deviceType == DeviceType.mobile || deviceType == DeviceType.largeMobile;

  double get titleLarge => _scale(28);
  double get title => _scale(24);
  double get subtitle => _scale(20);
  double get body => _scale(16);
  double get bodySmall => _scale(14);
  double get caption => _scale(12);
  double get button => _scale(18);

  double get iconSmall => _scale(20);
  double get iconMedium => _scale(24);
  double get iconLarge => _scale(32);
  double get iconHuge => _scale(60);

  double get spaceTiny => _scale(4);
  double get spaceSmall => _scale(8);
  double get spaceMedium => _scale(12);
  double get space => _scale(16);
  double get spaceLarge => _scale(24);
  double get spaceXLarge => _scale(32);
  double get spaceHuge => _scale(48);

  double get paddingScreen => isTablet ? _scale(40) : _scale(20);
  double get paddingCard => _scale(16);
  double get paddingButton => _scale(12);

  double get buttonHeight => _scale(56);
  double get buttonHeightSmall => _scale(48);
  double get buttonWidth => isTablet ? _scale(300) : width * 0.7;

  double get cardHeight => _scale(80);
  double get cardHeightSmall => _scale(85);

  double get backButtonSize => _scale(44);

  double get radiusSmall => _scale(8);
  double get radiusMedium => _scale(12);
  double get radius => _scale(16);
  double get radiusLarge => _scale(20);
  double get radiusXLarge => _scale(24);

  double get borderThin => 1.0;
  double get borderMedium => 1.5;
  double get borderThick => 2.0;

  double _scale(double value) => value * scale;
}

enum DeviceType {
  mobile,
  largeMobile,
  smallTablet,
  tablet,
}