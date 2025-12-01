import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/core/theming.dart';
import 'package:library_project/core/root_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://ujbjmvvcmdaayraixqji.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVqYmptdnZjbWRhYXlyYWl4cWppIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDI0OTUsImV4cCI6MjA4MDA3ODQ5NX0.8YSs6J155KD3JymePwxvig3WQlxsR-__uQb_caNLTDc",
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //Set the fit size (Find your UI design, look at the dimensions of the device screen and fill it in,unit in dp)
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return ProviderScope(
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Library app',
            theme: AppTheme.lightTheme,
            home: const RootScreen(),
          ),
        );
      },
    );
  }
}
