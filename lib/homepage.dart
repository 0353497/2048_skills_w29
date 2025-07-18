import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
     prefs = await SharedPreferences.getInstance();
  }
  late SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: setup(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                AnimatedScale(
                  duration: Duration(seconds: 1),
                  scale: 1.2,
                  child: Text("2024 - The Modern Edition"),
                  ),
                (prefs.getInt('highScore') != null) ? Text("Welcome back!") : Text("Welcome!"),
                ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage()));
                },
                child: Text("New Game"),
                ),
                (prefs.getString("lastGame") != null) ?
                ElevatedButton(
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(isLastGame: true,)));
                },
                child: Text("Resume game")
                ) : SizedBox(),
                Row(),
              ],
            );
          }
        )
        ),
    );
  }
}