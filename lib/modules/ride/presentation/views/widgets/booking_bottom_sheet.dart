// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/enums/vehicle_type_enum.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class BookingBottomSheet extends StatefulWidget {
  final VehicleType selectedVehicle;
  final String pickupAddress;
  final String destinationAddress;
  final double walletBalance;
  final Function(double amount, bool autoAccept) onBookRide;
  final VoidCallback onTopUp;

  const BookingBottomSheet({
    super.key,
    required this.selectedVehicle,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.walletBalance,
    required this.onBookRide,
    required this.onTopUp,
  });

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  bool _autoAccept = false;
  bool _showConfirmation = false;
  double _enteredAmount = 0.0;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onContinue() {
    final amount = _amountController.text.toNumber();
    if (amount <= 0) {
      ToastService.showWarning('Please enter a valid amount');
      return;
    }
    setState(() {
      _enteredAmount = amount;
      _showConfirmation = true;
    });
  }

  void _onBookRide() {
    widget.onBookRide(_enteredAmount, _autoAccept);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child:
          _showConfirmation
              ? _buildConfirmationView()
              : _buildAmountInputView(),
    );
  }

  Widget _buildAmountInputView() {
    final hasInsufficientBalance =
        _amountController.text.toNumber() > widget.walletBalance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        SizedBox(height: 8.h),
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),

        // Pink Amount Section
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD6E0), // Light pink
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(
                'How much do you want to pay',
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
              SizedBox(height: 12.h),
              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 36.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE91E63),
                ),
                decoration: InputDecoration(
                  prefixText: '₦',
                  prefixStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE91E63),
                  ),
                  border: InputBorder.none,
                  hintText: '5000',
                  hintStyle: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFE91E63).withOpacity(0.3),
                  ),
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (hasInsufficientBalance) ...[
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: widget.onTopUp,
                  child: Text(
                    'You don\'t have enough in your wallet. Top up',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: const Color(0xFFE91E63),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 16.h),

        // Auto-accept Toggle
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 28.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14.r),
                  color:
                      _autoAccept ? const Color(0xFF4285F4) : Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: _autoAccept ? 22.w : 2.w,
                      top: 2.h,
                      child: Container(
                        width: 24.w,
                        height: 24.h,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ).onTap(() => setState(() => _autoAccept = !_autoAccept)),
              SizedBox(width: 12.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    children: [
                      const TextSpan(text: 'Accept the nearest driver for '),
                      TextSpan(
                        text:
                            (_amountController.text.isEmpty ? "5000" : _amountController.text).formatAmountWithCurrency(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: '\nautomatically.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),

        // Continue Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: hasInsufficientBalance ? null : _onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE0E0E0),
                disabledBackgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continue',
                style: TextStyle(
                  color: hasInsufficientBalance ? Colors.grey : Colors.black87,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildConfirmationView() {
    final hasInsufficientBalance = _enteredAmount > widget.walletBalance;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Drag Handle
        SizedBox(height: 8.h),
        Center(
          child: Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
        SizedBox(height: 24.h),

        // Title
        Text(
          'Your Ride is ${_enteredAmount.formatAmountWithCurrency()}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 20.h),

        // Wallet Balance Card
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5FF), // Light blue-grey
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text(
                'Your Wallet Balance',
                style: TextStyle(fontSize: 13.sp, color: Colors.black54),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.walletBalance.formatAmountWithCurrency(),
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              if (hasInsufficientBalance) ...[
                SizedBox(height: 4.h),
                Text(
                  'Insufficient wallet balance',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFE91E63),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
              SizedBox(height: 16.h),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: hasInsufficientBalance ? null : _onBookRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4), // Blue
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Book ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: widget.onTopUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE0E0E0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Top-up',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Ride Details
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: const Color(0xFF4285F4),
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Your ride details',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _buildDetailRow('Going to', widget.destinationAddress),
              SizedBox(height: 8.h),
              _buildDetailRow('From', widget.pickupAddress),
              SizedBox(height: 8.h),
              _buildDetailRow('Vehicle', widget.selectedVehicle.displayName),
            ],
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.black54)),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

extension on Widget {
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}
