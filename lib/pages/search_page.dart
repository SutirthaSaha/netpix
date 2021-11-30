import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:netpix/models/user.dart';
import 'package:netpix/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:netpix/pages/profile_page.dart';
import 'package:netpix/widgets/progress_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with AutomaticKeepAliveClientMixin<SearchPage>{
  TextEditingController searchTextEditingController = TextEditingController();
  Future<QuerySnapshot>? futureSearchResults;

  controlSearching(String str){
    Future<QuerySnapshot> allUsers = usersReference.where("profileName", isGreaterThanOrEqualTo: str).get();
    setState(() {
      futureSearchResults = allUsers;
    });
  }

  emptyTextFormField(){
    searchTextEditingController.clear();
  }

  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.white,
      title: TextFormField(
        style: const TextStyle(fontSize: 18.0, color: Colors.black),
        controller: searchTextEditingController,
        decoration: InputDecoration(
            hintText: "Search here...",
            hintStyle: const TextStyle(color: Colors.grey),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)
            ),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)
            ),
            filled: true,
            prefixIcon: const Icon(Icons.person_pin, color: Colors.black, size: 30.0),
            suffixIcon: IconButton(icon: const Icon(Icons.clear, color: Colors.black,), onPressed: emptyTextFormField)
        ),
        onFieldSubmitted: controlSearching,
      ),
    );
  }

  Widget displayNoSearchResultScreen(){
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: const [
          Icon(Icons.group, color: Colors.grey, size: 200.0),
          Text(
            "Search Users",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 50.0),
          )
        ],
      ),
    );
  }

  displayUsersFoundScreen(){
    return FutureBuilder<QuerySnapshot>(
      future: futureSearchResults,
      builder: (context, dataSnapshot)
      {
        if(!dataSnapshot.hasData)
        {
          return circularProgress();
        }

        List<UserResult> searchUserResult = [];

        List<DocumentSnapshot> users = dataSnapshot.data!.docs;
        for(DocumentSnapshot document in users){
          User eachUser = User.fromDocument(document);
          UserResult userResult = UserResult(eachUser);
          searchUserResult.add(userResult);
        }
        return ListView(children: searchUserResult);
      },
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchPageHeader(),
      body: futureSearchResults==null? displayNoSearchResultScreen() : displayUsersFoundScreen(),
    );
  }
}

class UserResult extends StatelessWidget {

  final User eachUser;

  const UserResult(this.eachUser);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        color: Colors.black54,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: () => displayUserProfile(context, profileId: eachUser.id),
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.white, backgroundImage: CachedNetworkImageProvider(eachUser.url),),
                title: Text(eachUser.profileName, style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  displayUserProfile(BuildContext context, {required String profileId}) {
    Navigator.push(context, MaterialPageRoute(builder: (context)=> ProfilePage(userProfileId: profileId)));
  }
}