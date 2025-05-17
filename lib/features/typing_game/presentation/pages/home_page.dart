import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:typing/features/typing_game/presentation/bloc/theme/theme_bloc.dart';
import 'package:typing/features/typing_game/presentation/pages/typing_page.dart';
import 'package:typing/features/typing_game/presentation/widgets/game_settings_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typing Game'),
        actions: [
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return IconButton(
                icon: Icon(state.themeMode == ThemeMode.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () {
                  context.read<ThemeBloc>().add(
                        ThemeChanged(
                          state.themeMode == ThemeMode.light
                              ? ThemeMode.dark
                              : ThemeMode.light,
                        ),
                      );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Don't expand to full height
            children: [
              Text(
                'Welcome to Typing Game!',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Test your typing speed and accuracy with our fun typing challenges.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const GameSettingsPanel(),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TypingPage(),
                    ),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    'Start Typing Test',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20), // Add some bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
