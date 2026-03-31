import 'package:flutter/material.dart';
import 'dart:math' as math;

class GlowingOnlineToggle extends StatefulWidget {
  final bool isOnline;
  final bool isLoading;
  final VoidCallback onToggle;

  const GlowingOnlineToggle({
    super.key,
    required this.isOnline,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  State<GlowingOnlineToggle> createState() => _GlowingOnlineToggleState();
}

class _GlowingOnlineToggleState extends State<GlowingOnlineToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (!widget.isOnline) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GlowingOnlineToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOnline != oldWidget.isOnline) {
      if (widget.isOnline) {
        _controller.stop();
      } else {
        _controller.repeat();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onToggle,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Glowing Waves (only when offline)
          if (!widget.isOnline)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(3, (index) {
                    final progress = (_controller.value + (index / 3)) % 1.0;
                    return Container(
                      width: 48 + (progress * 40),
                      height: 48 + (progress * 40),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(
                            (1.0 - progress) * 0.5,
                          ),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          
          // Toggle Button
          Container(
            width: 100,
            height: 44,
            decoration: BoxDecoration(
              color: widget.isOnline 
                ? Colors.green.withOpacity(0.1) 
                : Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
                if (!widget.isOnline)
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
              ],
              border: Border.all(
                color: widget.isOnline 
                  ? Colors.green.withOpacity(0.5) 
                  : Theme.of(context).primaryColor.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Stack(
              children: [
                // Text Labels
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: !widget.isOnline 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                        Text(
                          'ON',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: widget.isOnline 
                              ? Colors.green 
                              : Colors.grey.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Sliding Circle
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: widget.isOnline 
                    ? Alignment.centerRight 
                    : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.isLoading 
                          ? Colors.white 
                          : (widget.isOnline ? Colors.green : Theme.of(context).primaryColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: widget.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            )
                          : Icon(
                              widget.isOnline ? Icons.check : Icons.power_settings_new,
                              size: 18,
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
