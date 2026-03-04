import 'package:flutter/widgets.dart';

class SizeConfig {
  SizeConfig._();

  // iPhone 13 reference dimensions
  static const double _designWidth = 390.0;
  static const double _designHeight = 844.0;

  // Scaling cap — UI does not grow beyond reference size
  static const double _maxScaleWidth = 1.0;
  static const double _maxScaleHeight = 1.0;

  static late double _screenWidth;
  static late double _screenHeight;
  static late double _scaleWidth;
  static late double _scaleHeight;
  static late double _textScale;

  static void init(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    _screenWidth = size.width;
    _screenHeight = size.height;

    _scaleWidth = (_screenWidth / _designWidth).clamp(0.0, _maxScaleWidth);
    _scaleHeight = (_screenHeight / _designHeight).clamp(0.0, _maxScaleHeight);
    _textScale = _scaleWidth;
  }

  /// Scales a width/horizontal value
  static double w(double value) => value * _scaleWidth;

  /// Scales a height/vertical value
  static double h(double value) => value * _scaleHeight;

  /// Scales a font size
  static double sp(double value) => value * _textScale;

  /// Scales symmetrically (uses width scale)
  static double r(double value) => value * _scaleWidth;

  static double get screenWidth => _screenWidth;
  static double get screenHeight => _screenHeight;
}
