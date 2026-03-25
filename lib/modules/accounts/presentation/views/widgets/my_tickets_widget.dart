import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/theme/app_colors.dart';
import 'package:ridenowappsss/modules/accounts/data/models/support_models.dart';
import 'package:ridenowappsss/modules/accounts/presentation/providers/support_provider.dart';
import 'package:intl/intl.dart';

class MyTicketsWidget extends StatefulWidget {
  const MyTicketsWidget({super.key});

  @override
  State<MyTicketsWidget> createState() => _MyTicketsWidgetState();
}

class _MyTicketsWidgetState extends State<MyTicketsWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().fetchUserTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SupportProvider>(
      builder: (context, provider, child) {
        if (provider.userTicketsState == SupportState.loading &&
            provider.userTickets.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.navy500,
            ),
          );
        }

        if (provider.userTicketsState == SupportState.error &&
            provider.userTickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.sp, color: AppColors.red500),
                SizedBox(height: 16.h),
                Text(
                  'Failed to load tickets',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () => provider.fetchUserTickets(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink500,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.userTickets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.confirmation_number_outlined,
                  size: 64.sp,
                  color: AppColors.gray300,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No tickets found',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'You haven\'t submitted any tickets yet.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchUserTickets(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.ticketsData != null)
                _buildSummaryCards(provider.ticketsData!),
              Expanded(
                child: ListView.separated(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: provider.userTickets.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final ticket = provider.userTickets[index];
                    return _TicketCard(ticket: ticket);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards(TicketsData data) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Total',
            value: data.total.toString(),
            color: AppColors.navy500,
          ),
          SizedBox(width: 12.w),
          _SummaryCard(
            label: 'Open',
            value: data.open.toString(),
            color: AppColors.orange500,
          ),
          SizedBox(width: 12.w),
          _SummaryCard(
            label: 'Resolved',
            value: data.resolved.toString(),
            color: AppColors.green500,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketCard extends StatelessWidget {
  final UserTicket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: Navigate to ticket details if needed
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.navy50,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        ticket.ticketNumber,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navy500,
                        ),
                      ),
                    ),
                    _StatusBadge(status: ticket.status),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  ticket.subject,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  ticket.lastMessage,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 14.sp, color: AppColors.textTertiary),
                        SizedBox(width: 4.w),
                        Text(
                          _formatDate(ticket.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    if (ticket.assignedAgent != null)
                      Row(
                        children: [
                          Icon(Icons.person_outline,
                              size: 14.sp, color: AppColors.textTertiary),
                          SizedBox(width: 4.w),
                          Text(
                            ticket.assignedAgent!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM d, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label = status.replaceAll('_', ' ').toUpperCase();

    switch (status.toLowerCase()) {
      case 'open':
        color = AppColors.blue500;
        break;
      case 'in_progress':
        color = AppColors.orange500;
        break;
      case 'resolved':
      case 'closed':
        color = AppColors.green500;
        break;
      case 'waiting_user':
        color = AppColors.pink500;
        break;
      default:
        color = AppColors.gray500;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
