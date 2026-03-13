import 'package:flutter/material.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String> stepLabels;
  final List<bool> showStepLabels;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepLabels,
    required this.showStepLabels,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...List.generate(totalSteps, (index) {
              final stepNumber = index + 1;
              final isCurrent = stepNumber == currentStep;
              final isPassed = stepNumber < currentStep;
              final isActive = isCurrent || isPassed;

              return Row(
                children: [
                  if (index > 0) const SizedBox(width: 8.0),

                  Container(
                    width: 27,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isActive ? appColors.pink500 : appColors.pink200,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Center(
                      child: Text(
                        '$stepNumber',
                        style: appFonts.textXsBold.copyWith(
                          color: appColors.textWhite,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  if (showStepLabels.length > index &&
                      showStepLabels[index] &&
                      stepLabels.length > index)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        stepLabels[index],
                        style: appFonts.textSmMedium.copyWith(
                          color: appColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                ],
              );
            }),
          ],
        ),
      ],
    );
  }
}
