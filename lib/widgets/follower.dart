import 'package:flutter/material.dart';

class FollowWidget extends StatefulWidget {
  const FollowWidget({
    Key? key,
    required this.title,
    required this.data,
  }) : super(key: key);

  final String title;
  final int data;

  @override
  State<FollowWidget> createState() => _FollowWidgetState();
}

class _FollowWidgetState extends State<FollowWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          '${widget.data}',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text('${widget.title}', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
