import 'dart:async';
import 'dart:math';

import 'package:MoonGoAdmin/api/bloc_patterns/pendingPostBloc/pending_post_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/post.dart';
import 'package:MoonGoAdmin/services/moonblink_repository.dart';
import 'package:MoonGoAdmin/ui/helper/full_screen_image_view.dart';
import 'package:MoonGoAdmin/ui/helper/image_helper.dart';
import 'package:MoonGoAdmin/ui/helper/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rxdart/rxdart.dart';

class PendingPostListPage extends StatefulWidget {
  @override
  _PendingPostListPageState createState() => _PendingPostListPageState();
}

class _PendingPostListPageState extends State<PendingPostListPage> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final _scrollController = ScrollController();
  final _scrollThreshold = 600.0;
  Completer<void> _refreshCompleter;
  PendingPostBloc _PendingPostBloc;

  @override
  void initState() {
    _PendingPostBloc = PendingPostBloc(_listKey, _buildRemoveItem);
    _PendingPostBloc.add(PendingPostFetched());
    _scrollController.addListener(_onScroll);
    _refreshCompleter = Completer<void>();
    super.initState();
  }

  @override
  void dispose() {
    _PendingPostBloc.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildItem(
      BuildContext context, int index, Animation<double> animation, Post data) {
    return SlideTransition(
        position: CurvedAnimation(
          curve: Curves.easeOut,
          parent: animation,
        ).drive(Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        )),
        child: BlocProvider.value(
          value: BlocProvider.of<PendingPostBloc>(context),
          child: PendingListTile(
            data: data,
            index: index,
          ),
        ));
  }

  Widget _buildRemoveItem(
      BuildContext context, int index, Animation<double> animation, Post data) {
    return SlideTransition(
        position: CurvedAnimation(
          curve: Curves.easeOut,
          parent: animation,
        ).drive(Tween<Offset>(
          begin: Offset(1, 0),
          end: Offset(0, 0),
        )),
        child: BlocProvider.value(
          value: BlocProvider.of<PendingPostBloc>(context),
          child: PendingListTile(
            data: data,
            index: index,
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PendingPostBloc>(
      create: (_) => _PendingPostBloc,
      child: Scaffold(
        appBar: AppBar(
          title: BlocBuilder<PendingPostBloc, PendingPostState>(
            builder: (context, state) {
              if (state is PendingPostInit) {
                return Text('Pending Post List');
              }
              if (state is PendingPostFail) {
                return Column(
                  children: [
                    Text('Pending Post List'),
                    Text('Total: UNKNOWN'),
                  ],
                );
              }
              if (state is PendingPostSuccess) {
                return Column(
                  children: [
                    Text('Pending Post List'),
                    // Text('Total: ${state.totalCount}',
                    //     style: TextStyle(
                    //         fontSize: 18, fontWeight: FontWeight.bold))
                  ],
                );
              }
              return Text('Something went wrong!');
            },
          ),
          backgroundColor: Colors.lightBlue[100],
        ),
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          child: BlocConsumer<PendingPostBloc, PendingPostState>(
            listener: (BuildContext context, state) {
              if (state is PendingPostSuccess) {
                _refreshCompleter.complete();
                _refreshCompleter = Completer();
              }
              if (state is PendingPostFail) {
                _refreshCompleter.completeError(state.error);
                _refreshCompleter = Completer();
              }
            },
            builder: (BuildContext context, state) {
              if (state is PendingPostInit) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is PendingPostFail) {
                return Center(
                  child: Text(state.error.toString()),
                );
              }
              if (state is PendingPostSuccess) {
                if (state.data.isEmpty) {
                  return Center(child: Text('No Pending User'));
                }
                return AnimatedList(
                  physics: ClampingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics()),
                  shrinkWrap: true,
                  key: _listKey,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index, animation) {
                    return Column(
                      children: <Widget>[
                        _buildItem(
                            context, index, animation, state.data[index]),
                        Divider(),
                        if (state.hasReachedMax == false &&
                            index >= state.data.length - 1)
                          Center(child: CupertinoActivityIndicator())
                      ],
                    );
                  },
                );
              }
              return Center(
                child: Text("Opps,. Error Appear"),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      _PendingPostBloc.add(PendingPostFetched());
    }
  }

  Future<void> _onRefresh() {
    _PendingPostBloc.add(PendingPostRefresh());
    return _refreshCompleter.future;
  }
}

class PendingListTile extends StatefulWidget {
  final Post data;
  final int index;

  PendingListTile({Key key, this.data, this.index}) : super(key: key);

  @override
  _PendingListTileState createState() => _PendingListTileState();
}

class _PendingListTileState extends State<PendingListTile> {
  final _acceptSubject = BehaviorSubject.seeded(false);
  final _rejectSubject = BehaviorSubject.seeded(false);
  final _currentPageSubject = BehaviorSubject.seeded(1);
  final _maxHeightSubject = BehaviorSubject.seeded(300.0);

  String getUrlType(String url) {
    bool isRemote = url.substring(0, 4) == 'http';
    List<String> strings = url.split('/');
    bool isImage = strings.last.contains('jpg') ||
        strings.last.contains('png') ||
        strings.last.contains('jpeg');
    bool isVideo = strings.last.contains('mp4');
    if (isRemote && isImage && !isVideo) {
      return "Image";
    } else if (isRemote && !isImage && isVideo) {
      return "Video";
    } else if (!isRemote && isImage && !isVideo) {
      return "LocalImage";
    } else if (!isRemote && !isImage && isVideo) {
      return "LocalVideo";
    } else {
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ImageView(widget.data.media[0])));
                },
                child: CachedNetworkImage(
                  imageUrl: widget.data.media[0],
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    backgroundImage: imageProvider,
                  ),
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.userid.toString(),
                ),
                // Text(
                //     'User type is ${widget.data.userid}\n ID is ${widget.data.id}'),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            StreamBuilder<double>(
                initialData: 300.0,
                stream: this._maxHeightSubject,
                builder: (context, maxHeightSnapshot) {
                  return AnimatedContainer(
                    width: double.infinity,
                    height: maxHeightSnapshot.data,
                    duration: Duration(milliseconds: 300),
                    child: PageView(
                      physics: ClampingScrollPhysics(),
                      onPageChanged: (value) {
                        _currentPageSubject.add(value + 1);
                      },
                      children: widget.data.media.map((element) {
                        String urlType = getUrlType(element);
                        if (urlType == "Image") {
                          return CupertinoButton(
                            padding: EdgeInsets.zero,
                            pressedOpacity: 0.9,
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (_) => ImageView(element),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: double.infinity,
                              child: CachedNetworkImage(
                                imageUrl: element,
                                imageBuilder: (context, imageProvider) {
                                  final imageListener =
                                      ImageStreamListener((info, _) {
                                    final _fittedSize = applyBoxFit(
                                        BoxFit.contain,
                                        Size(info.image.width.toDouble(),
                                            info.image.height.toDouble()),
                                        MediaQuery.of(context).size);
                                    this
                                        ._maxHeightSubject
                                        .add(_fittedSize.destination.height);
                                  });
                                  imageProvider
                                      .resolve(ImageConfiguration())
                                      .addListener(imageListener);
                                  return Image(
                                      image: imageProvider, fit: BoxFit.fill);
                                },
                                fadeOutDuration: Duration.zero,
                                fadeInDuration: Duration.zero,
                                placeholderFadeInDuration: Duration.zero,
                                progressIndicatorBuilder:
                                    (context, url, progress) {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: progress.progress,
                                      valueColor: AlwaysStoppedAnimation(
                                          Theme.of(context).accentColor),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                          );
                        }
                        if (urlType == "Video")
                          return Player(
                            url: element,
                            id: widget.data.id,
                            index: widget.index,
                            maxHeightCallBack: (double height) {
                              this._maxHeightSubject.add(min(height,
                                  MediaQuery.of(context).size.height * 0.7));
                            },
                          );
                        return Text('Not Supported Format');
                      }).toList(),
                    ),
                  );
                }),
            StreamBuilder<int>(
                initialData: 0,
                stream: this._currentPageSubject,
                builder: (context, snapshot) {
                  if (snapshot.data == null) return Container();
                  return Positioned(
                      top: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 6),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.5)),
                        child: Text(
                            '${snapshot.data} / ${widget.data.media.length}',
                            style: TextStyle(color: Colors.white)),
                      ));
                })
          ],
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                // CupertinoButton(child: Text(''), onPressed: null)
                //Still Unsupport
                StreamBuilder<bool>(
                    initialData: false,
                    stream: _rejectSubject,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        return CupertinoButton(
                          child: CupertinoActivityIndicator(),
                          onPressed: () {},
                        );
                      }
                      return CupertinoButton(
                        child: Text('Reject'),
                        onPressed: () {
                          rejectDialog();
                        },
                      );
                    }),
                StreamBuilder<bool>(
                    initialData: false,
                    stream: _acceptSubject,
                    builder: (context, snapshot) {
                      if (snapshot.data) {
                        return CupertinoButton(
                          child: CupertinoActivityIndicator(),
                          onPressed: () {},
                        );
                      }
                      return CupertinoButton(
                        child: Text('Accept'),
                        onPressed: _acceptPost,
                      );
                    })
              ],
            )
          ],
        ),
      ],
    );
  }

  _acceptPost() async {
    _acceptSubject.add(true);
    try {
      await MoonblinkRepository.approvedPosts(1, widget.data.id);
      BlocProvider.of<PendingPostBloc>(context)
          .add(PendingPostRemoveUser(widget.index));
      _acceptSubject.add(false);
    } catch (e) {
      showToast(e.toString());
      _acceptSubject.add(false);
    }
  }

  //Reject Dialog
  rejectDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.0),
          ),
          title: Text("Reject this Post"),
          content: Container(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            decoration: BoxDecoration(
              border: Border.all(width: 1, color: Colors.black),
              borderRadius: BorderRadius.all(Radius.circular(30.0)),
            ),
            child: Text("Are you sure to reject this Post?"),
          ),
          actions: [
            FlatButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            FlatButton(
              onPressed: () {
                _rejectUser();
              },
              child: Text("Reject"),
            ),
          ],
        );
      },
    );
  }

  _rejectUser() async {
    _rejectSubject.add(true);
    try {
      //await Future.delayed(Duration(milliseconds: 2000));
      await MoonblinkRepository.approvedPosts(-1, widget.data.id);
      Navigator.pop(context);
      BlocProvider.of<PendingPostBloc>(context)
          .add(PendingPostRemoveUser(widget.index));
      _rejectSubject.add(false);
    } catch (e) {
      showToast(e.toString());
      _rejectSubject.add(false);
    }
  }
}
