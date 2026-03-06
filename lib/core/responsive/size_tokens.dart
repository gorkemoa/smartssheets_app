import 'size_config.dart';

/// Token-based design system. All Views and Widgets use these tokens only.
/// Raw pixel values are FORBIDDEN in views.
class SizeTokens {
  SizeTokens._();

  // ─── Spacing ───────────────────────────────────────────────────────────────
  static double get spaceXXS => SizeConfig.w(4);
  static double get spaceXS => SizeConfig.w(8);
  static double get spaceSM => SizeConfig.w(12);
  static double get spaceMD => SizeConfig.w(16);
  static double get spaceLG => SizeConfig.w(20);
  static double get spaceXL => SizeConfig.w(24);
  static double get spaceXXL => SizeConfig.w(32);
  static double get spaceXXXL => SizeConfig.w(48);

  // ─── Padding ───────────────────────────────────────────────────────────────
  static double get paddingXS => SizeConfig.w(8);
  static double get paddingSM => SizeConfig.w(12);
  static double get paddingMD => SizeConfig.w(16);
  static double get paddingLG => SizeConfig.w(20);
  static double get paddingXL => SizeConfig.w(24);
  static double get paddingPage => SizeConfig.w(24);

  // ─── Border Radius ─────────────────────────────────────────────────────────
  static double get radiusXS => SizeConfig.r(4);
  static double get radiusSM => SizeConfig.r(8);
  static double get radiusMD => SizeConfig.r(10);
  static double get radiusLG => SizeConfig.r(14);
  static double get radiusXL => SizeConfig.r(20);
  static double get radiusXXL => SizeConfig.r(32);
  static double get radiusCircle => SizeConfig.r(100);


  // ─── Font Sizes ────────────────────────────────────────────────────────────
  static double get fontXS => SizeConfig.sp(11);
  static double get fontSM => SizeConfig.sp(12);
  static double get fontMD => SizeConfig.sp(14);
  static double get fontLG => SizeConfig.sp(16);
  static double get fontXL => SizeConfig.sp(18);
  static double get fontXXL => SizeConfig.sp(22);
  static double get fontDisplay => SizeConfig.sp(28);

  // ─── Icon Sizes ────────────────────────────────────────────────────────────
  static double get iconSM => SizeConfig.r(16);
  static double get iconMD => SizeConfig.r(20);
  static double get iconLG => SizeConfig.r(24);
  static double get iconXL => SizeConfig.r(32);

  // ─── Component Heights ─────────────────────────────────────────────────────
  static double get inputHeight => SizeConfig.h(52);
  static double get buttonHeight => SizeConfig.h(50);
  static double get appBarHeight => SizeConfig.h(56);
  static double get dividerHeight => SizeConfig.h(1);

  // ─── Logo / Branding ───────────────────────────────────────────────────────
  static double get logoSize => SizeConfig.r(64);

  // ─── Avatar ────────────────────────────────────────────────────────────────
  static double get avatarMD => SizeConfig.r(40);
  static double get avatarLG => SizeConfig.r(52);
}
