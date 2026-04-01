// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/data/models/available_drvers.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/shared/widgets/shimmer_widget.dart';
import 'package:ridenowappsss/core/utils/extensions/amount_extension_validations_utils.dart';

class DriverOffersBottomSheet {
  static Future<void> show(
    BuildContext context, {
    required RideProvider rideViewModel,
    required Future<void> Function(AvailableDriver) onBookDriver,
    required Function(CounterOffer) onAcceptOffer,
    required Function(CounterOffer) onDeclineOffer,
  }) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: true,
      builder:
          (context) => _DriverOffersContent(
            appColors: appColors,
            appFonts: appFonts,
            rideViewModel: rideViewModel,
            onBookDriver: onBookDriver,
            onAcceptOffer: onAcceptOffer,
            onDeclineOffer: onDeclineOffer,
          ),
    ).then((_) {
      rideViewModel.setRideDetailVisible(false);
    });
  }
}

class _DriverOffersContent extends StatefulWidget {
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final RideProvider rideViewModel;
  final Future<void> Function(AvailableDriver) onBookDriver;
  final Function(CounterOffer) onAcceptOffer;
  final Function(CounterOffer) onDeclineOffer;

  const _DriverOffersContent({
    required this.appColors,
    required this.appFonts,
    required this.rideViewModel,
    required this.onBookDriver,
    required this.onAcceptOffer,
    required this.onDeclineOffer,
  });

  @override
  State<_DriverOffersContent> createState() => _DriverOffersContentState();
}

