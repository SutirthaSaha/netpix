import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/models/user.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/progress_widget.dart';

import 'edit_profile_page.dart';
import 'home_page.dart';

class ProfilePage extends StatefulWidget {
  final String userProfileId;

  const ProfilePage({required this.userProfileId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final String? currentOnlineUserId = currentUser?.id;

  createProfileTopView(){
    return FutureBuilder<DocumentSnapshot>(
      future: usersReference.doc(widget.userProfileId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData)
        {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data!);
        return Padding(
          padding: const EdgeInsets.all(17.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 45.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.url),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createColumns("posts", 0),
                            createColumns("followers", 0),
                            createColumns("following", 0),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            createButton(),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 13.0),
                child: Text(user.profileName, style: const TextStyle(fontSize: 18.0, color: Colors.black)),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(top: 3.0),
                child: Text(user.bio, style: const TextStyle(fontSize: 18.0, color: Colors.black87)),
              ),
            ],
          ),
        );
      },
    );
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Edit Profile", performAction: editUserProfile);
    }
  }

  Container createButtonTitleAndFunction({required String title, required Function performAction}){
    return Container(
      padding: const EdgeInsets.only(top: 3.0),
      child: TextButton(
        onPressed: ()=>{performAction()},
        child: Container(
          width: 200.0,
          height: 26.0,
          // child: Text(title, style: TextStyle(color: following? Colors.grey: Colors.white70, fontWeight: FontWeight.bold)),
          child: Text(title, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white70,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
      ),
    );
  }

  Column createColumns(String title, int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 20.0, color: Colors.black, fontWeight: FontWeight.bold),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }

  editUserProfile(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfilePage(currentOnlineUserId: currentOnlineUserId!,))).then((_) {
      setState(() {
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Profile"),
      body: ListView(
        children: <Widget>[
          createProfileTopView()
        ],
      ),
    );
  }
}
