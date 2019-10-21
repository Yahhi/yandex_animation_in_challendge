import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';

class Former {
  final String data;
  int width, height;
  List<AnimatedItem> animateds;

  Former(this.data) {
    List<String> lines = data.split("\n");
    List<String> wh = lines[0].split(" ");
    width = int.parse(wh[0]);
    height = int.parse(wh[1]);
    animateds = new List();
    int index = 2;
    print("lines length is ${lines.length}");
    while (index < lines.length) {
      AnimatedItem item;
      if (lines[index].trim() == "") {
        index++;
        continue;
      }
      if (lines[index].trim().startsWith("rectangle")) {
        item = new AnimatedRectangle(lines[index++].trim());
      } else {
        item = new AnimatedCircle(lines[index++].trim());
      }
      int animationsCount = int.parse(lines[index++]);
      if (animationsCount > 0) {
        for (int i = 0; i < animationsCount; i++) {
          item.addAnimation(lines[index++].trim());
        }
      }
      animateds.add(item);
    }
  }

  void animate() {}

  List<Widget> getAnimations() {
    List<Widget> result = new List();
    for (AnimatedItem item in animateds) {
      result.add(item.getWidget());
    }
    return result;
  }
}

abstract class AnimatedItem {
  Widget getWidget();
  Widget getResultWidget();
  String color;
  List<SpecialAnimation> animations = new List();
  AnimationMove move;

  void addAnimation(String animationText) {
    List<String> animationParams = animationText.split(" ");
    switch (animationParams[0]) {
      case "rotate":
        animations.add(AnimationRotate(double.parse(animationParams[1]),
            int.parse(animationParams[2]), animationParams.length > 3));
        break;
      case "move":
        move = AnimationMove(
            double.parse(animationParams[1]),
            double.parse(animationParams[2]),
            int.parse(animationParams[3]),
            animationParams.length > 4);
        animations.add(move);
        break;
      case "scale":
        animations.add(AnimationScale(double.parse(animationParams[1]),
            int.parse(animationParams[2]), animationParams.length > 3));
        break;
    }
  }

  int getAnimationDuration() {
    int result = 0;
    if (animations.length > 0) {
      result = animations[0].time;
    }
    if (animations.length > 1 && animations[1].time > result) {
      result = animations[1].time;
    }
    if (animations.length > 2 && animations[2].time > result) {
      result = animations[2].time;
    }
    return result;
  }

  Color getColor() {
    switch (color) {
      case "black":
        return Colors.black;
      case "red":
        return Colors.red;
      case "white":
        return Colors.white;
      case "yellow":
        return Colors.yellow;
      default:
        return Colors.blue;
    }
  }
}

class AnimatedCircle extends AnimatedItem {
  double centerX, centerY;
  double radius;

  AnimatedCircle(String params) {
    print("params for circle: '$params'");
    List<String> paramsDivided = params.split(" ");
    centerX = double.parse(paramsDivided[1]);
    centerY = double.parse(paramsDivided[2]);
    radius = double.parse(paramsDivided[3]);
    color = paramsDivided[4];
  }

  @override
  Widget getWidget() {
    return Positioned(
      left: centerX - radius,
      top: centerY - radius,
      child: animations.length == 0
          ? Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                color: getColor(),
              ),
            )
          : AnimatedContainer(
              duration: Duration(milliseconds: getAnimationDuration()),
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                color: getColor(),
              ),
            ),
    );
  }

  @override
  Widget getResultWidget() {
    return Positioned(
      left: move.destX - radius,
      top: move.destY - radius,
      child: Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(radius)),
                color: getColor(),
              ),
            ),
    );
  }
}

class AnimatedRectangle extends AnimatedItem {
  double centerX, centerY, width, height, angle;

  AnimatedRectangle(String params) {
    print("params for rectangle: '$params'");
    List<String> paramsDivided = params.split(" ");
    centerX = double.parse(paramsDivided[1]);
    centerY = double.parse(paramsDivided[2]);
    width = double.parse(paramsDivided[3]);
    height = double.parse(paramsDivided[4]);
    angle = double.parse(paramsDivided[5]);
    color = paramsDivided[6];
  }

  @override
  Widget getWidget() {
    return Positioned(
      left: centerX - width / 2,
      top: centerY - height / 2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: getColor(),
        ),
      ),
    );
  }

  @override
  Widget getResultWidget() {
    return Positioned(
      left: centerX - width / 2 - ,
      top: centerY - height / 2,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: getColor(),
        ),
      ),
    );
  }
}

class SpecialAnimation {
  final int time;
  final bool isCycle;

  SpecialAnimation(this.time, this.isCycle);
}

class AnimationMove extends SpecialAnimation {
  final double destX, destY;

  AnimationMove(this.destX, this.destY, int time, bool isCycle)
      : super(time, isCycle);
}

class AnimationRotate extends SpecialAnimation {
  final double angle;

  AnimationRotate(this.angle, int time, bool isCycle) : super(time, isCycle);
}

class AnimationScale extends SpecialAnimation {
  final double destScale;

  AnimationScale(this.destScale, int time, bool isCycle) : super(time, isCycle);
}
