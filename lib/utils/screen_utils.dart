import 'package:flutter/material.dart';

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }

  /// Returns a width calculated as a percentage of the screen width.
  static double width(double percentage) => blockSizeHorizontal * percentage;

  /// Returns a height calculated as a percentage of the screen height.
  static double height(double percentage) => blockSizeVertical * percentage;

  /// Returns a responsive font size based on screen width.
  static double fontSize(double size) => blockSizeHorizontal * (size / 3.75);
}

extension ResponsiveSize on num {
  /// Percentage of screen width (e.g., 20.w)
  double get w => ScreenUtils.blockSizeHorizontal * this;

  /// Percentage of screen height (e.g., 10.h)
  double get h => ScreenUtils.blockSizeVertical * this;

  /// Responsive font size
  double get sp => ScreenUtils.blockSizeHorizontal * (this / 3.75);
}
