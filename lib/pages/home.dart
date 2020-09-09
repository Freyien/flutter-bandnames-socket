import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pie_chart/pie_chart.dart';

import 'package:band_names/model/band.dart';
import 'package:band_names/services/socket_service.dart';


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Band> bands = [
    // Band(id: '1', name: 'Metallica', votes: 5),
    // Band(id: '2', name: 'Queen', votes: 1),
    // Band(id: '3', name: 'Héroes del Silencio', votes: 2),
    // Band(id: '4', name: 'Bon Jovi', votes: 5),
  ];
  
  @override
  void initState() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.on('active-bands', _handleActiveBands);

    super.initState();
  }

  _handleActiveBands(dynamic payload) {
    this.bands = (payload as List)
      .map((band) => Band.fromMap(band))
      .toList();

    setState(() {});
  }

  @override
  void dispose() {
    final socketService = Provider.of<SocketService>(context, listen: false);
    socketService.socket.off('active-bands');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Band Names', style: TextStyle(color: Colors.black87),),
        backgroundColor: Colors.white,
        elevation: 1,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10),
            child: (socketService.serverStatus == ServerStatus.Online)
              ? Icon(Icons.check_circle, color: Colors.blue[300])
              : Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
      ),
      body: Column(
        children: [
          _showGraph(),

          Expanded(
            child: ListView.builder(
              itemCount: bands.length,
              itemBuilder: (context, i) => _bandTitle(bands[i])
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        elevation: 1,
        onPressed: addNewBand
      ),
   );
  }

  Widget _bandTitle(Band band) {
    final socketService = Provider.of<SocketService>(context, listen: false);

    return Dismissible(
      key: Key(band.id),
      background: Container(
        padding: EdgeInsets.only(left: 8),
        color: Colors.red,
        alignment: Alignment.centerLeft,
        child: Text('Delete Band', style: TextStyle(color: Colors.white),),
      ),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) 
        => socketService.emit('delete-band', {'id': band.id}),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(band.name.substring(0,2)),
          backgroundColor: Colors.blue[100],
        ),
        title: Text(band.name),
        trailing: Text('${band.votes}', style: TextStyle(fontSize: 20),),
        onTap: () 
          => socketService.emit('vote-band', {'id': band.id})
      ),
    );
  }

  addNewBand() {
    final textController = TextEditingController();

    if (!Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (_) =>
          AlertDialog(
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
          )
      );
    } else {
      showCupertinoDialog(
        context: context,
        builder: (_) =>
          CupertinoAlertDialog(
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
          )
      );
    }

  }

  void addBandToList(String bandname) {
    final socketService = Provider.of<SocketService>(context, listen: false);
    if (bandname.isNotEmpty) {
      socketService.emit('add-band', {
        'name': bandname
      });

    }

    Navigator.pop(context);
  }

  Widget _showGraph() {
    Map<String, double> dataMap = {
    };

    bands.forEach((band) { 
      dataMap.putIfAbsent(band.name, () => band.votes.toDouble());
    });

    if (dataMap.length == 0)
      return Container();

    return Container(
      margin: EdgeInsets.only(top: 20),
      height: 200,
      child: PieChart(
        dataMap: dataMap,
        animationDuration: Duration(milliseconds: 800),
        chartLegendSpacing: 32,
        initialAngleInDegree: 0,
        ringStrokeWidth: 25,
        chartType: ChartType.ring,
        chartValuesOptions: ChartValuesOptions(
          chartValueStyle: TextStyle(
            color: Colors.black87
          ),
          decimalPlaces: 1,
          showChartValueBackground: false,
          showChartValues: true,
          showChartValuesInPercentage: true,
          showChartValuesOutside: false,
        ),
      )
    );

  }
}