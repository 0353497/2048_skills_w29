import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/utils/colorhandler.dart';

class ScoreContainer extends StatefulWidget {
  const ScoreContainer({
    super.key, 
    required this.score,
    required this.position,
    required this.cellSize,
    this.isNew = false,
  });
  
  final int score;
  final Offset position;
  final double cellSize;
  final bool isNew;
  
  @override
  State<ScoreContainer> createState() => _ScoreContainerState();
}

class _ScoreContainerState extends State<ScoreContainer> with SingleTickerProviderStateMixin {
  AnimationController? _scaleController;
  Animation<double>? _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: widget.isNew ? 0.1 : 1.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController!,
      curve: Curves.easeInOutBack,
    ));
    
    if (widget.isNew) {
      _scaleController!.forward();
    }
  }
  
  @override
  void dispose() {
    _scaleController?.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    if (_scaleController == null || _scaleAnimation == null) {
      _initializeAnimation();
    }

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      left: widget.position.dx,
      top: widget.position.dy,
      width: widget.cellSize,
      height: widget.cellSize,
      child: AnimatedBuilder(
        animation: _scaleAnimation!,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation!.value,
            child: child,
          );
        },
        child: _buildTileContent(),
      ),
    );
  }
  
  Widget _buildTileContent() {
    return widget.score == 0 
      ? const SizedBox() 
      : AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
        );
  }
}


