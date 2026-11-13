import 'package:flutter/material.dart';
import '../utils/maneuver_mapper.dart';

/// Widget hiển thị icon hướng rẽ với vòng tròn màu nền
class ManeuverIcon extends StatelessWidget {
  final String maneuver;
  final double size;
  final Color? color;
  final Color? backgroundColor;

  const ManeuverIcon({
    super.key,
    required this.maneuver,
    this.size = 36.0,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? Colors.white;
    final bgColor = backgroundColor ?? ManeuverMapper.getColor(maneuver);

    return Container(
      width: size * 1.6,
      height: size * 1.6,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          ManeuverMapper.getIcon(maneuver),
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
