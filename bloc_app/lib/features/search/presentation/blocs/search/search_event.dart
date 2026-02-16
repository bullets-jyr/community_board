part of 'search_bloc.dart';

sealed class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object> get props => [];
}

final class SearchQueryChanged extends SearchEvent {
  const SearchQueryChanged({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

final class SearchTabChanged extends SearchEvent {
  const SearchTabChanged({required this.tabIndex});

  final int tabIndex;

  @override
  List<Object> get props => [tabIndex];
}

final class _SearchExecutionTriggered extends SearchEvent {
  const _SearchExecutionTriggered({required this.query});

  final String query;

  @override
  List<Object> get props => [query];
}

final class SearchPostLikeToggled extends SearchEvent {
  const SearchPostLikeToggled({required this.post});

  final PostDisplay post;

  @override
  List<Object> get props => [post];
}

final class _GlobalEventReceived extends SearchEvent {
  const _GlobalEventReceived({required this.event});

  final GlobalEvent event;

  @override
  List<Object> get props => [event];
}

final class SearchTransientFailureConsumed extends SearchEvent {}
