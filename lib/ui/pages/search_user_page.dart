import 'dart:async';
import 'dart:io';

import 'package:MoonGoAdmin/api/bloc_patterns/searchBloc/search_user_bloc.dart';
import 'package:MoonGoAdmin/global/router_manager.dart';
import 'package:MoonGoAdmin/models/search_user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchUserPage extends StatefulWidget {
  @override
  _SearchUserPageState createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  final TextEditingController _queryController = TextEditingController();
  final SearchUserBloc _searchUserBloc = SearchUserBloc();
  final _scrollController = ScrollController();
  final _scrollThreshold = 400.0;
  Timer _debounce;

  @override
  void initState() {
    _scrollController.addListener(_onScroll);
    _searchUserBloc.add(SearchUserNotSearching());
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _queryController.dispose();
    //_debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.lightBlue[100],
          leading: IconButton(
            icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
          title: CupertinoTextField(
            controller: _queryController,
            autofocus: true,
            placeholder: "Search...",
            clearButtonMode: OverlayVisibilityMode.editing,
            textInputAction: TextInputAction.search,
            onSubmitted: (query) => _search(),
            onChanged: (query) {
              if (query.isEmpty)
                _searchUserBloc.add(SearchUserNotSearching());
              else
                _searchUserBloc.add(SearchUserSuggestions(query));
            },
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: _search,
            ),
          ]),
      body: SafeArea(
        child: BlocProvider(
          create: (_) => _searchUserBloc,
          child: BlocConsumer<SearchUserBloc, SearchUserState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is SearchUserInitial) {
                return Center(child: CupertinoActivityIndicator());
              }
              if (state is SearchUserNotSearchingSuccess) {
                return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    if (state.histories.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text('No Search History'),
                      );
                    }
                    String history = state.histories[index];
                    return ListTile(
                      leading: Icon(Icons.history),
                      title: Text(history),
                      trailing: Icon(Icons.call_missed),
                      onTap: () {
                        _queryController.text = history;
                        _queryController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _queryController.text.length));
                        _search();
                      },
                    );
                  },
                  itemCount: state.histories.length,
                );
              }
              if (state is SearchUserSearchingFailure) {
                print(state.error.toString());
                return Center(child: Text('No User Found'));
              }
              if (state is SearchUserSuggestionsSuccess) {
                if (state.suggestions == null || state.suggestions.isEmpty) {
                  return Container();
                }
                return ListView.builder(
                  physics: ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    String suggestion = state.suggestions[index];
                    return ListTile(
                      leading: Icon(Icons.subdirectory_arrow_right),
                      title: Text(suggestion),
                      trailing: Icon(Icons.call_missed),
                      onTap: () {
                        _queryController.text = suggestion;
                        _queryController.selection = TextSelection.fromPosition(
                            TextPosition(offset: _queryController.text.length));
                        _search();
                      },
                    );
                  },
                  itemCount: state.suggestions.length,
                );
              }
              if (state is SearchUserSearchingSuccess) {
                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _scrollController,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Search results for "${state.query}"',
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    if (index >= state.data.length + 1) {
                      return CupertinoActivityIndicator();
                    }
                    SearchUserModel item = state.data[index - 1];
                    return ListTile(
                      onTap: () => Navigator.pushNamed(
                          context, RouteName.userControl,
                          arguments: item.id),
                      leading: CachedNetworkImage(
                        imageUrl: item.profileImage,
                        placeholder: (_, __) => CupertinoActivityIndicator(),
                        errorWidget: (_, __, ___) => Icon(Icons.error),
                        imageBuilder: (context, imageProvider) => Container(
                          width: 50.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        ),
                      ),
                      title: Text(item.name),
                    );
                  },
                  itemCount: state.hasReachedMax
                      ? state.data.length + 1
                      : state.data.length + 2,
                );
              }
              return Text('Oops! Something went wrong!');
            },
          ),
        ),
      ),
    );
  }

  _search() {
    _searchUserBloc.add(SearchUserSearched(_queryController.text));
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= _scrollThreshold) {
      if (_debounce?.isActive ?? false) _debounce.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        _searchUserBloc.add(SearchUserSearchedMore());
      });
    }
  }
}
