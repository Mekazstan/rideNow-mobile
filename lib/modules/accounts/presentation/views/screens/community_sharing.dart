// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:ridenowappsss/modules/community/presentation/views/screens/community_screen.dart';

class CommunitySharing extends StatefulWidget {
  const CommunitySharing({super.key});

  @override
  State<CommunitySharing> createState() => _CommunitySharingState();
}

class _CommunitySharingState extends State<CommunitySharing> {
  @override
  Widget build(BuildContext context) {
    return const CommunityScreen(showBackButton: true);
  }
}
