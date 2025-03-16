import 'package:flutter/material.dart';

class Adddata extends StatefulWidget {
  const Adddata({super.key});

  @override
  State<Adddata> createState() => _AdddataState();
}

class _AdddataState extends State<Adddata> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}