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
            // Original text to type with highlighted progress
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              width: double.infinity,
              child: RichText(
                text: TextSpan(
                  children: _buildTextWithHighlighting(
                    state.typingText.originalText, 
                    state.typingText.typedText,
                  ),
                  style: const TextStyle(fontSize: 18, height: 1.5, color: Colors.black),
                ),
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
                    
                    // Accuracy indicator
                    Text('Accuracy: ${_calculateAccuracy(state.typingText.originalText, state.typingText.typedText).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
  
  // Build text spans with appropriate coloring
  List<TextSpan> _buildTextWithHighlighting(String originalText, String typedText) {
    List<TextSpan> spans = [];
    
    for (int i = 0; i < originalText.length; i++) {
      if (i < typedText.length) {
        // Character has been typed
        if (originalText[i] == typedText[i]) {
          // Correct character
          spans.add(TextSpan(
            text: originalText[i],
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ));
        } else {
          // Incorrect character
          spans.add(TextSpan(
            text: originalText[i],
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ));
        }
      } else {
        // Not yet typed
        spans.add(TextSpan(
          text: originalText[i],
          style: TextStyle(color: Colors.grey[800]),
        ));
      }
    }
    
    // Add extra typed characters as errors (if any)
    if (typedText.length > originalText.length) {
      spans.add(TextSpan(
        text: typedText.substring(originalText.length),
        style: const TextStyle(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        ),
      ));
    }
    
    return spans;
  }
  
  // Calculate typing accuracy
  double _calculateAccuracy(String originalText, String typedText) {
    if (typedText.isEmpty) return 100.0;
    
    int correctChars = 0;
    int totalChars = typedText.length;
    
    for (int i = 0; i < typedText.length && i < originalText.length; i++) {
      if (originalText[i] == typedText[i]) {
        correctChars++;
      }
    }
    
    return (correctChars / totalChars) * 100;
  }
}
