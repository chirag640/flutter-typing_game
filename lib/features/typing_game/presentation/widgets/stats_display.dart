import 'package:flutter/material.dart';
import 'package:typing/features/typing_game/domain/entities/typing_stats.dart';

class StatsDisplay extends StatelessWidget {
  final TypingStats stats;

  const StatsDisplay({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatRow(
              context,
              'Words Per Minute',
              '${stats.wordsPerMinute}',
              Icons.speed,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Accuracy',
              '${stats.accuracy}%',
              Icons.analytics,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Correct Characters',
              '${stats.correctChars}',
              Icons.check_circle,
              color: Colors.green,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Incorrect Characters',
              '${stats.incorrectChars}',
              Icons.cancel,
              color: Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              context,
              'Time',
              '${stats.duration.inSeconds} seconds',
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
