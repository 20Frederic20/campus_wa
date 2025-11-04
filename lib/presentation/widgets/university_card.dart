import 'dart:developer';

import 'package:campus_wa/domain/models/university.dart';
import 'package:flutter/material.dart';

class UniversityCard extends StatefulWidget {
  const UniversityCard({super.key, required this.university, required this.onTap});

  final University university;
  final VoidCallback onTap;

  @override
  State<UniversityCard> createState() => _UniversityCardState();
}

class _UniversityCardState extends State<UniversityCard> {
  double _height = 100;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(left: 16, bottom: 16),
      child: Align(
        alignment: Alignment.topCenter,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          height: _height,
          child: ListTile(
            //onTap: widget.onTap,
            title: Text(widget.university.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(widget.university.slug),
            trailing: IconButton(
              onPressed: () {
                setState(() {
                  if(_height == 100){
                    _height = 200;
                  }else{
                    _height = 100;
                  }
                  log('Height: $_height');
                });
              }, 
              icon: const Icon(Icons.keyboard_arrow_up, size: 16)),
          ),
        ),
      ),
    );
  }
}