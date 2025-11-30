import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/onboarding/model/onboarding_model.dart';
import 'package:library_project/feature/onboarding/view/onboarding_widget.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);
  static const String routeName = '/onboarding';

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingModel> pages = [
    OnboardingModel(
      title: "Find Your Book",
      description:
          "Find your next read from a wide collection of\nnovels, textbooks, and more.",
      image: "assets/images/onboarding1.png",
    ),
    OnboardingModel(
      title: "Save Your Favorites",
      description:
          "Bookmark books, create reading lists, and keep\neverything organized in one place.",
      image: "assets/images/onboarding2.png",
    ),
    OnboardingModel(
      title: "Read Anytime",
      description:
          "Access your library instantly on any device and\nenjoy a smooth reading experience.",
      image: "assets/images/onboarding3.png",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _currentPage = _controller.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleNextButton() {
    if (_controller.page == pages.length - 1) {
      // Navigate to next screen (e.g., login or home)
      // Navigator.pushReplacementNamed(context, '/home');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              itemBuilder: (_, i) => OnboardingWidget(
                image: pages[i].image,
                title: pages[i].title,
                description: pages[i].description,
              ),
              itemCount: pages.length,
              controller: _controller,
            ),
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: _handleNextButton,
            child: Text(
              _currentPage == pages.length - 1 ? 'Start Now' : 'Next',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          SmoothPageIndicator(
            controller: _controller,
            count: pages.length,
            effect: WormEffect(
              activeDotColor: Color(0xFF2E2087),
              dotColor: Color.fromARGB(255, 180, 175, 213),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }
}
