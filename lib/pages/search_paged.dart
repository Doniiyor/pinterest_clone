import 'dart:io';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:lottie/lottie.dart';
import 'package:network_image_progres/models/user_model.dart';
import 'package:network_image_progres/services/http_servikes.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:http/http.dart' as http;

import '../services/log_db_services.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  static const String id = "search_page";

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<UsersModels> userModels = [];
  bool isLoadMore = false;
  bool showDraggableSheet = false;
  int selectedPost = 0;
  String searchedCategory = 'All';
  DateTime? currentBackPressTime;
  double downloadPercent = 0;
  bool showDownloadIndicator = false;

  List<String> categories = [ "Football", "technology",  "Hollywood", "Kremlin"];

  TextEditingController textEditingController = TextEditingController();

  /// Search Images by Category
  void searchCategory(String category) {
    setState(() {
      isLoadMore = true;
    });
    HttpServices.GET(HttpServices.API_SEARCH,
        HttpServices.paramsSearch((userModels.length ~/ 10) + 1, category))
        .then((value) => {
      userModels
          .addAll(List.from(HttpServices.pareseSearchModelsList(value!))),
      Log.w(userModels.length.toString()),
      setState(() {
        isLoadMore = false;
      }),
    });
  }

  void downloadFile(String url,String filename) async {
    var permission = await _getPermission(Permission.storage);
    try{
      if(permission != false){

        var httpClient = http.Client();
        var request = http.Request('GET', Uri.parse(url));
        var res = httpClient.send(request);
        final response = await get(Uri.parse(url));
        Directory generalDownloadDir = Directory('/storage/emulated/0/Download');
        List<List<int>> chunks = [];
        int downloaded = 0;

        res.asStream().listen((http.StreamedResponse r) {
          r.stream.listen((List<int> chunk) {
            // Display percentage of completion

            setState(() {
              chunks.add(chunk);
              downloaded += chunk.length;
              showDownloadIndicator = true;
              downloadPercent = downloaded / r.contentLength!;
              debugPrint(downloadPercent.toString());

            });
          }, onDone: () async {
            // Display percentage of completion
            debugPrint('downloadPercentage: ${downloaded / r.contentLength! * 100}');

            setState(() {
              downloadPercent = 0;
              showDownloadIndicator = false;
              showToast();
            });
            // Save the file
            File imageFile = File("${generalDownloadDir.path}/$filename.jpg");
            Log.w(generalDownloadDir.path);
            await imageFile.writeAsBytes(response.bodyBytes);
            return;
          });
        });
      }
      else {
        Log.i("Permission Denied");
      }
    }
    catch(e){
      Log.e(e.toString());
    }
  }


  Future<bool> _getPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();

      if (result == PermissionStatus.granted) {
        return true;
      } else {
        Log.w(result.toString());
        return false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Scaffold(
          appBar: (showDraggableSheet) ? null : searchWidget(context),
          body: (userModels.isNotEmpty)
              ? Stack(
            children: [
              /// NotificationListener work when User reach last post

              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoadMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    searchCategory(textEditingController.text);
                    // start loading data
                    setState(() {});
                  }
                  return true;
                },
                child: MasonryGridView.count(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: userModels.length,
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  itemBuilder: (context, index) {
                    return postItems(index);
                  },
                ),
              ),
              /// DraggableScrollSheet
              (showDraggableSheet)
                  ? draggableScrollableSheet(userModels[selectedPost])
                  : SizedBox.shrink(),
              /// Lottie_Loading appear when User reach last post and start Load More

              isLoadMore ?
              LinearProgressIndicator(
                color: Colors.pink,
                backgroundColor: Colors.green,
              )
                  : SizedBox.shrink(),
            ],
          )
              : Stack(
            children: [


              NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollInfo) {
                  if (!isLoadMore &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    searchCategory(textEditingController.text);
                    // start loading data
                    setState(() {});
                  }
                  return true;
                },
                child: Column(
                  children: [
                    SizedBox(height: 20,),

                    Text('Ideas for you',style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10,),

                    GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          childAspectRatio: 2,
                        ),
                        itemCount: categories.length,
                        itemBuilder: (context, index){
                          return GestureDetector(
                            onTap: (){
                              userModels.clear();
                              searchedCategory = categories[index];
                              searchCategory(categories[index]);
                              selectedPost = index;
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: AssetImage("assets/images/pic$index.jpg")
                                  )
                              ),
                            ),
                          );
                        }
                    ),



                  ],
                ),
              ),

            ],
          )
        ),
      ),
    );
  }

  /// Search Widget
  PreferredSize searchWidget(BuildContext context) {
    return PreferredSize(
        child: Container(
          margin: EdgeInsets.only(top: 10, right: 10, left: 10, bottom: 10),
          decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(30)),

          /// TextField Search
          child: TextField(
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyText2!.color,
                decoration: TextDecoration.none),
            cursorColor: Theme.of(context).textTheme.bodyText2!.color,
            controller: textEditingController,
            onSubmitted: (text) {
              setState(() {
                userModels.clear();
                textEditingController.text = text.trim();
                searchCategory(text.trim().toString());
              });
            },
            decoration: InputDecoration(
                hintText: "Search for ideas",
                hintStyle: TextStyle(
                    color: Colors.grey.shade700,
                    decoration: TextDecoration.none),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 30,
                  color: Colors.blue,
                ),
                suffixIcon: Icon(
                  CupertinoIcons.camera_fill,
                  size: 30,
                  color: Colors.blue,
                ),
                contentPadding: EdgeInsets.all(15),
                border: InputBorder.none),
          ),
        ),
        preferredSize: Size(double.infinity, 80));
  }

  /// DraggableSheet
  DraggableScrollableSheet draggableScrollableSheet(UsersModels post) {
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
                /// Full view
                NotificationListener<ScrollNotification>(

                  onNotification: (ScrollNotification scrollInfo) {
                    if (!isLoadMore &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      searchCategory(searchedCategory);
                      // start loading data
                      setState(() {});
                    }
                    return true;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /// ClipRect (Image,user info)
                        Container(
                          padding: EdgeInsets.only(bottom: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Column(
                                children: [
                                  /// Image full
                                  Stack(
                                    children: [
                                      /// Image Full
                                      CachedNetworkImage(
                                        imageUrl: post.urls!.full!,
                                        placeholder: (context, url) => AspectRatio(
                                            aspectRatio: post.width! / post.height!,
                                            child: Lottie.asset("assets/anims/anim4.json")
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                      /// Button more horiz
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: [
                                          IconButton(
                                              onPressed: () {},
                                              iconSize: 30,
                                              color: Colors.white,
                                              icon: Icon(CupertinoIcons.ellipsis)),
                                        ],
                                      ),
                                    ],
                                  ),

                                  /// ListTile => Name, followers count,
                                  Container(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    child: ListTile(
                                      leading: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: SizedBox(
                                          height: 50,
                                          width: 50,
                                          child: CachedNetworkImage(
                                            imageUrl:
                                            post.user!.profileImage!.medium!,
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
                                          borderRadius: BorderRadius.circular(30),
                                          child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 15),
                                              color: Theme.of(context).primaryColor,
                                              child: Text(
                                                "Follow",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .scaffoldBackgroundColor),
                                              ))),
                                    ),
                                  ),

                                  /// Image Description
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 20),
                                    width: MediaQuery.of(context).size.width,
                                    alignment: AlignmentDirectional.center,
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    child: Text(
                                      (post.description != null)
                                          ? post.description!
                                          : "",
                                      style: TextStyle(fontSize: 18),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),

                                  /// Save and view button
                                  Container(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        /// Message button
                                        IconButton(
                                            onPressed: () {},
                                            iconSize: 30,
                                            icon: Icon(
                                                CupertinoIcons.chat_bubble_fill)),

                                        /// View Button
                                        Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(30),
                                              color: Theme.of(context).primaryColor,
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
                                          onTap: (){
                                            downloadFile(post.links!.download!,"${post.user!.name}${Random().nextInt(10)}");
                                          },
                                          child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(30),
                                                color: Colors.red.shade800,
                                              ),
                                              margin: EdgeInsets.only(right: 40),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 25, vertical: 20),
                                              child: Text(
                                                "Save",
                                                style: TextStyle(color: Colors.white),
                                              )),
                                        ),

                                        /// Share Button
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
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                        /// Feedback
                        Container(
                          height: 200,
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
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
                                    color: Theme.of(context).textTheme.bodyText2!.color,
                                    decoration: TextDecoration.none),
                                cursorColor: Theme.of(context).textTheme.bodyText2!.color,
                                onSubmitted: (text) {
                                  setState(() {});
                                },
                                decoration: InputDecoration(
                                    hintText: "Add a comment",
                                    hintStyle: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        decoration: TextDecoration.none),
                                    prefixIcon: Container(
                                      height: 20,
                                      width: 20,
                                      padding: EdgeInsets.all(5),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: CachedNetworkImage(imageUrl: post.user!.profileImage!.medium!),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(15),
                                    border: InputBorder.none),
                              ),

                            ],
                          ),
                        ),
                        /// More like this /// Posts
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 5),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              color: Theme.of(context).scaffoldBackgroundColor,
                              child: Column(
                                children: [
                                  Text("More like this",style: TextStyle(fontSize: 22,fontWeight: FontWeight.w600),),
                                  MasonryGridView.count(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    itemCount: userModels.length,
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 10,
                                    mainAxisSpacing: 10,
                                    itemBuilder: (context, index) {
                                      return postItems(index);
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
                        showDraggableSheet = false;
                      });
                    },
                    iconSize: 30,
                    color: Colors.white,
                    icon: Icon(CupertinoIcons.back)),
                (showDownloadIndicator) ? Align(
                  alignment: Alignment.topCenter,
                  child: CircularPercentIndicator(
                    animateFromLastPercent: true,
                    progressColor: Colors.green,
                    backgroundColor: Colors.grey.shade200,
                    percent: downloadPercent,
                    radius: 30.0,
                    lineWidth: 8.0,
                    circularStrokeCap: CircularStrokeCap.round,
                    center: Text(
                      "${(downloadPercent * 100).toInt()} %",
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 16.0,color: Colors.white),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ) : const SizedBox.shrink(),

              ],
            ),
          );
        });
  }

  /// Post Items
  Widget postItems(int index) {
    return Column(
      children: [
        /// Image

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GestureDetector(
            onTap: (){
              setState(() {
                showDraggableSheet = true;
                selectedPost = index;
                searchedCategory = textEditingController.text;
              });

            },
            child: CachedNetworkImage(
              imageUrl: userModels[index].urls!.regular!,
              imageBuilder: (context, imageProvider) => Image(
                  image: CachedNetworkImageProvider(
                      userModels[index].urls!.regular!)),
              placeholder: (context, url) => AspectRatio(
                  aspectRatio:
                  userModels[index].width! / userModels[index].height!,
                  child: Lottie.asset("assets/anims/anim4.json"),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
        ),

        /// Description or Profile Image
        Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              (userModels[index].altDescription != null)
                  ? Flexible(
                child: Text(
                  userModels[index].altDescription!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: CachedNetworkImage(
                  imageUrl: userModels[index].user!.profileImage!.small!,
                ),
              ),
              IconButton(onPressed: () {
                buildShowModalBottomSheet(context, index);
              }, icon: Icon(Icons.more_horiz))
            ],
          ),
        )
      ],
    );
  }

  /// BottomSheet
  Future<dynamic> buildShowModalBottomSheet(BuildContext context,int index) {
    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
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

                    /// Send Via Social Networks and othes
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    await launch("https://telegram.me/share/url?url=${Uri.encodeComponent(userModels[index].urls!.full!)}");
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
                                    await launch("https://api.whatsapp.com/send?text=${Uri.encodeComponent(userModels[index].urls!.full!)}");
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
                                    await launch("sms:?body=${Uri.encodeComponent(userModels[index].urls!.full!)}");
                                  },
                                  iconSize: 60,
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    image:
                                    AssetImage('assets/images/message.png'),
                                  )),
                              const Text(
                                "Message",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    await launch("mailto:?subject=Flutter&body=${Uri.encodeComponent(userModels[index].urls!.full!)}");
                                  },
                                  iconSize: 60,
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/images/gmail.png'),
                                  )),
                              const Text(
                                "Gmail",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () {
                                    launch('https://facebook.com');
                                  },
                                  iconSize: 60,
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    image:
                                    AssetImage('assets/images/facebook.png'),
                                  )),
                              const Text(
                                "Facebook",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () async{
                                    await Clipboard.setData(ClipboardData(text: userModels[index].urls!.full!));
                                    showToast(userModels[index].urls!.full!);
                                  },
                                  iconSize: 60,
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage(
                                        'assets/images/copy_link.png'),
                                  )),
                              const Text(
                                "Links",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              IconButton(
                                  onPressed: () {},
                                  iconSize: 60,
                                  icon: const Image(
                                    fit: BoxFit.cover,
                                    image: AssetImage('assets/images/more.png'),
                                  )),
                              const Text(
                                "More",
                                style: TextStyle(fontSize: 12),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// Buttons
                    TextButton(
                        onPressed: () {
                          downloadFile(userModels[index].links!.download!,"${userModels[index].user!.name}${Random().nextInt(10)}");
                          Navigator.pop(context);
                        },
                        child: Text("Download image",
                            style: TextStyle(
                                fontSize: 18,
                                color: Theme.of(context).primaryColor))),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            userModels.removeAt(index);
                            Navigator.pop(context);
                          });
                        },
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
                  ]),
            ),
          );
        });
  }

  /// Will pop
  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      setState(() {
        currentBackPressTime = now;
        showDraggableSheet = false;
      });

      return Future.value(false);
    }
    return Future.value(true);
  }

  void showToast([String? clipboard]) {
    Fluttertoast.showToast(
        fontSize: 16,
        msg: 'Downloaded successfully',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.white,
        textColor: Colors.black
    );
  }

}