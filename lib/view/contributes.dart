import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:logger/logger.dart';
import 'package:translator/controller/account.dart';
import 'package:translator/controller/forms.dart';
import 'package:translator/view/favorite.dart';
import 'package:translator/view/history.dart';
import 'package:translator/view/home.dart';

class ContributesScreen extends StatefulWidget {
  final int selectedIndex;

  const ContributesScreen({super.key, required this.selectedIndex});

  @override
  State<ContributesScreen> createState() => _ContributesScreenState();
}

class _ContributesScreenState extends State<ContributesScreen> {
  List<String> listItems = ['1', '2'];
  String? dropdownValue; // Make it nullable
  var logger = Logger();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => FavoriteScreen(selectedIndex: index)),
              );
            }

            // setState(() {
            //   _selectedIndex = index;
            // });
          }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
        title: const Text("Contributes"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
            // tooltip: '',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FormScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 58, 16, 136),
              textStyle: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              padding: const EdgeInsets.all(16.0), // Add padding to the button
            ),
            child: const Text(
              "Contribute now",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // String _getContributeDetails(String item) {
  //   switch (item) {
  //     case '1':
  //       return 'Surigaonon language';
  //     case '2':
  //       return 'Translated language';
  //     default:
  //       return '';
  //   }
  // }
}
