import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/view/widgets/admin_add_book_body.dart';
import 'package:library_project/service/admin_service.dart';

class AdminAddBookScreen extends StatefulWidget {
  const AdminAddBookScreen({super.key});
  static const String routeName = '/adminAddBook';

  @override
  State<AdminAddBookScreen> createState() => _AdminAddBookScreenState();
}

class _AdminAddBookScreenState extends State<AdminAddBookScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _copiesController = TextEditingController(
    text: '1',
  );
  final TextEditingController _priceController = TextEditingController();

  List<Map<String, dynamic>> _categories = [];
  int? _selectedCategoryId;
  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await AdminService.fetchAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingCategories = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load categories'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _copiesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();
    final description = _descriptionController.text.trim();
    final copiesText = _copiesController.text.trim();
    final priceText = _priceController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a book title'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    double price = double.tryParse(priceText) ?? 0.0;
    if (price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid price greater than 0'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    int copies = int.tryParse(copiesText) ?? 1;
    if (copies < 1 || copies > 1000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Number of copies must be between 1 and 1000'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await AdminService.addBook(
        title: title,
        author: author.isEmpty ? null : author,
        description: description.isEmpty ? null : description,
        categoryId: _selectedCategoryId,
        dailyPrice: price,
        copiesCount: copies,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added successfully'),
          backgroundColor: Color(0xFF231480),
        ),
      );

      // Clear the form fields for adding another book
      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _copiesController.text = '1';
      setState(() {
        _selectedCategoryId = null;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add book. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCDBFD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDCDBFD),
        elevation: 0,
        title: Text(
          'Add New Book',
          style: TextStyle(
            color: const Color(0xFF231480),
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: AdminAddBookBody(
        titleController: _titleController,
        authorController: _authorController,
        descriptionController: _descriptionController,
        copiesController: _copiesController,
        priceController: _priceController,
        categories: _categories,
        selectedCategoryId: _selectedCategoryId,
        isLoadingCategories: _isLoadingCategories,
        isSubmitting: _isSubmitting,
        onCategoryChanged: (value) {
          setState(() {
            _selectedCategoryId = value;
          });
        },
        onSubmit: _handleSubmit,
      ),
    );
  }
}
