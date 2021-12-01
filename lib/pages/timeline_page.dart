import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart';
import 'package:netpix/models/user.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/post_widget.dart';
import 'package:netpix/widgets/progress_widget.dart';

import 'home_page.dart';

class TimelinePage extends StatefulWidget {
  final User gCurrentUser;

  TimelinePage({required this.gCurrentUser});


  @override
  _TimelinePageState createState() => _TimelinePageState();
}

class _TimelinePageState extends State<TimelinePage> {
  List<Post> posts = [];
  List<String> followingsList = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  retrieveTimeline() async {
    QuerySnapshot querySnapshot = await timelineReference.doc(widget.gCurrentUser.id).collection("timelinePosts").orderBy("timestamp", descending: true).get();
    // List<Post> allPosts = querySnapshot.docs.map((document) => Post.fromDocument(document)).toList();
    List<Post> allPosts = [];
    for(DocumentSnapshot document in querySnapshot.docs){
      await postsReference.doc(document['ownerId']).collection("userPosts").doc(document['postId']).get().then((post) => {
        if(post.exists){
          allPosts.add(Post.fromDocument(post))
        }
      });
    }
    setState(() {
      posts = allPosts;
    });
  }

  retrieveFollowings() async {
    QuerySnapshot querySnapShot = await followingReference.doc(currentUser!.id).collection("userFollowing").get();

    setState(() {
      followingsList = querySnapShot.docs.map((document) => document.id).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    retrieveTimeline();
    retrieveFollowings();
  }

  createUserTimeline(){
    if(posts == null){
      return circularProgress();
    }
    else{
      return ListView(children: posts);
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(context, isAppTitle: true),
      body: RefreshIndicator(child: createUserTimeline(), onRefresh: ()=> retrieveTimeline()),
    );
  }
}
