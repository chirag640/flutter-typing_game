import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart';
import 'package:typing/features/typing_game/domain/entities/typing_text.dart';

class ResultsDisplay extends StatelessWidget {
  const ResultsDisplay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypingBloc, TypingState>(      builder: (context, state) {
        if (state.stats == null) {
          return const SizedBox.shrink();
        }

        // Different styling based on completion or failure
        Color headerColor = state.status == TypingStatus.completed ? 
            Theme.of(context).colorScheme.primary : 
            Theme.of(context).colorScheme.error;

        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      state.status == TypingStatus.completed ? 
                        Icons.celebration : 
                        Icons.error_outline,
                      color: headerColor,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.status == TypingStatus.completed ? 'Test Results' : 'Game Over',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: headerColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // If game mode is error survival and failed, show special message
                if (state.status == TypingStatus.failed && 
                    state.gameMode == GameMode.errorSurvival)
                  _buildErrorFailureMessage(context, state),
                  
                // Display different results based on game mode
                _buildModeSpecificResults(state),
                
                const Divider(height: 32),
                
                // Common stats for all modes
                _buildStatRow(
                  icon: Icons.speed,
                  label: 'Speed',
                  value: '${state.stats!.wordsPerMinute} WPM',
                ),
                _buildStatRow(
                  icon: Icons.check_circle,
                  label: 'Accuracy',
                  value: '${state.stats!.accuracy}%',
                ),
                _buildStatRow(
                  icon: Icons.timer,
                  label: 'Time',
                  value: _formatDuration(state.stats!.duration),
                ),
                _buildStatRow(
                  icon: Icons.keyboard,
                  label: 'Characters',
                  value: '${state.stats!.correctChars} correct, ${state.stats!.incorrectChars} incorrect',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorFailureMessage(BuildContext context, TypingState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.errorContainer,
        ),
      ),
      child: Column(
        children: [
          Text(
            'You reached the error limit of ${state.errorLimit}!',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try again and be more careful with your typing.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModeSpecificResults(TypingState state) {
    switch (state.gameMode) {
      case GameMode.timed:
        return _buildStatRow(
          icon: Icons.hourglass_full,
          label: 'Time Mode',
          value: '${state.timedDurationMinutes} minute${state.timedDurationMinutes > 1 ? 's' : ''}',
        );
      case GameMode.wordCount:
        final completedWords = _countCompletedWords(state.typingText);
        return _buildStatRow(
          icon: Icons.format_list_numbered,
          label: 'Word Count Mode',
          value: '$completedWords/${state.wordCountTarget} words completed',
        );
      case GameMode.errorSurvival:
        return _buildStatRow(
          icon: Icons.error_outline,
          label: 'Error Survival Mode',
          value: '${state.currentErrorCount}/${state.errorLimit} errors',
          isNegative: state.currentErrorCount >= state.errorLimit,
        );
      case GameMode.standard:
      default:
        return _buildStatRow(
          icon: Icons.keyboard,
          label: 'Standard Mode',
          value: 'Completed!',
        );
    }
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: isNegative ? Colors.red : Colors.blue,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isNegative ? Colors.red : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
