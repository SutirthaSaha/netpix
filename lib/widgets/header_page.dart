import 'package:flutter/material.dart';


AppBar header(context, {bool isAppTitle = false, String strTitle = "", disableBackButton = false}) {
  return AppBar(
    iconTheme: const IconThemeData(
        color: Colors.black
    ),
    automaticallyImplyLeading: disableBackButton ? false : true,
    title: Text(
      isAppTitle? 'NetPix': strTitle,
      style: TextStyle(
          color: Colors.black,
          fontFamily: isAppTitle? "GrandHotel": "",
          fontSize: isAppTitle? 45.0 : 22.0
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).colorScheme.primary,
  );
}
