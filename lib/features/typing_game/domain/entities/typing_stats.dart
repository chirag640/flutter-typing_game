import 'package:equatable/equatable.dart';

class TypingStats extends Equatable {
  final int wordsPerMinute;
  final int accuracy;
  final int correctChars;
  final int incorrectChars;
  final Duration duration;
  final int completedWords;
  final int totalWords;
  
  const TypingStats({
    required this.wordsPerMinute,
    required this.accuracy,
    required this.correctChars,
    required this.incorrectChars,
    required this.duration,
    this.completedWords = 0,
    this.totalWords = 0,
  });

  @override
  List<Object?> get props => [
    wordsPerMinute,
    accuracy,
    correctChars,
    incorrectChars,
    duration,
    completedWords,
    totalWords,
  ];
}
