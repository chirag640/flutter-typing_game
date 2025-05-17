import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:typing/features/typing_game/domain/entities/typing_stats.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';
import 'package:typing/features/typing_game/domain/enums/difficulty.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart';

part 'typing_event.dart';
part 'typing_state.dart';

class TypingBloc extends Bloc<TypingEvent, TypingState> {
  Timer? _timer;
  int _elapsedSeconds = 0;
  
  // Longer texts for timed mode to ensure users don't run out of text
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
  
  // Longer combined texts for timed mode
  static final Map<Difficulty, String> _combinedTexts = {
    Difficulty.easy: _difficultyTexts[Difficulty.easy]!.join(' '),
    Difficulty.medium: _difficultyTexts[Difficulty.medium]!.join(' '),
    Difficulty.hard: _difficultyTexts[Difficulty.hard]!.join(' '),
  };

  TypingBloc() : super(TypingState.initial()) {
    on<StartTypingTest>(_onStartTypingTest);
    on<UpdateTypedText>(_onUpdateTypedText);
    on<FinishTypingTest>(_onFinishTypingTest);
    on<ResetTypingTest>(_onResetTypingTest);
    on<ChangeDifficulty>(_onChangeDifficulty);
    on<ChangeGameMode>(_onChangeGameMode);
    on<SetTimedDuration>(_onSetTimedDuration);
    on<SetWordCountTarget>(_onSetWordCountTarget);
    on<SetErrorLimit>(_onSetErrorLimit);
  }

  void _onStartTypingTest(StartTypingTest event, Emitter<TypingState> emit) {
    _cancelTimer();
    _elapsedSeconds = 0;
    
    String text;
    int remainingSeconds = 0;
    
    switch (state.gameMode) {
      case GameMode.timed:
        // For timed mode, use combined texts to provide enough content
        text = _combinedTexts[state.difficulty] ?? '';
        remainingSeconds = state.timedDurationMinutes * 60;
        break;
      case GameMode.wordCount:
        // For word count, select text with enough words
        text = _getTextWithWordCount(state.wordCountTarget, state.difficulty);
        break;
      case GameMode.errorSurvival:
      case GameMode.standard:
      default:
        text = _getRandomText(state.difficulty);
        break;
    }
    
    emit(state.copyWith(
      status: TypingStatus.inProgress,
      typingText: TypingText(originalText: text),
      startTime: DateTime.now(),
      currentErrorCount: 0,
      remainingSeconds: remainingSeconds,
    ));
    
    _startTimer();
  }

  void _onUpdateTypedText(UpdateTypedText event, Emitter<TypingState> emit) {
    if (state.status != TypingStatus.inProgress) return;
    
    final updatedTypingText = state.typingText.copyWith(typedText: event.text);
    int errorCount = state.currentErrorCount;
    
    // Check for errors in typing for error survival mode
    if (state.gameMode == GameMode.errorSurvival) {
      errorCount = _countErrors(updatedTypingText);
      
      // End game if error limit reached
      if (errorCount >= state.errorLimit) {
        emit(state.copyWith(
          typingText: updatedTypingText,
          currentErrorCount: errorCount,
        ));
        add(FinishTypingTest());
        return;
      }
    }
    
    // For word count mode, check if target is reached
    if (state.gameMode == GameMode.wordCount) {
      int completedWords = _countCompletedWords(updatedTypingText);
      if (completedWords >= state.wordCountTarget) {
        emit(state.copyWith(typingText: updatedTypingText));
        add(FinishTypingTest());
        return;
      }
    }
    
    // Auto finish if text is complete for standard mode
    if (state.gameMode == GameMode.standard && 
        updatedTypingText.typedText.length == updatedTypingText.originalText.length) {
      emit(state.copyWith(typingText: updatedTypingText));
      add(FinishTypingTest());
      return;
    }
    
    emit(state.copyWith(
      typingText: updatedTypingText,
      currentErrorCount: errorCount,
    ));
  }

  void _onFinishTypingTest(FinishTypingTest event, Emitter<TypingState> emit) {
    _cancelTimer();
    final duration = Duration(seconds: _elapsedSeconds);
    
    final TypingStats stats = _calculateStats(state.typingText, duration);
    
    // Explicitly determine the status based on game mode and conditions
    TypingStatus endStatus;
    if (state.gameMode == GameMode.errorSurvival && state.currentErrorCount >= state.errorLimit) {
      endStatus = TypingStatus.failed;
    } else {
      endStatus = TypingStatus.completed;
    }
    
    emit(state.copyWith(
      status: endStatus,
      stats: stats,
    ));
  }

  void _onResetTypingTest(ResetTypingTest event, Emitter<TypingState> emit) {
    _cancelTimer();
    _elapsedSeconds = 0;
    emit(TypingState.initial().copyWith(
      difficulty: state.difficulty,
      gameMode: state.gameMode,
      timedDurationMinutes: state.timedDurationMinutes,
      wordCountTarget: state.wordCountTarget,
      errorLimit: state.errorLimit,
    ));
  }
  
  void _onChangeDifficulty(ChangeDifficulty event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(difficulty: event.difficulty));
    }
  }
  
  void _onChangeGameMode(ChangeGameMode event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(gameMode: event.gameMode));
    }
  }
  
  void _onSetTimedDuration(SetTimedDuration event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(timedDurationMinutes: event.minutes));
    }
  }
  
  void _onSetWordCountTarget(SetWordCountTarget event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(wordCountTarget: event.targetWords));
    }
  }
  
  void _onSetErrorLimit(SetErrorLimit event, Emitter<TypingState> emit) {
    if (state.status == TypingStatus.initial) {
      emit(state.copyWith(errorLimit: event.errorLimit));
    }
  }

  String _getRandomText(Difficulty difficulty) {
    final texts = List<String>.from(_difficultyTexts[difficulty] ?? _difficultyTexts[Difficulty.easy]!);
    texts.shuffle();
    return texts.first;
  }
  
  String _getTextWithWordCount(int wordCount, Difficulty difficulty) {
    final texts = _difficultyTexts[difficulty] ?? _difficultyTexts[Difficulty.easy]!;
    String combined = '';
    
    // Keep adding texts until we reach the word count
    while (_countWords(combined) < wordCount) {
      texts.shuffle();
      combined += ' ${texts.first}';
    }
    
    return combined.trim();
  }
  
  int _countWords(String text) {
    return text.trim().split(RegExp(r'\s+')).length;
  }
  
  int _countCompletedWords(TypingText typingText) {
    // Count fully typed words
    final typedWords = typingText.typedText.trim().split(RegExp(r'\s+'));
    final originalWords = typingText.originalText.trim().split(RegExp(r'\s+'));
    
    int completedWords = 0;
    for (int i = 0; i < typedWords.length && i < originalWords.length; i++) {
      if (typedWords[i] == originalWords[i]) {
        completedWords++;
      }
    }
    
    return completedWords;
  }
  
  int _countErrors(TypingText typingText) {
    int errors = 0;
    final String typed = typingText.typedText;
    final String original = typingText.originalText;
    
    for (int i = 0; i < typed.length && i < original.length; i++) {
      if (typed[i] != original[i]) {
        errors++;
      }
    }
    
    return errors;
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
      
      // For timed mode, update remaining time and finish when time's up
      if (state.gameMode == GameMode.timed && state.status == TypingStatus.inProgress) {
        final remainingSeconds = (state.timedDurationMinutes * 60) - _elapsedSeconds;
        
        if (remainingSeconds <= 0) {
          add(FinishTypingTest());
        } else {
          emit(state.copyWith(remainingSeconds: remainingSeconds));
        }
      }
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
