import 'package:flutter/material.dart';

Widget showSearchBar(TextEditingController searchController, String searchText, {dynamic function}) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: TextField(
      style: const TextStyle(
          color: Colors.black, fontSize: 20.0, 
          // fontFamily: "DIN",
          ),
      controller: searchController,
      onChanged: function,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: searchText,
      ),
    ),
  );
}