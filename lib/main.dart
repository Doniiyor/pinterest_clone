import 'package:flutter/material.dart';
import 'package:network_image_progres/pages/chat_page.dart';
import 'package:network_image_progres/pages/detail_page.dart';
import 'package:network_image_progres/pages/home_page.dart';
import 'package:network_image_progres/pages/page_conteoller.dart';
import 'package:network_image_progres/pages/profile_page.dart';
import 'package:network_image_progres/pages/search_paged.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home:
      PagesControllers(),
      routes: {
        PagesControllers.id: (context) => PagesControllers(),
        HomePage.id: (context) => HomePage(),
        SearchPage.id: (context) => SearchPage(),
        ChatPage.id: (context) => ChatPage(),
        ProfilePage.id: (context) => ProfilePage(),
      },
    );
  }
}
