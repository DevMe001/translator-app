import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:translator/controller/helper.dart';
import 'package:translator/controller/voice-controller.dart';
import 'package:translator/services/api-service.dart';
import 'package:logger/logger.dart';
import 'package:translator/view/contributes.dart';
import 'package:translator/view/favorite.dart';
import 'package:translator/view/history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // API service
  final TranslatorService _translatorService = TranslatorService();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var logger = Logger();

  String dropdownvalue = '0';
  String dropdownTranslatedWord = '2';
  String wordTraslated = '';

  static int counter = 0;

  bool getWord = false;

  bool filterExist = false;

  String status = 'idle';
  // List of items in our dropdown menu

  List<String> listItems = []; // Initial empty list
  final StreamController<List<dynamic>> _streamController =
      StreamController<List<dynamic>>();

  final TextEditingController _textController = TextEditingController();
  final TextEditingController _wordController = TextEditingController();
  final Future<SharedPreferences> prefs = SharedPreferences.getInstance();

  List<Map<String, String>> favoriteState = [];

  FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    getTranslatorAvailable();
    getFavorite();
    if (_textController.text.isNotEmpty) {
      _textController.addListener(onTextChanged);
    }
  }

  Future<void> getTranslatorAvailable() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        status = 'loading';
      });

      final dataRes = await _translatorService.getTranslatorAvailable();

      // logger.d(dataRes);
      _streamController.add(dataRes);

      Set<String> uniqueLanguages = <String>{};

      for (var i = 0; i < dataRes.length; i++) {
        uniqueLanguages.add(dataRes[i]['language'].toString());
      }

      List<String> appendZero = List.from(uniqueLanguages)..add('0');

      // logger.d(appendZero);
      // logger.d('appendZero');
      // logger.d(appendZero);

      setState(
        () {
          listItems.addAll(appendZero.toList());
          status = 'success';
        },
      );
    } catch (e) {
      setState(() {
        status = 'error';
      });
      logger.d('Error: $e');
    }
  }

  void onTextChanged() {
    // Your logic when the text changes
    String newText = _textController.text;
    logger.d('Text changed: $newText');

    counter = 0;
    onDataHandler(newText);
  }

  void initMic() {
    setState(() {
      getWord = false;
    });
  }

  void speaktoWord(recorgnizeWord) async {
    _textController.text = recorgnizeWord;
    favoriteColorCheck(recorgnizeWord);
    onTextChanged();
  }

  Future<void> onDataHandler(String value) async {
    final dataRes = await _translatorService.getTranslatorAvailable();

    String selectedItem =
        dropdownvalue == '0' ? 'suriganon' : 'translated_word';
    String translatedItem =
        dropdownTranslatedWord == '0' ? 'suriganon' : 'translated_word';
    String getSelectedId = '';

    // if suriganon
    if (selectedItem == 'translated_word') {
      dataRes
          .where(
              (word) => word[selectedItem].toLowerCase() == value.toLowerCase())
          .forEach((item) {
        logger.d(item['siargao_id'].runtimeType);

        logger.d(item['language'].runtimeType);
        getSelectedId = item['siargao_id'].toString();
      });
      if (getSelectedId.isNotEmpty) {
        if (translatedItem == 'suriganon') {
          dataRes
              .where((word) => word['siargao_id'].toString() == getSelectedId)
              .forEach((item) {
            logger.d('item surganon get data id word');
            logger.d(item);
            logger.d(translatedItem);

            wordTraslated = item[translatedItem];

            if (wordTraslated == '') {
              _wordController.text = '';
            } else {
              _wordController.text = wordTraslated;
            }
          });
        } else {
          dataRes
              .where((word) =>
                  word['siargao_id'].toString() == getSelectedId &&
                  word['language'] == int.parse(dropdownTranslatedWord))
              .forEach((item) {
            logger.d('item translated speak word');
            logger.d(item);
            logger.d(translatedItem);

            wordTraslated = item[translatedItem];

            if (wordTraslated == '') {
              _wordController.text = '';
            } else {
              _wordController.text = wordTraslated;
            }
          });
        }
      }
    } else {
      dataRes
          .where((word) =>
              word[selectedItem].toLowerCase().contains(value.toLowerCase()))
          .forEach((item) {
        logger.d('item suriganon speak get');
        logger.d(item);
        if (item['language'] == int.parse(dropdownTranslatedWord)) {
          wordTraslated = item[translatedItem];

          if (wordTraslated == '') {
            _wordController.text = '';
          } else {
            _wordController.text = wordTraslated;
          }
        }
      });
    }

    if (_wordController.text != '') {
      List<Map<String, String>> map = [
        {
          'searchTerm': _wordController.text.trim(),
          'type': 'voice',
          'keyword': _textController.text.trim(),
        },
      ];
      List<Map<String, String>> uniqueList =
          removeDuplicatesByKey(map, 'keyword');

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final List<String> history = prefs.getStringList('history') ?? <String>[];

      if (counter == 0) {
        history.add(jsonEncode(uniqueList[0]));
        counter++;
      }
      prefs.setStringList('history', history);

      setState(() => getWord = true);
    }
  }

  void touchPrefCache(String terms, String keyword, {String? type}) {
    String getType = type ?? 'history';

    SharedPreferences.getInstance().then((SharedPreferences prefs) {
      List<Map<String, String>> map = [
        {
          'searchTerm': terms,
          'type': 'touch',
          'keyword': keyword.trim(),
        },
      ];
      List<Map<String, String>> uniqueList =
          removeDuplicatesByKey(map, 'keyword');

      final List<String> history = prefs.getStringList(getType) ?? <String>[];

      if (type == 'history') {
        if (counter == 0) {
          history.add(jsonEncode(uniqueList[0]));
          counter++;
        }
      } else {
        history.add(jsonEncode(uniqueList[0]));
      }

      prefs.setStringList(getType, history);

      if (type == 'favorite') {
        showPopupMessage('$terms has been added to favorite list', context);
      }
    });
  }

  Future<void> getFavorite() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favorite = prefs.getStringList('favorite') ?? <String>[];

    // Convert the JSON strings back to maps
    List<Map<String, String>> favoriteList = favorite
        .map((item) => Map<String, String>.from(jsonDecode(item)))
        .toList();

    setState(() {
      favoriteState = favoriteList;
    });
  }

  void filterFavorite(String searchTerm) {
    logger.d('favoriteState results');

    List<Map<String, String>> filterList = favoriteState
        .where((term) => term['searchTerm'] == searchTerm)
        .toList();

    if (filterList.isNotEmpty) {
      showPopupMessage('Already added to favorite list', context);
    } else {
      touchPrefCache(_wordController.text, _textController.text,
          type: 'favorite');
    }
  }

  void favoriteColorCheck(String searchTerm) {
    logger.d('favoriteState results');

    List<Map<String, String>> filterList = favoriteState
        .where((term) => term['searchTerm'] == searchTerm)
        .toList();

    if (filterList.isNotEmpty) {
      setState(() {
        filterExist = true;
      });
    } else {
      setState(() {
        filterExist = false;
      });
    }
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
          selectedIndex: 0,
          onTabChange: (index) {
            if (index == 1) {
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
            } else if (index == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        ContributesScreen(selectedIndex: index)),
              );
            }

            logger.d('index');
            logger.d(index);
            // setState(() {
            //   _selectedIndex = index;
            // });
          }),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
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
          mainAxisAlignment: getWord
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (status == 'success')
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  StreamBuilder<List<dynamic>>(
                      stream: _streamController.stream,
                      builder: (context, snapshot) {
                        // logger.d(snapshot.data);

                        String dropselected = dropdownvalue;
                        String dropdtranslated = dropdownTranslatedWord;

                        String selectedItem = dropselected == '0'
                            ? 'suriganon'
                            : 'translated_word';
                        String translatedItem = dropdtranslated == '0'
                            ? 'suriganon'
                            : 'translated_word';

                        String getSelectedId = '';

                        logger.d('selectedItem');
                        logger.d(selectedItem);

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 5),
                          child: SizedBox(
                            width: double.infinity,
                            height: 100,
                            child: TextField(
                              controller: _textController,
                              // onTapOutside: (e) {
                              //   setState(() {
                              //     getWord = false;
                              //   });
                              // },
                              onTap: () {
                                setState(() {
                                  getWord = false;
                                });
                              },
                              onSubmitted: (text) {
                                // This callback is triggered when the user submits the text.
                                logger.d('Text submitted: $text');
                              },
                              onChanged: (value) => {
                                counter == 0,
                                if (value.isNotEmpty)
                                  {
                                    if (snapshot.hasData)
                                      {
                                        if (selectedItem == 'translated_word')
                                          {
                                            snapshot.data
                                                ?.where((word) =>
                                                    word[selectedItem]
                                                        .toLowerCase() ==
                                                    value.toLowerCase())
                                                .forEach((item) {
                                              logger.d(item['siargao_id']
                                                  .runtimeType);

                                              logger.d(
                                                  item['language'].runtimeType);
                                              getSelectedId =
                                                  item['siargao_id'].toString();
                                            }),
                                            if (getSelectedId.isNotEmpty)
                                              {
                                                if (translatedItem ==
                                                    'suriganon')
                                                  {
                                                    snapshot.data
                                                        ?.where((word) =>
                                                            word['siargao_id']
                                                                .toString() ==
                                                            getSelectedId)
                                                        .forEach((item) {
                                                      logger.d(
                                                          'item surganon get data id word');
                                                      logger.d(item);
                                                      logger.d(translatedItem);

                                                      wordTraslated =
                                                          item[translatedItem];
                                                      favoriteColorCheck(value);
                                                      touchPrefCache(
                                                          wordTraslated, value);
                                                      _wordController.text =
                                                          wordTraslated;
                                                    })
                                                  }
                                                else
                                                  {
                                                    snapshot.data
                                                        ?.where((word) =>
                                                            word['siargao_id']
                                                                    .toString() ==
                                                                getSelectedId &&
                                                            word['language'] ==
                                                                int.parse(
                                                                    dropdownTranslatedWord))
                                                        .forEach((item) {
                                                      logger.d(
                                                          'item translated word');
                                                      logger.d(item);
                                                      logger.d(translatedItem);

                                                      wordTraslated =
                                                          item[translatedItem];
                                                      favoriteColorCheck(value);
                                                      touchPrefCache(
                                                          wordTraslated, value);
                                                      _wordController.text =
                                                          wordTraslated;
                                                    })
                                                  }
                                              }
                                          }
                                        else
                                          {
                                            snapshot.data
                                                ?.where((word) =>
                                                    word[selectedItem]
                                                        .toLowerCase() ==
                                                    value.toLowerCase())
                                                .forEach((item) {
                                              logger.d('item suriganon');
                                              logger.d(item);
                                              if (item['language'] ==
                                                  int.parse(
                                                      dropdownTranslatedWord)) {
                                                wordTraslated =
                                                    item[translatedItem];
                                                favoriteColorCheck(value);
                                                touchPrefCache(
                                                    wordTraslated, value);

                                                _wordController.text =
                                                    wordTraslated;
                                              }
                                            })
                                          },
                                      }
                                  }
                                else
                                  {
                                    _wordController.text = '',
                                    setState(() => getWord = false)
                                  },
                                if (_wordController.text != '')
                                  {setState(() => getWord = true)}
                              },
                              maxLines: 5,
                              decoration: const InputDecoration(
                                labelText: 'Enter text',
                                labelStyle: TextStyle(
                                  color: Colors
                                      .teal, // Set your desired label text color
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .teal, // Set your desired border color
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors
                                        .teal, // Set your focused border color
                                  ),
                                ),
                              ),
                              style: const TextStyle(
                                color:
                                    Colors.black, // Set your desired text color
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        );
                      }),
                  if (getWord)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 5),
                      child: SizedBox(
                        width: double.infinity,
                        height: 100,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _wordController,
                                maxLines: 1,
                                enabled: false,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16.0,
                                ),
                                decoration: const InputDecoration(
                                  labelText: '',
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.teal,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.favorite,
                                color: filterExist
                                    ? const Color(0xFF7F2505)
                                    : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  getWord = true;
                                });

                                filterFavorite(_textController.text);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () async {
                                await flutterTts.setLanguage("fil-PH");
                                await flutterTts.setVoice({
                                  "name": "fil-ph-x-cfc-network",
                                  "locale": "fil-PH"
                                });

                                await flutterTts.setSpeechRate(0.8);

                                await flutterTts.setVolume(1.0);

                                await flutterTts.setPitch(0.8);

                                flutterTts.speak(_wordController.text);

                                var voices = await flutterTts.getVoices;

                                for (var voice in voices) {
                                  logger.d(voice);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            if (status == 'success')
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
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
                            child: Center(
                              child: Text(_getLanguageName(int.parse(item)),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7F2505),
                                  )),
                            ),
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
                            _textController.text = '';
                            getWord = false;
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

                            _wordController.text = _textController.text;

                            _textController.text = wordTraslated;
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
                            child: Center(
                              child: Text(_getLanguageName(int.parse(item)),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF7F2505),
                                  )),
                            ),
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
                            _textController.text = '';
                            getWord = false;
                          });
                        },
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: getWord ? 20 : 50),
                        child: Center(
                          child: AnimateMic(
                              speaktoWord: speaktoWord, initMic: initMic),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            if (status == 'idle')
              const Center(child: CircularProgressIndicator()),
            if (status == 'error')
              const Center(child: Text('Something went wrong'))
          ],
        ),
      ),
    );
  }

  String _getLanguageName(dynamic languageCode) {
    if (languageCode == 0) {
      return 'Surigaonon';
    } else if (languageCode == 1) {
      return 'Bisaya';
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
    _textController.dispose();
    super.dispose();
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
