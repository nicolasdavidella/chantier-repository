import 'package:flutter/material.dart';
import 'package:chantier_track/data/models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final Function(String) onPhotoUpdated;

  const ProfileHeader({super.key, required this.user, required this.onPhotoUpdated});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
