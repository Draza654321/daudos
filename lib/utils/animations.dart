import 'package:flutter/material.dart';

class AppAnimations {
  // Duration constants
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);
  static const Duration extraSlow = Duration(milliseconds: 800);

  // Curve constants
  static const Curve bounceIn = Curves.bounceIn;
  static const Curve bounceOut = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve smooth = Curves.easeInOutCubic;

  // Slide transitions
  static Widget slideInFromLeft(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: -1.0, end: 0.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideInFromRight(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: 1.0, end: 0.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(value * MediaQuery.of(context).size.width, 0),
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideInFromTop(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: -1.0, end: 0.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget slideInFromBottom(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: 1.0, end: 0.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, value * MediaQuery.of(context).size.height),
          child: child,
        );
      },
      child: child,
    );
  }

  // Scale animations
  static Widget scaleIn(Widget child, {Duration? duration, Curve? curve}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: curve ?? elastic,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget bounceIn(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? slow,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.bounceOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Fade animations
  static Widget fadeIn(Widget child, {Duration? duration, double? begin}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: begin ?? 0.0, end: 1.0),
      curve: smooth,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget fadeInUp(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Rotation animations
  static Widget rotateIn(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: 0.0, end: 1.0),
      curve: smooth,
      builder: (context, value, child) {
        return Transform.rotate(
          angle: (1 - value) * 3.14159 * 2,
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Shimmer effect
  static Widget shimmer(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? Duration(milliseconds: 1500),
      tween: Tween(begin: -1.0, end: 2.0),
      curve: Curves.linear,
      builder: (context, value, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.5),
                Colors.transparent,
              ],
              stops: [
                (value - 0.3).clamp(0.0, 1.0),
                value.clamp(0.0, 1.0),
                (value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: child,
    );
  }

  // Pulse animation
  static Widget pulse(Widget child, {Duration? duration}) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? Duration(milliseconds: 1000),
      tween: Tween(begin: 0.8, end: 1.2),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: child,
    );
  }

  // Staggered list animation
  static Widget staggeredList({
    required List<Widget> children,
    Duration? duration,
    Duration? delay,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final index = entry.key;
        final child = entry.value;
        
        return TweenAnimationBuilder<double>(
          duration: (duration ?? medium) + Duration(milliseconds: index * 100),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: smooth,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }

  // Success celebration animation
  static Widget celebrationBurst(Widget child, {bool trigger = false}) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600),
      tween: Tween(begin: trigger ? 0.0 : 1.0, end: 1.0),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: 0.8 + (0.4 * value),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3 * value),
                  blurRadius: 20 * value,
                  spreadRadius: 5 * value,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Loading skeleton
  static Widget skeleton({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 1200),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.linear,
      builder: (context, value, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * value, 0.0),
              end: Alignment(1.0 + 2.0 * value, 0.0),
              colors: [
                Colors.grey.shade300,
                Colors.grey.shade100,
                Colors.grey.shade300,
              ],
            ),
          ),
        );
      },
    );
  }

  // Page transition
  static PageRouteBuilder<T> createRoute<T>(Widget page, {String? routeName}) {
    return PageRouteBuilder<T>(
      settings: RouteSettings(name: routeName),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: medium,
    );
  }

  // Floating action button animation
  static Widget animatedFAB({
    required VoidCallback onPressed,
    required IconData icon,
    bool isVisible = true,
  }) {
    return AnimatedScale(
      scale: isVisible ? 1.0 : 0.0,
      duration: medium,
      curve: elastic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: fast,
        child: FloatingActionButton(
          onPressed: onPressed,
          child: Icon(icon),
        ),
      ),
    );
  }

  // Card flip animation
  static Widget flipCard({
    required Widget front,
    required Widget back,
    required bool showFront,
    Duration? duration,
  }) {
    return TweenAnimationBuilder<double>(
      duration: duration ?? medium,
      tween: Tween(begin: showFront ? 0.0 : 1.0, end: showFront ? 0.0 : 1.0),
      builder: (context, value, child) {
        if (value < 0.5) {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(value * 3.14159),
            child: front,
          );
        } else {
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY((1 - value) * 3.14159),
            child: back,
          );
        }
      },
    );
  }
}

