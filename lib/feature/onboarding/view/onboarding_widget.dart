import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingWidget extends StatelessWidget {
  const OnboardingWidget({
    Key? key,
    required this.image,
    required this.title,
    required this.description,
  }) : super(key: key);

  final String image;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 504.h,
          width: double.infinity,
          color: Color(0xFFDCDBFD),
          child: Center(child: Image.asset(image)),
        ),
        SizedBox(height: 36.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 35.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF231480),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF989898),
            ),
          ),
        ),
      ],
    );
  }
}
