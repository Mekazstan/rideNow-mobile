import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class ContactListShimmer extends StatelessWidget {
  final int itemCount;

  const ContactListShimmer({super.key, this.itemCount = 10});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: itemCount,
      separatorBuilder: (_, __) => Divider(height: 1.h),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
          child: Row(
            children: [
              AvatarShimmer(size: 48.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 150.w, height: 16.h, borderRadius: 4.r),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 120.w, height: 14.h, borderRadius: 4.r),
                  ],
                ),
              ),
              ShimmerBox(width: 24.w, height: 24.h, borderRadius: 12.r),
            ],
          ),
        );
      },
    );
  }
}
