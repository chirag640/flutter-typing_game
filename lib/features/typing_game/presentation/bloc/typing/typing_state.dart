part of 'typing_bloc.dart';

enum TypingStatus { initial, inProgress, completed, failed }

class TypingState extends Equatable {
  final TypingStatus status;
  final TypingText typingText;
  final TypingStats? stats;
  final DateTime? startTime;
  final Difficulty difficulty;
  final GameMode gameMode;
  final int timedDurationMinutes;
  final int wordCountTarget;
  final int errorLimit;
  final int currentErrorCount;
  final int remainingSeconds;

  const TypingState({
    required this.status,
    required this.typingText,
    this.stats,
    this.startTime,
    required this.difficulty,
    required this.gameMode,
    required this.timedDurationMinutes,
    required this.wordCountTarget,
    required this.errorLimit,
    required this.currentErrorCount,
    required this.remainingSeconds,
  });

  factory TypingState.initial() {
    return const TypingState(
      status: TypingStatus.initial,
      typingText: TypingText(originalText: '', typedText: ''),
      difficulty: Difficulty.easy,
      gameMode: GameMode.standard,
      timedDurationMinutes: 1,
      wordCountTarget: 50,
      errorLimit: 5,
      currentErrorCount: 0,
      remainingSeconds: 0,
    );
  }

  TypingState copyWith({
    TypingStatus? status,
    TypingText? typingText,
    TypingStats? stats,
    DateTime? startTime,
    Difficulty? difficulty,
    GameMode? gameMode,
    int? timedDurationMinutes,
    int? wordCountTarget,
    int? errorLimit,
    int? currentErrorCount,
    int? remainingSeconds,
  }) {
    return TypingState(
      status: status ?? this.status,
      typingText: typingText ?? this.typingText,
      stats: stats ?? this.stats,
      startTime: startTime ?? this.startTime,
      difficulty: difficulty ?? this.difficulty,
      gameMode: gameMode ?? this.gameMode,
      timedDurationMinutes: timedDurationMinutes ?? this.timedDurationMinutes,
      wordCountTarget: wordCountTarget ?? this.wordCountTarget,
      errorLimit: errorLimit ?? this.errorLimit,
      currentErrorCount: currentErrorCount ?? this.currentErrorCount,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
    );
  }

  @override
  List<Object?> get props => [
        status,
        typingText,
        stats,
        startTime,
        difficulty,
        gameMode,
        timedDurationMinutes,
        wordCountTarget,
        errorLimit,
        currentErrorCount,
        remainingSeconds,
      ];
}
