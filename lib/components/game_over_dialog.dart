import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/homepage.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key, required this.currentScore, required this.highScore, required this.undo});
  final int currentScore;
  final int highScore;
  final VoidCallback undo;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xffd86a54),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Game Over!",
              style: TextStyle(
                fontSize: 42,
                color: Colors.white,
                fontWeight: FontWeight.bold
              ),
            ),
            Text("Current Score: $currentScore",
            style: TextStyle(
              fontSize: 32,
              color: Colors.white
            ),
            textAlign: TextAlign.center,
            ),
            Text("HighScore: $highScore",
            style: TextStyle(
              fontSize: 32,
              color: Colors.white
            ),
            textAlign: TextAlign.center,
            ),
            SizedBox(
              width: 250,
              child: TextButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10))
                ),
              onPressed: () {
                undo();
                Navigator.pop(context);
              } ,
              child: Text("undo", style: TextStyle(fontSize: 32),),
              ),
            ),
            SizedBox(
              width: 250,
              child: TextButton(
                 style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.white),
                  foregroundColor: WidgetStatePropertyAll(Colors.black),
                  padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 20, vertical: 10))
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => Homepage()));
                },
                 child: Text("End Game", style: TextStyle(fontSize: 32),)
                 ),
            ),
          ],
        ),
      ),
    );
  }
}