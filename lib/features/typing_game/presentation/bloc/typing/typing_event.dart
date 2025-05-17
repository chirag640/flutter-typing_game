part of 'typing_bloc.dart';

abstract class TypingEvent extends Equatable {
  const TypingEvent();

  @override
  List<Object> get props => [];
}

class StartTypingTest extends TypingEvent {}

class UpdateTypedText extends TypingEvent {
  final String text;

  const UpdateTypedText(this.text);

  @override
  List<Object> get props => [text];
}

class FinishTypingTest extends TypingEvent {}

class ResetTypingTest extends TypingEvent {}

class ChangeDifficulty extends TypingEvent {
  final Difficulty difficulty;

  const ChangeDifficulty(this.difficulty);

  @override
  List<Object> get props => [difficulty];
}

class ChangeGameMode extends TypingEvent {
  final GameMode gameMode;

  const ChangeGameMode(this.gameMode);

  @override
  List<Object> get props => [gameMode];
}

class SetTimedDuration extends TypingEvent {
  final int minutes;

  const SetTimedDuration(this.minutes);

  @override
  List<Object> get props => [minutes];
}

class SetWordCountTarget extends TypingEvent {
  final int targetWords;

  const SetWordCountTarget(this.targetWords);

  @override
  List<Object> get props => [targetWords];
}

class SetErrorLimit extends TypingEvent {
  final int errorLimit;

  const SetErrorLimit(this.errorLimit);

  @override
  List<Object> get props => [errorLimit];
}
