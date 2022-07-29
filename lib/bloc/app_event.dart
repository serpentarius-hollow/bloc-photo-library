part of 'app_bloc.dart';

@immutable
abstract class AppEvent {
  const AppEvent();
}

@immutable
class AppEventUploadImage implements AppEvent {
  final String filePathToUpload;

  const AppEventUploadImage({
    required this.filePathToUpload,
  });
}

@immutable
class AppEventDeleteAccount implements AppEvent {
  const AppEventDeleteAccount();
}

@immutable
class AppEventLogout implements AppEvent {
  const AppEventLogout();
}

@immutable
class AppEventInitialize implements AppEvent {
  const AppEventInitialize();
}

@immutable
class AppEventLogin implements AppEvent {
  final String emailAddress;
  final String password;

  const AppEventLogin({
    required this.emailAddress,
    required this.password,
  });
}

@immutable
class AppEventGoToRegistration implements AppEvent {
  const AppEventGoToRegistration();
}

@immutable
class AppEventGoToLogin implements AppEvent {
  const AppEventGoToLogin();
}

@immutable
class AppEventRegister implements AppEvent {
  final String emailAddress;
  final String password;

  const AppEventRegister({
    required this.emailAddress,
    required this.password,
  });
}
