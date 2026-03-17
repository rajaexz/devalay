import 'package:equatable/equatable.dart';

/// Base class for all signin/signup states
abstract class SigninState extends Equatable {
  const SigninState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class SigninInitial extends SigninState {
  const SigninInitial();
}

/// Loading state
class SigninLoading extends SigninState {
  const SigninLoading();
}

/// Success state
class SigninSuccess extends SigninState {
  const SigninSuccess();
}

/// Error state
class SigninError extends SigninState {
  final String message;

  const SigninError(this.message);

  @override
  List<Object?> get props => [message];
}

// ============ Backward Compatibility Aliases ============

@Deprecated('Use SigninState instead')
typedef SiginState = SigninState;

@Deprecated('Use SigninInitial instead')
typedef SiginInitial = SigninInitial;

@Deprecated('Use SigninLoading instead')  
typedef SiginLoaded = SigninLoading;
