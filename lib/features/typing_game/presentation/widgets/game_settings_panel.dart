import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/domain/enums/difficulty.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';

class GameSettingsPanel extends StatelessWidget {
  const GameSettingsPanel({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypingBloc, TypingState>(
      builder: (context, state) {
        if (state.status != TypingStatus.initial) {
          return const SizedBox.shrink(); // Don't show settings during the test
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Game Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Difficulty selection
                const Text('Difficulty:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildDifficultySelector(context, state),
                const SizedBox(height: 16),

                // Game mode selection
                const Text('Game Mode:', style: TextStyle(fontWeight: FontWeight.bold)),
                _buildGameModeSelector(context, state),
                const SizedBox(height: 16),

                // Mode-specific settings
                _buildModeSpecificSettings(context, state),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDifficultySelector(BuildContext context, TypingState state) {
    return SegmentedButton<Difficulty>(
      segments: const [
        ButtonSegment(
          value: Difficulty.easy,
          label: Text('Easy'),
        ),
        ButtonSegment(
          value: Difficulty.medium,
          label: Text('Medium'),
        ),
        ButtonSegment(
          value: Difficulty.hard,
          label: Text('Hard'),
        ),
      ],
      selected: {state.difficulty},
      onSelectionChanged: (Set<Difficulty> selection) {
        context.read<TypingBloc>().add(ChangeDifficulty(selection.first));
      },
    );
  }

  Widget _buildGameModeSelector(BuildContext context, TypingState state) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          children: [
            _buildModeChip(
              context,
              GameMode.standard,
              'Standard',
              Icons.keyboard,
              state.gameMode == GameMode.standard,
            ),
            _buildModeChip(
              context,
              GameMode.timed,
              'Timed',
              Icons.timer,
              state.gameMode == GameMode.timed,
            ),
            _buildModeChip(
              context,
              GameMode.wordCount,
              'Word Count',
              Icons.format_list_numbered,
              state.gameMode == GameMode.wordCount,
            ),
            _buildModeChip(
              context,
              GameMode.errorSurvival,
              'Error Survival',
              Icons.error_outline,
              state.gameMode == GameMode.errorSurvival,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeChip(BuildContext context, GameMode mode, String label, 
                      IconData icon, bool isSelected) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          context.read<TypingBloc>().add(ChangeGameMode(mode));
        }
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildModeSpecificSettings(BuildContext context, TypingState state) {
    switch (state.gameMode) {
      case GameMode.timed:
        return _buildTimedSettings(context, state);
      case GameMode.wordCount:
        return _buildWordCountSettings(context, state);
      case GameMode.errorSurvival:
        return _buildErrorSurvivalSettings(context, state);
      case GameMode.standard:
      default:
        return const Text(
          'Standard Mode: Type the complete text as accurately as possible.',
          style: TextStyle(fontStyle: FontStyle.italic),
        );
    }
  }

  Widget _buildTimedSettings(BuildContext context, TypingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type as much text as possible within the time limit.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        const Text('Time Duration:'),
        Wrap(
          spacing: 8,
          children: [1, 3, 5].map((minutes) {
            return ChoiceChip(
              label: Text('$minutes min'),
              selected: state.timedDurationMinutes == minutes,
              onSelected: (selected) {
                if (selected) {
                  context.read<TypingBloc>().add(SetTimedDuration(minutes));
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWordCountSettings(BuildContext context, TypingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Race to complete the target number of words.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        const Text('Target Word Count:'),
        Slider(
          value: state.wordCountTarget.toDouble(),
          min: 10,
          max: 100,
          divisions: 9,
          label: '${state.wordCountTarget} words',
          onChanged: (value) {
            context.read<TypingBloc>().add(SetWordCountTarget(value.round()));
          },
        ),
        Text('Current target: ${state.wordCountTarget} words'),
      ],
    );
  }

  Widget _buildErrorSurvivalSettings(BuildContext context, TypingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type carefully! The game ends after reaching the error limit.',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        const Text('Error Limit:'),
        Slider(
          value: state.errorLimit.toDouble(),
          min: 1,
          max: 15,
          divisions: 14,
          label: '${state.errorLimit} errors',
          onChanged: (value) {
            context.read<TypingBloc>().add(SetErrorLimit(value.round()));
          },
        ),
        Text('Current limit: ${state.errorLimit} errors'),
      ],
    );
  }
}
