import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:library_project/feature/admin/model/admin_dashboard_model.dart';

class BorrowingTile extends StatelessWidget {
  final BorrowingRecord record;

  const BorrowingTile({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final statusColor = record.returnedAt != null
        ? const Color(0xFF30C48D)
        : (record.dueAt != null &&
              record.dueAt!.isBefore(DateTime.now()) &&
              record.returnedAt == null)
        ? const Color(0xFFFF6B6B)
        : const Color(0xFFFFB347);

    final statusLabel = record.status;

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  record.bookTitle,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF231480),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            record.memberLabel,
            style: TextStyle(fontSize: 14.sp, color: const Color(0xFF989898)),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _InfoChip(
                icon: Icons.calendar_month_outlined,
                label: 'Borrowed ${_formatDate(record.borrowedAt)}',
              ),
              SizedBox(width: 12.w),
              if (record.dueAt != null)
                _InfoChip(
                  icon: Icons.timer_outlined,
                  label: 'Due ${_formatDate(record.dueAt!)}',
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFDCDBFD),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.w, color: const Color(0xFF231480)),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              color: const Color(0xFF231480),
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
