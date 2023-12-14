import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/view/contributes.dart';
import 'package:translator/view/history.dart';
import 'package:translator/view/home.dart';

class FavoriteScreen extends StatefulWidget {
  final int selectedIndex;

  const FavoriteScreen({super.key, required, required this.selectedIndex});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  var logger = Logger();

  List<Map<String, String>> favoriteState = [];
  String status = 'idle';

  @override
  void initState() {
    super.initState();
    getfavorite();
  }

  Future<void> getfavorite() async {
    setState(() {
      status = 'loading';
    });
    // Retrieve the favorite from shared preferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorite = prefs.getStringList('favorite') ?? <String>[];

// Convert the JSON strings back to maps
    List<Map<String, String>> favoriteList = favorite
        .map((item) => Map<String, String>.from(jsonDecode(item)))
        .toList();

// Sort the list in descending order based on 'searchTerm'
    favoriteList.sort((a, b) => b['searchTerm']!.compareTo(a['searchTerm']!));

    logger.d(favoriteList);

// Now you can use favoriteList in your ListView.builder
    setState(() {
      // Assuming you have a state variable called `favoriteList`
      favoriteState = favoriteList;
      status = 'success';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: GNav(
          rippleColor: Colors.grey[300]!,
          hoverColor: Colors.grey[100]!,
          gap: 8,
          activeColor: Colors.black,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          duration: const Duration(milliseconds: 400),
          tabBackgroundColor: Colors.grey[100]!,
          color: Colors.black,
          backgroundColor: const Color.fromARGB(255, 58, 16, 136),
          tabs: const [
            GButton(icon: Icons.home, text: 'Home', iconColor: Colors.white),
            GButton(
                icon: Icons.history, text: 'History', iconColor: Colors.white),
            GButton(icon: Icons.drafts, text: 'Save', iconColor: Colors.white),
            GButton(
                icon: Icons.person,
                text: 'Contributes',
                iconColor: Colors.white),
          ],
          selectedIndex: widget.selectedIndex,
          onTabChange: (index) {
            logger.d('index');
            logger.d(index);

            if (index == 0) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HistoryScreen(selectedIndex: index)),
              );
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContributesScreen(selectedIndex: index)),
              );
            }

            // setState(() {
            //   _selectedIndex = index;
            // });
          }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
        title: const Text(
          'Favorite',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set the title color to white
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            tooltip: 'Open shopping cart',
            onPressed: () {
              SharedPreferences.getInstance().then((SharedPreferences prefs) {
                prefs.remove('favorite');

                setState(() {
                  favoriteState = [];
                });
              });
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );

              showPopupMessage('favorite cleared successfully!', context);
            },
          ),
        ],
      ),
      body: favoriteState.isEmpty
          ? status == 'idle'
              ? const Center(
                  child: Text(
                    'No recent history found',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal, // Set the title color to white
                    ),
                  ),
                )
              : const Center(
                  child: CircularProgressIndicator(),
                )
          : ListView.builder(
              itemCount: favoriteState.length,
              itemBuilder: (context, index) {
                var item = favoriteState[index];

                return ListTile(
                  leading: const Icon(
                    Icons.favorite,
                    color: Color(0xFF7F2505),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    tooltip: 'Delete',
                    onPressed: () {
                      SharedPreferences.getInstance()
                          .then((SharedPreferences prefs) {
                        List<String> favorite =
                            prefs.getStringList('favorite') ?? <String>[];

                        if (index >= 0 && index < favorite.length) {
                          favorite.removeAt(index);

                          // Update shared preferences with the modified favorite list
                          prefs.setStringList('favorite', favorite);

                          // Convert the JSON strings back to maps and update the state
                          List<Map<String, String>> favoriteList = favorite
                              .map((item) =>
                                  Map<String, String>.from(jsonDecode(item)))
                              .toList();

                          setState(() {
                            // Assuming you have a state variable called `historyState`
                            favoriteList = favoriteList;
                          });
                        }
                      });

                      showPopupMessage('Selected history deleted!', context);
                    },
                  ),
                  title: Text(item['searchTerm']!,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7F2505))),
                  subtitle:
                      Text('Keywords: ${item['keyword']} - (${item['type']})}'),
                );
              },
            ),
    );
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPopupMessage(
    String message, BuildContext context) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // action: SnackBarAction(
      //   label: 'Action',
      //   onPressed: () {
      //     // Code to execute.
      //   },
      // ),
      backgroundColor: Colors.black,
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(milliseconds: 1500),
      width: 280.0, // Width of the SnackBar.

      padding: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0, // Inner padding for SnackBar content.
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  );
}
