import 'package:flutter/material.dart';
import 'package:library_project/core/root_screen.dart';
import 'package:library_project/feature/admin/view/admin_dashboard_screen.dart';
import 'package:library_project/feature/admin/view/admin_main_screen.dart';
import 'package:library_project/feature/authentication/view/login.dart';
import 'package:library_project/feature/authentication/view/signup.dart';
import 'package:library_project/feature/member/view/member_dashboard_screen.dart';
import 'package:library_project/feature/admin/view/admin_add_book_screen.dart';
import 'package:library_project/feature/member/view/member_books_screen.dart';
import 'package:library_project/feature/member/view/member_main_screen.dart';
import 'package:library_project/feature/onboarding/view/onboardingScreen.dart';

class AppRoute {
  static Route<dynamic>? generate(RouteSettings settings) {
    switch (settings.name) {
      case RootScreen.routeName:
        return MaterialPageRoute(builder: (_) => const RootScreen());
      case OnboardingScreen.routeName:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case Login.routeName:
        return MaterialPageRoute(builder: (_) => const Login());
      case Signup.routeName:
        return MaterialPageRoute(builder: (_) => const Signup());
      case AdminDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminDashboardScreen());
      case MemberDashboardScreen.routeName:
        return MaterialPageRoute(builder: (_) => const MemberDashboardScreen());
      case AdminAddBookScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminAddBookScreen());
      case MemberBooksScreen.routeName:
        return MaterialPageRoute(builder: (_) => const MemberBooksScreen());
      case AdminMainScreen.routeName:
        return MaterialPageRoute(builder: (_) => const AdminMainScreen());
      case MemberMainScreen.routeName:
        return MaterialPageRoute(builder: (_) => const MemberMainScreen());
      default:
        return MaterialPageRoute(builder: (_) => const RootScreen());
    }
  }
}
