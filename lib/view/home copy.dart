import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:translator/services/api-service.dart';
import 'package:logger/logger.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API service
  final TranslatorService _translatorService = TranslatorService();

  var logger = Logger();

  String dropdownvalue = '1';
  String dropdownTranslatedWord = '2';

  // List of items in our dropdown menu

  List<String> listItems = []; // Initial empty list
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  @override
  void initState() {
    super.initState();
    getTranslatorAvailable();
  }

  Future<void> getTranslatorAvailable() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final dataRes = await _translatorService.getTranslatorAvailable();

      // logger.d(dataRes);
      _streamController.add(dataRes);

      Set<String> uniqueLanguages = <String>{};

      for (var i = 0; i < dataRes.length; i++) {
        uniqueLanguages.add(dataRes[i]['language'].toString());
      }

      logger.d(uniqueLanguages);

      setState(
        () {
          listItems = uniqueLanguages.toList();
        },
      );
    } catch (e) {
      print('Error: $e');
    }
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
            GButton(
                icon: Icons.history, text: 'History', iconColor: Colors.white),
            GButton(icon: Icons.drafts, text: 'Save', iconColor: Colors.white),
            GButton(
                icon: Icons.person,
                text: 'Contributes',
                iconColor: Colors.white),
          ],
          selectedIndex: 0,
          onTabChange: (index) {
            // setState(() {
            //   _selectedIndex = index;
            // });
          }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF7F2505),
        title: const Text(
          'ESTL Translator',
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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: StreamBuilder<List<dynamic>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return SizedBox(
                      height: 200.0,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final item = snapshot.data![index];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SizedBox(
                                width: 200.0,
                                child: Card(
                                  color: Colors.white,
                                  child: ListTile(
                                    title: Text(
                                      item['translated_word'] ?? 'No Suriganon',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      _getLanguageName(item['language']) ??
                                          'No Language',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DropdownButton<String>(
                    // Initial Value
                    dropdownColor: Colors.white,
                    value: dropdownvalue,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: listItems
                        .where((item) => item != dropdownTranslatedWord)
                        .map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(_getLanguageName(int.parse(item)),
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                      );
                    }).toList(),
                    underline: Container(
                        height: 1, // Customize the underline height
                        color: Colors.teal // Set the color of the underline
                        ),
                    // After selecting the desired option,
                    // it will change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownvalue = newValue!;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    child: GestureDetector(
                      onTap: () {
                        final dp1 = dropdownvalue;
                        final dp2 = dropdownTranslatedWord;
                        setState(() {
                          dropdownvalue = dp2;
                          dropdownTranslatedWord = dp1;
                        });
                      },
                      child: const Text('⇆',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF7F2505),
                          )),
                    ),
                  ),
                  DropdownButton<String>(
                    // Initial Value
                    dropdownColor: Colors.white,
                    value: dropdownTranslatedWord,

                    // Down Arrow Icon
                    icon: const Icon(Icons.keyboard_arrow_down),

                    // Array list of items
                    items: listItems
                        .where((item) => item != dropdownvalue)
                        .map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(_getLanguageName(int.parse(item)),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7F2505),
                            )),
                      );
                    }).toList(),

                    underline: Container(
                      height: 1, // Customize the underline height
                      color: Colors.teal, // Set the color of the underline
                    ),
                    // After selecting the desired option,
                    // it will change button value to selected value
                    onChanged: (String? newValue) {
                      setState(() {
                        dropdownTranslatedWord = newValue!;
                      });
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  String _getLanguageName(dynamic languageCode) {
    if (languageCode == 1) {
      return 'Cebuano';
    } else if (languageCode == 2) {
      return 'Tagalog';
    } else if (languageCode == 3) {
      return 'English';
    } else {
      return 'Unknown Language';
    }
  }

  @override
  void dispose() {
    _streamController.close();
    super.dispose();
  }
}
