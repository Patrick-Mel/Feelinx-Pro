import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class FxOtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;

  const FxOtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
  });

  @override
  State<FxOtpInput> createState() => _FxOtpInputState();
}

class _FxOtpInputState extends State<FxOtpInput> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.length > 1) {
      // Auto paste code case
      final code = value.substring(0, widget.length);
      for (int i = 0; i < code.length; i++) {
        _controllers[i].text = code[i];
      }
      widget.onCompleted(code);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }

    final fullCode = _controllers.map((c) => c.text).join();
    if (fullCode.length == widget.length) {
      widget.onCompleted(fullCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(widget.length, (index) {
        return SizedBox(
          width: 48,
          height: 56,
          child: TextField(
            controller: _controllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            maxLength: 1,
            style: FxTypography.titleLarge,
            decoration: InputDecoration(
              counterText: "",
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FxRadius.medium16),
                borderSide: const BorderSide(color: FxColors.darkBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(FxRadius.medium16),
                borderSide: const BorderSide(color: FxColors.primaryCoral, width: 2),
              ),
            ),
            onChanged: (val) => _onChanged(index, val),
          ),
        );
      }),
    );
  }
}
