import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';
import 'package:typing/features/typing_game/presentation/widgets/typing_area.dart';
import 'package:typing/features/typing_game/presentation/widgets/results_display.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';

class TypingPage extends StatefulWidget {
  const TypingPage({Key? key}) : super(key: key);

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypingBloc, TypingState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_getAppBarTitle(state)),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                // Reset the typing test if navigating back
                context.read<TypingBloc>().add(ResetTypingTest());
                Navigator.of(context).pop();
              },
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Game status indicator
                  _buildGameStatusIndicator(context, state),
                  const SizedBox(height: 16),
                
                  // Show appropriate content based on game status
                  if (state.status == TypingStatus.initial)
                    _buildStartButton(context)
                  else if (state.status == TypingStatus.inProgress)
                    const TypingArea()
                  else // completed or failed
                    _buildResultsSection(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getAppBarTitle(TypingState state) {
    switch (state.status) {
      case TypingStatus.initial:
        return 'Ready to Type';
      case TypingStatus.inProgress:
        return 'Typing Test';
      case TypingStatus.completed:
        return 'Test Complete';
      case TypingStatus.failed:
        return 'Game Over';
      default:
        return 'Typing Game';
    }
  }

  Widget _buildGameStatusIndicator(BuildContext context, TypingState state) {
    if (state.status == TypingStatus.initial) {
      return const SizedBox.shrink();
    }
    
    // Show relevant information based on game mode
    String statusText = '';
    Color statusColor = Colors.blue;
    
    if (state.status == TypingStatus.inProgress) {
      switch (state.gameMode) {
        case GameMode.timed:
          final minutes = state.remainingSeconds ~/ 60;
          final seconds = state.remainingSeconds % 60;
          statusText = 'Time Remaining: $minutes:${seconds.toString().padLeft(2, '0')}';
          if (state.remainingSeconds < 10) {
            statusColor = Colors.red;
          } else if (state.remainingSeconds < 30) {
            statusColor = Colors.orange;
          }
          break;
        case GameMode.wordCount:
          final completedWords = _countCompletedWords(state.typingText);
          final progress = completedWords / state.wordCountTarget;
          statusText = 'Words: $completedWords / ${state.wordCountTarget}';
          if (progress > 0.8) {
            statusColor = Colors.green;
          } else if (progress > 0.5) {
            statusColor = Colors.blue;
          } else {
            statusColor = Colors.orange;
          }
          break;
        case GameMode.errorSurvival:
          final errorsLeft = state.errorLimit - state.currentErrorCount;
          statusText = 'Errors: ${state.currentErrorCount} / ${state.errorLimit}';
          if (errorsLeft <= 1) {
            statusColor = Colors.red;
          } else if (errorsLeft <= 3) {
            statusColor = Colors.orange;
          }
          break;
        default:
          final progress = state.typingText.typedText.length / 
              (state.typingText.originalText.isNotEmpty ? state.typingText.originalText.length : 1);
          statusText = 'Progress: ${(progress * 100).toInt()}%';
      }
    } else {
      statusText = state.status == TypingStatus.completed ? 'Completed!' : 'Game Over!';
      statusColor = state.status == TypingStatus.completed ? Colors.green : Colors.red;
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: statusColor),
      ),
      child: Text(
        statusText,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: statusColor,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Text(
              'Ready to start the typing test?',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<TypingBloc>().add(StartTypingTest());
              },
              icon: const Icon(Icons.play_arrow),
              label: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text('Start Typing', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context, TypingState state) {
    return Column(
      children: [
        const ResultsDisplay(),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                context.read<TypingBloc>().add(ResetTypingTest());
              },
              icon: const Icon(Icons.replay),
              label: const Text('Try Again'),
            ),
            const SizedBox(width: 16),
            OutlinedButton.icon(
              onPressed: () {
                // Reset and navigate back
                context.read<TypingBloc>().add(ResetTypingTest());
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.home),
              label: const Text('Home'),
            ),
          ],
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
