import 'package:flutter/material.dart';
import 'package:frontend/services/app_strings.dart';
import 'package:intl/intl.dart';

class DateField extends StatefulWidget {
  final String hintText;
  final DateTime? initialDate;
  final void Function(DateTime)? onDateSelected;

  const DateField({
    super.key,
    required this.hintText,
    this.onDateSelected,
    this.initialDate,
  });

  @override
  State<DateField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DateField> {
  final TextEditingController _controller = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    _controller.text = DateFormat(
      AppStrings.get('date_format'),
    ).format(_selectedDate);
    widget.onDateSelected?.call(_selectedDate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) {
      _controller.text = DateFormat(AppStrings.get('date_format')).format(date);
      widget.onDateSelected?.call(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: _pickDate,
    );
  }
}