class _DriverOffersContentState extends State<_DriverOffersContent> {
  final Map<String, bool> _acceptedOffers = {};
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDriversAndOffers();
    widget.rideViewModel.startPollingOffers();
  }

  @override
  void dispose() {
    widget.rideViewModel.stopPollingOffers();
    super.dispose();
  }

  Future<void> _fetchDriversAndOffers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Fetch both drivers and offers concurrently
      await Future.wait([
        widget.rideViewModel.fetchAvailableDrivers(),
        widget.rideViewModel.fetchCounterOffers(),
      ]);

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      debugPrint(
        'Found ${widget.rideViewModel.availableDrivers.length} accepted drivers',
      );
      debugPrint(
        'Found ${widget.rideViewModel.counterOffers.length} counter offers',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
      debugPrint('Error fetching drivers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.rideViewModel,
      builder: (context, _) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              _DragHandle(appColors: widget.appColors),
              Expanded(
                child:
                    _isLoading
                        ? _buildLoadingState()
                        : _hasError
                        ? _buildErrorState()
                        : _buildContent(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Header shimmer
            ShimmerBox(width: 150.w, height: 24.h, borderRadius: 4.r),
            SizedBox(height: 4.h),
            ShimmerBox(width: 200.w, height: 14.h, borderRadius: 4.r),

            SizedBox(height: 24.h),

            // Driver cards shimmer
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => SizedBox(height: 16.h),
              itemBuilder:
                  (context, index) =>
                      _DriverCardShimmer(appColors: widget.appColors),
            ),

            SizedBox(height: 24.h),

            // Offers header shimmer
            ShimmerBox(width: 100.w, height: 18.h, borderRadius: 4.r),
            SizedBox(height: 4.h),
            ShimmerBox(width: 250.w, height: 14.h, borderRadius: 4.r),

            SizedBox(height: 16.h),

            // Offer cards shimmer
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              separatorBuilder: (context, index) => SizedBox(height: 12.h),
              itemBuilder:
                  (context, index) =>
                      _DriverCardShimmer(appColors: widget.appColors),
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: widget.appColors.red50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 60.sp,
                color: widget.appColors.red500,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Error loading drivers',
              style: widget.appFonts.textBaseMedium.copyWith(
                color: widget.appColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              _errorMessage,
              style: widget.appFonts.textSmRegular.copyWith(
                color: widget.appColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _fetchDriversAndOffers,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.appColors.blue600,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Retry',
                        style: widget.appFonts.textBaseMedium.copyWith(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.appColors.gray100,
                        foregroundColor: widget.appColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: widget.appFonts.textBaseMedium.copyWith(
                          color: widget.appColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final acceptedDrivers = widget.rideViewModel.availableDrivers;
    final pendingOffers = widget.rideViewModel.counterOffers;
    final hasNoData = acceptedDrivers.isEmpty && pendingOffers.isEmpty;

    if (hasNoData) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),

            // Find a driver header
            _buildHeader(acceptedDrivers.length),

            SizedBox(height: 24.h),

            // Accepted Drivers List
            if (acceptedDrivers.isNotEmpty) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: acceptedDrivers.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  return _AcceptedDriverCard(
                    driver: acceptedDrivers[index],
                    appColors: widget.appColors,
                    appFonts: widget.appFonts,
                    onBookDriver:
                        () => widget.onBookDriver(acceptedDrivers[index]),
                  );
                },
              ),
              SizedBox(height: 24.h),
            ],

            // Offers Section
            // Offers Section
            _buildOffersHeader(
              showSubtitle: pendingOffers.isNotEmpty,
              isLoading: widget.rideViewModel.isLoadingOffers,
            ),
            SizedBox(height: 16.h),

            if (pendingOffers.isNotEmpty) ...[
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pendingOffers.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final offer = pendingOffers[index];
                  final isAccepted = _acceptedOffers[offer.offerId] ?? false;

                  return _SwipeableOfferCard(
                    key: ValueKey(offer.offerId),
                    offer: offer,
                    appColors: widget.appColors,
                    appFonts: widget.appFonts,
                    isAccepted: isAccepted,
                    onAccept: () {
                      setState(() {
                        _acceptedOffers[offer.offerId] = true;
                      });
                      widget.onAcceptOffer(offer);
                    },
                    onDecline: () {
                      widget.onDeclineOffer(offer);
                    },
                  );
                },
              ),
              SizedBox(height: 24.h),
            ] else ...[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Text(
                  'No counter offers available',
                  style: widget.appFonts.textSmRegular.copyWith(
                    color: widget.appColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 40.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: widget.appColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_taxi_outlined,
                size: 60.sp,
                color: widget.appColors.gray400,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No drivers or offers for your location',
              style: widget.appFonts.textBaseMedium.copyWith(
                color: widget.appColors.textPrimary,
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'No drivers are available in your location at the moment. Please try again later.',
              style: widget.appFonts.textSmRegular.copyWith(
                color: widget.appColors.textSecondary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.appColors.blue600,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Close',
                  style: widget.appFonts.textBaseMedium.copyWith(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int driverCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Find a driver',
          style: widget.appFonts.textBaseMedium.copyWith(
            color: widget.appColors.textPrimary,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          '$driverCount available drivers near you',
          style: widget.appFonts.textSmRegular.copyWith(
            color: widget.appColors.textSecondary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildOffersHeader({
    bool showSubtitle = true,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Offers',
              style: widget.appFonts.textBaseMedium.copyWith(
                color: widget.appColors.textPrimary,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isLoading) ...[
              SizedBox(width: 8.w),
              SizedBox(
                width: 14.w,
                height: 14.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.appColors.blue600,
                ),
              ),
            ],
          ],
        ),
        if (showSubtitle) ...[
          SizedBox(height: 4.h),
          Text(
            'Swipe right to accept and left to decline',
            style: widget.appFonts.textSmRegular.copyWith(
              color: widget.appColors.textSecondary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ],
    );
  }
}

// Shimmer widget for driver cards
class _DriverCardShimmer extends StatelessWidget {
  final AppColorExtension appColors;

  const _DriverCardShimmer({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: appColors.gray200, width: 1),
      ),
      child: Row(
        children: [
          ShimmerBox(width: 48.w, height: 48.h, borderRadius: 8.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 120.w, height: 16.h, borderRadius: 4.r),
                SizedBox(height: 6.h),
                ShimmerBox(width: 160.w, height: 12.h, borderRadius: 4.r),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ShimmerBox(width: 70.w, height: 36.h, borderRadius: 8.r),
        ],
      ),
    );
  }
}

class _AcceptedDriverCard extends StatefulWidget {
  final AvailableDriver driver;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final Future<void> Function() onBookDriver;

  const _AcceptedDriverCard({
    required this.driver,
    required this.appColors,
    required this.appFonts,
    required this.onBookDriver,
  });

  @override
  State<_AcceptedDriverCard> createState() => _AcceptedDriverCardState();
}

class _AcceptedDriverCardState extends State<_AcceptedDriverCard> {
  bool _isLoading = false;

  Future<void> _handleBookDriver() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onBookDriver();
    } catch (e) {
      // Error handling is managed by the callback logic (e.g. snackbar)
      debugPrint('Error booking driver: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: widget.appColors.gray200, width: 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child:
                widget.driver.imageUrl != null
                    ? Image.network(
                      widget.driver.imageUrl!,
                      width: 48.w,
                      height: 48.h,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              _buildPlaceholderAvatar(),
                    )
                    : _buildPlaceholderAvatar(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        widget.driver.driverName,
                        style: widget.appFonts.textBaseMedium.copyWith(
                          color: widget.appColors.textPrimary,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    _buildRatingBadge(widget.driver.rating),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.driver.ridesCompleted} rides ETA: ${widget.driver.estimatedTime}',
                  style: widget.appFonts.textSmRegular.copyWith(
                    color: widget.appColors.textSecondary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            height: 36.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleBookDriver,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.appColors.blue600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, size: 16.sp),
                          SizedBox(width: 6.w),
                          Text(
                            'Book',
                            style: widget.appFonts.textSmRegular.copyWith(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: widget.appColors.gray200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.person, size: 24.sp, color: widget.appColors.gray400),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12.sp, color: const Color(0xFF10B981)),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: widget.appFonts.textSmRegular.copyWith(
              color: const Color(0xFF10B981),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the existing _SwipeableOfferCard and _DragHandle classes unchanged
class _SwipeableOfferCard extends StatefulWidget {
  final CounterOffer offer;
  final AppColorExtension appColors;
  final AppFontThemeExtension appFonts;
  final bool isAccepted;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _SwipeableOfferCard({
    super.key,
    required this.offer,
    required this.appColors,
    required this.appFonts,
    required this.isAccepted,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  State<_SwipeableOfferCard> createState() => _SwipeableOfferCardState();
}

class _SwipeableOfferCardState extends State<_SwipeableOfferCard>
    with SingleTickerProviderStateMixin {
  double _dragExtent = 0;
  final double _threshold = 100;
  final double _maxDragExtent = 150;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    )..addListener(() {
      setState(() {
        _dragExtent = _animation.value;
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragExtent += details.primaryDelta ?? 0;
      _dragExtent = _dragExtent.clamp(-_maxDragExtent, _maxDragExtent);
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (_dragExtent > _threshold) {
      _animateToPosition(0);
      widget.onAccept();
    } else if (_dragExtent < -_threshold) {
      _animateToPosition(0);
      widget.onDecline();
    } else {
      _animateToPosition(0);
    }
  }

  void _animateToPosition(double targetPosition) {
    _animation = Tween<double>(begin: _dragExtent, end: targetPosition).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.reset();
    _animationController.forward().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final opacity = (_dragExtent.abs() / _maxDragExtent).clamp(0.0, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: widget.isAccepted ? null : _handleDragUpdate,
      onHorizontalDragEnd: widget.isAccepted ? null : _handleDragEnd,
      child: Stack(
        children: [
          Positioned.fill(
            child: Row(
              children: [
                if (_dragExtent > 0)
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: _dragExtent,
                      decoration: BoxDecoration(
                        color: widget.appColors.blue600,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                const Spacer(),
                if (_dragExtent < 0)
                  Opacity(
                    opacity: opacity,
                    child: Container(
                      width: -_dragExtent,
                      decoration: BoxDecoration(
                        color: widget.appColors.red500,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(_dragExtent, 0),
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color:
                    widget.isAccepted
                        ? (widget.appColors.blue50)
                        : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color:
                      widget.isAccepted
                          ? (widget.appColors.blue600)
                          : (widget.appColors.gray200),
                  width: widget.isAccepted ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  if (widget.isAccepted)
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: widget.appColors.blue600,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    )
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child:
                          widget.offer.imageUrl != null
                              ? Image.network(
                                widget.offer.imageUrl!,
                                width: 48.w,
                                height: 48.h,
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (context, error, stackTrace) =>
                                        _buildPlaceholderAvatar(),
                              )
                              : _buildPlaceholderAvatar(),
                    ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.offer.driverName,
                                style: widget.appFonts.textBaseMedium.copyWith(
                                  color: widget.appColors.textPrimary,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            _buildRatingBadge(widget.offer.rating),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${widget.offer.ridesCompleted} rides ETA: ${widget.offer.estimatedTime}',
                          style: widget.appFonts.textSmRegular.copyWith(
                            color: widget.appColors.textSecondary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.offer.proposedFare.formatAmountWithCurrency(),
                        style: widget.appFonts.textBaseMedium.copyWith(
                          color: widget.appColors.textPrimary,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderAvatar() {
    return Container(
      width: 48.w,
      height: 48.h,
      decoration: BoxDecoration(
        color: widget.appColors.gray200,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(Icons.person, size: 24.sp, color: widget.appColors.gray400),
    );
  }

  Widget _buildRatingBadge(double rating) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 12.sp, color: const Color(0xFF10B981)),
          SizedBox(width: 2.w),
          Text(
            rating.toStringAsFixed(1),
            style: widget.appFonts.textSmRegular.copyWith(
              color: const Color(0xFF10B981),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  final AppColorExtension appColors;

  const _DragHandle({required this.appColors});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: appColors.gray300,
          borderRadius: BorderRadius.circular(2.r),
        ),
      ),
    );
  }
}
