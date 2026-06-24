import 'package:flutter/material.dart';

import '../../res/app_colors.dart';
import '../../res/app_image.dart';

class BackgroundWithImg extends StatelessWidget {
  final Widget child;
  const BackgroundWithImg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          AppImage.background,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secPrimary.withOpacity(0.8),
          ),
        ),

        Positioned(right: -50, top: -50, child: _softBlueGlow()),

        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

class BackgroundWithOutImg extends StatelessWidget {
  final Widget child;
  const BackgroundWithOutImg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secPrimary.withOpacity(0.2),
          ),
        ),

        Positioned(right: -50, top: -50, child: _softBlueGlow()),

        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

class BackgroundWithOneLight extends StatelessWidget {
  final Widget child;
  const BackgroundWithOneLight({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secPrimary.withOpacity(0.2),
          ),
        ),
        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

Widget _softBlueGlow() {
  return Container(
    width: 250,
    height: 250,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(
        colors: [
          Colors.blue.withOpacity(0.12),
          Colors.transparent,
        ],
      ),
    ),
  );
}
