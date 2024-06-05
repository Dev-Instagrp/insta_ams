import 'package:flutter/material.dart';

class InputFields extends StatefulWidget {
  final TextEditingController inputController;
  final String label;
  final bool isPassword;

  const InputFields({super.key, required this.inputController, required this.label, required this.isPassword});

  @override
  State<InputFields> createState() => _InputFieldsState();
}

class _InputFieldsState extends State<InputFields> {
  bool _isObscure = true;
  @override
  Widget build(BuildContext context) {

    return TextFormField(
      controller: widget.inputController,
      obscureText: widget.isPassword ? _isObscure : false,
      decoration: InputDecoration(
        labelText: widget.label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        suffixIcon: widget.isPassword ? IconButton(
            onPressed: (){
          setState(() {
            _isObscure = !_isObscure;
          });
        }, icon: _isObscure ? Icon(Icons.remove_red_eye_rounded) : Icon(Icons.remove_red_eye_rounded, color: Colors.blue,)) : null
      ),
    );
  }
}
