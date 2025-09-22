import 'package:fire_behaviour_app/global.dart';
import 'package:flutter/material.dart';

class DatePicker extends StatefulWidget {
  const DatePicker(
      {Key? key, required this.onChanged, required this.initialValue})
      : super(key: key);
  final Function onChanged;
  final DateTime initialValue;

  @override
  State<DatePicker> createState() => _DatePickerState();
}

class _DatePickerState extends State<DatePicker> {
  Future<void> _selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.initialValue,
      firstDate: DateTime(2021),
      lastDate: DateTime.now(),
    );

    setState(() {
      widget.onChanged(pickedDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    final date = widget.initialValue;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // "Date:" label
        const Row(children: [
          Text(
            "Date",
            style: TextStyle(
                fontSize: fontSize, color: Color.fromARGB(255, 53, 150, 243)),
          ),
        ]),
        // Clickable date picker BELOW the label
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text('${date.day}/${date.month}/${date.year}'),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
