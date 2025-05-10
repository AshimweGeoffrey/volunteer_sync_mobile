import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnimatedLogo extends StatelessWidget {
  final AnimationController controller;
  final double size;

  const AnimatedLogo({
    Key? key,
    required this.controller,
    this.size = 100,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Animation<double> scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    final Animation<double> rotateAnimation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: scaleAnimation.value,
          child: Transform.rotate(
            angle: rotateAnimation.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.volunteer_activism,
                  color: Colors.white,
                  size: size * 0.5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
