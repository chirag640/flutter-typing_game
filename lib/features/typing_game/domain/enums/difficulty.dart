import 'package:flutter/material.dart';

enum Difficulty {
  easy,
  medium,
  hard
}

extension DifficultyExtension on Difficulty {
  String get name {
    switch (this) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }
  
  Color getColor() {
    switch (this) {
      case Difficulty.easy:
        return const Color(0xFF19A3B1);
      case Difficulty.medium:
        return Colors.orange;
      case Difficulty.hard:
        return Colors.red;
    }
  }
}
