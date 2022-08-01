import 'package:bloc_photo_library/auth/auth_error.dart';
import 'package:flutter/material.dart';

import 'generic_dialog.dart';

Future<void> showAuthError({
  required BuildContext context,
  required AuthError authError,
}) {
  return showGenericDialog<void>(
    context: context,
    title: authError.dialogTitle,
    content: authError.dialogText,
    optionsBuilder: () => {
      'OK': true,
    },
  );
}
