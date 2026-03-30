import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class SubmitTicket extends StatefulWidget {
  const SubmitTicket({super.key});

  @override
  State<SubmitTicket> createState() => _SubmitTicketState();
}

class _SubmitTicketState extends State<SubmitTicket> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final supportProvider = context.read<SupportProvider>();

    final response = await supportProvider.submitTicket(
      name: _nameController.text,
      description: _descriptionController.text,
    );

    if (!mounted) return;

    if (response != null) {
      ToastService.showSuccess(response.message);

      _nameController.clear();
      _descriptionController.clear();
      _formKey.currentState!.reset();
    } else {
      ToastService.showError(
        supportProvider.errorMessage ??
            'Failed to submit ticket. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 27.h),
              Text(
                'RideNow is a safety first ride-hailing application that helps users stay safe on the road. It\'s fun, engaging and decisive.',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 27.h),
              RidenowTextfield(
                fieldName: 'Name',
                hintText: 'First name',
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 17.h),
              RidenowTextfield(
                fieldName: 'What would you like to report?',
                hintText: 'I caught a suspicious account...',
                controller: _descriptionController,
                maxLines: 6,
                minLines: 6,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length < 10) {
                    return 'Description must be at least 10 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 17.h),
              Consumer<SupportProvider>(
                builder: (context, supportProvider, child) {
                  return RideNowButton(
                    colorSet: RideNowButtonColorSet.primary,
                    width: 349.w,
                    height: 49.h,
                    title:
                        supportProvider.isLoadingTicket
                            ? 'Submitting...'
                            : 'Submit',
                    onTap:
                        supportProvider.isLoadingTicket
                            ? () {}
                            : () => _handleSubmit(),
                    isLoading: supportProvider.isLoadingTicket,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
