import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';
import 'package:typing/features/typing_game/domain/enums/game_mode.dart';
class TypingArea extends StatefulWidget {
  const TypingArea({Key? key}) : super(key: key);

  @override
  State<TypingArea> createState() => _TypingAreaState();
}

class _TypingAreaState extends State<TypingArea> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  @override
  void initState() {
    super.initState();
    // Request focus to start typing immediately
    Future.microtask(() => _focusNode.requestFocus());
    
    // Listen to changes and update bloc
    _controller.addListener(() {
      context.read<TypingBloc>().add(UpdateTypedText(_controller.text));
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TypingBloc, TypingState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Original text to type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: Text(
                state.typingText.originalText,
                style: const TextStyle(fontSize: 18, height: 1.5),
              ),
            ),
            const SizedBox(height: 24),
            
            // Text field for typing
            TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Start typing here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                fillColor: Colors.white,
                filled: true,
              ),
              style: const TextStyle(fontSize: 18),
            ),
            
            // Show some stats while typing (WPM, accuracy)
            if (state.gameMode == GameMode.standard || state.gameMode == GameMode.timed)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Live progress indicator
                    Text('Progress: ${(state.typingText.typedText.length / 
                          (state.typingText.originalText.length > 0 ? state.typingText.originalText.length : 1) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}
