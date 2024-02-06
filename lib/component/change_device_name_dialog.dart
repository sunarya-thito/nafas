import 'package:flutter/material.dart';
import 'package:nafas/nafas_client_app.dart';

class ChangeDeviceNameDialog extends StatefulWidget {
  final Device device;

  const ChangeDeviceNameDialog({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  _ChangeDeviceNameDialogState createState() => _ChangeDeviceNameDialogState();
}

class _ChangeDeviceNameDialogState extends State<ChangeDeviceNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.device.name.value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Device Name'),
      content: TextField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: 'Device Name',
          hintText: 'Enter device name',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.device.rename(_controller.text);
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
