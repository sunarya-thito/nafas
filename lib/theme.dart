import 'package:flutter/material.dart';

class GlassThemeData {
  final Color backgroundColor;
  final Color primaryTextColor;
  final Color secondaryTextColor;
  final Color surfaceColor;
  final Color disabledSurfaceColor;
  final Color surfaceBorderColor;
  final Color surfaceBorderDisabledColor;
  final Color selectedSurfaceColor;
  final Color selectedSurfaceBorderColor;
  final Color badgeColor;
  final Color goodBadgeColor;
  final Color surfaceWarningColor;
  final Color surfaceErrorColor;
  final Color surfaceBorderWarningColor;
  final Color surfaceBorderErrorColor;
  final Color primaryWarningTextColor;
  final Color primaryErrorTextColor;
  final Color sliderTrackColor;
  final Color sliderActiveTrackColor;
  final Color sliderThumbColor;

  const GlassThemeData.dark({
    this.backgroundColor = const Color(0xFF040608),
    this.primaryTextColor = const Color(0xFFFFFFFF),
    this.secondaryTextColor = const Color(0xFFAFCEED),
    this.surfaceColor = const Color(0xFF0F151F),
    this.surfaceBorderColor = const Color(0xFF1B2639),
    this.disabledSurfaceColor = const Color(0xFF0F151F),
    this.surfaceBorderDisabledColor = const Color(0xFF1B2639),
    this.selectedSurfaceColor = const Color(0xFF4E7093),
    this.selectedSurfaceBorderColor = const Color(0xFF688FB5),
    this.badgeColor = const Color(0xFFDE4343),
    this.goodBadgeColor = const Color(0xFF70C453),
    this.surfaceWarningColor = const Color(0xFF1F1A0F),
    this.surfaceErrorColor = const Color(0xFF1F0F0F),
    this.surfaceBorderWarningColor = const Color(0xFF39301B),
    this.surfaceBorderErrorColor = const Color(0xFF391B1B),
    this.primaryWarningTextColor = const Color(0xFFEDD8AF),
    this.primaryErrorTextColor = const Color(0xFFEDAFAF),
    this.sliderTrackColor = const Color(0xFF182C41),
    this.sliderActiveTrackColor = const Color(0xFF0E9CFF),
    this.sliderThumbColor = const Color(0xFFAFCEED),
  });

  const GlassThemeData.light({
    this.backgroundColor = const Color(0xFFE5E5E5),
    this.primaryTextColor = const Color(0xFF000000),
    this.secondaryTextColor = const Color(0xFF5C5C5C),
    this.surfaceColor = const Color(0xFFFFFFFF),
    this.surfaceBorderColor = const Color(0xFFBFBFBF),
    this.disabledSurfaceColor = const Color(0xFFE5E5E5),
    this.surfaceBorderDisabledColor = const Color(0xFFBFBFBF),
    this.selectedSurfaceColor = const Color(0xFFE5E5E5),
    this.selectedSurfaceBorderColor = const Color(0xFFBFBFBF),
    this.badgeColor = const Color(0xFFDE4343),
    this.goodBadgeColor = const Color(0xFF70C453),
    this.surfaceWarningColor = const Color(0xFFE5E5E5),
    this.surfaceErrorColor = const Color(0xFFE5E5E5),
    this.surfaceBorderWarningColor = const Color(0xFFBFBFBF),
    this.surfaceBorderErrorColor = const Color(0xFFBFBFBF),
    this.primaryWarningTextColor = const Color(0xFF5C5C5C),
    this.primaryErrorTextColor = const Color(0xFF5C5C5C),
    this.sliderTrackColor = const Color(0xFFE5E5E5),
    this.sliderActiveTrackColor = const Color(0xFF0E9CFF),
    this.sliderThumbColor = const Color(0xFFAFCEED),
  });

  TextStyle text(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      TextOverflow? overflow}) {
    return TextStyle(
      color: color ?? primaryTextColor,
      fontFamily: 'Inter',
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      overflow: overflow,
    );
  }

  TextStyle secondaryText(
      {Color? color,
      double? fontSize,
      FontWeight? fontWeight,
      FontStyle? fontStyle,
      TextOverflow? overflow}) {
    return text(
      color: color ?? secondaryTextColor,
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      overflow: overflow,
    );
  }
}

class GlassTheme extends InheritedWidget {
  final GlassThemeData data;

  const GlassTheme({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  static GlassThemeData of(BuildContext context) {
    final GlassTheme? result =
        context.dependOnInheritedWidgetOfExactType<GlassTheme>();
    assert(result != null, 'No GlassTheme found in context');
    return result!.data;
  }

  @override
  bool updateShouldNotify(GlassTheme oldWidget) => data != oldWidget.data;
}

extension GlassThemeExtension on BuildContext {
  GlassThemeData get theme => GlassTheme.of(this);
}

extension GlassThemeStatelessExtension on StatelessWidget {
  GlassThemeData theme(BuildContext context) => GlassTheme.of(context);
}
