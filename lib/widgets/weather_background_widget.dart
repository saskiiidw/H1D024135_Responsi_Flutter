import 'dart:math' as math;
import 'package:flutter/material.dart';

enum WeatherAtmosphereType {
  sunnyDay,
  sunnyNight,
  cloudyDay,
  cloudyNight,
  rainyDay,
  rainyNight,
  thunderstorm,
}

class WeatherBackgroundWidget extends StatefulWidget {
  final int weatherCode;
  final int isDay;
  final Widget child;

  const WeatherBackgroundWidget({
    super.key,
    required this.weatherCode,
    required this.isDay,
    required this.child,
  });

  static WeatherAtmosphereType getAtmosphereType(int code, int isDay) {
    final bool day = (isDay == 1);

    // 1. Thunderstorm or Heavy Snow
    if ([95, 96, 99, 71, 73, 75, 77, 85, 86].contains(code)) {
      return WeatherAtmosphereType.thunderstorm;
    }
    // 2. Rain / Drizzle / Showers
    if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
      return day ? WeatherAtmosphereType.rainyDay : WeatherAtmosphereType.rainyNight;
    }
    // 3. Cloudy / Fog
    if ([2, 3, 45, 48].contains(code)) {
      return day ? WeatherAtmosphereType.cloudyDay : WeatherAtmosphereType.cloudyNight;
    }
    // 4. Sunny / Clear (code 0, 1)
    return day ? WeatherAtmosphereType.sunnyDay : WeatherAtmosphereType.sunnyNight;
  }

  @override
  State<WeatherBackgroundWidget> createState() => _WeatherBackgroundWidgetState();
}

class _WeatherBackgroundWidgetState extends State<WeatherBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Star> _stars = [];
  final List<_RainDrop> _rainDrops = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Generate fixed random stars
    for (int i = 0; i < 45; i++) {
      _stars.add(_Star(
        x: _random.nextDouble(),
        y: _random.nextDouble() * 0.55,
        size: _random.nextDouble() * 2.2 + 0.8,
        blinkSpeed: _random.nextDouble() * 3 + 1,
      ));
    }

    // Generate rain drops
    for (int i = 0; i < 55; i++) {
      _rainDrops.add(_RainDrop(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        length: _random.nextDouble() * 18 + 10,
        speed: _random.nextDouble() * 0.4 + 0.6,
        opacity: _random.nextDouble() * 0.5 + 0.3,
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Color> _getGradientColors(WeatherAtmosphereType type) {
    switch (type) {
      case WeatherAtmosphereType.sunnyDay:
        return const [
          Color(0xFF5D91B9),
          Color(0xFF8BB8D8),
          Color(0xFFB8D4E8),
        ];
      case WeatherAtmosphereType.sunnyNight:
        return const [
          Color(0xFF0B1B3D),
          Color(0xFF132A53),
          Color(0xFF1C3A6B),
        ];
      case WeatherAtmosphereType.cloudyDay:
        return const [
          Color(0xFF4A6B82),
          Color(0xFF6B8CA3),
          Color(0xFF8DAEC4),
        ];
      case WeatherAtmosphereType.cloudyNight:
        return const [
          Color(0xFF0F172A),
          Color(0xFF1E293B),
          Color(0xFF334155),
        ];
      case WeatherAtmosphereType.rainyDay:
        return const [
          Color(0xFF3B4E61),
          Color(0xFF52697F),
          Color(0xFF6C849B),
        ];
      case WeatherAtmosphereType.rainyNight:
        return const [
          Color(0xFF09121F),
          Color(0xFF112033),
          Color(0xFF1B2E47),
        ];
      case WeatherAtmosphereType.thunderstorm:
        return const [
          Color(0xFF0D131A),
          Color(0xFF1A2634),
          Color(0xFF283647),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final type = WeatherBackgroundWidget.getAtmosphereType(
        widget.weatherCode, widget.isDay);
    final colors = _getGradientColors(type);

    final bool isNight = widget.isDay == 0;
    final bool isRainy = type == WeatherAtmosphereType.rainyDay ||
        type == WeatherAtmosphereType.rainyNight ||
        type == WeatherAtmosphereType.thunderstorm;
    final bool isStorm = type == WeatherAtmosphereType.thunderstorm;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;

          return Stack(
            children: [
              // 1. Sunlight Glow Effect (Sunny Day)
              if (type == WeatherAtmosphereType.sunnyDay)
                Positioned(
                  top: -60,
                  right: MediaQuery.of(context).size.width * 0.2,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.amberAccent.withValues(alpha: 0.35),
                          Colors.white.withValues(alpha: 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

              // 2. Moon (Night Modes)
              if (isNight)
                Positioned(
                  top: 50,
                  right: 40,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.amber.shade50.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.shade100.withValues(alpha: 0.4),
                          blurRadius: 24,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),

              // 3. Twinkling Stars (Sunny/Cloudy Night)
              if (isNight && !isRainy)
                CustomPaint(
                  size: Size.infinite,
                  painter: _StarsPainter(_stars, progress),
                ),

              // 4. Floating Clouds Movement
              Positioned(
                top: -30,
                right: -40 + (math.sin(progress * math.pi * 2) * 20),
                child: Icon(
                  Icons.cloud_rounded,
                  size: 260,
                  color: isNight
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.white.withValues(alpha: 0.15),
                ),
              ),
              Positioned(
                top: 140,
                left: -50 + (math.cos(progress * math.pi * 2) * 15),
                child: Icon(
                  Icons.cloud_queue_rounded,
                  size: 200,
                  color: isNight
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),

              // 5. Falling Raindrops (Rainy/Storm Modes)
              if (isRainy)
                CustomPaint(
                  size: Size.infinite,
                  painter: _RainPainter(_rainDrops, progress),
                ),

              // 6. Lightning Flash (Thunderstorm)
              if (isStorm)
                _LightningFlashWidget(progress: progress),

              // Main Child Content
              widget.child,
            ],
          );
        },
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double blinkSpeed;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.blinkSpeed,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress;

  _StarsPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var star in stars) {
      final opacity =
          (0.3 + 0.7 * math.sin((progress * star.blinkSpeed * math.pi * 2)))
              .clamp(0.1, 1.0);
      paint.color = Colors.white.withValues(alpha: opacity);
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}

class _RainDrop {
  final double x;
  final double y;
  final double length;
  final double speed;
  final double opacity;

  _RainDrop({
    required this.x,
    required this.y,
    required this.length,
    required this.speed,
    required this.opacity,
  });
}

class _RainPainter extends CustomPainter {
  final List<_RainDrop> drops;
  final double progress;

  _RainPainter(this.drops, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5;

    for (var drop in drops) {
      final currentY = ((drop.y + progress * drop.speed * 2) % 1.0) * size.height;
      final currentX = drop.x * size.width - 20; // Slight slant

      paint.color = Colors.lightBlue.shade100.withValues(alpha: drop.opacity);
      canvas.drawLine(
        Offset(currentX, currentY),
        Offset(currentX - 5, currentY + drop.length),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) => true;
}

class _LightningFlashWidget extends StatelessWidget {
  final double progress;

  const _LightningFlashWidget({required this.progress});

  @override
  Widget build(BuildContext context) {
    // Flash briefly at specific animation progress intervals (e.g. 0.24-0.27 and 0.74-0.76)
    final bool isFlashing =
        (progress > 0.24 && progress < 0.27) || (progress > 0.74 && progress < 0.76);
    final double opacity = isFlashing ? 0.25 : 0.0;

    return IgnorePointer(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
