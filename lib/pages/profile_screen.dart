import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_app/provider/user_provider.dart';
import 'package:test_app/utils/utils.dart';
import 'package:test_app/widgets/confirmation.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  
  @override
  void initState() {
    
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    
    var userProvider = Provider.of<UserProvider>(context);
    return FutureBuilder(
      future: userProvider.readFromSecureStorage(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var tempUser = userProvider.user;
          return Scaffold(
            appBar: AppBar(
              title: const Text("Profil"),
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Name:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  "Email:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  "Version:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  "Letztes-Update:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                      // fontFamily: "DIN",
                                      ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tempUser.username,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  tempUser.email,
                                    overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  getAppVersion(),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      // fontFamily: "DIN",
                                      ),
                                ),
                                Text(
                                  getReleaseDate(), // Letztes App-Update
                                  style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                      // fontFamily: "DIN",
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            logOutButton(context),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget logOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(
                  color: Colors.redAccent[700]!.withOpacity(0.8), width: 2.0),
            ),
          ),
          onPressed: () {
            showConfirmationDialog(
              context,
              title: "Abmelden",
              content: "Wollen Sie sich wirklich abmelden?",
              cancelText: "Abbrechen",
              confirmText: "Abmelden",
              onCancel: () {},
              onConfirm: () => handleLogout(context),
            );
            
          },
          child: Text('Nutzer abmelden',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent[700],
                  // fontFamily: "DIN",
                  ),
                  ),
                  ),
    );
  }

  Future<String> getDatabaseFilePath() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final databasePath = '${documentsDir.path}/MyDatabase.db';
    return databasePath;
  }
}