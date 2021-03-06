import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:flutter/material.dart";
import 'package:netpix/models/user.dart';
import 'package:netpix/widgets/progress_widget.dart';

import 'home_page.dart';

class EditProfilePage extends StatefulWidget {
  final String currentOnlineUserId;

  EditProfilePage({required this.currentOnlineUserId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  TextEditingController profileNameTextEditingController = TextEditingController();
  TextEditingController bioTextEditingController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool loading = false;
  User? user;
  bool _bioValid = true;
  bool _profileNameValid = true;

  @override
  void initState(){
    super.initState();

    getAndDisplayUserInformation();
  }

  getAndDisplayUserInformation() async{
    setState(() {
      loading = true;
    });

    DocumentSnapshot documentSnapshot = await usersReference.doc(widget.currentOnlineUserId).get();
    user = User.fromDocument(documentSnapshot);

    profileNameTextEditingController.text = user!.profileName;
    bioTextEditingController.text = user!.bio;

    setState(() {
      loading = false;
    });
  }

  updateUserData(){
    setState(() {
      profileNameTextEditingController.text.trim().length < 3 || profileNameTextEditingController.text.isEmpty ? _profileNameValid = false : _profileNameValid = true;
      bioTextEditingController.text.trim().length > 110 ? _bioValid = false : _bioValid = true;
    });

    if(_bioValid && _profileNameValid){
      usersReference.doc(widget.currentOnlineUserId).update({
        "profileName": profileNameTextEditingController.text,
        "bio": bioTextEditingController.text
      });

      SnackBar snackBar = const SnackBar(content: Text("Profile has been updated"));
      _scaffoldKey.currentState!.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        // actions: <Widget>[
        //   IconButton(icon: const Icon(Icons.done, color: Colors.black, size: 30.0), onPressed: ()=> Navigator.pop(context))
        // ],
      ),
      body: loading? circularProgress() : ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 15.0, bottom: 7.0),
                  child: CircleAvatar(
                    radius: 52.0,
                    backgroundImage: CachedNetworkImageProvider(user!.url),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(children: <Widget>[createProfileNameTextFormField(),createBioTextFormField()],),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 29.0, right: 50.0, left: 50.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.green,
                      onPressed: updateUserData,
                      child: const Text(
                        "Update",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 29.0, right: 50.0, left: 50.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: RaisedButton(
                      color: Colors.red,
                      onPressed: logoutUser,
                      child: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }


  logoutUser() async {
    await gSignIn.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => const HomePage(),
      ),
          (route) => false,
    );
  }

  Column createProfileNameTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Profile Name", style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: profileNameTextEditingController,
          decoration: InputDecoration(
              hintText: "Write profile name here...",
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
              ),
              hintStyle: const TextStyle(color: Colors.grey),
              errorText: _profileNameValid? null: "Profile name is too short"
          ),
        )
      ],
    );
  }

  Column createBioTextFormField(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.only(top: 13.0),
          child: Text(
            "Bio", style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          style: const TextStyle(color: Colors.black),
          controller: bioTextEditingController,
          keyboardType: TextInputType.multiline,
          maxLines: null,
          maxLength: 110,
          decoration: InputDecoration(
              hintText: "Write your bio here...",
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey)
              ),
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.black)
              ),
              hintStyle: const TextStyle(color: Colors.grey),
              errorText: _bioValid? null: "Bio is too long"
          ),
        )
      ],
    );
  }
}
