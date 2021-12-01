import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/models/user.dart';
import 'package:netpix/pages/home_page.dart';
import 'package:netpix/pages/profile_page.dart';
import 'package:netpix/widgets/progress_widget.dart';

class Post extends StatefulWidget {
  final String postId, ownerId, profileName, username, description, url;
  final dynamic likes;

  const Post({
    required this.postId,
    required this.ownerId,
    required this.username,
    required this.description,
    required this.url,
    this.likes,
    required this.profileName
  });

  factory Post.fromDocument(DocumentSnapshot documentSnapshot){
    return Post(
      postId: documentSnapshot["postId"],
      ownerId: documentSnapshot["ownerId"],
      likes: documentSnapshot["likes"],
      profileName: documentSnapshot["profileName"],
      username: documentSnapshot["username"],
      description: documentSnapshot["description"],
      url: documentSnapshot["url"],
    );
  }

  int getTotalNumberOfLikes(likes){
    if(likes == null){
      return 0;
    }

    int counter = 0;
    likes.values.forEach((eachValue){
      if(eachValue == true){
        counter++;
      }
    });
    return counter;
  }

  @override
  _PostState createState() => _PostState(
      postId: postId,
      ownerId: ownerId,
      profileName: profileName,
      username: username,
      description: description,
      url: url,
      likes: likes,
      likeCount: getTotalNumberOfLikes(this.likes)
  );
}

class _PostState extends State<Post> {

  late final String postId, ownerId, profileName, username, description, url;
  final String? currentOnlineUserId = currentUser?.id;
  bool showHeart = false;
  Map likes;
  int likeCount;
  late bool isLiked;

  _PostState({
    required this.postId,
    required this.ownerId,
    required this.profileName,
    required this.username,
    required this.description,
    required this.url,
    required this.likes,
    required this.likeCount
  });

  createPostHead(){
    return FutureBuilder<DocumentSnapshot>(
      future: usersReference.doc(ownerId).get(),
      builder: (context, dataSnapshot){
        if(!dataSnapshot.hasData)
        {
          return circularProgress();
        }
        User user = User.fromDocument(dataSnapshot.data!);
        bool isPostOwner = currentOnlineUserId == ownerId;

        return ListTile(
          leading: CircleAvatar(backgroundImage: CachedNetworkImageProvider(user.url), backgroundColor: Colors.grey),
          title: GestureDetector(
            onTap: ()=> displayUserProfile(context, profileId: user.id),
            child: Text(
              user.profileName,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
          trailing: isPostOwner? IconButton(icon: const Icon(Icons.more_vert, color: Colors.black,),
            // onPressed: ()=> controlPostDelete(context),
            onPressed: ()=>print("Delete"),
          ): const Text(""),
        );
      },
    );
  }

  displayUserProfile(BuildContext context, {required String profileId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(userProfileId: profileId)));
  }

  createPostPicture(){
    return GestureDetector(
      // onDoubleTap: ()=> controlUserPostLike(),
      onDoubleTap: ()=>print("Like"),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Image.network(url),
          showHeart? const Icon(Icons.favorite, size: 140.0, color: Colors.pinkAccent) : const Text("")
        ],
      ),
    );
  }

  createPostFooter(){
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 40.0, left: 20.0)),
            GestureDetector(
              // onTap: ()=> controlUserPostLike(),
              onTap: ()=>"Like",
              child: Icon(
                isLiked? Icons.favorite: Icons.favorite_border,
                size: 20.0,
                color: Colors.red,
              ),
            ),
            const Padding(padding: EdgeInsets.only(right: 20.0)),
            GestureDetector(
//              onTap: ()=> displayComments(context, postId: postId, ownerId: ownerId, url: url),
              onTap: ()=>print("comments"),
              child: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.black,
                size: 20.0,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '$likeCount likes',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20.0),
              child: Text(
                '$profileName ',
                style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Text(description, style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentOnlineUserId] == true);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          createPostHead(),
          createPostPicture(),
          createPostFooter()
        ],
      ),
    );
  }
}
