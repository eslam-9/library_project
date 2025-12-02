import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/authentication/view/widgets/custom_text_field.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_notifier.dart';
import 'package:library_project/feature/authentication/viewmodel/auth_state.dart';

class AdminProfileScreen extends ConsumerStatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  ConsumerState<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends ConsumerState<AdminProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authState = ref.read(authNotifierProvider);
    if (authState is AuthenticationLoaded) {
      _nameController.text = authState.user.name;
      _emailController.text = authState.user.email;
      _phoneController.text = authState.user.phone;
      _addressController.text = authState.user.address;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final authNotifier = ref.read(authNotifierProvider.notifier);

    ref.listen<AuthenticationState>(authNotifierProvider, (previous, next) {
      if (next is AuthenticationError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.error), backgroundColor: Colors.red),
        );
      } else if (next is AuthenticationLoaded &&
          previous is AuthenticationLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFF231480),
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Admin Profile',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_isEditing) {
                  _loadUserData();
                }
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(
              _isEditing ? Icons.close : Icons.edit,
              color: const Color(0xFF231480),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50.r,
                backgroundColor: const Color(0xFF231480),
                child: Text(
                  _nameController.text.isNotEmpty
                      ? _nameController.text[0].toUpperCase()
                      : 'A',
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 32.h),
              CustomTextField(
                hintText: 'Full Name',
                controller: _nameController,
                readOnly: !_isEditing,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: 'Email Address',
                controller: _emailController,
                readOnly: true,
                fillColor: Colors.grey.shade200,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: 'Phone Number',
                controller: _phoneController,
                readOnly: !_isEditing,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: 'Address',
                controller: _addressController,
                readOnly: !_isEditing,
                maxLines: 3,
              ),
              SizedBox(height: 32.h),
              if (_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authState is AuthenticationLoading
                        ? null
                        : () async {
                            await authNotifier.updateProfile(
                              fullName: _nameController.text.trim(),
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF231480),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: authState is AuthenticationLoading
                        ? SizedBox(
                            height: 20.h,
                            width: 20.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              if (!_isEditing)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await authNotifier.signOut();
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
