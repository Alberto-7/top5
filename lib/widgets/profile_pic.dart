import 'package:flutter/material.dart';

class ProfilePicWidget extends StatefulWidget {
  const ProfilePicWidget({
    Key? key,
    required this.picLocation,
  }) : super(key: key);

  final String? picLocation;

  @override
  State<ProfilePicWidget> createState() => _ProfilePicWidgetState();
}

class _ProfilePicWidgetState extends State<ProfilePicWidget> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: Colors.white,
      radius: 65,
      child: CircleAvatar(
        backgroundImage:
            Image.asset('assets/images/${widget.picLocation}').image,
        radius: 60,
      ),
    );
  }
}
