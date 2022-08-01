import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_bloc.dart';
import '../dialogs/show_auth_error.dart';
import '../loading/loading_screen.dart';
import 'login_view.dart';
import 'photo_gallery_view.dart';
import 'registration_view.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AppBloc>(
      create: (_) => AppBloc()..add(const AppEventInitialize()),
      child: MaterialApp(
        title: 'Bloc Photo Library',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        debugShowCheckedModeBanner: false,
        home: BlocConsumer<AppBloc, AppState>(
          builder: (context, state) {
            if (state is AppStateLoggedOut) {
              return const LoginView();
            } else if (state is AppStateLoggedIn) {
              return const PhotoGalleryView();
            } else if (state is AppStateIsInRegistration) {
              return const RegistrationView();
            } else {
              // Implement assertion in the future
              return Container();
            }
          },
          listener: (context, state) {
            if (state.isLoading) {
              LoadingScreen.instance().show(
                context: context,
                text: 'Loading...',
              );
            } else {
              LoadingScreen.instance().hide();
            }

            final authError = state.authError;
            if (authError != null) {
              showAuthError(
                context: context,
                authError: authError,
              );
            }
          },
        ),
      ),
    );
  }
}
