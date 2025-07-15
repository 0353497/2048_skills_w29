import 'dart:math';

import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/components/score_container.dart';
import 'package:the_modern_edition_2048/homepage.dart';

enum SwipeDirection {
  up,
  down,
  left,
  right,
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {

  List<List<int>> game = [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ];
  final List<List<List<int>>> gameStates = [];
  bool isGameOver = false;
  int currentScore = 0;
  int highScore = 0;

  final Duration _debounceTime = Duration(milliseconds: 400);
  bool _isProcessingSwipe = false;

  @override
  void initState() {
    super.initState();
    addBlock();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          spacing: 20,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Score: $currentScore", style: TextStyle(fontSize: 16)),
            Text("Best: $highScore", style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => undo(),
              child: Text("undo"),
              ),
          ),
           SizedBox(
            width: 100,
            child: ElevatedButton(
              onPressed: () => pause(),
              child: Text("pauze"),
              ),
          )
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          if (details.delta.dy < -5) {
            _handleSwipe(SwipeDirection.up);
          } else if (details.delta.dy > 5) {
            _handleSwipe(SwipeDirection.down);
          }
          if (details.delta.dx < -5) {
            _handleSwipe(SwipeDirection.left);
          } else if (details.delta.dx > 5) {
            _handleSwipe(SwipeDirection.right);
          }
        },
        onDoubleTap: () {
          final int rndValue = Random().nextInt(4);
          if (rndValue == 0) _handleSwipe(SwipeDirection.down);
          if (rndValue == 1) _handleSwipe(SwipeDirection.up);
          if (rndValue == 2) _handleSwipe(SwipeDirection.right);
          if (rndValue == 3) _handleSwipe(SwipeDirection.left);
        },
        child: SizedBox.expand(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Stack(
                  children: [
                    GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      crossAxisCount: 4,
                      children: [
                        for (final rows in game)
                        ...rows.map(
                          (number) {
                            return ScoreContainer(score: number);
                          }
                        )
                      ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  void _handleSwipe(SwipeDirection direction) {
    if (_isProcessingSwipe) return;
    
    setState(() {
      _isProcessingSwipe = true;
    });
    
    swipe(direction);
    
    Future.delayed(_debounceTime, () {
      setState(() {
        _isProcessingSwipe = false;
      });
    });
  }
  
  void undo() {
    if (gameStates.isNotEmpty) {
      setState(() {
        currentScore = (currentScore / 2).toInt();
        game = gameStates.removeLast();
      });
    }
  }

  void swipe(SwipeDirection direction) {
    debugPrint("called swipe!");
    calculateNewPositions(direction);
    addBlock();
  }
  
  void addBlock() {
    List<(int, int)> options = getOptionsWhereNull();

    if (options.isEmpty) {
      setState(() {
        isGameOver = true;
      });
      return;
    }

    final randomNumber = Random().nextInt(10);
    int numberToAdd = 2;

    //10% change
    if (randomNumber == 0) {
      numberToAdd = 4;
    }

    final randomIndex = Random().nextInt(options.length);
    final (int, int) placeToAddNumber = options[randomIndex];

    setState(() {
      List<List<int>> gameCopy = List.generate(
        game.length, 
        (i) => List.from(game[i])
      );
      gameStates.add(gameCopy);
      
      game[placeToAddNumber.$1][placeToAddNumber.$2] = numberToAdd;
    });
  }

  List<(int, int)> getOptionsWhereNull() {
      final List<(int, int)> options = [];
    for (var i = 0; i < game.length; i++) {
      final row = game[i];
      for (var j = 0; j < row.length; j++) {
        final int value = row[j];
        if (value == 0) {
          options.add((i, j));
        }
      }
    }
    return options;
  }

  List<(int, int)> getOptionsWhereNotNull() {
      final List<(int, int)> options = [];
    for (var i = 0; i < game.length; i++) {
      final row = game[i];
      for (var j = 0; j < row.length; j++) {
        final int value = row[j];
        if (value != 0) {
          options.add((i, j));
        }
      }
    }
    return options;
  }
  
  void calculateNewPositions(SwipeDirection direction) {
    List<List<bool>> merged = List.generate(
      game.length,
      (i) => List.generate(game[i].length, (j) => false)
    );
    
    List<(int, int)> options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    }

    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int) newPos = _moveBlockAsFarAsPossible(option, direction);
      
      if (newPos != option) {
        setState(() {
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
        });
      }
    }
    
    options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    }
    
    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int)? mergeTarget = _findMergeTarget(option, direction, merged);
      if (mergeTarget != null) {
        setState(() {
          int mergedValue = value * 2;
          game[mergeTarget.$1][mergeTarget.$2] = mergedValue;
          game[option.$1][option.$2] = 0;
          merged[mergeTarget.$1][mergeTarget.$2] = true;
          
          currentScore += mergedValue;
          
          if (currentScore > highScore) {
            highScore = currentScore;
          }
        });
      }
    }
    
    options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    }
    
    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int) newPos = _moveBlockAsFarAsPossible(option, direction);
      
      if (newPos != option) {
        setState(() {
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
        });
      }
    }
  }
  
  (int, int) _moveBlockAsFarAsPossible((int, int) position, SwipeDirection direction) {
    int row = position.$1;
    int col = position.$2;
    
    if (direction == SwipeDirection.left) {
      while (col > 0 && game[row][col - 1] == 0) {
        col--;
      }
    } else if (direction == SwipeDirection.right) {
      while (col < game[0].length - 1 && game[row][col + 1] == 0) {
        col++;
      }
    } else if (direction == SwipeDirection.up) {
      while (row > 0 && game[row - 1][col] == 0) {
        row--;
      }
    } else if (direction == SwipeDirection.down) {
      while (row < game.length - 1 && game[row + 1][col] == 0) {
        row++;
      }
    }
    
    return (row, col);
  }
  
  (int, int)? _findMergeTarget((int, int) position, SwipeDirection direction, List<List<bool>> merged) {
    int row = position.$1;
    int col = position.$2;
    int value = game[row][col];
    
    if (direction == SwipeDirection.left) {
      for (int c = col - 1; c >= 0; c--) {
        if (game[row][c] == value && !merged[row][c]) {
          return (row, c);
        } else if (game[row][c] != 0) {
          break;
        }
      }
    } else if (direction == SwipeDirection.right) {
      for (int c = col + 1; c < game[0].length; c++) {
        if (game[row][c] == value && !merged[row][c]) {
          return (row, c);
        } else if (game[row][c] != 0) {
          break;
        }
      }
    } else if (direction == SwipeDirection.up) {
      for (int r = row - 1; r >= 0; r--) {
        if (game[r][col] == value && !merged[r][col]) {
          return (r, col);
        } else if (game[r][col] != 0) {
          break;
        }
      }
    } else if (direction == SwipeDirection.down) {
      for (int r = row + 1; r < game.length; r++) {
        if (game[r][col] == value && !merged[r][col]) {
          return (r, col);
        } else if (game[r][col] != 0) {
          break;
        }
      }
    }
    
    return null;
  }
  
  void pause() {
    Navigator.push(context, MaterialPageRoute(builder: (_) => Homepage()));
  }
}