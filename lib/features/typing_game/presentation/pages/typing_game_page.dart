import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart'; // Add this import
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';
import 'package:typing/features/typing_game/presentation/widgets/game_settings_panel.dart';
import 'package:typing/features/typing_game/presentation/widgets/typing_area.dart';
import 'package:typing/features/typing_game/presentation/widgets/results_display.dart';

class TypingGamePage extends StatelessWidget {
  const TypingGamePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TypingBloc(),
      child: const _TypingGameView(),
    );
  }
}

class _TypingGameView extends StatelessWidget {
  const _TypingGameView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Game'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<TypingBloc, TypingState>(
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game mode & settings section
                  const GameSettingsPanel(),
                  
                  // Game status indicator
                  _buildGameStatusIndicator(context, state),
                  
                  // Game area (typing area or results)
                  if (state.status == TypingStatus.initial) 
                    _buildStartButton(context)
                  else if (state.status == TypingStatus.inProgress)
                    _buildTypingTest(context, state)
                  else
                    _buildResults(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGameStatusIndicator(BuildContext context, TypingState state) {
    if (state.status == TypingStatus.initial) {
      return const SizedBox.shrink();
    }
    
    // Show relevant information based on game mode
    String statusText = '';
    if (state.status == TypingStatus.inProgress) {
      if (state.gameMode == GameMode.timed) {
        final minutes = state.remainingSeconds ~/ 60;
        final seconds = state.remainingSeconds % 60;
        statusText = 'Time Remaining: $minutes:${seconds.toString().padLeft(2, '0')}';
      } else if (state.gameMode == GameMode.wordCount) {
        final completedWords = _countCompletedWords(state.typingText);
        statusText = 'Words: $completedWords / ${state.wordCountTarget}';
      } else if (state.gameMode == GameMode.errorSurvival) {
        statusText = 'Errors: ${state.currentErrorCount} / ${state.errorLimit}';
      }
    } else {
      statusText = state.status == TypingStatus.completed ? 'Completed!' : 'Failed!';
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: Text(
          statusText,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () {
            context.read<TypingBloc>().add(StartTypingTest());
          },
          child: const Text(
            'Start Typing Test',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }

  Widget _buildTypingTest(BuildContext context, TypingState state) {
    return const TypingArea(); // Implement this widget to handle typing
  }

  Widget _buildResults(BuildContext context, TypingState state) {
    return Column(
      children: [
        const ResultsDisplay(), // Implement this widget to show test results
        const SizedBox(height: 24),
        Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<TypingBloc>().add(ResetTypingTest());
            },
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }

  // Helper method to count completed words
  int _countCompletedWords(TypingText typingText) {
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
}
