import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:netpix/pages/post_screen_page.dart';
import 'package:netpix/pages/profile_page.dart';
import 'package:netpix/widgets/header_page.dart';
import 'package:netpix/widgets/progress_widget.dart';
import 'package:timeago/timeago.dart' as tAgo;
import 'home_page.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, strTitle: "Notifications"),
      body: FutureBuilder<dynamic>(
        future: retrieveNotifications(),
        builder: (context, dataSnapshot){
          if(!dataSnapshot.hasData){
            return circularProgress();
          }
          return ListView(children: dataSnapshot.data!);
        },
      ),
    );
  }

  retrieveNotifications() async{
    QuerySnapshot querySnapshot = await activityFeedReference.doc(currentUser!.id)
        .collection("feedItems").orderBy("timestamp", descending: true)
        .limit(60).get();

    List<NotificationsItem> notificationsItem = [];

    for (var document in querySnapshot.docs) {
      NotificationsItem notificationItem = NotificationsItem.fromDocument(document);
      notificationsItem.add(notificationItem);
    }
    return notificationsItem;
  }
}

String? notificationItemText;
Widget? mediaPreview;

class NotificationsItem extends StatelessWidget {
  final String profileName;
  final String type;
  final String? commentData;
  final String postId;
  final String userId;
  final String userProfileImg;
  final String url;
  final Timestamp timestamp;

  NotificationsItem({
    required this.profileName,
    required this.type,
    this.commentData,
    required this.postId,
    required this.userId,
    required this.userProfileImg,
    required this.url,
    required this.timestamp
  });

  factory NotificationsItem.fromDocument(DocumentSnapshot documentSnapshot){
    return NotificationsItem(
      profileName: documentSnapshot["profileName"],
      type: documentSnapshot["type"],
      // commentData: documentSnapshot["commentData"],
      url: documentSnapshot["url"],
      postId: documentSnapshot["postId"],
      userId: documentSnapshot["userId"],
      userProfileImg: documentSnapshot["userProfileImg"],
      timestamp: documentSnapshot["timestamp"],
    );
  }


  @override
  Widget build(BuildContext context) {
    configureMediaPreview(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.0),
      child: Container(
        color: Colors.white,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=> displayUserProfile(context, profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                  style: const TextStyle(fontSize: 14.0, color: Colors.black),
                  children: [
                    TextSpan(text: profileName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "$notificationItemText")
                  ]
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          subtitle: Text(tAgo.format(timestamp.toDate()), overflow: TextOverflow.ellipsis,),
          trailing: mediaPreview,
        ),
      ),
    );
  }

  configureMediaPreview(context){
    if(type == "comment" || type == "like"){
      mediaPreview = GestureDetector(
        onTap: ()=> displayFullPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
            aspectRatio: 16/9,
            child: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(fit: BoxFit.cover, image: CachedNetworkImageProvider(url))
              ),
            ),
          ),
        ),
      );
    }
    else{
      mediaPreview = const Text("");
    }
    if(type == "like"){
      notificationItemText = " liked your post";
    }
    else if(type == "comment"){
      notificationItemText = " replied $commentData";
    }
    else  if(type == "follow"){
      notificationItemText = " started following you";
    }
    else{
      notificationItemText = "Error, unknown type = $type";
    }
  }
  displayFullPost(BuildContext context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=> PostScreenPage(userId: currentUser!.id, postId: postId)));
  }

  displayUserProfile(BuildContext context, {required String profileId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(userProfileId: profileId)));
  }
}
