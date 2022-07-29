import 'package:flutter/foundation.dart' show immutable;
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;

const Map<String, AuthError> authErrorMapping = {
  'user-not-found': AuthErrorUserNotFound(),
  'weak-password': AuthErrorWeakPassword(),
  'invalid-email': AuthErrorInvalidEmail(),
  'operation-not-allowed': AuthErrorOperationNotAllowed(),
  'email-already-in-use': AuthErrorEmailAlreadyInUse(),
  'requires-recent-login': AuthErrorRequiresRecentLogin(),
  'no-current-user': AuthErrorNoCurrentUser(),
};

@immutable
abstract class AuthError {
  final String dialogTitle;
  final String dialogText;

  const AuthError({
    required this.dialogTitle,
    required this.dialogText,
  });

  factory AuthError.from(FirebaseAuthException exception) {
    return authErrorMapping[exception.code.toLowerCase().trim()] ??
        AuthErrorUnknown(exception);
  }
}

@immutable
class AuthErrorUnknown extends AuthError {
  final FirebaseAuthException innerException;
  const AuthErrorUnknown(this.innerException)
      : super(
          dialogTitle: 'Authentication Error',
          dialogText: 'Unknown authentication error',
        );
}

@immutable
class AuthErrorNoCurrentUser extends AuthError {
  const AuthErrorNoCurrentUser()
      : super(
          dialogTitle: 'No Current User',
          dialogText: 'No current user with this information founc',
        );
}

@immutable
class AuthErrorRequiresRecentLogin extends AuthError {
  const AuthErrorRequiresRecentLogin()
      : super(
          dialogTitle: 'Requires Recent Login',
          dialogText:
              'You need to logout and login again in order to perform this operation',
        );
}

// The signin provider is disabled
@immutable
class AuthErrorOperationNotAllowed extends AuthError {
  const AuthErrorOperationNotAllowed()
      : super(
          dialogTitle: 'Operation Not ALlowed',
          dialogText: 'You cannot register using this method at this time',
        );
}

@immutable
class AuthErrorUserNotFound extends AuthError {
  const AuthErrorUserNotFound()
      : super(
          dialogTitle: 'User Not Found',
          dialogText: 'The given user was not found on the server',
        );
}

@immutable
class AuthErrorWeakPassword extends AuthError {
  const AuthErrorWeakPassword()
      : super(
          dialogTitle: 'Weak Password',
          dialogText:
              'Please choose a stronger password consisting of more characters',
        );
}

@immutable
class AuthErrorInvalidEmail extends AuthError {
  const AuthErrorInvalidEmail()
      : super(
          dialogTitle: 'Invalid Email',
          dialogText: 'Please double check your email and try again ',
        );
}

@immutable
class AuthErrorEmailAlreadyInUse extends AuthError {
  const AuthErrorEmailAlreadyInUse()
      : super(
          dialogTitle: 'Email Already In Use',
          dialogText: 'Please choose another email to register with',
        );
}
