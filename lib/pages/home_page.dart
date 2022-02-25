import 'dart:async';
import 'dart:convert';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';

import 'package:network_image_progres/models/user_model.dart';


import 'package:url_launcher/url_launcher.dart';


import '../services/http_servikes.dart';
import '../services/log_db_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  static const String id = 'home_page';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int categoryIndex = 0;
  bool loading = true;
  bool postLoading = false;
  String search = "All";
  bool isLoadMore = false;
  bool fulImageSheet = false;
  String? postData;
  int postIndex = 0;
  DateTime? backPostTime;



  List<UsersModels> usersModelsList = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();
  List<String> categories = ["All", "Football", "Google", "Tokyo", "Korea", "Dubai",];

  void getPhotos() {
    HttpServices.GET(HttpServices.API_LIST, HttpServices.paramsEmpty()).then((value) => {
      usersModelsList = List.from(HttpServices.parseUserModelLIst(value!)),

    loading = false,
      setState(() {

      }),
    });
  }

  void searchCategory(String category) {
    setState(() {
      isLoadMore = true;
    });
    HttpServices.GET(HttpServices.API_SEARCH,
        HttpServices.paramsSearch((usersModelsList.length ~/ 10) + 1, category))
        .then((value) => {
      usersModelsList
          .addAll(List.from(HttpServices.pareseSearchModelsList(value!))),
      Log.d(usersModelsList.length.toString()),
      setState(() {
        isLoadMore = false;
      }),
    });
  }


  @override
  void initState() {
    super.initState();
    getPhotos();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          extendBody: true,
          body:  loading ? Center(
            child: Lottie.asset('assets/anims/anim2.json'),
          )  :
          Stack(
            children: [

              /// Categort in Post

              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoadMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    searchCategory(search);
                    setState(() {});
                  }
                  return true;
                },
                child:   Column(

                  children: [
                    if (fulImageSheet) SizedBox.shrink() else Container(
                      alignment: Alignment.center,
                      height: 50,
                      child: ListView.builder(
                          padding: EdgeInsets.all(6),
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  usersModelsList.clear();
                                  search = categories[index];
                                  searchCategory(categories[index]);
                                  categoryIndex = index;
                                });
                              },
                              child: Container(
                               width: 75,
                                padding: EdgeInsets.all(12),
                                alignment: Alignment.center,
                                margin: EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: categoryIndex == index
                                      ? Colors.black
                                      : Colors.white,
                                ),
                                child: Text(
                                  categories[index],
                                  style: TextStyle(
                                      color: categoryIndex == index
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: categoryIndex == index ? 16 : 15),
                                ),
                              ),
                            );
                          }),
                    ),


                    /// BODY
                    Expanded(
                        child: MasonryGridView.count(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            controller: _scrollController,
                            itemCount: usersModelsList.length,
                            crossAxisCount: 2,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                            itemBuilder: (context, index) {
                              return postGridView(index);
                            }
                            ),
                    ),

                  ],
                ),
              ),

              /// FUll IMages BottomSHeetDragable

              (fulImageSheet) ? fullImagesPost(usersModelsList[postIndex]) : SizedBox.shrink(),

              (isLoadMore)  ?
             LinearProgressIndicator(
               minHeight: 8,
               color: Colors.red,
               backgroundColor: Colors.purpleAccent,
             )
              :SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  /// POST GRIDVIEW
  GestureDetector postGridView(int index) {
    return GestureDetector(

                            child: Column(
                              children: [
                                GestureDetector(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: GestureDetector(
                                      onTap: (){
                                       setState(() {
                                          fulImageSheet = true;
                                          postIndex =index;
                                      //   Navigator.push(context, MAteri)
                                      //   Navigator.of(context).push(MaterialPageRoute (builder: (BuildContext context) => DetailPage(usersModels: usersModelsList[index],)));

                                       });
                                      },
                                      child: CachedNetworkImage(
                                        fit: BoxFit.cover,
                                        imageUrl:
                                        usersModelsList[index].urls!.regular!,
                                        placeholder: (context, url) => Lottie.asset("assets/anims/anim1.json")
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    height: 40,
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        usersModelsList[index].altDescription != null
                                            ?  Flexible(
                                          child: Container(
                                            padding: EdgeInsets.only(left: 8),
                                            child: Text(
                                              usersModelsList[index].altDescription!,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        )

                                            :CircleAvatar(
                                          radius: 15,
                                          backgroundImage: NetworkImage(
                                              usersModelsList[index].user!.profileImage!.large!  ),
                                        ),

                                        IconButton(
                                          onPressed: () {
                                            bottomsheet(context, index);
                                          },
                                          icon: Icon(
                                            Icons.more_horiz,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ))
                              ],
                            )
                          );
  }
/// BOTOMSHEET
  Future<dynamic> bottomsheet(BuildContext context,int index) {
    return showModalBottomSheet(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return  Container(
                                                color: Theme.of(context).scaffoldBackgroundColor,
                                                child: Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        /// Cancel button
                                                        Row(
                                                          children: [
                                                            IconButton(
                                                              icon: Icon(
                                                                CupertinoIcons.clear,
                                                                size: 25,
                                                                color: Theme.of(context).primaryColor,
                                                              ),
                                                              onPressed: () {
                                                                Navigator.pop(context);
                                                              },
                                                            ),
                                                            TextButton(
                                                              style: TextButton.styleFrom(),
                                                              onPressed: () {},
                                                              child: Text(
                                                                "Share to",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Theme.of(context).primaryColor),
                                                              ),
                                                            ),
                                                          ],
                                                        ),


                                                        SizedBox(
                                                          height: 100,
                                                          child: ListView(
                                                            scrollDirection: Axis.horizontal,
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async{
                                                                        await launch("https://telegram.me/share/url?url=${Uri.encodeComponent(usersModelsList[index].urls!.full!)}");
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: const Image(
                                                                        fit: BoxFit.cover,
                                                                        image:
                                                                        AssetImage('assets/images/telegram.png'),
                                                                      )),
                                                                  const Text(
                                                                    "Telegram",
                                                                    style: TextStyle(fontSize: 12),
                                                                  )
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async{
                                                                        await launch("https://api.whatsapp.com/send?text=${Uri.encodeComponent(usersModelsList[index].urls!.full!)}");
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: const Image(
                                                                        fit: BoxFit.cover,
                                                                        image:
                                                                        AssetImage('assets/images/whatsapp.png'),
                                                                      )),
                                                                  const Text(
                                                                    "Whatsapp",
                                                                    style: TextStyle(fontSize: 12),
                                                                  )
                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async{
                                                                        HapticFeedback.vibrate();
                                                                        await launch("sms:?body=${Uri.encodeComponent(usersModelsList[index].urls!.full!)}");
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/message.png'),
                                                                      )),
                                                                  Text("Message",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: ()async {
                                                                        await launch("mailto:?subject=Flutter&body=${Uri.encodeComponent(usersModelsList[index].urls!.full!)}");
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/gmail.png'),
                                                                      )),
                                                                  Text("Gmail",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async {
                                                                        launch('https://facebook.com');
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/facebook.png'),
                                                                      )),
                                                                  Text("Facebook",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () {},
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/whatsapp.png'),
                                                                      )),
                                                                  Text("Twitter",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () async{
                                                                        await Clipboard.setData(ClipboardData(text: usersModelsList[index].urls!.full!));
                                                                        showToast(usersModelsList[index].urls!.full!);
                                                                      },
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/copy_link.png'),
                                                                      )),
                                                                  Text("Links",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                              Column(
                                                                children: [
                                                                  IconButton(
                                                                      onPressed: () {},
                                                                      iconSize: 60,
                                                                      icon: Image(
                                                                        fit: BoxFit.cover,
                                                                        image: AssetImage('assets/images/more.png'),
                                                                      )),
                                                                  Text("More",style: TextStyle(fontSize: 12),)

                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        /// Buttons
                                                        TextButton(
                                                            onPressed: () {},
                                                            child: Text("Download image",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Theme.of(context).primaryColor))),
                                                        TextButton(
                                                            onPressed: () {},
                                                            child: Text("Hide Pin",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Theme.of(context).primaryColor))),
                                                        TextButton(
                                                            onPressed: () {},
                                                            child: Text("Report Pin",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    color: Theme.of(context).primaryColor))),

                                                      ]
                                                  ),
                                                ),
                                              );
                                            },
                                          );
  }

 /// FULIMAGE

   fullImagesPost(UsersModels post) {
    return DraggableScrollableSheet(
        initialChildSize: 1,
        maxChildSize: 1,
        minChildSize: 1,
        builder: (context, scrollController) {
          return Container(
            color: Colors.black,
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoadMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      searchCategory(search);
                      setState(() {});
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,

                              /// IMAGES
                              child: Column(
                                children: [
                                  Stack(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: post.urls!.full!,
                                        placeholder: (context, url) =>
                                            AspectRatio(
                                                aspectRatio:
                                                post.width! / post.height!,
                                                child: Container(
                                                  child: Lottie.asset("assets/anims/anim1.json"),
                                                )
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              onPressed: () {},
                                              iconSize: 30,
                                              color: Colors.white,
                                              icon: Icon(
                                                  CupertinoIcons.ellipsis)),
                                        ],
                                      ),
                                    ],
                                  ),

                                  /// USERS NAME FOLLOWER
                                  Container(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CachedNetworkImage(
                                            imageUrl: post
                                                .user!.profileImage!.medium!,
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        (post.user!.totalLikes != null)
                                            ? post.user!.name!
                                            : "",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      subtitle: Text(
                                          "${(post.user!.totalLikes != null) ? post.user!.totalLikes! : 0} followers"),
                                      trailing: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(30),
                                          child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 15),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              child: Text(
                                                "Follow",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor),
                                              ))),
                                    ),
                                  ),

                                  /// DESCRIPTIONS
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    width: MediaQuery.of(context).size.width,
                                    alignment: AlignmentDirectional.center,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    child: Text(
                                      (post.description != null)
                                          ? post.description!
                                          : "",
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  /// Save
                                  Container(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: MediaQuery.of(context).size.width,
                                    padding:
                                    EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [

                                        IconButton(
                                            onPressed: () {},
                                            iconSize: 30,
                                            icon: Icon(CupertinoIcons
                                                .chat_bubble_fill)),

                                        Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                              BorderRadius.circular(30),
                                              color: Theme.of(context)
                                                  .primaryColor,
                                            ),
                                            margin: EdgeInsets.only(left: 40),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 25, vertical: 20),
                                            child: Text(
                                              "View",
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .scaffoldBackgroundColor),
                                            )),

                                        /// Save Button
                                        GestureDetector(
                                          onTap: () {
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                BorderRadius.circular(30),
                                                color: Colors.red.shade800,
                                              ),
                                              margin:
                                              EdgeInsets.only(right: 40),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 20),
                                              child: Text(
                                                "Save",
                                                style: TextStyle(
                                                    color: Colors.white),
                                              )),
                                        ),

                                        IconButton(
                                            onPressed: () {},
                                            iconSize: 30,
                                            icon: Icon(
                                              Icons.share,
                                            ))
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 20,
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),


                        Container(
                          height: 200,
                          padding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            children: [
                              Text(
                                "Share your feedback",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w600),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              TextField(
                                style: TextStyle(
                                    color: Colors.black,
                                    decoration: TextDecoration.none),
                                cursorColor: Colors.purpleAccent,
                                onSubmitted: (text) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    hintText: "Add a comment",
                                    hintStyle: TextStyle(
                                        color: Colors.green,
                                        decoration: TextDecoration.none),
                                    prefixIcon: Container(
                                      height: 20,
                                      width: 20,
                                      padding: EdgeInsets.all(5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(
                                            imageUrl: post
                                                .user!.profileImage!.medium!),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(15),
                                    border: InputBorder.none),
                              ),
                            ],
                          ),
                        ),


                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Column(
                                children: [
                                  Text(
                                    "MORE",
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  MasonryGridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    itemCount: usersModelsList.length,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemBuilder: (context, index) {
                                      return postGridView(index);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      setState(() {
                        fulImageSheet = false;
                      });
                    },
                    iconSize: 30,
                    color: Colors.white,
                    icon: Icon(CupertinoIcons.back)),
              ],
            ),
          );
        });
  }

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (backPostTime == null ||
        now.difference(backPostTime!) > Duration(seconds: 2)) {
      setState(() {
        backPostTime = now;
        fulImageSheet = false;
      });

      return Future.value(false);
    }
    return Future.value(true);
  }
  void showToast([String? clipboard]) {
    Fluttertoast.showToast(
        fontSize: 16,
        msg: (clipboard != null) ? clipboard : 'Downloaded successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black
    );
  }

}
