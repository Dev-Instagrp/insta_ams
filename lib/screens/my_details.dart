import 'package:flutter/material.dart';


class MyDetails extends StatefulWidget {
  const MyDetails({super.key});

  @override
  State<MyDetails> createState() => _MyDetailsState();
}

class _MyDetailsState extends State<MyDetails> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text("MyDetails"),
    );
  }
}
