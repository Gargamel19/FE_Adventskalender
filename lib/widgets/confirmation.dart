import 'package:flutter/material.dart';

class ConfirmationDialog extends StatefulWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final Future<void> Function()? onConfirm; // Async support for confirm
  final VoidCallback? onCancel;
  final bool closeOnAction;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    this.onCancel,
    this.onConfirm,
    this.closeOnAction = true,
  });

  @override
  State<ConfirmationDialog> createState() => _ConfirmationDialogState();
}

class _ConfirmationDialogState extends State<ConfirmationDialog> {
  bool _isLoading = false;

  void _handleConfirm() async {
    if (widget.onConfirm != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        await widget.onConfirm!();
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.content,
            style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 24.0),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      actions: [
        if (!_isLoading)
          TextButton(
            onPressed: () {
              if (widget.onCancel != null) widget.onCancel!();
              if (widget.closeOnAction) Navigator.of(context).pop();
            },
            child: Text(
              widget.cancelText,
              style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        if (!_isLoading)
          TextButton(
            onPressed: _handleConfirm,
            child: Text(
              widget.confirmText,
              style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
      ],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    );
  }
}

showConfirmationDialog(
  BuildContext context, {
  required String title,
  required String content,
  required String cancelText,
  required String confirmText,
  Future<void> Function()? onConfirm, // Async callback for confirm action
  VoidCallback? onCancel,
  bool closeOnAction = true,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ConfirmationDialog(
        title: title,
        content: content,
        cancelText: cancelText,
        confirmText: confirmText,
        onCancel: onCancel,
        onConfirm: onConfirm,
        closeOnAction: closeOnAction,
      );
    },
  );
}
