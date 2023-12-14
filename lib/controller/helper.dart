import 'package:flutter/material.dart';

List<Map<String, String>> removeDuplicatesByKey(
    List<Map<String, String>> list, String key) {
  Map<String, Map<String, String>> uniqueMap = {};

  for (var item in list) {
    uniqueMap[item[key] as String] = item;
  }

  return uniqueMap.values.toList();
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
