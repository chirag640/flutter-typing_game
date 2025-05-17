import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/domain/entities/typing_stats.dart';
import 'package:typing/features/typing_game/presentation/bloc/typing/typing_bloc.dart';
import 'package:typing/features/typing_game/presentation/widgets/character_highlight.dart';
import 'package:typing/features/typing_game/presentation/widgets/stats_display.dart';

class TypingPage extends StatefulWidget {
  const TypingPage({super.key});

  @override
  State<TypingPage> createState() => _TypingPageState();
}

class _TypingPageState extends State<TypingPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Request focus when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Test'),
      ),
      body: BlocConsumer<TypingBloc, TypingState>(
        listener: (context, state) {
          if (state.status == TypingStatus.completed) {
            _controller.clear();
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.status == TypingStatus.initial) ...[
                  _buildInitialState(context),
                ] else if (state.status == TypingStatus.inProgress) ...[
                  _buildInProgressState(context, state),
                ] else if (state.status == TypingStatus.completed) ...[
                  _buildCompletedState(context, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInitialState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Ready to test your typing skills?',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<TypingBloc>().add(StartTypingTest());
              _focusNode.requestFocus();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Start Test', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInProgressState(BuildContext context, TypingState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: CharacterHighlight(
              originalText: state.typingText.originalText,
              typedText: state.typingText.typedText,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          onChanged: (value) {
            context.read<TypingBloc>().add(UpdateTypedText(value));
          },
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Type here...',
            labelText: 'Typing Area',
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 20),
        Center(
          child: ElevatedButton(
            onPressed: () {
              context.read<TypingBloc>().add(FinishTypingTest());
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Finish Test', style: TextStyle(fontSize: 16)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedState(BuildContext context, TypingState state) {
    final stats = state.stats!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Test Completed!',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          StatsDisplay(stats: stats),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              context.read<TypingBloc>().add(ResetTypingTest());
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text('Try Again', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
