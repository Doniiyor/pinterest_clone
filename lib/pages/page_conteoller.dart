import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:network_image_progres/pages/chat_page.dart';
import 'package:network_image_progres/pages/home_page.dart';
import 'package:network_image_progres/pages/profile_page.dart';
import 'package:network_image_progres/pages/search_paged.dart';

import '../services/log_db_services.dart';

class PagesControllers extends StatefulWidget {
  const PagesControllers({Key? key}) : super(key: key);
  static const String id = 'pages_controllers';

  @override
  _PagesControllersState createState() => _PagesControllersState();
}

class _PagesControllersState extends State<PagesControllers> {
  int floatingIconIndex = 0;
  int pageIndex = 0;
  DateTime? backPostTime;
  PageController _pageController = PageController();
  bool online = false;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      Log.e(
        'Couldn\'t check connectivity status',
      );
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    if(_connectionStatus == ConnectivityResult.none){
      setState(() {
        online = true;
      });
    }

    else {
      setState(() {
        online = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _connectivitySubscription.cancel();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: online ?   Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           Lottie.asset("assets/anims/conect2.json",width: 150),
            const SizedBox(height: 15),
            const Text(
              "No Internet Connection",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      )
      :PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        onPageChanged: (index){
        },
        children: [
          HomePage(key: PageStorageKey("Home"),),
          SearchPage(key: PageStorageKey("Search"),),
          ChatPage(),
          ProfilePage(key: PageStorageKey("Profile")),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (online) ? null:
      Container(
      //  height: MediaQuery.of(context).size.height*0.085,
        width: MediaQuery.of(context).size.width*0.7,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          color: Colors.white
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.03,), /*  left: MediaQuery.of(context).size.width*0.05,right: MediaQuery.of(context).size.width*0.11, ), */
        child: BottomNavigationBar  (
          currentIndex:floatingIconIndex,
          onTap: (index){
            setState(() {
              floatingIconIndex = index;
           _pageController.jumpToPage(index);
            //  _pageController.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.easeIn);
            });
          },
          elevation: 0,
          backgroundColor: Colors.transparent,
         showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 20,
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem  (icon: Icon(Icons.home,color:  Colors.grey,size: 25), label: "",activeIcon:Icon(Icons.home,color:  Colors.black,size: 28,), ),
            BottomNavigationBarItem(icon: Icon(Icons.search,color: Colors.grey,size: 25,), label: "",activeIcon: Icon(Icons.search,color:  Colors.black,size: 28,),),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.chat_bubble_text_fill,color: Colors.grey,size: 23,), label: "",activeIcon: Icon(CupertinoIcons.chat_bubble_text_fill,color:  Colors.black,size: 25,),),
            BottomNavigationBarItem(icon: Icon(Icons.person,color: Colors.grey,size: 25,), label: "",activeIcon: Icon(Icons.person,color:  Colors.black,size: 28,),),
          ],

        ),
      ),
    );
  }


}
