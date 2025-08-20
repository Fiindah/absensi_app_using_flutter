import 'package:flutter/material.dart';

class CopyrightOverlay extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;
  final String appName;
  final String devName;

  const CopyrightOverlay({
    super.key,
    this.textColor,
    this.fontSize,
    this.appName = "Si Absensi",
    this.devName = "Endah F N",
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: Center(
        child: Text(
          '$appName © $currentYear — $devName',
          style: TextStyle(
            color: textColor ?? Colors.grey[600],
            fontSize: fontSize ?? 12.0,
          ),
        ),
      ),
    );
  }
}
