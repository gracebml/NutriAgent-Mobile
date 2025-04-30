import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A widget that creates an animated gradient background with subtle motion.
class GradientBackground extends StatefulWidget {
  final List<Color>? colors;
  final List<double>? stops;
  final Duration animationDuration;
  final Widget child; // Add this line to accept a child widget
  
  /// Creates a GradientBackground with optional custom colors and animation settings.
  /// 
  /// By default, it uses a green/white gradient theme matching the app's design.
  const GradientBackground({
    Key? key,
    this.colors,
    this.stops,
    this.animationDuration = const Duration(seconds: 20),
    required this.child, // Add this line to require a child widget
  }) : super(key: key);

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  // Default colors with alpha values for subtle gradient effects
  static final List<Color> defaultColors = [
    Color(0xFFFAFAFA), // Off-white
    Color(0x80E8F5E9), // Light green with alpha
    Color(0x40C8E6C9), // Medium green with alpha
    Color(0x30A5D6A7), // Darker green with alpha
    Color(0xFFFAFAFA), // Off-white again for smooth transition
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // We create a unique animation pattern by using different curves
        final firstPos = Tween<double>(begin: -0.3, end: 0.7)
            .animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ))
            .value;
            
        final secondPos = Tween<double>(begin: 1.3, end: 0.3)
            .animate(CurvedAnimation(
              parent: _controller,
              curve: Curves.easeInOut,
            ))
            .value;
            
        return Stack(
          children: [
            // Base gradient covering the whole screen
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.colors ?? defaultColors,
                  stops: widget.stops,
                ),
              ),
            ),
            
            // Decorative animated blur elements
            Positioned(
              top: MediaQuery.of(context).size.height * firstPos,
              left: MediaQuery.of(context).size.width * 0.1,
              child: _buildBlurCircle(
                size: MediaQuery.of(context).size.width * 0.7,
                color: Colors.green.withOpacity(0.07),
              ),
            ),
            
            Positioned(
              top: MediaQuery.of(context).size.height * 0.6,
              right: MediaQuery.of(context).size.width * secondPos - MediaQuery.of(context).size.width,
              child: _buildBlurCircle(
                size: MediaQuery.of(context).size.width * 0.8,
                color: Colors.green.withOpacity(0.05),
              ),
            ),
            
            // Additional decorative elements for depth
            Positioned(
              bottom: MediaQuery.of(context).size.height * (1 - firstPos) - MediaQuery.of(context).size.height,
              right: MediaQuery.of(context).size.width * 0.1,
              child: _buildBlurCircle(
                size: MediaQuery.of(context).size.width * 0.5,
                color: Colors.green.withOpacity(0.06),
              ),
            ),
            
            // Add the child widget here
            widget.child,
          ],
        );
      },
    );
  }
  
  Widget _buildBlurCircle({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: size * 0.5,
            spreadRadius: size * 0.1,
          ),
        ],
      ),
    );
  }
}