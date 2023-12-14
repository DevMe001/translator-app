import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:translator/controller/forms.dart';

class DialogBox extends StatefulWidget {
  const DialogBox({super.key});

  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  List<String> listItems = ['1', '2'];
  String? dropdownValue; // Make it nullable
  var logger = Logger();
  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        // Initial Value
        hint: const Text(
          "Select Language",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        value: dropdownValue,
        onChanged: (String? newValue) {
          setState(() {
            dropdownValue = newValue!;
          });

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormScreen()),
          );
        },

        // Down Arrow Icon
        icon: const Icon(Icons.keyboard_arrow_down),

        // Array list of items
        items: listItems.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Center(
              child: Text((_getContributeDDialogBoxetails(item)),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7F2505),
                  )),
            ),
          );
        }).toList());
  }

  String _getContributeDDialogBoxetails(String item) {
    switch (item) {
      case '1':
        return 'Surigaonon language';
      case '2':
        return 'Translated language';
      default:
        return '';
    }
  }
}
