import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    // Glowing profile image
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.6),
                            spreadRadius: 3,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(
                          'http://www.venmond.com/demo/vendroid/img/avatar/big.jpg',
                        ),
                      ),
                    ),

                    // Camera icon overlay
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          print("Change photo tapped!");
                        },
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 4,
                                color: Colors.black26,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text("Username"),
            const SizedBox(height: 10),
            Container(
              height: 20,
              width: 200,
              decoration: BoxDecoration(
                color: const Color.fromARGB(98, 211, 227, 30),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Padding(
                padding: EdgeInsets.all(1.0),
                child: Text(
                  textAlign: TextAlign.center,
                  "steffithomas439@gmail.com",
                ),
              ),
            ),
            const SizedBox(height: 10),
            const ListTile(
              leading: Icon(Icons.account_circle, color: Colors.yellow),
              title: Text('Change Profile Details'),
              trailing: Icon(Icons.arrow_forward),
            ),
            const ListTile(
              leading: Icon(Icons.settings, color: Colors.yellow),
              title: Text('Settings'),
              trailing: Icon(Icons.arrow_forward),
            ),
            const ListTile(
              leading:
                  Icon(Icons.logout, color: Color.fromARGB(224, 225, 12, 12)),
              title: Text('Logout'),
              trailing: Icon(Icons.arrow_forward),
            ),
          ],
        ),
      ),
    );
  }
}
