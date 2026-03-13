// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';

class RidenowTextfield extends StatefulWidget {
  final String fieldName;
  final bool showFieldName;
  final String hintText;
  final TextEditingController controller;
  final bool readOnly;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final bool showAuthfield;
  final bool showAuthHintText;
  final bool showShadow;
  final Function(String)? onChanged;
  final Function()? onTap;
  final Function(String)? onSubmitted;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;

  const RidenowTextfield({
    super.key,
    required this.fieldName,
    this.showFieldName = true,
    required this.hintText,
    required this.controller,
    this.readOnly = false,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.validator,
    this.showAuthfield = false,
    this.showAuthHintText = false,
    this.showShadow = false,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.maxLength,
    this.focusNode,
    this.keyboardType,
    this.inputFormatters,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  State<RidenowTextfield> createState() => _RidenowTextfieldState();
}

class _RidenowTextfieldState extends State<RidenowTextfield> {
  late bool _isObscure;
  late FocusNode _internalFocusNode;
  FocusNode get _effectiveFocusNode => widget.focusNode ?? _internalFocusNode;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
    _internalFocusNode = FocusNode();
    _effectiveFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _internalFocusNode.dispose();
    }
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showFieldName)
            Text(
              widget.fieldName,
              style: appFonts.textMdRegular.copyWith(color: appColors.gray300),
            ),
          if (widget.showFieldName) const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            readOnly: widget.readOnly,
            obscureText: _isObscure,
            validator: widget.validator,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            onFieldSubmitted: widget.onSubmitted,
            maxLength: widget.maxLength,
            focusNode: _effectiveFocusNode,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            enabled: widget.enabled,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.obscureText ? 1 : widget.minLines,
            textAlign: widget.textAlign,
            textCapitalization: widget.textCapitalization,
            textInputAction:
                widget.onSubmitted != null
                    ? TextInputAction.done
                    : (widget.maxLines != null && widget.maxLines! > 1)
                    ? TextInputAction.newline
                    : TextInputAction.none,
            style: appFonts.textBaseRegular.copyWith(
              color:
                  widget.enabled ? appColors.textSecondary : appColors.gray400,
            ),
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appColors.blue200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appColors.blue600, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appColors.red600),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appColors.red600, width: 2),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: appColors.gray300),
              ),
              hintText: widget.hintText,
              hintStyle: appFonts.textBaseRegular.copyWith(
                color: appColors.gray400,
              ),
              prefixIcon: widget.prefixIcon,
              suffixIcon:
                  widget.obscureText
                      ? IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility_off : Icons.visibility,
                          color: appColors.textTertiary,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      )
                      : widget.suffixIcon,
              counterText: "",
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical:
                    widget.maxLines != null && widget.maxLines! > 1 ? 16 : 12,
              ),
              filled: !widget.enabled,
              fillColor:
                  widget.enabled ? null : appColors.gray100.withOpacity(0.5),
              alignLabelWithHint:
                  widget.maxLines != null && widget.maxLines! > 1,
            ),
          ),
        ],
      ),
    );
  }
}
