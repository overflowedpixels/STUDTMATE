import 'package:colorful_iconify_flutter/icons/emojione.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:study_mate/pages/Assignment.dart';
import 'package:study_mate/pages/Notes.dart';
import 'package:study_mate/pages/about.dart';
import 'package:study_mate/pages/notification.dart';
import 'package:study_mate/utilities/color_theme.dart';
import 'package:colorful_iconify_flutter/icons/flat_color_icons.dart';

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            expandedHeight: 100,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 25, bottom: 16),
              title: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Hello ",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color.fromARGB(150, 255, 255, 255),
                    ),
                  ),
                  Text(
                    "${FirebaseAuth.instance.currentUser?.email?.replaceAll('@gmail.com', '') ?? 'Guest'} 👋",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 5, top: 10),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.card,
                  child: IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AppUpdatePage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 15, top: 10),
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: AppTheme.card,
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AboutPage(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            floating: false,
            pinned: false,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Your Alltime",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "Studymate",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          height: 200,
                          decoration: const BoxDecoration(
                            color: AppTheme.softPurple,
                            borderRadius: BorderRadius.all(Radius.circular(20)),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(FlatColorIcons.add_image, size: 50),
                              SizedBox(height: 10),
                              Text(
                                "Add New",
                                style: TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            height: 90,
                            width: 180,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentMint,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                left: 0,
                                right: 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Iconify(Emojione.books, size: 35),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Study Notes",
                                        style: TextStyle(
                                          color: AppTheme.background,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: const Text(
                                          "view",
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppTheme.background,
                                            color: AppTheme.background,
                                            fontSize: 15,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const StudyNotesPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 90,
                            width: 180,
                            decoration: const BoxDecoration(
                              color: AppTheme.accentYellow,
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 20,
                                left: 0,
                                right: 0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Iconify(
                                    FlatColorIcons.document,
                                    size: 35,
                                  ),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Assignments",
                                        style: TextStyle(
                                          color: AppTheme.background,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        child: const Text(
                                          "view",
                                          style: TextStyle(
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                AppTheme.background,
                                            color: AppTheme.background,
                                            fontSize: 15,
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AssignmentPage(),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Latest Uploads", style: TextStyle(fontSize: 20)),
                      Text(
                        "View all",
                        style: TextStyle(
                          fontSize: 15,
                          color: AppTheme.accentYellow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Material(
                        elevation: 4,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.card,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          height: 150,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 35,
                            ),
                            title: const Text(
                              "Title",
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Date:12/12/2025"),
                                SizedBox(height: 10),
                                Text(
                                  "Contributed by :@Username",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.arrow_circle_right_outlined,
                                color: AppTheme.accentYellow,
                                size: 40,
                              ),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            style: ListTileStyle.list,
                          ),
                        ),
                      ),
                    ),

                    // Positioned badge/tag
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.only(
                            bottomRight: Radius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Note",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.accentYellow,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                childCount: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
