class TypingStats {
  final int wordsPerMinute;
  final int accuracy;
  final int correctChars;
  final int incorrectChars;
  final Duration duration;

  const TypingStats({
    required this.wordsPerMinute,
    required this.accuracy,
    required this.correctChars,
    required this.incorrectChars,
    required this.duration,
  });
}
