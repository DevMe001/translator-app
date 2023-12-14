import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/services/api-service.dart';

class FormScreen extends StatefulWidget {
  const FormScreen({
    super.key,
  });

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _translatedController = TextEditingController();
  final TranslatorService _translatorService = TranslatorService();
  List<String> listItems = [];
  String? selectedItem;

  bool proceedNextForm = false;
  bool lastNextForm = false;
  var logger = Logger();

  @override
  void initState() {
    super.initState();
    getTranslatorAvailable();
  }

  Future<void> getTranslatorAvailable() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      final dataRes = await _translatorService.getTranslatorAvailable();

      Set<String> uniqueLanguages = <String>{};

      for (var i = 0; i < dataRes.length; i++) {
        uniqueLanguages.add(dataRes[i]['language'].toString());
      }

      // List<String> appendZero = List.from(uniqueLanguages)..add('0');

      // logger.d(appendZero);
      // logger.d('appendZero');
      // logger.d(appendZero);

      setState(
        () {
          listItems.addAll(uniqueLanguages.toList());
        },
      );
    } catch (e) {
      logger.d('Error: $e');
    }
  }

  void readyToSubmit(validatedList) {
    if (!validatedList) {
      showPopupMessage(
          'Pardon me request declined,this word already existed', context);
    } else {
      _translatorService.createContributes(_textController.text,
          int.parse(selectedItem!), _translatedController.text);

      showPopupMessage(
          'Thank you, we will review your contribute word', context,
          colorStyle: 'success');

      setState(() {});

      Navigator.pop(context);
    }
  }

  String getLabelText(String? selectedItem) {
    if (selectedItem == null) {
      return 'Select an option';
    } else {
      return 'Enter ${_getLanguageName(int.parse(selectedItem))} word';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
        title: const Text(
          'Contributes Form',
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
      body: Form(
        key: _formKey,
        child: Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  if (!lastNextForm && !proceedNextForm)
                    DropdownButtonFormField<String>(
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7F2505),
                        ),
                        value: selectedItem,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedItem = newValue;
                          });
                        },
                        items: listItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(
                              _getLanguageName(int.parse(item)),
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),
                        decoration: const InputDecoration(
                          labelText: 'Select language to translate',
                          errorStyle: TextStyle(
                            color: Colors
                                .red, // Change the color of the error text
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Field is not empty';
                          }
                          return null;
                        },
                        dropdownColor: Colors.white),
                  if (!lastNextForm && proceedNextForm)
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F2505),
                      ),
                      textAlign: TextAlign.center,
                      controller: _translatedController,
                      decoration: InputDecoration(
                        labelText: getLabelText(selectedItem),
                        errorStyle: const TextStyle(
                          color:
                              Colors.red, // Change the color of the error text
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Field is not empty.';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                  if (lastNextForm && proceedNextForm)
                    TextFormField(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7F2505),
                      ),
                      textAlign: TextAlign.center,
                      controller: _textController,
                      decoration: const InputDecoration(
                        labelText:
                            'What surigaonon word you want to contribute?',
                        errorStyle: TextStyle(
                          color:
                              Colors.red, // Change the color of the error text
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Field is not empty.';
                        }
                        return null; // Return null if the input is valid
                      },
                    ),
                ],
              )),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_formKey.currentState?.validate() == true) {
            // The form is valid, process the data
            String enteredText = _textController.text;
            // Do something with the entered text
            if (!proceedNextForm) {
              setState(() {
                proceedNextForm = true;
              });
            } else {
              if (lastNextForm && proceedNextForm) {
                final validateContribute =
                    await _translatorService.getContributorList(
                        _translatedController.text,
                        int.parse(selectedItem!),
                        enteredText);

                readyToSubmit(validateContribute);

                logger.d('is validated $validateContribute');
              }
              // logger.d(selectedItem);
              // logger.d('dropdown done');
              else {
                setState(() {
                  lastNextForm = true;
                });
              }
            }
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  String _getLanguageName(dynamic languageCode) {
    if (languageCode == 1) {
      return 'Bisaya';
    } else if (languageCode == 2) {
      return 'Tagalog';
    } else if (languageCode == 3) {
      return 'English';
    } else {
      return 'Unknown Language';
    }
  }
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showPopupMessage(
    String message, BuildContext context,
    {String? colorStyle}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      // action: SnackBarAction(
      //   label: 'Action',
      //   onPressed: () {
      //     // Code to execute.
      //   },
      // ),
      backgroundColor: colorStyle == 'success'
          ? const Color.fromARGB(255, 130, 143, 30)
          : const Color(0xFFF9906B),
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
