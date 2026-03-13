import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/extensions/app_font_extension.dart';
import 'package:ridenowappsss/modules/ride/presentation/providers/rider_provider.dart';
import 'package:ridenowappsss/modules/ride/data/models/ride_api_models.dart'
    as api;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideProvider>().fetchChatHistory();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    final success = await context.read<RideProvider>().sendMessage(message);
    if (success) {
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColorExtension>()!;
    final appFonts = Theme.of(context).extension<AppFontThemeExtension>()!;
    final provider = context.watch<RideProvider>();
    final driver = provider.rideDetails?.driver;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.grey, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Chat',
          style: appFonts.heading3Bold.copyWith(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Driver Info Header
          _buildDriverHeader(context, appColors, appFonts, driver),

          Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

          // Messages List
          Expanded(
            child:
                provider.isLoadingChat
                    ? const Center(child: CircularProgressIndicator())
                    : _buildMessageList(
                      provider.chatMessages,
                      appColors,
                      appFonts,
                    ),
          ),

          // Message Input
          _buildMessageInput(context, appColors, appFonts),
        ],
      ),
    );
  }

  Widget _buildDriverHeader(
    BuildContext context,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
    dynamic driver,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              image: DecorationImage(
                image:
                    (driver?.profileImage != null &&
                            driver.profileImage!.isNotEmpty)
                        ? NetworkImage(driver.profileImage!) as ImageProvider
                        : const AssetImage(
                          'assets/images/user_placeholder.png',
                        ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Driver',
                  style: appFonts.textSmRegular.copyWith(color: Colors.grey),
                ),
                Row(
                  children: [
                    Text(
                      driver?.name ?? 'Kelechi Eze',
                      style: appFonts.textBaseBold.copyWith(fontSize: 16.sp),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.star, color: Colors.green, size: 14.sp),
                    SizedBox(width: 2.w),
                    Text(
                      '4.0',
                      style: appFonts.textSmRegular.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'Nissan 16v 322 Machine',
                  style: appFonts.textSmRegular.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.call, color: Colors.black, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    List<api.ChatMessage> messages,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: appFonts.textSmRegular.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMe = message.senderType == 'rider';
        final showTime =
            index == 0 ||
            message.timestamp
                    .difference(messages[index - 1].timestamp)
                    .inMinutes >
                5;

        return Column(
          children: [
            if (showTime)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10.h),
                child: Text(
                  DateFormat('h:mm a').format(message.timestamp),
                  style: appFonts.textSmRegular.copyWith(
                    color: Colors.grey,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            _buildMessageBubble(message, isMe, appColors, appFonts),
          ],
        );
      },
    );
  }

  Widget _buildMessageBubble(
    api.ChatMessage message,
    bool isMe,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    // Special handling for call bubbles if message type indicates it
    if (message.messageType == 'voice_call') {
      return _buildCallBubble(
        isMe: isMe,
        title: 'Voice call',
        subtitle: '2 min',
        icon: Icons.call,
        borderColor: Colors.purple.withOpacity(0.3),
        appFonts: appFonts,
      );
    }
    if (message.messageType == 'missed_call') {
      return _buildCallBubble(
        isMe: isMe,
        title: 'Missed call',
        subtitle: 'Tap to call back',
        icon: Icons.call_missed,
        borderColor: Colors.red.withOpacity(0.3),
        appFonts: appFonts,
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        constraints: BoxConstraints(maxWidth: 0.7.sw),
        decoration: BoxDecoration(
          color: isMe ? appColors.brandDefault : const Color(0xFFF3F5FF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16.r),
          ),
        ),
        child: Text(
          message.message,
          style: appFonts.textBaseRegular.copyWith(
            color: isMe ? Colors.white : Colors.black87,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildCallBubble({
    required bool isMe,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color borderColor,
    required AppFontThemeExtension appFonts,
  }) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        width: 0.6.sw,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: borderColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: borderColor.withOpacity(0.8),
                size: 18.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: appFonts.textBaseBold.copyWith(fontSize: 14.sp),
                  ),
                  Text(
                    subtitle,
                    style: appFonts.textSmRegular.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput(
    BuildContext context,
    AppColorExtension appColors,
    AppFontThemeExtension appFonts,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.05),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: appFonts.textSmRegular.copyWith(
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: _handleSendMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: appColors.brandDefault,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
