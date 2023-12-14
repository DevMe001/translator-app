import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/controller/dialog.dart';

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

    // Instead of calling showNow() in initState, schedule it to be called after the build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNow();
    });
  }

  void showNow() {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation,
          Animation<double> secondaryAnimation) {
        return AlertDialog(
            backgroundColor: Colors.white,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Contributes",
                      style: TextStyle(
                        color: Color(0xFF7F2505),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ],
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            content: const DialogBox()
            // actions: [
            //   TextButton(
            //     onPressed: () {
            //       Navigator.of(context).pop();
            //     },
            //     child: const Text("Close"),
            //   ),
            // ],
            );
      },
      // barrierDismissible: false,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 200),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contributes"),
      ),
      body: Center(
        child: TextButton(
            onPressed: () {
              showNow();
            },
            child: const Text("Contributes")),
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
