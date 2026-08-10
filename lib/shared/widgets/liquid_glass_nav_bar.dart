import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import '../../app/app_colors.dart';
import '../../app/app_spacing.dart';
import '../../app/app_text_styles.dart';

/// Liquid glass bottom navigation'daki tek bir item'ı tanımlar.
class LiquidNavItem {
  const LiquidNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Apple tarzı floating, glass/translucent bottom navigation.
///
/// Adım 2: Highlight artık AnimationController + SpringSimulation ile
/// fiziksel bir yay gibi hareket ediyor (Adım 1'deki düz AnimatedPositioned
/// kaldırıldı). Adım 3'te aynı controller'a stretch/squash eklenecek.
///
/// Dışa açık API (items/selectedIndex/onDestinationSelected) değişmedi —
/// bu widget'ı kullanan yerlerde (RoomDetailScreen) hiçbir değişiklik
/// gerekmiyor.
///
///

class _LiquidIndicatorPainter extends CustomPainter {
  const _LiquidIndicatorPainter({
    required this.progress,
    required this.velocity,
    required this.color,
  });

  final double progress;
  final double velocity;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final speed = velocity.abs().clamp(0.0, 5.0);
    final movement = (speed / 5.0).clamp(0.0, 1.0);

    // Seçili kategorinin tamamını kaplayan kapsül.
    // Kenarlarda sadece küçük bir nefes payı bırakıyoruz.
    final horizontalPadding = size.width * 0.035;
    final verticalPadding = size.height * 0.08;

    final baseWidth = size.width - (horizontalPadding * 2);
    final baseHeight = size.height - (verticalPadding * 2);

    // Hareket sırasında hafif liquid stretch.
    final stretch = 1.0 + (movement * 0.12);
    final squash = 1.0 - (movement * 0.035);

    final bubbleWidth = baseWidth * stretch;
    final bubbleHeight = baseHeight * squash;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    final left = centerX - bubbleWidth / 2;
    final top = centerY - bubbleHeight / 2;
    final right = centerX + bubbleWidth / 2;
    final bottom = centerY + bubbleHeight / 2;

    // Tam kapsül/elips.
    final radius = bubbleHeight / 2;

    final rect = Rect.fromLTRB(left, top, right, bottom);

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // ─────────────────────────────────────────
    // GLASS BODY
    // ─────────────────────────────────────────

    final glassPaint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              color.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.08),
            ],
          ).createShader(rect);

    canvas.drawRRect(rrect, glassPaint);

    // ─────────────────────────────────────────
    // SOFT LIGHT / HIGHLIGHT
    // ─────────────────────────────────────────

    final highlightPaint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.45, -0.7),
            radius: 1.15,
            colors: [
              Colors.white.withValues(alpha: 0.20),
              Colors.white.withValues(alpha: 0.04),
              Colors.transparent,
            ],
          ).createShader(rect);

    canvas.drawRRect(rrect, highlightPaint);

    // ─────────────────────────────────────────
    // GLASS EDGE
    // ─────────────────────────────────────────

    final borderPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.16)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _LiquidIndicatorPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.velocity != velocity ||
        oldDelegate.color != color;
  }
}

class LiquidGlassNavBar extends StatefulWidget {
  const LiquidGlassNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<LiquidNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  State<LiquidGlassNavBar> createState() => _LiquidGlassNavBarState();
}

class _LiquidGlassNavBarState extends State<LiquidGlassNavBar>
    with SingleTickerProviderStateMixin {
  static const double _barHeight = 68;
  static const double _radius = 28;

  // Agresif olmayan, doğal hissettiren bir yay: hafif "overshoot" var
  // ama hızlı sönümleniyor. Beğenmezsen bu 3 sayıyla oynanabilir.
  static const SpringDescription _spring = SpringDescription(
    mass: 1,
    stiffness: 300,
    damping: 24,
  );

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(
      vsync: this,
      value: widget.selectedIndex.toDouble(),
    );
  }

  @override
  void didUpdateWidget(covariant LiquidGlassNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _animateTo(widget.selectedIndex.toDouble());
    }
  }

  void _animateTo(double target) {
    final simulation = SpringSimulation(
      _spring,
      _controller.value, // mevcut konum
      target, // hedef index
      _controller.velocity, // devam eden hareketin hızı (kesiklik olmasın)
    );
    _controller.animateWith(simulation);
  }

  Widget _buildNavItem({required LiquidNavItem item, required int index}) {
    final selected = index == widget.selectedIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          splashColor: Colors.white.withValues(alpha: 0.06),
          highlightColor: Colors.white.withValues(alpha: 0.03),
          onTap: () => widget.onDestinationSelected(index),
          child: SizedBox(
            height: _barHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: selected ? 1.06 : 1.0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: selected ? 1.0 : 0.55,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      selected ? item.selectedIcon : item.icon,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                ),

                const SizedBox(height: 3),

                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white.withValues(
                      alpha: selected ? 1.0 : 0.55,
                    ),
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  child: Text(item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          0,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: _barHeight,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(_radius),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.28),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / widget.items.length;

                  return Stack(
                    children: [
                      // ── Highlight (spring ile hareket ediyor) ────────
                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          final current = _controller.value;
                          final velocity = _controller.velocity;

                          return Positioned(
                            left: itemWidth * current,
                            top: 3,
                            width: itemWidth,
                            height: _barHeight - 6,
                            child: CustomPaint(
                              painter: _LiquidIndicatorPainter(
                                progress: current,
                                velocity: velocity,
                                color: Colors.white.withValues(alpha: 0.10),
                              ),
                            ),
                          );
                        },
                      ),

                      // ── Item'lar ─────────────────────────────────────
                      Row(
                        children: List.generate(
                          widget.items.length,
                          (index) => _buildNavItem(
                            item: widget.items[index],
                            index: index,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
