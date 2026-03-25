import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ridenowappsss/core/utils/extensions/app_color_extension.dart';
import 'package:ridenowappsss/core/utils/theme/app_theme.dart';
import 'package:ridenowappsss/modules/authentication/presentation/providers/auth_provider.dart';
import 'package:ridenowappsss/core/navigation/route_constant.dart';
import 'package:go_router/go_router.dart';

class SwitchRoleModal extends StatefulWidget {
  final String targetRole;

  const SwitchRoleModal({
    super.key,
    required this.targetRole,
  });

  @override
  State<SwitchRoleModal> createState() => _SwitchRoleModalState();
}

class _SwitchRoleModalState extends State<SwitchRoleModal> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).colors;
    final isDriver = widget.targetRole.toLowerCase() == 'driver';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: appColors.textWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: appColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Icon(
            isDriver ? Icons.drive_eta : Icons.person,
            size: 48,
            color: appColors.blue500,
          ),
          const SizedBox(height: 16),
          Text(
            isDriver ? 'Switch to Driver' : 'Switch to Rider',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: appColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isDriver
                ? 'You are about to switch to your driver account. You will be able to accept ride requests.'
                : 'You are about to switch to your rider account. You will be able to book rides.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: appColors.gray500,
            ),
          ),
          const SizedBox(height: 24),
          _buildActionButton(context, appColors),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: appColors.gray500),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, AppColorExtension appColors) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.user;
    
    if (user == null) return const SizedBox.shrink();

    final isDriver = widget.targetRole.toLowerCase() == 'driver';
    final hasDriverRole = user.activeRoles.contains('driver');

    if (isDriver && !hasDriverRole) {
      if (user.driverOnboardingStatus == 'pending') {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.blue500,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            final success = await authProvider.startDriverOnboarding();
            if (success && mounted) {
              Navigator.pop(context);
              final route = await authProvider.getOnboardingRoute();
              if (route != null && mounted) {
                context.pushNamed(route);
              } else if (mounted) {
                context.goNamed(RouteConstants.letsGetToKnowYou);
              }
            }
            if (mounted) setState(() => _isLoading = false);
          },
          child: _isLoading 
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Start Driver Onboarding', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      } else if (user.driverOnboardingStatus == 'in_progress') {
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.blue500,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _isLoading ? null : () async {
            setState(() => _isLoading = true);
            final route = await authProvider.getOnboardingRoute();
            if (mounted) {
              Navigator.pop(context);
              if (route != null) {
                context.pushNamed(route);
              } else {
                context.goNamed(RouteConstants.letsGetToKnowYou);
              }
            }
          },
          child: _isLoading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Let's continue onboarding", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        );
      }
    }

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: appColors.blue500,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: _isLoading ? null : () async {
        setState(() => _isLoading = true);
        final response = await authProvider.switchRole(widget.targetRole);
        if (mounted) {
          setState(() => _isLoading = false);
          if (response != null && response.success) {
            Navigator.pop(context);
            // UI will automatically switch due to ConditionalWidget
          } else if (response != null && !response.success) {
            // Handle specific failure cases if needed
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response.message)),
            );
          }
        }
      },
      child: _isLoading
          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
          : const Text('Switch Now', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }
}
