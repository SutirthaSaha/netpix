import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/models/user.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/post_tile_widget.dart';
import 'package:netpix/widgets/post_widget.dart';
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
  String postOrientation = "grid";
  bool loading = false;
  int countPost = 0;
  List<Post> postsList = [];
  int countTotalFollowers = 0;
  int countTotalFollowing = 0;
  bool following = false;

  @override
  void initState(){
    super.initState();
    getAllProfilePosts();
    getAllFollowers();
    getAllFollowing();
    checkIfAlreadyFollowing();
  }

  getAllFollowers() async{
    QuerySnapshot querySnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .get();

    setState(() {
      countTotalFollowers = querySnapshot.docs.length;
    });
  }

  getAllFollowing() async{
    QuerySnapshot querySnapshot = await followingReference
        .doc(widget.userProfileId)
        .collection("userFollowing")
        .get();

    setState(() {
      countTotalFollowing = querySnapshot.docs.length;
    });
  }

  checkIfAlreadyFollowing() async{
    DocumentSnapshot documentSnapshot = await followersReference
        .doc(widget.userProfileId)
        .collection("userFollowers")
        .doc(currentOnlineUserId)
        .get();

    setState(() {
      following = documentSnapshot.exists;
    });
  }


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
                            createColumns("posts", countPost),
                            createColumns("followers", countTotalFollowers),
                            createColumns("following", countTotalFollowing),
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

  controlUnfollowUser(){
    setState(() {
      following = false;
    });

    followersReference.doc(widget.userProfileId).collection("userFollowers").doc(currentOnlineUserId).get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });

    followingReference.doc(currentOnlineUserId).collection("userFollowing").doc(widget.userProfileId).get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });

    activityFeedReference.doc(widget.userProfileId).collection("feedItems").doc(currentOnlineUserId).get().then((document){
      if(document.exists){
        document.reference.delete();
      }
    });
  }

  controlFollowUser(){
    setState(() {
      following = true;
    });

    followersReference.doc(widget.userProfileId).collection("userFollowers").doc(currentOnlineUserId).set({

    });

    followingReference.doc(currentOnlineUserId).collection("userFollowing").doc(widget.userProfileId).set({

    });

    activityFeedReference.doc(widget.userProfileId).collection("feedItems").doc(currentOnlineUserId).set({
      "type": "follow",
      "ownerId": widget.userProfileId,
      "profileName": currentUser!.profileName,
      "timestamp": DateTime.now(),
      "userProfileImg": currentUser!.url,
      "userId": currentOnlineUserId
    });
  }

  createButton() {
    bool ownProfile = currentOnlineUserId == widget.userProfileId;
    if (ownProfile) {
      return createButtonTitleAndFunction(
          title: "Edit Profile", performAction: editUserProfile);
    }
    else if(following){
      return createButtonTitleAndFunction(title: "Unfollow", performAction: controlUnfollowUser);
    }
    else if(!following){
      return createButtonTitleAndFunction(title: "Follow", performAction: controlFollowUser);
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

  setOrientation(String orientation){
    setState(() {
      postOrientation = orientation;
    });
  }

  createListAndGridPostOrientation(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          onPressed: ()=> setOrientation("grid"),
          icon: const Icon(Icons.grid_on),
          color: postOrientation == "grid"? Theme.of(context).primaryColor : Colors.grey,
        ),
        IconButton(
          onPressed: ()=> setOrientation("list"),
          icon: const Icon(Icons.list),
          color: postOrientation == "list"? Theme.of(context).primaryColor : Colors.grey,
        ),
      ],
    );
  }

  displayProfilePost(){
    if(loading){
      return circularProgress();
    }
    else if(postsList.isEmpty){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const <Widget>[
          Padding(
            padding: EdgeInsets.all(30.0),
            child: Icon(Icons.photo_library, color: Colors.grey, size: 200.0),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text("No Posts", style: TextStyle(fontSize: 40.0, color: Colors.redAccent, fontWeight: FontWeight.bold)),
          )
        ],
      );
    }
    else if(postOrientation == "grid"){
      List<GridTile> gridTilesList = [];
      for (var eachPost in postsList) {
        gridTilesList.add(GridTile(child: PostTile(post: eachPost)));
      }
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: gridTilesList,
      );
    }
    else if(postOrientation == "list"){
      return Column(
        children: postsList,
      );
    }
  }

  getAllProfilePosts() async{
    setState(() {
      loading = true;
    });

    QuerySnapshot querySnapshot = await postsReference.doc(widget.userProfileId).collection("userPosts").orderBy("timestamp", descending: true).get();
    setState(() {
      loading = false;
      countPost = querySnapshot.docs.length;
      postsList = querySnapshot.docs.map((documentSnapshot) => Post.fromDocument(documentSnapshot)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Profile"),
      body: ListView(
        children: <Widget>[
          createProfileTopView(),
          const Divider(),
          createListAndGridPostOrientation(),
          const Divider(height: 0.0,),
          displayProfilePost()
        ],
      ),
    );
  }
}
