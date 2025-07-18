import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/components/instructions_dialog.dart';
import 'package:the_modern_edition_2048/game.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    setup();
  }

  Future<void> setup() async {
     prefs = await SharedPreferences.getInstance();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe1ccb7),
      appBar: AppBar(
        backgroundColor: Color(0xffe1ccb7),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
          onPressed: () {
            showDialog(context: context, builder: (_) => InstructionsDialog());
          },
          child: Text("instructions", style: TextStyle(color: Colors.black),),
          )
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: setup(),
          builder: (context, asyncSnapshot) {
            if (asyncSnapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator(),);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 200,
                  child: TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0.8, end: 1.6),
                    duration: Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Text("2024 - The Modern Edition",
                        style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
                      );
                    },
                  ),
                ),
                (prefs.getInt('highScore') != null) ?
                Text("Welcome back!", style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600
                ),)
                : Text("Welcome!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600
                ),
                ),
                ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Color(0xffdfad7a)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white)
                ),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage()));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("New Game", style: TextStyle(fontSize: 32),),
                ),
                ),
                (prefs.getString("lastGame") != null) ?
                ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: WidgetStatePropertyAll(Colors.white),
                    backgroundColor: WidgetStatePropertyAll(Color(0xffd86a54))
                  ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GamePage(isLastGame: true,)));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Resume game", 
                  style: TextStyle(fontSize: 32),
                  ),
                )
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