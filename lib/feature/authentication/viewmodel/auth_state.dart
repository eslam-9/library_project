import 'package:library_project/feature/authentication/model/user_model.dart';

sealed class AuthenticationState {}

class AuthenticationInitialState extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationLoaded extends AuthenticationState {
  final UserModel user;

  AuthenticationLoaded(this.user);
}

class AuthenticationError extends AuthenticationState {
  final String error;

  AuthenticationError(this.error);
}
