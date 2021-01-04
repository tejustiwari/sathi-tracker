import 'package:flutter/material.dart';


class ImageBanner extends StatelessWidget {
  final String _assetPath;

  ImageBanner(this._assetPath);

  @override

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(75.0, 0.0, 75.0, 0.0),
      constraints: BoxConstraints.expand(
        height: 0.20* MediaQuery.of(context).size.height,
        width: 0.20 * MediaQuery.of(context).size.width,
      ),
      child:Image.asset(
        _assetPath,
      )
    );
  }
}
