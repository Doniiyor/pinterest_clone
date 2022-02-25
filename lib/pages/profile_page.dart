import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);
  static const String id = "profile_page";

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ScrollController scrollController = ScrollController();

  bool showNameInAppBar = false;
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();

    appBarInfo();
    // scrollController.addListener(() {
    //   if (scrollController.offset == 0.0) {
    //     setState(() {
    //     });
    //   } else {
    //     setState(() {
    //     });
    //   }
    // });
  }

  void appBarInfo() {
    return WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      scrollController.addListener(() {
        setState(() {
          showNameInAppBar = true;
        });
        print('scrolling');
      });
      scrollController.position.isScrollingNotifier.addListener(() {
        if (!scrollController.position.isScrollingNotifier.value) {
          setState(() {
            showNameInAppBar = false;
          });
          print('scroll is stopped');
        } else {
          print('scroll is started');
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: (showNameInAppBar)
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: Text(
              "D",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          ),
        )
            : null,
        centerTitle: true,
        title: (showNameInAppBar)
            ? Text(
          "Doniyorbek",
          style: TextStyle(
              fontSize: 16,
              color: Colors.blue,
              fontWeight: FontWeight.w600),
        )
            : null,
        elevation: (showNameInAppBar) ? 4 : 0,
        shadowColor: Colors.grey.shade300,
        backgroundColor: Colors.grey.shade50,
        actions: [
          (showNameInAppBar)
              ? SizedBox.shrink()
              : IconButton(
            onPressed: () {},
            icon: Icon(Icons.share),
            color: Colors.blue,
          ),
          (showNameInAppBar)
              ? SizedBox.shrink()
              : IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_horiz),
              color: Colors.blue,
          )
        ],
      ),
      body: NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return [
              SliverList(
                  delegate: SliverChildListDelegate([profileDetails(context)]))
            ];
          },
          body: SingleChildScrollView(
            child: Column(
              children: [
                textFieldWidget(context),
                GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02,vertical: MediaQuery.of(context).size.width*0.08 ),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 9,
                      crossAxisSpacing: 5,
                      childAspectRatio: 1,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index){
                      return GestureDetector(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: (NetworkImage("https://source.unsplash.com/random?sig=$index")
              ),
                              )
                          ),
                        ),
                      );
                    }
                ),
              ],
            ),
          )),
    );
  }

  Widget textFieldWidget(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Container(
            margin: EdgeInsets.only(left: 10),
            decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(20)),

            /// TextField Search
            child: TextField(
              style: TextStyle(
                  color: Colors.black,
                  decoration: TextDecoration.none),
              cursorColor: Colors.blueAccent,
              controller: textEditingController,
              onSubmitted: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                  hintText: "Search your Pins",
                  hintStyle: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.none),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 25,
                    color: Colors.black,
                  ),
                  contentPadding: EdgeInsets.all(15),
                  border: InputBorder.none),
            ),
          ),
        ),
        Expanded(
            child: IconButton(
                iconSize: 30,
                onPressed: () {},
                icon: Icon(CupertinoIcons.add))),
      ],
    );
  }

  Widget profileDetails(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: MediaQuery.of(context).size.width / 7,
          backgroundColor: Colors.grey.shade300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image(
                image: AssetImage('assets/images/pimg.png')),
          ),
          foregroundColor: Theme.of(context).primaryColor,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "Doniyor Flutter Developer",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          "@doniyor_flutter_developer",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '1,2 mln followers ',
              style: TextStyle(
                  fontSize: 14, color: Colors.blue,),
            ),
            Text(
              "• 2 following",
              style: TextStyle(
                  fontSize: 14, color: Colors.blue,
            ),
            ),
          ],
        ),
        SizedBox(
          height: 20,
        )
      ],
    );
  }
}