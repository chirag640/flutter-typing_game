import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/domain/enums/difficulty.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';

class DifficultySelector extends StatelessWidget {
  const DifficultySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypingBloc, TypingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                'Select Difficulty:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: Difficulty.values.map((difficulty) => 
                _buildDifficultyButton(
                  context, 
                  difficulty, 
                  isSelected: state.difficulty == difficulty,
                ),
              ).toList(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDifficultyButton(BuildContext context, Difficulty difficulty, {required bool isSelected}) {
    return ElevatedButton(
      onPressed: () {
        context.read<TypingBloc>().add(ChangeDifficulty(difficulty));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? difficulty.getColor() : Theme.of(context).disabledColor.withOpacity(0.1),
        foregroundColor: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? difficulty.getColor() : Colors.transparent,
            width: 2,
          ),
        ),
      ),
      child: Text(difficulty.name),
    );
  }
}
