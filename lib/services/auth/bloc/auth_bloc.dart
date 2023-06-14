import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mypersonalnote/services/auth/auth_provider.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_event.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider provider) : super(const AuthStateLoading()) {
    // initialized event
    on<AuthEventInitialized>((event, emit) async {
      await provider.initialize();
      final user = provider.currentUser;
      if (user == null) {
        emit(const AuthStateLoggedOut());
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedsVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    on<AuthEventLogIn>(
      (event, emit) async {
        try {
          emit(const AuthStateLoading());
          final email = event.email;
          final password = event.password;
          final user = await provider.logIn(email: email, password: password);
          emit(AuthStateLoggedIn(user));
        } on Exception catch (e) {
          emit(AuthStateLoggedInFailure(e));
        }
      },
    );
// logout event
    on<AuthEventLogOut>(
      (event, emit) async {
        emit(const AuthStateLoading());
        try {
          await provider.logOut();
        } on Exception catch (e) {
          emit(AuthStateLoggedInFailure(e));
        }
      },
    );
  }
}
