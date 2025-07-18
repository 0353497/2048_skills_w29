import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

import 'package:the_modern_edition_2048/components/game_background.dart';
import 'package:the_modern_edition_2048/components/score_container.dart';
import 'package:the_modern_edition_2048/utils/colorhandler.dart';

class MergeComponent extends StatefulWidget {
  const MergeComponent({
    super.key,
    required this.score,
    required this.position,
    required this.cellSize,
    required this.onMergeComplete,
  });
  
  final int score;
  final Offset position;
  final double cellSize;
  final VoidCallback onMergeComplete;
  
  @override
  State<MergeComponent> createState() => _MergeComponentState();
}

class _MergeComponentState extends State<MergeComponent> with SingleTickerProviderStateMixin {
  late AnimationController _mergeController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }
  
  void _initializeAnimation() {
    _mergeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 60,
      ),
    ]).animate(CurvedAnimation(
      parent: _mergeController,
      curve: Curves.easeInOut,
    ));
    
    _mergeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onMergeComplete();
      }
    });
    
    _mergeController.forward();
  }
  
  @override
  void dispose() {
    _mergeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      width: widget.cellSize,
      height: widget.cellSize,
      child: SizedBox(
        width: 55,
        height: 55,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: ColorHandler.getColorFromValue(widget.score),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                widget.score.toString(),
                style: TextStyle(
                  fontSize: widget.score > 100 ? 22 : 28,
                  fontWeight: FontWeight.bold,
                  color: ColorHandler.getTextColorFromValue(widget.score),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InstructionsDialog extends StatefulWidget {
  const InstructionsDialog({super.key});

  @override
  State<InstructionsDialog> createState() => _InstructionsDialogState();
}

class _InstructionsDialogState extends State<InstructionsDialog> {
  final List<IconData> icons = [
    Icons.swipe_down,
    Icons.swipe_left,
    Icons.swipe_up,
    Icons.swipe_right
  ];

  final List<Offset> iconDirections = [
    Offset(0, 48),
    Offset(-48, 0),
    Offset(0, -48),
    Offset(48, 0),
  ];

  final List<Offset> scoreDirections = [
    Offset(49, 48),
    Offset(-49, 48),
    Offset(-49, -50), 
    Offset(49, -50),
  ];

  late StreamController<int> _streamController;
  late Timer _timer;
  int currentIndex = 0;
  int currentPage = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    
    _streamController = StreamController<int>.broadcast();
    
    _streamController.add(currentIndex);
    
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      currentIndex = (currentIndex + 1) % icons.length;
      if (_streamController.isClosed == false) {
        _streamController.add(currentIndex);
      }
    });
  }
  
  @override
  void dispose() {
    _timer.cancel();
    _streamController.close();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Card(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              children: [
                Intro1(
                  streamController: _streamController,
                  scoreDirections: scoreDirections,
                  iconDirections: iconDirections,
                  icons: icons
                ),
                
                Intro2(),

                Intro3(),

                Intro4()
                
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 4; i++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: currentPage == i
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Intro1 extends StatelessWidget {
  const Intro1({
    super.key,
    required StreamController<int> streamController,
    required this.scoreDirections,
    required this.iconDirections,
    required this.icons,
  }) : _streamController = streamController;

  final StreamController<int> _streamController;
  final List<Offset> scoreDirections;
  final List<Offset> iconDirections;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: GameBackground(size: 4, cellSize: 55, cellSpacing: 15)
                    ),
                  StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, asyncSnapshot) {
                      final index = asyncSnapshot.data ?? 0;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
                              begin: Offset.zero,
                              end: scoreDirections[index],
                            ),
                            duration: const Duration(milliseconds: 480),
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: (offset * 2.15),
                                child: SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: ScoreContainer(
                                    score: 16,
                                    position: const Offset(55, 55),
                                    cellSize: 48,
                                    isNew: false,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          TweenAnimationBuilder<Offset>(
                            key: ValueKey("swipe_$index"),
                            tween: Tween<Offset>(
                              begin: Offset.zero,
                              end: iconDirections[index],
                            ),
                            duration: const Duration(milliseconds: 1000),
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: offset,
                                child: Icon(
                                  icons[index], 
                                  size: 64,
                                  color: Color(0xffd86a54),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 148),
                    child: Text(
                      "Swipe to move tiles",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}



class MergeIntro extends StatelessWidget {
  const MergeIntro({
    super.key,
    required StreamController<int> streamController,
    required this.scoreDirections,
    required this.iconDirections,
    required this.icons,
  }) : _streamController = streamController;

  final StreamController<int> _streamController;
  final List<Offset> scoreDirections;
  final List<Offset> iconDirections;
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: [
          Center(
            child: SizedBox(
              width: 400,
              height: 400,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 300,
                    height: 300,
                    child: GameBackground(size: 4, cellSize: 55, cellSpacing: 15)
                    ),
                  StreamBuilder(
                    stream: _streamController.stream,
                    builder: (context, asyncSnapshot) {
                      final index = asyncSnapshot.data ?? 0;
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
                              begin: Offset.zero,
                              end: scoreDirections[index],
                            ),
                            duration: const Duration(milliseconds: 480),
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: (offset * 2.15),
                                child: SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: ScoreContainer(
                                    score: 16,
                                    position: const Offset(55, 55),
                                    cellSize: 48,
                                    isNew: false,
                                  ),
                                ),
                              );
                            },
                          ),
                          TweenAnimationBuilder<Offset>(
                            tween: Tween<Offset>(
                              begin: Offset.zero,
                              end: scoreDirections[index],
                            ),
                            duration: const Duration(milliseconds: 480),
                            builder: (context, offset, child) {
                              return Transform.translate(
                                offset: (offset * 2.15),
                                child: SizedBox(
                                  width: 55,
                                  height: 55,
                                  child: ScoreContainer(
                                    score: 16,
                                    position: const Offset(55, 55),
                                    cellSize: 48,
                                    isNew: false,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    }
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 148),
                    child: Text(
                      "Tiles with the same number merge in to one",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class Intro2 extends StatefulWidget {
  const Intro2({Key? key}) : super(key: key);

  @override
  State<Intro2> createState() => _Intro2State();
}

class _Intro2State extends State<Intro2> with SingleTickerProviderStateMixin {
  bool _isAnimating = false;
  late Timer _animationTimer;
  
  @override
  void initState() {
    super.initState();
    _startAnimationLoop();
  }
  
  @override
  void dispose() {
    _animationTimer.cancel();
    super.dispose();
  }
  
  void _startAnimationLoop() {
    _animationTimer = Timer.periodic(const Duration(milliseconds: 3000), (_) {
      if (mounted) {
        setState(() {
          _isAnimating = true;
        });
        
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            setState(() {
              _isAnimating = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GameBackground(size: 4, cellSize: 55, cellSpacing: 15)
            ),
            
            _isAnimating 
                ? MergeDemonstration()
                : _buildInitialTiles(),
            
            const Padding(
              padding: EdgeInsets.only(top: 180),
              child: Text(
                "Tiles with the same number merge into one",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInitialTiles() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 17,
          top: 65,
          child: SizedBox(
            width: 55,
            height: 55,
            child: ScoreContainer(
              score: 8,
              position: const Offset(0, 0),
              cellSize: 48,
              isNew: false,
            ),
          ),
        ),
        Positioned(
          left: 89,
          top: 65,
          child: SizedBox(
            height: 55,
            width: 55,
            child: ScoreContainer(
              score: 8,
              position: const Offset(0, 0),
              cellSize: 48,
              isNew: false,
            ),
          ),
        ),
      ],
    );
  }
}

class MergeDemonstration extends StatefulWidget {
  const MergeDemonstration({super.key});

  @override
  State<MergeDemonstration> createState() => _MergeDemonstrationState();
}

class _MergeDemonstrationState extends State<MergeDemonstration> with SingleTickerProviderStateMixin {
  bool showMerge = false;
  bool showFinalTile = false;
  late AnimationController _slideController;
  late Animation<Offset> _rightTileAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimation();
  }

  void _initAnimations() {
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _rightTileAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _slideController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          showMerge = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _slideController.forward();
    }
    
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        showMerge = false;
        showFinalTile = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (!showMerge && !showFinalTile) ...[
          Positioned(
            left: 17,
            top: 65,
            child: SizedBox(
              width: 55,
              height: 55,
              child: ScoreContainer(
                score: 8,
                position: const Offset(0, 0),
                cellSize: 48,
                isNew: false,
              ),
            ),
          ),
          Positioned(
            left: 89,
            top: 65,
            child: SlideTransition(
              position: _rightTileAnimation,
              child: SizedBox(
                width: 55,
                height: 55,
                child: ScoreContainer(
                  score: 8,
                  position: const Offset(0, 0),
                  cellSize: 48,
                  isNew: false,
                ),
              ),
            ),
          ),
        ],
        
        if (showMerge)
          Positioned(
            left: 17,
            top: 65,
            child: MergeComponent(
              score: 16,
              position: const Offset(0, 0),
              cellSize: 48,
              onMergeComplete: () {
                if (mounted) {
                  setState(() {
                    showMerge = false;
                    showFinalTile = true;
                  });
                }
              },
            ),
          ),
          
        if (showFinalTile)
          Positioned(
            left: 17,
            top: 65,
            child: SizedBox(
              width: 55,
              height: 55,
              child: ScoreContainer(
                score: 16,
                position: const Offset(0, 0),
                cellSize: 48,
                isNew: false,
              ),
            ),
          ),
      ],
    );
  }
}

class Intro3 extends StatefulWidget {
  const Intro3({Key? key}) : super(key: key);

  @override
  State<Intro3> createState() => _Intro3State();
}

class _Intro3State extends State<Intro3> with SingleTickerProviderStateMixin {
  bool _isSwipeAnimating = true;
  bool _showNewTile = false;
  late AnimationController _swipeController;
  late Animation<Offset> _tileAnimation;
  
  int _newTileValue = 2;
  final int _newTileRow = 2;
  final int _newTileCol = 3;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _determineNewTileValue();
    _startAnimationSequence();
  }
  
  void _determineNewTileValue() {
    _newTileValue = (Random().nextInt(10) == 0) ? 4 : 2;
  }
  
  void _initAnimations() {
    _swipeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _tileAnimation = Tween<Offset>(
      begin:Offset(0.57, 0.54),
      end: Offset(0.57, -1.93),
    ).animate(CurvedAnimation(
      parent: _swipeController,
      curve: Curves.easeInOut,
    ));
    
    _swipeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showNewTile = true;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _swipeController.dispose();
    super.dispose();
  }
  
  void _startAnimationSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      _swipeController.forward();
    }
    
    Timer.periodic(const Duration(milliseconds: 3000), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _isSwipeAnimating = true;
        _showNewTile = false;
        _determineNewTileValue();
      });
      
      _swipeController.reset();
      
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _swipeController.forward();
        }
      });
    });
  }
  
  Offset _calculatePosition(int row, int col) {
    const double cellSize = 58;
    const double cellSpacing = 15;
    
    return Offset(
      col * cellSize + (col + 1) * cellSpacing,
      row * cellSize + (row + 1) * cellSpacing,
    );
  }

  @override
  Widget build(BuildContext context) {
    final Offset tilePosition = _calculatePosition(1, 1);
    
    return Center(
      child: SizedBox(
        width: 400,
        height: 400,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: GameBackground(size: 4, cellSize: 55, cellSpacing: 15)
            ),
            
            if (_isSwipeAnimating)
              SlideTransition(
                position: _tileAnimation,
                child: Positioned(
                  left: tilePosition.dx,
                  top: tilePosition.dy,
                  child: SizedBox(
                    width: 55,
                    height: 55,
                    child: ScoreContainer(
                      score: 8,
                      position: Offset.zero,
                      cellSize: 48,
                      isNew: false,
                    ),
                  ),
                ),
              ),
            
            if (_showNewTile)
              Positioned(
                left: 88,
                top: 135,
                child: SizedBox(
                  width: 55,
                  height: 55,
                  child: ScoreContainer(
                    score: _newTileValue,
                    position: Offset.zero,
                    cellSize: 48,
                    isNew: true,
                  ),
                ),
              ),
            
            const Padding(
              padding: EdgeInsets.only(top: 180),
              child: Text(
                "A new tile (2 or 4) appears\nafter each swipe",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const Padding(
              padding: EdgeInsets.only(top: 270),
              child: Text(
                "with a 10% chance for a 4 \n else 2",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}





class Intro4 extends StatelessWidget {
  const Intro4({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text("Other mechanics:",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        InstructionText(text: "you can press Undo to revert your last swipe!", icon: Icons.undo,),
        InstructionText(text: "undoing will half you current score", icon: Icons.leaderboard,),
        InstructionText(text: "by pressing pauze you save your last game", icon: Icons.save,),
        InstructionText(text: "double tapping the screen will swipe in a random direction", icon: Icons.touch_app,),
        SizedBox(
          width: 200,
          child: TextButton(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.green)
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Play!",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),),
          ),
        )
      ],
    );
  }
}

class InstructionText extends StatelessWidget {
  const InstructionText({
    super.key,
    required this.text,
    required this.icon
  });
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        spacing: 20,
        children: [
          Icon(icon),
          SizedBox(
            width: 220,
            child: Text(text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}