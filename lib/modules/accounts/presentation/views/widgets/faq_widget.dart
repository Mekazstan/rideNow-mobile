import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:ridenowappsss/shared/widgets/ride_now_search_bar.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';

class FaqWidget extends StatefulWidget {
  const FaqWidget({super.key});

  @override
  State<FaqWidget> createState() => _FaqWidgetState();
}

class _FaqWidgetState extends State<FaqWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  /// Fetches FAQ data from the server
  Future<void> _loadFaqs() async {
    final supportProvider = context.read<SupportProvider>();
    await supportProvider.fetchFaqs();
  }

  /// Filters FAQs based on search input
  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
      });
      return;
    }

    final supportProvider = context.read<SupportProvider>();
    setState(() {
      _isSearching = true;
      _searchResults = supportProvider.searchFaqs(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return Column(
      children: [
        SizedBox(height: 20.h),
        Row(
          children: [
            SvgPicture.asset('assets/faq.svg'),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Find the answers to all your questions',
                style: appFonts.textSmMedium.copyWith(
                  color: appColors.textPrimary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        RideNowSearchBar(
          hintText: 'Ask a question or enter a keyword',
          controller: _searchController,
        ),
        SizedBox(height: 24.h),
        Expanded(
          child: Consumer<SupportProvider>(
            builder: (context, supportProvider, child) {
              if (supportProvider.isLoadingFaq) {
                return _buildShimmerView(appColors);
              }

              if (supportProvider.faqState == SupportState.error) {
                return _buildErrorView(appColors, appFonts, supportProvider);
              }

              final faqs =
                  _isSearching ? _searchResults : supportProvider.filteredFaqs;

              if (faqs.isEmpty) {
                return _buildEmptyView(appColors, appFonts);
              }

              return RefreshIndicator(
                onRefresh: _loadFaqs,
                color: appColors.blue500,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: faqs.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final faq = faqs[index];
                    return _FaqItem(
                      question: faq.question,
                      answer: faq.answer,
                      appColors: appColors,
                      appFonts: appFonts,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds shimmer loading placeholder for FAQ list
  Widget _buildShimmerView(AppColorExtension appColors) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: 6,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: appColors.gray200),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(
                        width: double.infinity,
                        height: 14.h,
                        borderRadius: 4.r,
                      ),
                      SizedBox(height: 8.h),
                      ShimmerBox(width: 200.w, height: 14.h, borderRadius: 4.r),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                ShimmerBox(width: 24.w, height: 24.h, borderRadius: 4.r),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds error state view with retry option
  Widget _buildErrorView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    SupportProvider supportProvider,
  ) {
    return RefreshIndicator(
      onRefresh: _loadFaqs,
      color: appColors.blue500,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  supportProvider.errorMessage ?? 'Failed to load FAQs',
                  style: appFonts.textSmMedium.copyWith(
                    color: appColors.red600,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _loadFaqs,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state view when no FAQs match search
  Widget _buildEmptyView(
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return RefreshIndicator(
      onRefresh: _loadFaqs,
      color: appColors.blue500,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 100.h),
          Center(
            child: Text(
              _isSearching
                  ? 'No FAQs found for "${_searchController.text}"'
                  : 'No FAQs available',
              style: appFonts.textSmMedium.copyWith(
                color: appColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Expandable FAQ item showing question and answer
class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;

  const _FaqItem({
    required this.question,
    required this.answer,
    required this.appColors,
    required this.appFonts,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: widget.appColors.gray200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: widget.appFonts.textSmMedium.copyWith(
                        color: widget.appColors.textPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: widget.appColors.textPrimary,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              decoration: BoxDecoration(
                color: widget.appColors.gray50,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(8.r),
                  bottomRight: Radius.circular(8.r),
                ),
              ),
              child: Text(
                widget.answer,
                style: widget.appFonts.textSmMedium.copyWith(
                  color: widget.appColors.textSecondary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
