import 'package:devalay_app/src/application/authentication/signup/signin_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for handling signup state
/// 
/// Note: Phone-based signup uses the same flow as login (OTP verification).
/// This cubit is kept for backward compatibility and future extensibility.
class SigninCubit extends Cubit<SigninState> {
  SigninCubit() : super(const SigninInitial());

  /// Check if currently in loading state
  bool get isLoading => state is SigninLoading;

  /// Reset to initial state
  void resetState() {
    emit(const SigninInitial());
    }
}

// ============ Backward Compatibility Alias ============

@Deprecated('Use SigninCubit instead')
typedef SiginCubit = SigninCubit;
