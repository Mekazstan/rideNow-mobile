import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/authentication/data/models/emergency_contact_model.dart';
import 'package:ridenowappsss/shared/widgets/ridenow_button.dart';

class ContactSelectionSheet extends StatefulWidget {
  final List<EmergencyContact> available;

  const ContactSelectionSheet({super.key, required this.available});

  @override
  State<ContactSelectionSheet> createState() => _ContactSelectionSheetState();
}

class _ContactSelectionSheetState extends State<ContactSelectionSheet> {
  final List<EmergencyContact> _selected = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _pop(BuildContext context) {
    Navigator.pop(context, _selected);
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final query = _searchController.text.toLowerCase();

    final filtered = widget.available.where((c) {
      return c.name.toLowerCase().contains(query) ||
          c.phone.toLowerCase().contains(query);
    }).toList();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: appColors.textSecondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Add Emergency Contacts',
            style: appFonts.textLgBold.copyWith(
              color: appColors.textPrimary,
              fontSize: 20.sp,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select contacts from your phone to add as emergency contacts.',
            style: appFonts.textSmRegular.copyWith(
              color: appColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // ── Search bar ───────────────────────────────────────────────
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: appFonts.textMdRegular.copyWith(color: appColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Search by name or phone…',
              hintStyle: appFonts.textSmRegular.copyWith(
                color: appColors.textSecondary,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: appColors.textSecondary,
                size: 20.sp,
              ),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: appColors.textSecondary,
                        size: 18.sp,
                      ),
                      onPressed: () => setState(() => _searchController.clear()),
                    )
                  : null,
              filled: true,
              fillColor: appColors.textSecondary.withOpacity(0.07),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: appColors.textSecondary.withOpacity(0.3),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // ── Contact list ───────────────────────────────────────────────
          Flexible(
            child: filtered.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 40.sp,
                          color: appColors.textSecondary.withOpacity(0.4),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'No contacts match "$query"',
                          style: appFonts.textSmRegular.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: appColors.textSecondary.withOpacity(0.1),
                    ),
                    itemBuilder: (_, index) {
                      final contact = filtered[index];
                      final isSelected = _selected.contains(contact);
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        title: Text(
                          contact.name,
                          style: appFonts.textMdMedium.copyWith(
                            color: appColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          contact.phone,
                          style: appFonts.textSmRegular.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                        trailing: Checkbox(
                          value: isSelected,
                          onChanged: (value) => setState(() {
                            value == true
                                ? _selected.add(contact)
                                : _selected.remove(contact);
                          }),
                        ),
                        onTap: () => setState(() {
                          isSelected
                              ? _selected.remove(contact)
                              : _selected.add(contact);
                        }),
                      );
                    },
                  ),
          ),

          SizedBox(height: 16.h),
          RideNowButton(
            title: _selected.isEmpty
                ? 'Select at least one contact'
                : 'Add ${_selected.length} Contact${_selected.length > 1 ? "s" : ""}',
            onTap: _selected.isEmpty ? null : () => _pop(context),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16.h),
        ],
      ),
    );
  }
}
