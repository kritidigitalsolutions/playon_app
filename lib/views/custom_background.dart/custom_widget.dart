import 'package:flutter/material.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/res/app_image.dart';

// ignore: must_be_immutable
class BackgroundWithImg extends StatelessWidget {
  Widget child;
  BackgroundWithImg({super.key, required this.child});

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
            color: AppColors.secPrimary.withValues(alpha: 0.8),
          ),
        ),

        Positioned(right: -50, top: -50, child: _softBlueGlow()),

        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

//

// ignore: must_be_immutable
class BackgroundWithOutImg extends StatelessWidget {
  Widget child;
  BackgroundWithOutImg({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secPrimary.withValues(alpha: 0.2),
          ),
        ),

        Positioned(right: -50, top: -50, child: _softBlueGlow()),

        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

// only one blue light

class BackgroundWithOneLight extends StatelessWidget {
  Widget child;
  BackgroundWithOneLight({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.secPrimary.withValues(alpha: 0.2),
          ),
        ),
        Positioned(left: -50, bottom: -50, child: _softBlueGlow()),
        child,
      ],
    );
  }
}

// Add this widget outside any class (or inside your file)
Widget _softBlueGlow({double size = 220, double opacity = 0.7}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        // Outer soft glow
        BoxShadow(
          color: AppColors.primary.withOpacity(opacity * 0.2),
          blurRadius: 80,
          spreadRadius: 30,
        ),
        // Medium glow
        BoxShadow(
          color: AppColors.primary.withOpacity(opacity * 0.1),
          blurRadius: 60,
          spreadRadius: 10,
        ),
        // Inner bright glow
        BoxShadow(
          color: AppColors.primary.withOpacity(opacity * 0.5),
          blurRadius: 40,
          spreadRadius: -10,
        ),
      ],
    ),
  );
}
