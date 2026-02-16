part of 'user_profile_bloc.dart';

sealed class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

final class UserProfileFetched extends UserProfileEvent {
  const UserProfileFetched({required this.userId});

  final String userId;

  @override
  List<Object> get props => [userId];
}
