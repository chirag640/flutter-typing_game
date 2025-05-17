import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/features/typing_game/domain/entities/typing_stats.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';


class TypingBloc extends Bloc<TypingEvent, TypingState> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  static const List<String> _sampleTexts = [
    'The quick brown fox jumps over the lazy dog.',
    'Programming is the art of telling another human what one wants the computer to do.',
    'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
    'Life is like riding a bicycle. To keep your balance, you must keep moving.',
    'The greatest glory in living lies not in never falling, but in rising every time we fall.',
  ];

  TypingBloc() : super(TypingState.initial()) {
    on<StartTypingTest>(_onStartTypingTest);
    on<UpdateTypedText>(_onUpdateTypedText);
    on<FinishTypingTest>(_onFinishTypingTest);
    on<ResetTypingTest>(_onResetTypingTest);
  }

  void _onStartTypingTest(StartTypingTest event, Emitter<TypingState> emit) {
    _startTimer();
    
    final String randomText = _getRandomText();
    emit(state.copyWith(
      status: TypingStatus.inProgress,
      typingText: TypingText(originalText: randomText),
      startTime: DateTime.now(),
    ));
  }

  void _onUpdateTypedText(UpdateTypedText event, Emitter<TypingState> emit) {
    if (state.status != TypingStatus.inProgress) return;
    
    final updatedTypingText = state.typingText.copyWith(typedText: event.text);
    
    // Auto finish if text is complete
    if (updatedTypingText.typedText.length == updatedTypingText.originalText.length) {
      add(FinishTypingTest());
    }
    
    emit(state.copyWith(typingText: updatedTypingText));
  }

  void _onFinishTypingTest(FinishTypingTest event, Emitter<TypingState> emit) {
    _cancelTimer();
    final duration = Duration(seconds: _elapsedSeconds);
    
    final stats = _calculateStats(state.typingText, duration);
    
    emit(state.copyWith(
      status: TypingStatus.completed,
      stats: stats,
    ));
  }

  void _onResetTypingTest(ResetTypingTest event, Emitter<TypingState> emit) {
    _cancelTimer();
    _elapsedSeconds = 0;
    emit(TypingState.initial());
  }

  String _getRandomText() {
    final texts = List<String>.from(_sampleTexts); // Create a mutable copy
    texts.shuffle();
    return texts.first;
  }

  TypingStats _calculateStats(TypingText typingText, Duration duration) {
    int correctChars = 0;
    int incorrectChars = 0;
    
    for (int i = 0; i < typingText.typedText.length; i++) {
      if (i >= typingText.originalText.length) {
        incorrectChars++;
      } else if (typingText.typedText[i] == typingText.originalText[i]) {
        correctChars++;
      } else {
        incorrectChars++;
      }
    }
    
    // Calculate words per minute (assuming average word length is 5 characters)
    final totalChars = correctChars;
    final minutes = duration.inSeconds / 60;
    final wordsPerMinute = minutes > 0 ? ((totalChars / 5) / minutes).round() : 0;
    
    // Calculate accuracy
    final totalTyped = correctChars + incorrectChars;
    final accuracy = totalTyped > 0 ? ((correctChars / totalTyped) * 100).round() : 0;
    
    return TypingStats(
      wordsPerMinute: wordsPerMinute,
      accuracy: accuracy,
      correctChars: correctChars,
      incorrectChars: incorrectChars,
      duration: duration,
    );
  }

  void _startTimer() {
    _cancelTimer();
    _elapsedSeconds = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
    });
  }

  void _cancelTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}

class TypingEvent extends Equatable {
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


enum TypingStatus { initial, inProgress, completed }

class TypingState extends Equatable {
  final TypingStatus status;
  final TypingText typingText;
  final DateTime? startTime;
  final TypingStats? stats;

  const TypingState({
    required this.status,
    required this.typingText,
    this.startTime,
    this.stats,
  });

  factory TypingState.initial() {
    return TypingState(
      status: TypingStatus.initial,
      typingText: const TypingText(originalText: ''),
    );
  }

  TypingState copyWith({
    TypingStatus? status,
    TypingText? typingText,
    DateTime? startTime,
    TypingStats? stats,
  }) {
    return TypingState(
      status: status ?? this.status,
      typingText: typingText ?? this.typingText,
      startTime: startTime ?? this.startTime,
      stats: stats ?? this.stats,
    );
  }

  @override
  List<Object?> get props => [status, typingText, startTime, stats];
}
