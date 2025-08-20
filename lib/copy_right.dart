import 'package:flutter/material.dart';

class CopyrightWidget extends StatelessWidget {
  final Color? textColor;
  final double? fontSize;
  final String appName;
  final String devName;

  const CopyrightWidget({
    super.key,
    this.textColor,
    this.fontSize,
    this.appName = 'Si Absensi',
    this.devName = 'Endah F N',
  });

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          '$appName. © $currentYear - $devName.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor ?? Colors.grey[600],
            fontSize: fontSize ?? 12.0,
          ),
        ),
      ),
    );
  }
}
