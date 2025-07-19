import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/components/game_background.dart';
import 'package:the_modern_edition_2048/components/game_over_dialog.dart';
import 'package:the_modern_edition_2048/components/instructions_dialog.dart';
import 'package:the_modern_edition_2048/components/score_container.dart';
import 'package:the_modern_edition_2048/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_modern_edition_2048/models/swipe_direction_model.dart';
import 'package:the_modern_edition_2048/models/tile_model.dart';


class GamePage extends StatefulWidget {
  const GamePage({super.key, this.isLastGame = false});
  final bool isLastGame;
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
  List<List<List<int>>> gameStates = [];
  List<TileModel> tiles = [];
  int nextTileId = 0;
  bool isGameOver = false;
  int currentScore = 0;
  int highScore = 0;

  final int gridSize = 4;
  final double cellSize = 70.0;
  final double cellSpacing = 10.0;
  (int, int) lastAddedPosition = (0, 0);
  final Duration _debounceTime = Duration(milliseconds: 400);
  bool _isProcessingSwipe = false;
  late SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
   if (!widget.isLastGame) addBlock();
    setup();
    if (widget.isLastGame) setupLastGame();
  }
  
  void _updateTilesList() {
    Map<String, TileModel> existingTilesByPosition = {};
    for (var tile in tiles) {
      existingTilesByPosition["${tile.row}-${tile.col}"] = tile;
    }
    
    List<TileModel> newTiles = [];
    
    for (int row = 0; row < game.length; row++) {
      for (int col = 0; col < game[row].length; col++) {
        int value = game[row][col];
        if (value > 0) {
          String posKey = "$row-$col";
          if (existingTilesByPosition.containsKey(posKey)) {
            TileModel existing = existingTilesByPosition[posKey]!;
            if (existing.value != value) {
              newTiles.add(existing.copyWith(value: value, isNew: false));
            } else {
              newTiles.add(existing.copyWith(isNew: false));
            }
          } else {
            newTiles.add(TileModel(
              id: "$row-$col-$nextTileId",
              value: value,
              row: row,
              col: col,
              isNew: true,
            ));
            nextTileId++;
          }
        }
      }
    }
    
    setState(() {
      tiles = newTiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    double gridWidth = gridSize * cellSize + (gridSize + 1) * cellSpacing;
    
    return Scaffold(
      backgroundColor: Color(0xffe1ccb7),
      appBar: AppBar(
        backgroundColor: Color(0xffe1ccb7),
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Score: $currentScore", style: TextStyle(fontSize: 16)),
            SizedBox(width: 20),
            Text("Best: $highScore", style: TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          SizedBox(
            width: 100,
            child: ElevatedButton.icon(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xffd86a54)),
                foregroundColor: WidgetStatePropertyAll(Colors.white)
              ),
              onPressed: () => undo(),
              icon: Icon(Icons.undo),
              label: Text("undo", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),),
              ),
          ),
          SizedBox(
            width: 5,
          ),
           SizedBox(
            width: 100,
            child: ElevatedButton(
                style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(Color(0xffd86a54)),
                foregroundColor: WidgetStatePropertyAll(Colors.white)
              ),
              onPressed: () => pause(),
              child: Text("pauze", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12),),
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
          else if (details.delta.dx < -5) {
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
        child: SafeArea(
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: SizedBox(
                width: gridWidth,
                height: gridWidth,
                child: Stack(
                  children: [
                    GameBackground(
                      size: gridSize,
                      cellSize: cellSize,
                      cellSpacing: cellSpacing,
                    ),
                    
                    ...getAllCellWidgets(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> getAllCellWidgets() {
    List<Widget> cells = [];
    for (var tile in tiles) {
      cells.add(
        ScoreContainer(
          key: ValueKey(tile.id),
          score: tile.value,
          position: _calculatePosition(tile.row, tile.col),
          cellSize: cellSize,
          isNew: tile.isNew,
        ),
      );
    }
    
    return cells;
  }

  Offset _calculatePosition(int row, int col) {
    return Offset(
      col * cellSize + (col + 1) * cellSpacing,
      row * cellSize + (row + 1) * cellSpacing,
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
        _updateTilesList();
      });
    }
  }

  void swipe(SwipeDirection direction) {
    debugPrint("called swipe!");
    setState(() {
      List<List<int>> gameCopy = List.generate(
        game.length, 
        (i) => List.from(game[i])
      );
      gameStates.add(gameCopy);
    });
    calculateNewPositions(direction);
    addBlock();
  }
  
  void addBlock() {
    List<(int, int)> options = getOptionsWhereNull();

    if (options.isEmpty) {
      setState(() {
        isGameOver = true;
        showDialog(context: context,
        builder: (_)
        => GameOverDialog(currentScore: currentScore, highScore: highScore, undo: undo),
        barrierDismissible: false,
        );
      });
      return;
    }

    final randomNumber = Random().nextInt(10);
    int numberToAdd = 2;

    // 10% chance of adding a 4 instead of a 2
    if (randomNumber == 0) {
      numberToAdd = 4;
    }

    final randomIndex = Random().nextInt(options.length);
    final (int, int) placeToAddNumber = options[randomIndex];
    lastAddedPosition = placeToAddNumber;
    setState(() {
      game[placeToAddNumber.$1][placeToAddNumber.$2] = numberToAdd;
      
      tiles.add(TileModel(
        id: "${placeToAddNumber.$1}-${placeToAddNumber.$2}-$nextTileId",
        value: numberToAdd,
        row: placeToAddNumber.$1,
        col: placeToAddNumber.$2,
        isNew: true,
      ));
      nextTileId++;
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
    Map<String, TileModel> tilesByPosition = {};
    for (var tile in tiles) {
      tilesByPosition["${tile.row}-${tile.col}"] = tile;
    }
    
    List<List<bool>> merged = List.generate(
      game.length,
      (i) => List.generate(game[i].length, (j) => false)
    );
    
    List<(int, int)> options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    }

    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int) newPos = _moveBlockAsFarAsPossible(option, direction);
      
      if (newPos != option) {
        String oldPosKey = "${option.$1}-${option.$2}";
        if (tilesByPosition.containsKey(oldPosKey)) {
          TileModel movingTile = tilesByPosition[oldPosKey]!;
          tilesByPosition.remove(oldPosKey);
          
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
          
          tilesByPosition["${newPos.$1}-${newPos.$2}"] = movingTile.copyWith(
            row: newPos.$1,
            col: newPos.$2,
          );
        } else {
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
        }
      }
    }
    
    options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    }
    
    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int)? mergeTarget = _findMergeTarget(option, direction, merged);
      if (mergeTarget != null) {
        int mergedValue = value * 2;
        
        String srcPosKey = "${option.$1}-${option.$2}";
        String targetPosKey = "${mergeTarget.$1}-${mergeTarget.$2}";
        
        TileModel? sourceTile = tilesByPosition[srcPosKey];
        TileModel? targetTile = tilesByPosition[targetPosKey];
        
        if (sourceTile != null && targetTile != null) {
          tilesByPosition[targetPosKey] = targetTile.copyWith(
            value: mergedValue,
            isNew: false,
          );
          
          tilesByPosition.remove(srcPosKey);
        }
        
        game[mergeTarget.$1][mergeTarget.$2] = mergedValue;
        game[option.$1][option.$2] = 0;
        merged[mergeTarget.$1][mergeTarget.$2] = true;
        
        currentScore += mergedValue;
        
        if (currentScore > highScore) {
          highScore = currentScore;
          prefs.setInt("highScore", currentScore);
        }
      }
    }
    
    options = getOptionsWhereNotNull();
    if (direction == SwipeDirection.right) {
      options.sort((a, b) => b.$2.compareTo(a.$2));
    } else if (direction == SwipeDirection.down) {
      options.sort((a, b) => b.$1.compareTo(a.$1));
    } else if (direction == SwipeDirection.left) {
      options.sort((a, b) => a.$2.compareTo(b.$2));
    } else if (direction == SwipeDirection.up) {
      options.sort((a, b) => a.$1.compareTo(b.$1));
    }
    
    for (var option in options) {
      final int value = game[option.$1][option.$2];
      if (value == 0) continue;
      
      (int, int) newPos = _moveBlockAsFarAsPossible(option, direction);
      
      if (newPos != option) {
        String oldPosKey = "${option.$1}-${option.$2}";
        if (tilesByPosition.containsKey(oldPosKey)) {

          TileModel movingTile = tilesByPosition[oldPosKey]!;
          tilesByPosition.remove(oldPosKey);
          
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
          
          tilesByPosition["${newPos.$1}-${newPos.$2}"] = movingTile.copyWith(
            row: newPos.$1,
            col: newPos.$2,
          );
        } else {
          game[newPos.$1][newPos.$2] = value;
          game[option.$1][option.$2] = 0;
        }
      }
    }
    
    List<TileModel> updatedTiles = tilesByPosition.values.toList();
    
    setState(() {
      tiles = updatedTiles;
    });
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
      if (col > 0 && game[row][col - 1] == value && !merged[row][col - 1]) {
        return (row, col - 1);
      }
    } else if (direction == SwipeDirection.right) {
      if (col < game[0].length - 1 && game[row][col + 1] == value && !merged[row][col + 1]) {
        return (row, col + 1);
      }
    } else if (direction == SwipeDirection.up) {
      if (row > 0 && game[row - 1][col] == value && !merged[row - 1][col]) {
        return (row - 1, col);
      }
    } else if (direction == SwipeDirection.down) {
      if (row < game.length - 1 && game[row + 1][col] == value && !merged[row + 1][col]) {
        return (row + 1, col);
      }
    }
    
    return null;
  }
  
  void pause() async {
    gameStates.add(game);
    await prefs.setString("lastGame", jsonEncode(gameStates));
    if (mounted) Navigator.push(context, MaterialPageRoute(builder: (_) => Homepage()));
  }
  
  Future<void> setup() async{
    prefs = await SharedPreferences.getInstance();
    int? score = prefs.getInt("highScore");
    score == null ? highScore = 0 : highScore = score;
    if (score == null && mounted) showDialog(context: context, builder: (_) => InstructionsDialog(), barrierDismissible: false);
  }
  
  void setupLastGame() async {
    prefs = await SharedPreferences.getInstance();
    
    final String? lastGameJson = prefs.getString("lastGame");
    if (lastGameJson != null) {
      try {
        final dynamic decodedData = jsonDecode(lastGameJson);
        if (decodedData is List) {
          List<List<List<int>>> savedGameStates = [];
          
          for (var gameState in decodedData) {
            if (gameState is List) {
              List<List<int>> boardState = [];
              
              for (var row in gameState) {
                if (row is List) {
                  List<int> boardRow = [];
                  
                  for (var cell in row) {
                    boardRow.add(cell is int ? cell : 0);
                  }
                  
                  boardState.add(boardRow);
                }
              }
              
              if (boardState.isNotEmpty) {
                savedGameStates.add(boardState);
              }
            }
          }
          
          if (savedGameStates.isNotEmpty) {
            setState(() {
              gameStates = savedGameStates;
              game = savedGameStates.last;
            });
            _updateTilesList();
            prefs.remove("lastGame");
          }
        }
      } catch (e) {
        debugPrint("Error loading saved game: $e");
      }
    }
  }
}
