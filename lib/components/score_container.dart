import 'package:flutter/material.dart';
import 'package:the_modern_edition_2048/utils/colorhandler.dart';

class ScoreContainer extends StatelessWidget {
  const ScoreContainer({super.key, required this.score});
  final int score;
  @override
  Widget build(BuildContext context) {
    if (score == 0) {
      return Container(
        decoration: BoxDecoration(
        color: ColorHandler.getColorFromValue(score),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Center(
        child: Text(
          score == 0 ? '' : score.toString(),
          style: TextStyle(
            color: ColorHandler.getTextColorFromValue(score)
          ),
        ),
      ),
    );
    }


    return AnimatedContainer(
      duration: Duration(milliseconds: 500),
      decoration: BoxDecoration(
        color: ColorHandler.getColorFromValue(score),
        borderRadius: BorderRadius.circular(8)
      ),
      child: Center(
        child: Text(
          score == 0 ? '' : score.toString(),
          style: TextStyle(
            color: ColorHandler.getTextColorFromValue(score)
          ),
        ),
      ),
    );
  }
}