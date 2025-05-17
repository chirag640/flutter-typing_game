import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/features/typing_game/domain/entities/typing_stats.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';
import 'package:typing/features/typing_game/domain/enums/difficulty.dart';

part 'typing_event.dart';
part 'typing_state.dart';

class TypingBloc extends Bloc<TypingEvent, TypingState> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  static const Map<Difficulty, List<String>> _difficultyTexts = {
    Difficulty.easy: [
      'The countryside was a patchwork of fields and meadows, with rolling hills stretching out as far as the eye could see.',
      'I enjoy reading books and watching movies in my free time. What are your favorite hobbies?',
      'The sun rises in the east and sets in the west. It is a beautiful sight to see.',
      'My favorite season is spring when flowers bloom and birds sing happily in the trees.',
      'The small cafe on the corner serves the best coffee and pastries in town.',
    ],
    Difficulty.medium: [
      'Programming requires attention to detail, logical thinking, and problem-solving skills to create efficient solutions.',
      'Artificial intelligence and machine learning are transforming various industries through automation and data analysis.',
      'The quantum computer uses qubits instead of bits, allowing for much faster processing of certain complex problems.',
      'Sustainable development balances economic growth with environmental protection and social inclusion for future generations.',
      'The cryptocurrency market experiences significant volatility, influenced by regulatory news and technological developments.',
    ],
    Difficulty.hard: [
      'The juxtaposition of paradoxical elements in the quantum realm exemplifies the inexplicable nature of subatomic particles.',
      'The software developer implemented a sophisticated algorithm utilizing asynchronous processes and multithreading capabilities.',
      'Pseudopseudohypoparathyroidism is a genetic disorder characterized by end-organ resistance to the action of parathyroid hormone.',
      'The interdisciplinary approach to climate change mitigation encompasses economic, sociopolitical, and technological innovations.',
      'The archaeologist\'s meticulous excavation revealed an extraordinary paleolithic artifact with unprecedented hieroglyphic inscriptions.',
    ],
  };

  TypingBloc() : super(TypingState.initial()) {
    on<StartTypingTest>(_onStartTypingTest);
    on<UpdateTypedText>(_onUpdateTypedText);
    on<FinishTypingTest>(_onFinishTypingTest);
    on<ResetTypingTest>(_onResetTypingTest);
    on<ChangeDifficulty>(_onChangeDifficulty);
  }

  void _onStartTypingTest(StartTypingTest event, Emitter<TypingState> emit) {
    _startTimer();
    
    final String randomText = _getRandomText(state.difficulty);
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
    emit(TypingState.initial().copyWith(difficulty: state.difficulty));
  }
  
  void _onChangeDifficulty(ChangeDifficulty event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(difficulty: event.difficulty));
    }
  }

  String _getRandomText(Difficulty difficulty) {
    final texts = List<String>.from(_difficultyTexts[difficulty] ?? _difficultyTexts[Difficulty.easy]!);
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
