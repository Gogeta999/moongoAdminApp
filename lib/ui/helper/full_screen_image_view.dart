import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:rxdart/subjects.dart';

///null one to switch local and cache
class FullScreenImageView extends StatefulWidget {
  final List<File> images;
  final List<String> imageUrls;
  final List<String> assetNames;

  FullScreenImageView({this.images, this.imageUrls, this.assetNames});

  @override
  _FullScreenImageViewState createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  final _indexSubject = BehaviorSubject.seeded(0);

  @override
  void dispose() {
    _indexSubject.close();
    super.dispose();
  }

  int get imageLength {
    if (widget.images != null && widget.images.isNotEmpty) {
      return widget.images.length;
    } else if (widget.imageUrls != null && widget.imageUrls.isNotEmpty) {
      return widget.imageUrls.length;
    } else if (widget.assetNames != null && widget.assetNames.isNotEmpty) {
      return widget.assetNames.length;
    } else {
      return 0;
    }
  }

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
      body: Stack(
        children: [
          PageView.builder(
            itemCount: imageLength,
            onPageChanged: (value) {
              _indexSubject.add(value);
            },
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, index) {
              return PhotoView(
                loadFailedChild: Icon(Icons.error),
                minScale: PhotoViewComputedScale.covered * 0.5,
                maxScale: PhotoViewComputedScale.covered * 1.5,
                imageProvider: () {
                  if (widget.images != null && widget.images.isNotEmpty) {
                    return FileImage(widget.images[index]);
                  } else if (widget.imageUrls != null &&
                      widget.imageUrls.isNotEmpty) {
                    return CachedNetworkImageProvider(widget.imageUrls[index]);
                  } else if (widget.assetNames != null &&
                      widget.assetNames.isNotEmpty) {
                    return AssetImage(widget.assetNames[index]);
                  } else {
                    return AssetImage('assets/images/Later.jpg');
                  }
                }(),
              );
            },
          ),
          StreamBuilder<int>(
              initialData: 0,
              stream: _indexSubject,
              builder: (context, snapshot) {
                return Positioned(
                  top: 20,
                  right: 10,
                  child: Text(
                    '${snapshot.data + 1} / $imageLength',
                    style: TextStyle(color: Colors.white),
                  ),
                );
              }),
        ],
      ),
    );
  }
}
