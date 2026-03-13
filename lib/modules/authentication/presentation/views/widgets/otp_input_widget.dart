// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final List<TextEditingController> controllers;

  const OtpInputWidget({
    super.key,
    this.length = 4,
    required this.onCompleted,
    required this.controllers,
  }) : assert(
         controllers.length >= length,
         'Number of controllers must be at least equal to length',
       );

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());

    for (int i = 0; i < widget.length; i++) {
      widget.controllers[i].addListener(() => _handleTextChange(i));
    }
  }

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleTextChange(int index) {
    final currentText = widget.controllers[index].text;

    if (currentText.length == 1 && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    _checkCompletion();
  }

  void _checkCompletion() {
    final otp = widget.controllers.map((c) => c.text).join();

    if (otp.length == widget.length) {
      FocusScope.of(context).unfocus();
      widget.onCompleted(otp);
    }
  }

  void _handleKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (widget.controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _handlePastedText(String pastedText, int startIndex) {
    final digitsOnly = pastedText.replaceAll(RegExp(r'[^0-9]'), '');

    for (
      int i = 0;
      i < digitsOnly.length && (startIndex + i) < widget.length;
      i++
    ) {
      widget.controllers[startIndex + i].text = digitsOnly[i];
    }

    final nextFocusIndex = (startIndex + digitsOnly.length).clamp(
      0,
      widget.length - 1,
    );
    if (nextFocusIndex < widget.length) {
      _focusNodes[nextFocusIndex].requestFocus();
    }

    _checkCompletion();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 60,
          height: 60,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _handleKeyEvent(event, index),
            child: TextField(
              controller: widget.controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              inputFormatters: [
                LengthLimitingTextInputFormatter(1),
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: appFonts.heading2Bold.copyWith(
                color: appColors.textPrimary,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: appColors.bgB0,
                counterText: '',
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray200),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.gray200),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: appColors.blue600, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (value) {
                if (value.length > 1) {
                  _handlePastedText(value, index);
                }
              },
            ),
          ),
        );
      }),
    );
  }
}
