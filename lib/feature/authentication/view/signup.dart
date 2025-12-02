import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/authentication/view/login.dart';
import 'package:library_project/feature/authentication/view/widgets/custom_text_field.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_notifier.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';

class Signup extends ConsumerStatefulWidget {
  const Signup({super.key});
  static const String routeName = '/signup';

  @override
  ConsumerState<Signup> createState() => _SignupState();
}

class _SignupState extends ConsumerState<Signup> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    // Email regex pattern
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    // Show error message if there's an error and navigate on success
    ref.listen<AuthenticationState>(authNotifierProvider, (previous, next) {
      if (next is AuthenticationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error), backgroundColor: Colors.red),
        );
      }
      // Clear text fields and navigate to home if signup successful
      if (next is AuthenticationLoaded &&
          previous is! AuthenticationLoaded &&
          mounted) {
        // Clear all text fields
        _firstNameController.clear();
        _lastNameController.clear();
        _emailController.clear();
        _passwordController.clear();
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });

    return Scaffold(
      backgroundColor: Color(0xFFDCDBFD),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 40.h),
                // Create Account Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF231480),
                  ),
                ),
                SizedBox(height: 8.h),
                // Subtitle
                Text(
                  'Sign up to start your reading journey.',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF989898),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40.h),
                // First Name Field
                CustomTextField(
                  hintText: 'First Name',
                  controller: _firstNameController,
                ),
                SizedBox(height: 16.h),
                // Last Name Field
                CustomTextField(
                  hintText: 'Last Name',
                  controller: _lastNameController,
                ),
                SizedBox(height: 16.h),
                // Email Field
                CustomTextField(
                  hintText: 'Email Address',
                  controller: _emailController,
                ),
                SizedBox(height: 16.h),
                // Password Field
                CustomTextField(
                  hintText: 'Password',
                  obscureText: _obscurePassword,
                  controller: _passwordController,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: Color(0xFF989898),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                SizedBox(height: 32.h),
                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState is AuthenticationLoading
                        ? null
                        : () async {
                            final firstName = _firstNameController.text.trim();
                            final lastName = _lastNameController.text.trim();
                            final email = _emailController.text.trim();
                            final password = _passwordController.text;

                            if (firstName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter your first name'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (lastName.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter your last name'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (!isValidEmail(email)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Please enter a valid email address',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            if (password.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Please enter a password'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            await authNotifier.signUp(
                              email: email,
                              password: password,
                              firstName: firstName,
                              lastName: lastName,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF231480),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Color(
                        0xFF231480,
                      ).withOpacity(0.6),
                    ),
                    child: authState is AuthenticationLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 24.h),
                // Already have account Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF989898),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(
                          context,
                          Login.routeName,
                        );
                      },
                      child: Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF231480),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
