import 'package:flutter/material.dart';

// 帧动画Image
class FrameAnimationImage extends StatefulWidget {
  final List<String> _assetList;
  final double width;
  final double height;
  final int interval;

  FrameAnimationImage(this._assetList,
      {this.width, this.height, this.interval = 60});

  @override
  State<StatefulWidget> createState() {
    return _FrameAnimationImageState();
  }
}

class _FrameAnimationImageState extends State<FrameAnimationImage>
    with SingleTickerProviderStateMixin {
  // 动画控制
  Animation<double> _animation;
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    int interval = widget.interval;
    if (interval <= 0) {
      interval = 60;
    }
    final int imageCount = widget._assetList.length;
    final int maxTime = interval * imageCount;

    // 启动动画controller
    _controller = new AnimationController(
        duration: Duration(milliseconds: maxTime), vsync: this);
    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.forward(from: 0.0); // 完成后重新开始
      }
    });

    _animation = new Tween<double>(begin: 0, end: imageCount.toDouble())
        .animate(_controller)
          ..addListener(() {
            setState(() {
              // the state that has changed here is the animation object’s value
            });
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int ix = _animation.value.floor() % widget._assetList.length;

    List<Widget> images = [];
    // 把所有图片都加载进内容，否则每一帧加载时会卡顿
    for (int i = 0; i < widget._assetList.length; ++i) {
      if (i != ix) {
        images.add(Image.asset(
          widget._assetList[i],
          width: 0,
          height: 0,
        ));
      }
    }

    images.add(Image.asset(
      widget._assetList[ix],
      width: widget.width,
      height: widget.height,
    ));

    return Stack(alignment: AlignmentDirectional.center, children: images);
  }
}