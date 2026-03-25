// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/user_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';
import 'package:intl/intl.dart';

class LetsGetToKnowYouScreen extends StatefulWidget {
  const LetsGetToKnowYouScreen({super.key});

  @override
  State<LetsGetToKnowYouScreen> createState() => _LetsGetToKnowYouScreenState();
}

class _LetsGetToKnowYouScreenState extends State<LetsGetToKnowYouScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _dateOfBirthController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _selectedCountryCode = '+234';
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.isAuthenticated && authProvider.user != null) {
      final user = authProvider.user!;
      _fullNameController.text = '${user.firstName} ${user.lastName}';
      return;
    }

    if (authProvider.tempEmail == null) {
      ToastService.showWarning('Session Expired');
      context.goNamed(RouteConstants.signUp);
      return;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: appColors.blue600,
              onPrimary: appColors.textWhite,
              surface: appColors.textWhite,
              onSurface: appColors.gray900,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return RidenowScaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 19),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 58.h),
                        const StepIndicator(
                          currentStep: 2,
                          totalSteps: 4,
                          stepLabels: ['', 'Lets get to know you', '', ''],
                          showStepLabels: [false, true, false, false],
                        ),
                        SizedBox(height: 13.h),
                        Text(
                          'Lets get to know you',
                          style: appFonts.heading1Bold.copyWith(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: appColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Card(
                          elevation: 0,
                          color: appColors.gray50,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                RidenowTextfield(
                                  fieldName: 'FirstName and LastName',
                                  hintText: 'Firstname Lastname',
                                  controller: _fullNameController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Full name is required';
                                    }
                                    if (value.trim().split(' ').length < 2) {
                                      return 'Please enter your first and last name';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                _buildDateOfBirthField(appFonts, appColors),
                                SizedBox(height: 16.h),
                                _buildPhoneNumberField(appFonts, appColors),
                                SizedBox(height: 24.h),
                                _buildNextButton(appColors, appFonts),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateOfBirthField(
    AppFontThemeExtension appFonts,
    AppColorExtension appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of birth',
          style: appFonts.textBaseMedium.copyWith(
            color: appColors.gray300,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: AbsorbPointer(
            child: TextFormField(
              controller: _dateOfBirthController,
              style: appFonts.textBaseMedium.copyWith(
                color: appColors.gray900,
                fontSize: 16.sp,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Date of birth is required';
                }
                return null;
              },
              decoration: InputDecoration(
                hintText: '12/09/2001',
                hintStyle: appFonts.textBaseMedium.copyWith(
                  color: appColors.gray400,
                  fontSize: 16.sp,
                ),
                suffixIcon: Icon(
                  Icons.calendar_today,
                  color: appColors.gray500,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: appColors.textWhite,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: appColors.gray300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: appColors.gray300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: appColors.blue600),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: Colors.red),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 16.h,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField(
    AppFontThemeExtension appFonts,
    AppColorExtension appColors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone number',
          style: appFonts.textBaseMedium.copyWith(
            color: appColors.gray300,
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: appColors.textWhite,
                border: Border.all(color: appColors.gray300),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCountryCode,
                  items: [
                    DropdownMenuItem(
                      value: '+234',
                      child: Text(
                        '+234',
                        style: appFonts.textBaseMedium.copyWith(
                          color: appColors.gray900,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '+1',
                      child: Text(
                        '+1',
                        style: appFonts.textBaseMedium.copyWith(
                          color: appColors.gray900,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    DropdownMenuItem(
                      value: '+44',
                      child: Text(
                        '+44',
                        style: appFonts.textBaseMedium.copyWith(
                          color: appColors.gray900,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCountryCode = newValue;
                      });
                    }
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: appColors.gray500,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SizedBox(
                height: 48.h,
                child: TextFormField(
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                  style: appFonts.textBaseMedium.copyWith(
                    color: appColors.gray900,
                    fontSize: 16.sp,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Phone number is required';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '901 234 5678',
                    hintStyle: appFonts.textBaseMedium.copyWith(
                      color: appColors.gray400,
                      fontSize: 16.sp,
                    ),
                    filled: true,
                    fillColor: appColors.textWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: appColors.gray300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: appColors.gray300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: appColors.blue600),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNextButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: _isLoading ? 'Saving...' : 'Next',
      onTap: _handleNext,
      isLoading: _isLoading,
      leadingIcon: _isLoading ? null : SvgPicture.asset('assets/forwardArrow.svg'),
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    print('âœ… Form validated, starting signup...');

    setState(() {
      _isLoading = true;
    });

    try {
      final fullNameParts = _fullNameController.text.trim().split(' ');
      final firstName = fullNameParts.first;
      final lastName =
          fullNameParts.length > 1
              ? fullNameParts.sublist(1).join(' ')
              : fullNameParts.first;

      final fullPhoneNumber =
          '$_selectedCountryCode${_phoneNumberController.text.trim()}';

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      if (authProvider.isAuthenticated) {
        final dateOfBirth = _selectedDate != null
            ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
            : null;

        ToastService.init(context);

        final success = await authProvider.submitBioData(
          firstName: firstName,
          lastName: lastName,
          phone: fullPhoneNumber,
          dateOfBirth: dateOfBirth ?? '',
        );

        if (!mounted) return;

        setState(() {
          _isLoading = false;
        });

        if (success) {
          ToastService.showSuccess('Profile Updated!');
          context.goNamed(RouteConstants.emergencyContact);
        } else {
          ToastService.showError(authProvider.errorMessage ?? 'Update failed');
        }
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userType = userProvider.selectedUserType?.value ?? 'rider';
      final success = await authProvider.completeSignUp(
        firstName: firstName,
        lastName: lastName,
        phone: fullPhoneNumber,
        userType: userType,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      if (success) {
        ToastService.showSuccess('Account Created!');

        await Future.delayed(const Duration(milliseconds: 200));

        if (mounted) {
          context.goNamed(
            RouteConstants.verifyAccount,
            extra: {
              'email': authProvider.tempEmail ?? authProvider.user?.email,
            },
          );
        }
      } else {
        if (authProvider.hasError && authProvider.lastError != null) {
          if (authProvider.errorMessage != null) {
            ToastService.showError('Sign Up Failed');
          } else {
            ToastService.showError('Sign Up Failed');
          }
          authProvider.clearErrors();
        }
      }
    } catch (e, stackTrace) {
      ToastService.showError('Operation Failed');
    } finally {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
