import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:band_names/model/band.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    Band(id: '1', name: 'Metallica', votes: 5),
    Band(id: '2', name: 'Queen', votes: 1),
    Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        itemCount: bands.length,
        itemBuilder: (context, i) => _bandTitle(bands[i])
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      ),
   );
  }

  Widget _bandTitle(Band band) {
    return Dismissible(
      key: Key(band.id),
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        alignment: Alignment.centerLeft,
        child: Text('Delete Band', style: TextStyle(color: Colors.white),),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        print('direction: $direction');
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20),),
        onTap: (){}
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('New band name'),
            content: TextField(
              controller: textController,
            ),
            actions: [
              MaterialButton(
                child: Text('Add'),
                elevation: 5,
                textColor: Colors.blue,
                onPressed: () => addBandToList(textController.text)
              )
            ],
          );
        }
      );
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: Text('New band name'),
            content: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: CupertinoTextField(
                controller: textController,
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                child: Text('Add'),
                onPressed: () => addBandToList(textController.text)
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: Text('Dimiss'),
                onPressed: () => Navigator.pop(context)
              )
            ],
          );
        }
      );
    }

  }

  void addBandToList(String bandname) {
    if (bandname.isNotEmpty) {
      this.bands.add(Band(
        id: DateTime.now().toString(),
        name: bandname,
        votes: 0
      ));

      setState(() {});
    }

    Navigator.pop(context);
  }
}