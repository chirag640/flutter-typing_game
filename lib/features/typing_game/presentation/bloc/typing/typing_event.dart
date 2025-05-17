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
