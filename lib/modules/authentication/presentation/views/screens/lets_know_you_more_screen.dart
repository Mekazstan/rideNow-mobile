// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/user_provider.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_scaffold.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:ridenowappsss/shared/widgets/step_indicator.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class LetsKnowYouMoreScreen extends StatefulWidget {
  const LetsKnowYouMoreScreen({super.key});

  @override
  State<LetsKnowYouMoreScreen> createState() => _LetsKnowYouMoreScreenState();
}

class _LetsKnowYouMoreScreenState extends State<LetsKnowYouMoreScreen> {
  final TextEditingController _plateNumberController = TextEditingController();
  final TextEditingController _makeController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _carImages = [];
  String? _selectedVehicleType;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final List<Map<String, String>> _vehicleTypes = [
    {'value': 'standard_ride', 'label': 'Standard Ride'},
    {'value': 'luxury_vehicle', 'label': 'Luxury Vehicle'},
    {'value': 'bike', 'label': 'Bike'},
    {'value': 'tricycle', 'label': 'Tricycle'},
    {'value': 'seater_bus', 'label': 'Seater Bus'},
  ];


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _plateNumberController.dispose();
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
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
                          stepLabels: ["", "Let's know you more", "", ""],
                          showStepLabels: [false, true, false, false],
                        ),
                        SizedBox(height: 13.h),
                        Text(
                          'Let’s know you, more...',
                          style: appFonts.heading1Bold.copyWith(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: appColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 32.h),
                        Card(
                          elevation: 0,
                          color: appColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                RidenowTextfield(
                                  fieldName: 'Plate Number',
                                  hintText: 'ABJ-908-1234',
                                  controller: _plateNumberController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Plate number is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                _buildVehicleTypeDropdown(appColors, appFonts),
                                SizedBox(height: 16.h),
                                RidenowTextfield(
                                  fieldName: 'Car Make',
                                  hintText: 'E.g Toyota, Honda, Keke',
                                  controller: _makeController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Car make is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                RidenowTextfield(
                                  fieldName: 'Car Model',
                                  hintText: 'E.g Corolla, Accord, NAPEP',
                                  controller: _modelController,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Car model is required';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: RidenowTextfield(
                                        fieldName: 'Year (Optional)',
                                        hintText: 'E.g 2020',
                                        controller: _yearController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value != null && value.trim().isNotEmpty) {
                                            final year = int.tryParse(value.trim());
                                            if (year == null || year < 1990 || year > DateTime.now().year + 1) {
                                              return 'Enter a valid year';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: RidenowTextfield(
                                        fieldName: 'Color (Optional)',
                                        hintText: 'E.g Black, Silver',
                                        controller: _colorController,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),
                                _buildMultiImagePicker(
                                  label: 'Car Images',
                                  images: _carImages,
                                  onTap: () => _pickCarImages(),
                                  onRemove: (index) {
                                    setState(() {
                                      _carImages.removeAt(index);
                                    });
                                  },
                                  appColors: appColors,
                                  appFonts: appFonts,
                                ),
                                SizedBox(height: 32.h),
                                _buildNextButton(appColors, appFonts),
                                // SizedBox(height: 16.h),
                                // _buildSkipButton(appColors, appFonts),
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

  Widget _buildSkipButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Center(
      child: GestureDetector(
        onTap: () {
          context.goNamed(RouteConstants.driverDocumentCollection);
        },
        child: Text(
          'Skip',
          style: appFonts.textMdMedium.copyWith(
            color: appColors.blue600,
            decoration: TextDecoration.underline,
            decorationColor: appColors.blue600,
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RideNowButton(
      title: 'Next',
      onTap: _handleNext,
      isLoading: _isLoading,
      leadingIcon: _isLoading ? null : SvgPicture.asset('assets/forwardArrow.svg'),
    );
  }


  Future<void> _pickCarImages() async {
    try {
      final List<XFile>? images = await _picker.pickMultiImage(
        imageQuality: 70,
      );
      if (images != null && images.isNotEmpty) {
        setState(() {
          _carImages.addAll(images.map((img) => File(img.path)));
        });
      }
    } catch (e) {
      ToastService.showError('Failed to pick car images');
    }
  }

  Widget _buildFilePicker({
    required String label,
    required File? file,
    required VoidCallback onTap,
    required AppColorExtension appColors,
    required AppFontThemeExtension appFonts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFonts.textSmMedium.copyWith(color: appColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: appColors.gray100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: appColors.gray300),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Icon(
                    file != null ? Icons.check_circle : Icons.upload_file,
                    color: file != null ? appColors.green400 : appColors.blue600,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      file != null
                          ? file.path.split('/').last
                          : 'Select $label',
                      style: appFonts.textSmRegular.copyWith(
                        color: file != null
                            ? appColors.textPrimary
                            : appColors.gray400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMultiImagePicker({
    required String label,
    required List<File> images,
    required VoidCallback onTap,
    required Function(int) onRemove,
    required AppColorExtension appColors,
    required AppFontThemeExtension appFonts,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: appFonts.textSmMedium.copyWith(color: appColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        if (images.isNotEmpty)
          SizedBox(
            height: 80.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: images.length + 1,
              itemBuilder: (context, index) {
                if (index == images.length) {
                  return GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 80.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: appColors.gray100,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(color: appColors.gray300, style: BorderStyle.solid),
                      ),
                      child: Icon(Icons.add_a_photo, color: appColors.blue600),
                    ),
                  );
                }
                return Stack(
                  children: [
                    Container(
                      width: 80.w,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: DecorationImage(
                          image: FileImage(images[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => onRemove(index),
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, size: 14, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          )
        else
          GestureDetector(
            onTap: onTap,
            child: Container(
              height: 56.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: appColors.gray100,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: appColors.gray300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo, color: appColors.blue600),
                  SizedBox(width: 8.w),
                  Text(
                    'Add Car Images',
                    style: appFonts.textSmRegular.copyWith(color: appColors.gray400),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _handleNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVehicleType == null) {
      ToastService.showWarning('Please select a vehicle type');
      return;
    }

    if (_carImages.isEmpty) {
      ToastService.showWarning('Please upload at least one car image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userType = userProvider.selectedUserType?.value ?? 'driver';

      final success = await authProvider.submitVehicleSetup(
        licensePlate: _plateNumberController.text.trim(),
        vehicleType: _selectedVehicleType!,
        make: _makeController.text.trim(),
        model: _modelController.text.trim(),
        year: _yearController.text.trim().isNotEmpty
            ? int.tryParse(_yearController.text.trim())
            : null,
        color: _colorController.text.trim().isNotEmpty
            ? _colorController.text.trim()
            : null,
        carImageFiles: _carImages,
      );

      if (success && mounted) {
        context.goNamed(RouteConstants.driverDocumentCollection);
      } else if (mounted) {
        ToastService.showError(authProvider.errorMessage ?? 'Failed to setup vehicle');
      }
    } catch (e) {
      ToastService.showError('An unexpected error occurred: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildVehicleTypeDropdown(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vehicle Type',
          style: appFonts.textSmMedium.copyWith(color: appColors.textSecondary),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: appColors.gray100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: appColors.gray300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedVehicleType,
              hint: Text(
                'Select Vehicle Type',
                style: appFonts.textSmRegular.copyWith(color: appColors.gray400),
              ),
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down, color: appColors.gray500),
              dropdownColor: appColors.textWhite,
              items:
                  _vehicleTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(
                        type['label']!,
                        style: appFonts.textSmRegular.copyWith(
                          color: appColors.textPrimary,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVehicleType = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

}
