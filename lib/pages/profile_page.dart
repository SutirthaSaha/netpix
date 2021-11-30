import 'package:flutter/material.dart';
import 'package:netpix/widgets/header_page.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  const ProfilePage({required this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Profile"),
    );
  }
}
