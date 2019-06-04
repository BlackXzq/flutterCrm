import 'package:flutter/material.dart';
//import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:my_flutter/base/crm/customview/FrameAnimationImage.dart';

// ignore: must_be_immutable
//支持gif
class LoadingWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new LoadingWidgetState();
  }
}

class LoadingWidgetState extends State<LoadingWidget>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildGif() {
    List<String> _assetList = [];
    _assetList.add('images/loading00.png');
    _assetList.add('images/loading01.png');
    _assetList.add('images/loading02.png');
    _assetList.add('images/loading03.png');
    _assetList.add('images/loading04.png');
    _assetList.add('images/loading05.png');
    _assetList.add('images/loading06.png');

    _assetList.add('images/loading07.png');
    _assetList.add('images/loading08.png');
    _assetList.add('images/loading09.png');
    _assetList.add('images/loading10.png');
    _assetList.add('images/loading11.png');
    _assetList.add('images/loading12.png');
    _assetList.add('images/loading13.png');
    _assetList.add('images/loading14.png');
    _assetList.add('images/loading15.png');
    _assetList.add('images/loading16.png');
    _assetList.add('images/loading17.png');
    _assetList.add('images/loading18.png');
    _assetList.add('images/loading19.png');
    return Center(
        child: FrameAnimationImage(_assetList, width: 100,height: 100,)
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildGif();
  }
}
