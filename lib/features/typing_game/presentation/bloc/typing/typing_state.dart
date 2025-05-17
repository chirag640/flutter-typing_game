part of 'typing_bloc.dart';

enum TypingStatus { initial, inProgress, completed }

class TypingState extends Equatable {
  final TypingStatus status;
  final TypingText typingText;
  final DateTime? startTime;
  final TypingStats? stats;
  final Difficulty difficulty;

  const TypingState({
    required this.status,
    required this.typingText,
    this.startTime,
    this.stats,
    required this.difficulty,
  });

  factory TypingState.initial() {
    return const TypingState(
      status: TypingStatus.initial,
      typingText:  TypingText(originalText: ''),
      difficulty: Difficulty.easy,
    );
  }

  TypingState copyWith({
    TypingStatus? status,
    TypingText? typingText,
    DateTime? startTime,
    TypingStats? stats,
    Difficulty? difficulty,
  }) {
    return TypingState(
      status: status ?? this.status,
      typingText: typingText ?? this.typingText,
      startTime: startTime ?? this.startTime,
      stats: stats ?? this.stats,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object?> get props => [status, typingText, startTime, stats, difficulty];
}
