import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/services/api-service.dart';

class ApprovalScreenContribute extends StatefulWidget {
  const ApprovalScreenContribute({super.key});

  @override
  State<ApprovalScreenContribute> createState() =>
      _ApprovalScreenContributeState();
}

class _ApprovalScreenContributeState extends State<ApprovalScreenContribute> {
  List<Map<String, dynamic>> contributesState = [];

  var logger = Logger();

  bool _isLoading = false;
  bool isActiveError = false;
  String status = 'idle';

  // API service
  final TranslatorService _translatorService = TranslatorService();

  @override
  void initState() {
    super.initState();
    getContributeWordList();
  }

  Future<void> getContributeWordList() async {
    try {
      setState(() {
        status = 'loading';
      });

      await Future.delayed(const Duration(seconds: 2));

      final dataRes = await _translatorService.getContributeWord();

      setState(() {
        contributesState = dataRes.map((item) {
          return Map<String, dynamic>.from(item.map(
            (key, value) =>
                MapEntry(key, value is int ? value.toString() : value),
          ));
        }).toList();

        setState(() {
          status = 'success';
        });
      });
    } catch (e) {
      setState(() {
        isActiveError = true;
        setState(() {
          status = 'error';
        });
      });
      logger.d('Error: $e');
    }
  }

  void deletePopupMessage() {
    showMessage('Successfully deleted!');

    setState(() {});
    getContributeWordList();
  }

  void approvalMessage() {
    showMessage('Your word is now in the list!');

    setState(() {});

    getContributeWordList();
  }

  void showMessage(String message) {
    showPopupMessage(message, context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9906B),
        title: const Text(
          'Contributed Words',
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
            icon: const Icon(Icons.delete),
            // tooltip: 'Open shopping cart',
            onPressed: () async {
              // Set _isLoading to true to show CircularProgressIndicator
              setState(() {
                _isLoading = true;
              });

              // Perform the deletion logic
              await _translatorService.deleteAllContribution();
              // pass the item to delete

              // After deletion is complete, set _isLoading back to false
              setState(() {
                _isLoading = false;
              });

              deletePopupMessage();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : contributesState.isEmpty
              ? Center(
                  child: isActiveError && status == 'error'
                      ? const Text('Error')
                      : status == 'loading'
                          ? const CircularProgressIndicator()
                          : const Text('No recent contributed words',
                              style: TextStyle(
                                  fontSize: 20, color: Color(0xFF7F2505))),
                )
              : ListView.builder(
                  itemCount: contributesState.length,
                  itemBuilder: (context, index) {
                    var item = contributesState[index];

                    return ListTile(
                      leading: const Icon(
                        Icons.list,
                        color: Color(0xFF7F2505),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle,
                                color: Colors.red),
                            tooltip: 'Delete',
                            onPressed: () async {
                              // Set _isLoading to true to show CircularProgressIndicator
                              setState(() {
                                _isLoading = true;
                              });

                              // Perform the deletion logic
                              await _translatorService.deleteContribution(item[
                                  'contribute_id']); // pass the item to delete

                              // After deletion is complete, set _isLoading back to false
                              setState(() {
                                _isLoading = false;
                              });

                              deletePopupMessage();
                            },
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.save_sharp,
                              color: Color.fromARGB(255, 58, 16, 136),
                            ),
                            tooltip: 'Edit',
                            onPressed: () async {
                              // Set _isLoading to true to show CircularProgressIndicator
                              setState(() {
                                _isLoading = true;
                              });

                              await _translatorService.aprovalRequest(
                                  item['suriganon_word'],
                                  int.parse(item['language']),
                                  item['translated_word'],
                                  int.parse(item['contribute_id']));

                              // After deletion is complete, set _isLoading back to false
                              setState(() {
                                _isLoading = false;
                              });

                              approvalMessage();
                              // Handle edit action
                            },
                          ),
                        ],
                      ),
                      title: Text(
                        item['suriganon_word']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7F2505),
                        ),
                      ),
                      subtitle: Text(
                        'Language: ${_getLanguageName(int.parse(item['language']))} - (${item['translated_word']})',
                      ),
                    );
                  },
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
