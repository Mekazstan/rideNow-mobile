// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/location_suggestion_list.dart';
import 'package:ridenowappsss/modules/ride/presentation/views/widgets/ride_screen_shimmer.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_textfield.dart';
import 'package:ridenowappsss/core/services/toast_service.dart';

class LocationInputSection extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final FocusNode pickupFocusNode;
  final FocusNode destinationFocusNode;
  final Function(PlacePrediction) onPickupSelected;
  final Function(PlacePrediction) onDestinationSelected;

  const LocationInputSection({
    super.key,
    required this.pickupController,
    required this.destinationController,
    required this.pickupFocusNode,
    required this.destinationFocusNode,
    required this.onPickupSelected,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        final appColors = Theme.of(context).extension<AppColorExtension>()!;
        final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

        // Show shimmer while initializing
        if (viewModel.isInitializing) {
          return const LocationInputSectionShimmer();
        }

        return Container(
          constraints: BoxConstraints(
            minHeight: 220.h,
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.r),
              topRight: Radius.circular(25.r),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 24.h),
                _SectionTitle(appColors: appColors, appFonts: appFonts),
                SizedBox(height: 20.h),
                _PickupLocationField(
                  controller: pickupController,
                  focusNode: pickupFocusNode,
                  onSelected: onPickupSelected,
                  appColors: appColors,
                  appFonts: appFonts,
                ),
                SizedBox(height: 12.h),
                _DestinationLocationField(
                  controller: destinationController,
                  focusNode: destinationFocusNode,
                  onSelected: onDestinationSelected,
                  appColors: appColors,
                  appFonts: appFonts,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PickupLocationField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(PlacePrediction) onSelected;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const _PickupLocationField({
    required this.controller,
    required this.focusNode,
    required this.onSelected,
    required this.appColors,
    required this.appFonts,
  });

  @override
  State<_PickupLocationField> createState() => _PickupLocationFieldState();
}

class _PickupLocationFieldState extends State<_PickupLocationField> {
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            RidenowTextfield(
              prefixIcon: Icon(
                Icons.search,
                color: widget.appColors.gray300,
                size: 16,
              ),
              fieldName: '',
              showFieldName: false,
              hintText: 'Your Pickup location',
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: (value) {
                if (!_isSelecting && value.isNotEmpty) {
                  viewModel.fetchPickupSuggestions(value);
                }
              },
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  setState(() => _isSelecting = true);
                  await viewModel.geocodeAndSelectPickup(value);
                  widget.focusNode.unfocus();

                  // Verify selection worked
                  if (viewModel.pickupLocation == null) {
                    debugPrint(
                      'âš ï¸ Pickup location is still null after geocoding',
                    );
                  } else {
                    debugPrint(
                      'âœ… Pickup selected: ${viewModel.pickupLocation?.address}',
                    );
                  }

                  setState(() => _isSelecting = false);
                }
              },
            ),

            // Show shimmer while loading suggestions
            if (viewModel.isLoadingPickupSuggestions)
              const LocationSuggestionsShimmer()
            else if (viewModel.showPickupSuggestions && !_isSelecting)
              LocationSuggestionsList(
                suggestions: viewModel.pickupSuggestions,
                onSelect: (prediction) async {
                  setState(() => _isSelecting = true);

                  debugPrint('ðŸ”µ Pickup selected: ${prediction.description}');

                  // Update text field first
                  widget.controller.text = prediction.description;

                  // Hide suggestions and unfocus
                  viewModel.hidePickupSuggestions();
                  widget.focusNode.unfocus();

                  // IMPORTANT: Select location in ViewModel
                  await viewModel.selectPickupLocation(prediction);

                  // Verify the location was set
                  if (viewModel.pickupLocation != null) {
                    debugPrint(
                      'âœ… Pickup location set: ${viewModel.pickupLocation?.address}',
                    );
                    debugPrint('   Lat: ${viewModel.pickupLocation?.latitude}');
                    debugPrint(
                      '   Lng: ${viewModel.pickupLocation?.longitude}',
                    );

                    // Call the callback to notify parent widget
                    await widget.onSelected(prediction);
                  } else {
                    debugPrint('âŒ Failed to set pickup location');
                    // Show error to user
                    if (mounted) {
                      ToastService.showError('Failed to select pickup location. Please try again.');
                    }
                  }

                  // Reset selecting flag
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    setState(() => _isSelecting = false);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class _DestinationLocationField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(PlacePrediction) onSelected;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const _DestinationLocationField({
    required this.controller,
    required this.focusNode,
    required this.onSelected,
    required this.appColors,
    required this.appFonts,
  });

  @override
  State<_DestinationLocationField> createState() =>
      _DestinationLocationFieldState();
}

class _DestinationLocationFieldState extends State<_DestinationLocationField> {
  bool _isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RideProvider>(
      builder: (context, viewModel, _) {
        return Column(
          children: [
            RidenowTextfield(
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: widget.appColors.gray300,
                size: 16,
              ),
              fieldName: '',
              showFieldName: false,
              hintText: 'Where to?',
              controller: widget.controller,
              focusNode: widget.focusNode,
              onChanged: (value) {
                if (!_isSelecting && value.isNotEmpty) {
                  viewModel.fetchDestinationSuggestions(value);
                }
              },
              onSubmitted: (value) async {
                if (value.trim().isNotEmpty) {
                  setState(() => _isSelecting = true);
                  await viewModel.geocodeAndSelectDestination(value);
                  widget.focusNode.unfocus();

                  // Verify selection worked
                  if (viewModel.destinationLocation == null) {
                    debugPrint(
                      'âš ï¸ Destination location is still null after geocoding',
                    );
                  } else {
                    debugPrint(
                      'âœ… Destination selected: ${viewModel.destinationLocation?.address}',
                    );
                  }

                  setState(() => _isSelecting = false);
                }
              },
            ),

            // Show shimmer while loading suggestions
            if (viewModel.isLoadingDestinationSuggestions)
              const LocationSuggestionsShimmer()
            else if (viewModel.showDestinationSuggestions && !_isSelecting)
              LocationSuggestionsList(
                suggestions: viewModel.destinationSuggestions,
                onSelect: (prediction) async {
                  setState(() => _isSelecting = true);

                  debugPrint(
                    'ðŸ”µ Destination selected: ${prediction.description}',
                  );

                  // Update text field first
                  widget.controller.text = prediction.description;

                  // Hide suggestions and unfocus
                  viewModel.hideDestinationSuggestions();
                  widget.focusNode.unfocus();

                  // IMPORTANT: Select location in ViewModel
                  await viewModel.selectDestination(prediction);

                  // Verify the location was set
                  if (viewModel.destinationLocation != null) {
                    debugPrint(
                      'âœ… Destination location set: ${viewModel.destinationLocation?.address}',
                    );
                    debugPrint(
                      '   Lat: ${viewModel.destinationLocation?.latitude}',
                    );
                    debugPrint(
                      '   Lng: ${viewModel.destinationLocation?.longitude}',
                    );

                    // Call the callback to notify parent widget
                    await widget.onSelected(prediction);
                  } else {
                    debugPrint('âŒ Failed to set destination location');
                    // Show error to user
                    if (mounted) {
                      ToastService.showError('Failed to select destination. Please try again.');
                    }
                  }

                  // Reset selecting flag
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (mounted) {
                    setState(() => _isSelecting = false);
                  }
                },
              ),
          ],
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const _SectionTitle({required this.appColors, required this.appFonts});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Where would you like to go?',
      style: appFonts.textSmMedium.copyWith(
        color: appColors.textPrimary,
        fontSize: 18.sp,
      ),
    );
  }
}
