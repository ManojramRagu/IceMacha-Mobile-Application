import 'dart:async';
import 'package:flutter/material.dart';

typedef SlideOverlayBuilder = Widget Function(BuildContext context, int index);

class PromoCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final double height;
  final Duration interval;
  final Duration slideDuration;
  final bool dotsBelow;

  final void Function(int index)? onTapSlide;
  final void Function(int index)? onIndexChanged;
  final SlideOverlayBuilder? overlayBuilder;

  const PromoCarousel({
    super.key,
    required this.imagePaths,
    this.height = 180,
    this.interval = const Duration(seconds: 3),
    this.slideDuration = const Duration(milliseconds: 350),
    this.dotsBelow = true,
    this.onTapSlide,
    this.onIndexChanged,
    this.overlayBuilder,
  });

  @override
  State<PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<PromoCarousel> {
  late final PageController _controller;
  int _index = 0;
  Timer? _timer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController(keepPage: true);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.imagePaths.isEmpty) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!_isUserInteracting) _goNext();
    });
  }

  void _goPrev() {
    final prev =
        (_index - 1 + widget.imagePaths.length) % widget.imagePaths.length;
    _animateTo(prev);
  }

  void _goNext() {
    final next = (_index + 1) % widget.imagePaths.length;
    _animateTo(next);
  }

  void _animateTo(int page) {
    if (!mounted) return;
    _controller.animateToPage(
      page,
      duration: widget.slideDuration,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Dots
    Widget _dots() => Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.imagePaths.length, (i) {
        final selected = i == _index;
        return GestureDetector(
          onTap: () => _animateTo(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            height: 8,
            width: selected ? 18 : 8,
            decoration: BoxDecoration(
              color: selected
                  ? cs.primary
                  : cs.onSurfaceVariant.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        );
      }),
    );

    // Slide stack
    final slide = SizedBox(
      height: widget.height,
      child: Listener(
        onPointerDown: (_) {
          _isUserInteracting = true;
          _timer?.cancel();
        },
        onPointerUp: (_) {
          _isUserInteracting = false;
          _startAutoPlay();
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) {
                  setState(() => _index = i);
                  widget.onIndexChanged?.call(i);
                },
                itemCount: widget.imagePaths.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: widget.onTapSlide == null
                      ? null
                      : () => widget.onTapSlide!(i),
                  child: Image.asset(
                    widget.imagePaths[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),
              ),
            ),

            // Chevron arrows
            Positioned(
              left: 8,
              child: _RoundIconButton(
                icon: Icons.chevron_left,
                onTap: _goPrev,
                bg: cs.surface.withValues(alpha: 0.85),
                fg: cs.onSurface,
              ),
            ),
            Positioned(
              right: 8,
              child: _RoundIconButton(
                icon: Icons.chevron_right,
                onTap: _goNext,
                bg: cs.surface.withValues(alpha: 0.85),
                fg: cs.onSurface,
              ),
            ),

            if (widget.overlayBuilder != null)
              Positioned(
                left: 12,
                right: 12,
                bottom: 10,
                child: widget.overlayBuilder!(context, _index),
              ),

            if (!widget.dotsBelow)
              Positioned(
                bottom: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    child: _dots(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.dotsBelow) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [slide, const SizedBox(height: 8), _dots()],
      );
    }
    return slide;
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color bg;
  final Color fg;
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bg,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 22, color: fg),
        ),
      ),
    );
  }
}
