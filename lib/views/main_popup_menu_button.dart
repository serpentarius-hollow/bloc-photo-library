import 'package:bloc_photo_library/dialogs/delete_account_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/app_bloc.dart';
import '../dialogs/logout_dialog.dart';

enum MenuAction { logout, deleteAccount }

class MainPopupMenuButton extends StatelessWidget {
  const MainPopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<MenuAction>(
      onSelected: (value) async {
        switch (value) {
          case MenuAction.logout:
            final shouldLogout = await showLogoutDialog(context);
            if (shouldLogout) {
              context.read<AppBloc>().add(
                    const AppEventLogout(),
                  );
            }
            break;
          case MenuAction.deleteAccount:
            final shouldDeleteAccount = await showDeleteAccountDialog(context);
            if (shouldDeleteAccount) {
              context.read<AppBloc>().add(
                    const AppEventDeleteAccount(),
                  );
            }
            break;
          default:
        }
      },
      itemBuilder: (context) {
        return [
          const PopupMenuItem<MenuAction>(
            value: MenuAction.logout,
            child: Text('Logout'),
          ),
          const PopupMenuItem<MenuAction>(
            value: MenuAction.deleteAccount,
            child: Text('Delete Account'),
          ),
        ];
      },
    );
  }
}
