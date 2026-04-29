import 'package:flutter/material.dart';
import 'package:play_on_app/res/app_colors.dart';
import 'package:play_on_app/utils/app_text_style.dart';

class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;
  final double height;
  final double radius;
  final TextStyle? textStyle;

  const AppButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.color,
    this.height = 45,
    this.radius = 30,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(radius),
      onTap: isLoading ? null : onTap,
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isLoading
              ? (color ?? AppColors.button).withOpacity(0.7)
              : color ?? AppColors.button,
          borderRadius: BorderRadius.circular(radius),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Colors.white,
          ),
        )
            : Text(
          title,
          style: textStyle ?? text15(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AppOutlineButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Color? color;
  final double height;
  final double radius;
  final TextStyle? textStyle;

  const AppOutlineButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
    this.height = 45,
    this.radius = 30,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.button),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Text(
          title,
          style: textStyle ?? text14(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class CustomElevatedButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? color;
  final double height;
  final double radius;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isLoading = false,
    this.color,
    this.height = 50,
    this.radius = 30,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          backgroundColor: color ?? AppColors.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                title,
                style:
                    textStyle ??
                    text15(color: Colors.white, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}

class CustomElevatedIconButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final double height;
  final double iconSize;
  final EdgeInsetsGeometry padding;
  final TextStyle? textStyle;

  const CustomElevatedIconButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 30,
    this.height = 45,
    this.iconSize = 20,
    this.textStyle,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? (backgroundColor ?? AppColors.button).withOpacity(0.7)
              : backgroundColor ?? AppColors.button,
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: iconSize, color: textColor ?? AppColors.white),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: textStyle ??
                  text15(
                    color: textColor ?? AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

