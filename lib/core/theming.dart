import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData get lightTheme => ThemeData(
    primaryColor: Color(0xFF2E2087),
    scaffoldBackgroundColor: Color(0xFFF5F5F5),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        overlayColor: Colors.transparent,
        minimumSize: Size(193.w, 58.h),
        backgroundColor: Color(0xFF231480),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.r),
        ),
      ),
    ),
  );
}
