import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/colors.dart';

class DecorativeBackground extends StatelessWidget {
  final Widget child;

  const DecorativeBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _buildBlurCircle(250, AppColors.blurYellow.withOpacity(0.4)),
        ),
        Positioned(
          top: 150,
          left: -100,
          child: _buildBlurCircle(300, AppColors.blurBlue.withOpacity(0.3)),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: _buildBlurCircle(350, AppColors.blurPink.withOpacity(0.3)),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: _buildBlurCircle(200, AppColors.blurGreen.withOpacity(0.3)),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(color: Colors.transparent),
          ),
        ),
        child,
      ],
    );
  }

  Widget _buildBlurCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
