import 'package:flutter/material.dart';

/// Search box that owns its [TextEditingController].
///
/// Keeping the controller on a GetX controller and disposing it in
/// [GetxController.onClose] crashes the [TextField] when `/navigation` is
/// replaced while this field is still mounted ("used after being disposed").
class SymbolSearchField extends StatefulWidget {
  final String hintText;
  final String initialText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  const SymbolSearchField({
    super.key,
    required this.hintText,
    this.initialText = '',
    required this.onChanged,
    required this.onClose,
  });

  @override
  State<SymbolSearchField> createState() => _SymbolSearchFieldState();
}

class _SymbolSearchFieldState extends State<SymbolSearchField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: widget.onChanged,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF636F85)),
            onPressed: widget.onClose,
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE3E3E9)),
          ),
        ),
      ),
    );
  }
}
