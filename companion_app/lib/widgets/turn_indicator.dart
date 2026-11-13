import 'package:flutter/material.dart';
import '../models/turn_instruction.dart';
import '../utils/distance_formatter.dart';
import '../utils/maneuver_mapper.dart';
import 'maneuver_icon.dart';

/// Card thông báo hướng rẽ hiện tại trong chế độ dẫn đường
class TurnIndicator extends StatelessWidget {
  final TurnInstruction currentStep;
  final TurnInstruction? nextStep;
  final double distanceToNextTurn;

  const TurnIndicator({
    super.key,
    required this.currentStep,
    this.nextStep,
    required this.distanceToNextTurn,
  });

  @override
  Widget build(BuildContext context) {
    final distanceStr = DistanceFormatter.format(distanceToNextTurn);
    final street = currentStep.streetName.isNotEmpty
        ? currentStep.streetName
        : ManeuverMapper.getDescription(currentStep.maneuver);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ManeuverIcon(maneuver: currentStep.maneuver, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        distanceStr,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      Text(
                        street,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (nextStep != null) ...[
              const Divider(height: 20),
              Row(
                children: [
                  const Text(
                    'Tiếp theo:',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    ManeuverMapper.getIcon(nextStep!.maneuver),
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      nextStep!.streetName.isNotEmpty
                          ? nextStep!.streetName
                          : ManeuverMapper.getDescription(nextStep!.maneuver),
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
