import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:meta/meta.dart';

import '../auth/auth_error.dart';
import '../utils/upload_image.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc()
      : super(
          const AppStateLoggedOut(
            isLoading: false,
          ),
        ) {
    // Handle go to register from login page
    on<AppEventGoToRegistration>(
      (event, emit) {
        emit(const AppStateIsInRegistration(isLoading: false));
      },
    );
    on<AppEventLogin>(
      (event, emit) async {
        emit(const AppStateLoggedOut(isLoading: true));

        try {
          // Log the user in
          final email = event.emailAddress;
          final password = event.password;
          final credentials =
              await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          final user = credentials.user!;
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              user: user,
              images: images,
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedOut(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );
    // Handle go to login from register page
    on<AppEventGoToLogin>(
      (event, emit) {
        emit(const AppStateLoggedOut(isLoading: false));
      },
    );
    // Handle registration
    on<AppEventRegister>(
      (event, emit) async {
        // Start the loading process
        emit(const AppStateIsInRegistration(isLoading: true));
        final email = event.emailAddress;
        final password = event.password;
        try {
          // Create the user
          final credentials =
              await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          emit(
            AppStateLoggedIn(
              user: credentials.user!,
              images: const [],
              isLoading: false,
            ),
          );
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateIsInRegistration(
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        }
      },
    );
    // Handle app initialization
    on<AppEventInitialize>(
      (event, emit) async {
        // Get the current user
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          emit(const AppStateLoggedOut(isLoading: false));
        } else {
          // Get the user uploaded images
          final images = await _getImages(user.uid);
          emit(
            AppStateLoggedIn(
              user: user,
              images: images,
              isLoading: false,
            ),
          );
        }
      },
    );
    // Handle user log out
    on<AppEventLogout>(
      (event, emit) async {
        // Start the loading process
        emit(const AppStateLoggedOut(isLoading: true));
        // Log the user out
        await FirebaseAuth.instance.signOut();
        // Log the user out in the UI as well
        emit(const AppStateLoggedOut(isLoading: false));
      },
    );

    // Handle account deletion
    on<AppEventDeleteAccount>(
      (event, emit) async {
        final user = FirebaseAuth.instance.currentUser;

        // Log user out if we don't have an actual user in app state
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }

        // Start the loading process
        emit(
          AppStateLoggedIn(
            user: user,
            images: state.images ?? [],
            isLoading: true,
          ),
        );

        // Delete the user folder
        try {
          final folderContents =
              await FirebaseStorage.instance.ref(user.uid).listAll();
          for (final item in folderContents.items) {
            // Maybe handle the error?
            await item.delete().catchError((_) {});
          }
          // Delete the folder itself
          await FirebaseStorage.instance
              .ref(user.uid)
              .delete()
              .catchError((_) {});
          // Delete the user
          await user.delete();
          // Log the user out
          await FirebaseAuth.instance.signOut();
          // Log the user out in the UI as well
          emit(const AppStateLoggedOut(isLoading: false));
        } on FirebaseAuthException catch (e) {
          emit(
            AppStateLoggedIn(
              user: user,
              images: state.images ?? [],
              isLoading: false,
              authError: AuthError.from(e),
            ),
          );
        } on FirebaseException {
          // We might not be able to delete the folder
          // Log the user out
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
        }
      },
    );

    // Handle uploading images
    on<AppEventUploadImage>(
      (event, emit) async {
        final user = state.user;

        // Log user out if we don't have an actual user in app state
        if (user == null) {
          emit(
            const AppStateLoggedOut(isLoading: false),
          );
          return;
        }

        // Start the loading process
        emit(
          AppStateLoggedIn(
            user: user,
            images: state.images ?? [],
            isLoading: true,
          ),
        );

        // Upload the file
        final file = File(event.filePathToUpload);
        await uploadImage(file: file, userId: user.uid);

        // After upload is complete, grab the latest references
        final images = await _getImages(user.uid);
        // Emit the new images and turn off loading
        emit(
          AppStateLoggedIn(
            user: user,
            images: images,
            isLoading: false,
          ),
        );
      },
    );
  }

  Future<Iterable<Reference>> _getImages(String userId) {
    return FirebaseStorage.instance
        .ref(userId)
        .list()
        .then((listResult) => listResult.items);
  }
}
