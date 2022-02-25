import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:network_image_progres/pages/updates.dart';
import 'package:network_image_progres/services/http_servikes.dart';

import '../models/colections_model.dart';
import 'messages.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({Key? key}) : super(key: key);
  static const String id = "chat_page";

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  int selectedCategory = 0;
  List<Collections> collections = [];
  bool isLoading = true;

  void getCollections() async {
    await HttpServices.GET(HttpServices.API_COLLECTIONS, HttpServices.paramsEmpty())
        .then((response) => {
      _getResponse(response!),
      setState(() {
        isLoading = false;
      })
    });
  }

  void _getResponse(String response) {
    setState(() {
      collections = HttpServices.parseCollectionResponse(response);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCollections();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 10,
            backgroundColor: Colors.transparent,
            elevation: 0,
            bottom: TabBar(
              indicatorColor: Theme.of(context).scaffoldBackgroundColor,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.18),
              onTap: (index) {
                setState(() {
                  selectedCategory = index;
                });
              },
              tabs: [
                /// Update Button
                Tab(
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: (selectedCategory == 0)
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Text(
                          "Updates",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: (selectedCategory == 0)
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).primaryColor,
                          ),
                        ))),

                /// Inbox Button
                Tab(
                    child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: (selectedCategory == 1)
                              ? Theme.of(context).primaryColor
                              : Theme.of(context).scaffoldBackgroundColor,
                        ),
                        child: Text(
                          "Inbox",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: (selectedCategory == 1)
                                ? Theme.of(context).scaffoldBackgroundColor
                                : Theme.of(context).primaryColor,
                          ),
                        ))),
              ],
            ),
          ),
          body: (isLoading)
              ? Center(
              child: Lottie.asset('assets/anims/anim1.json', width: 100))
              : Padding(
            padding: const EdgeInsets.all(8.0),
            child:
            TabBarView(physics: NeverScrollableScrollPhysics(), children: [
              ListView.builder(
                itemBuilder: (context, index) {
                  return UpdatePage(collection: collections[index]);
                },
                itemCount: collections.length,
                padding: const EdgeInsets.only(top: 10),
              ),
              MessagePage(),
            ]),
          )),
    );
  }
}