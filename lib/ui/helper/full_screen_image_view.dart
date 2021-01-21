import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

///null one to switch local and cache
class FullScreenImageView extends StatelessWidget {
  final File image;
  final String imageUrl;
  final String assetsName;

  FullScreenImageView({this.image, this.imageUrl, this.assetsName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
            color: Theme.of(context).accentColor,
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context)),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (end) {
          Navigator.pop(context);
        },
        child: PhotoView(
          imageProvider: () {
            if (image != null) {
              return FileImage(image);
            } else if (imageUrl != null) {
              return CachedNetworkImageProvider(imageUrl);
            } else if (assetsName != null) {
              return AssetImage(assetsName);
            } else {
              return AssetImage('assets/images/Later.jpg');
            }
          }(),
        ),
      ),
    );
  }
}
