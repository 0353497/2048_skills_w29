import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/homepage.dart';

class GameOverDialog extends StatefulWidget {
  const GameOverDialog({super.key, required this.currentScore, required this.highScore, required this.undo, this.oldHighscore});
  final int currentScore;
  final int highScore;
  final VoidCallback undo;
  final int? oldHighscore;

  @override
  State<GameOverDialog> createState() => _GameOverDialogState();
}

class _GameOverDialogState extends State<GameOverDialog> {

  double scale = 1;
  late int scoreValue = widget.highScore;

  @override
  void initState() {
    super.initState();
    if (widget.oldHighscore != null) animateHighscore();
  }

  Future<void> animateHighscore() async{
    scoreValue = widget.oldHighscore!;
    setState(() {
      scale = 1;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      scale = 0.2;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      scale = 1.5;
      scoreValue = widget.highScore;
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      scale = 1;
    });
  }


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
            Text("Current Score: ${widget.currentScore}",
            style: TextStyle(
              fontSize: 32,
              color: Colors.white
            ),
            textAlign: TextAlign.center,
            ),
            AnimatedScale(
              duration: Duration(seconds: 1),
              scale: scale,
              child: Text("HighScore: $scoreValue",
              style: TextStyle(
                fontSize: 32,
                color: Colors.white
              ),
              textAlign: TextAlign.center,
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
              onPressed: () {
                widget.undo();
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