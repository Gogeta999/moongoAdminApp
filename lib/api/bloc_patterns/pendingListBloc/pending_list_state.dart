part of 'pending_list_bloc.dart';

abstract class PendingListState extends Equatable {
  const PendingListState();
}

class PendingListInit extends PendingListState {
  @override
  List<Object> get props => [];
}

class PendingListFail extends PendingListState {
  final error;

  const PendingListFail({this.error});

  @override
  List<Object> get props => [error];
}

class PendingListNoData extends PendingListState {
  @override
  List<Object> get props => [];
}

class PendingListSuccess extends PendingListState {
  final List<ListUser> data;
  final int totalCount;
  final bool hasReachedMax;
  final int page;

  const PendingListSuccess(
      {this.data, this.totalCount, this.hasReachedMax, this.page});

  PendingListSuccess copyWith(
      {List<ListUser> data, int totalCount, bool hasReachedMax, int page}) {
    return PendingListSuccess(
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
