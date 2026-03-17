import 'package:equatable/equatable.dart';

/// Base class for all login states
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the login screen is first loaded
class LoginInitial extends LoginState {
  const LoginInitial();
}

/// State when a login operation is in progress
class LoginLoading extends LoginState {
  final String? message;

  const LoginLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// State when OTP has been sent successfully
class LoginOtpSent extends LoginState {
  final String phoneNumber;

  const LoginOtpSent({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

/// State when login is successful
class LoginSuccess extends LoginState {
  const LoginSuccess();
}

/// State when a login operation fails
class LoginError extends LoginState {
  final String message;

  const LoginError(this.message);

  @override
  List<Object?> get props => [message];
}
