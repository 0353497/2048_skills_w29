import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/game.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("2024 - The Modern Edition"),
            Text("Welcome!"),
            ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage()));
            },
            child: Text("New Game"),
            ),
            Row(),
          ],
        )
        ),
    );
  }
}