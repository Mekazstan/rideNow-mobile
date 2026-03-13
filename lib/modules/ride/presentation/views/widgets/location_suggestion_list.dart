// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/place_prediction.dart';
import 'suggestion_tile.dart';

class LocationSuggestionsList extends StatelessWidget {
  final List<PlacePrediction> suggestions;
  final Function(PlacePrediction) onSelect;

  const LocationSuggestionsList({
    super.key,
    required this.suggestions,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: 8.h),
      constraints: BoxConstraints(maxHeight: 200.h),
      decoration: _buildDecoration(appColors),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: suggestions.length,
        separatorBuilder:
            (context, index) => Divider(height: 1.h, color: appColors.gray100),
        itemBuilder:
            (context, index) => SuggestionTile(
              suggestion: suggestions[index],
              onTap: () => onSelect(suggestions[index]),
            ),
      ),
    );
  }

  BoxDecoration _buildDecoration(AppColorExtension appColors) {
    return BoxDecoration(
      border: Border.all(color: appColors.gray200),
      borderRadius: BorderRadius.circular(8.r),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}
