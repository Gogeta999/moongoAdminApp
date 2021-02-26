part of 'pending_post_bloc.dart';

abstract class PendingPostState extends Equatable {
  const PendingPostState();
}

class PendingPostInit extends PendingPostState {
  @override
  List<Object> get props => [];
}

class PendingPostFail extends PendingPostState {
  final error;

  const PendingPostFail({this.error});

  @override
  List<Object> get props => [error];
}

class PendingPostSuccess extends PendingPostState {
  final List<Post> data;
  final int totalCount;
  final bool hasReachedMax;
  final int page;

  const PendingPostSuccess(
      {this.data, this.totalCount, this.hasReachedMax, this.page});

  PendingPostSuccess copyWith(
      {List<ListUser> data, int totalCount, bool hasReachedMax, int page}) {
    return PendingPostSuccess(
      data: data ?? this.data,
      totalCount: totalCount ?? this.totalCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      page: page ?? this.page,
    );
  }

  @override
  List<Object> get props => [data, totalCount, hasReachedMax, page];

  @override
  String toString() =>
      'BlockedUsersSuccess: ${data.length}, hasReachedMax: $hasReachedMax';
}
