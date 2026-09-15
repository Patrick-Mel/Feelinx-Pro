import 'package:flutter/material.dart';
import 'feelinx_logo.dart';

class FeelinxLogoAnimated extends StatefulWidget {
  final double size;
  final VoidCallback? onAnimationComplete;

  const FeelinxLogoAnimated({
    super.key,
    this.size = 120.0,
    this.onAnimationComplete,
  });

  @override
  State<FeelinxLogoAnimated> createState() => _FeelinxLogoAnimatedState();
}

class _FeelinxLogoAnimatedState extends State<FeelinxLogoAnimated> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _leftArcOffset;
  late Animation<Offset> _rightArcOffset;
  late Animation<double> _textFadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _leftArcOffset = Tween<Offset>(
      begin: const Offset(-0.8, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _rightArcOffset = Tween<Offset>(
      begin: const Offset(0.8, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward().then((_) {
      if (widget.onAnimationComplete != null) {
        widget.onAnimationComplete!();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    children: [
                      SlideTransition(
                        position: _leftArcOffset,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: FeelinxSymbolPainter(colorMode: FeelinxColorMode.gradient),
                        ),
                      ),
                      SlideTransition(
                        position: _rightArcOffset,
                        child: CustomPaint(
                          size: Size(widget.size, widget.size),
                          painter: FeelinxSymbolPainter(colorMode: FeelinxColorMode.gradient),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        FadeTransition(
          opacity: _textFadeAnimation,
          child: FeelinxLogo(
            size: widget.size * 0.45,
            variant: FeelinxLogoVariant.wordmark,
            colorMode: FeelinxColorMode.gradient,
          ),
        ),
      ],
    );
  }
}
