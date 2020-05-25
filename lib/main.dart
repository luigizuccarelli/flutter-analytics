import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'package:easy_web_view/easy_web_view.dart';
import 'dashboard.dart';

void main() {
  runApp(AnalyticsApp());
}

Future<Dashboard> _fetchStats() async {
  // update local cache
  final cache = await http.get('http://127.0.0.1:9000/api/v1/source');

  final response = await http.get('http://127.0.0.1:9000/api/v1/dashboard/stats');
  if (response.statusCode == 200) {
    return Dashboard.fromJson(json.decode(response.body));
  } else {
    print('Failed to load data');
    throw Exception('Failed to load data');
  }
}


class AnalyticsApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Analytics Dashboard [NMG]',
      theme: ThemeData(
        primaryColor: Colors.blue[800],
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: AnalyticsHomePage(title: 'Analytics Dashboard [NMG]'),
    );
  }
}

class AnalyticsHomePage extends StatefulWidget {
  
AnalyticsHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _AnalyticsHomePageState createState() => _AnalyticsHomePageState();
}


class _AnalyticsHomePageState extends State<AnalyticsHomePage> {

  Future<Dashboard> db;  

  @override
  void initState() {
    super.initState();
    db = _fetchStats();
    Timer.periodic(new Duration(seconds: 300), (timer) {
      var now = new DateTime.now();
      print('[INFO] ${now}'); 
      setState(() {
        db = _fetchStats();
        refreshChart();
      });
    });
  }

  SizedBox buildBox(String name,String data) {
    return SizedBox(
      height: 120.0,
      width: 270.0,
      child: Card(
        color: Colors.grey[800],
        borderOnForeground: true,
        elevation: 5.0,
        margin: EdgeInsets.all(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.label_important, color: Colors.blue[700]),
              title: Text(
                name,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  height: 3.0),
              ),
              //trailing: Icon(Icons.more_vert, color: Colors.white),
              subtitle: Text(
                data,
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SizedBox> buildStatCards(Dashboard dash) {
      List<SizedBox> sb = [];
      sb.add(buildBox('Campaign','Pilot'));
      sb.add(buildBox('Visits', dash.stats.visits.toString()));
      sb.add(buildBox('Confirmations', dash.stats.confirmations.toString()));
      sb.add(buildBox('Convertion Rate', dash.stats.rate.toStringAsFixed(2)+ " %"));
      return sb;
  }

  Container refreshChart() {
    return Container(
      width: 1060.0,
      height: 700.0,
      child: EasyWebView(
        src: 'http://127.0.0.1:9000/api/v2/web/sankey-new.html',
        isHtml: false,
        isMarkdown: false,
        convertToWidets: false,
        key: UniqueKey(),
        width: 20,
        height: 20,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: SafeArea(
        child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                SizedBox(
                  height: 50.0,
                ),
              ],
            ),
            FutureBuilder<Dashboard>(
              future: db,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: buildStatCards(snapshot.data),
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                } 
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : <Widget>[
                    SizedBox(
                      height: 50.0,
                      width: 50.0,
                      child: CircularProgressIndicator(),
                    )
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                SizedBox(
                  height: 800.0,
                  width: 1080.0,
                  child: Card(
                    color: Colors.grey[800],
                    borderOnForeground: false,
                    elevation: 5.0,
                    margin: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget> [
                        ListTile(
                          leading:
                              Icon(Icons.label_important, color: Colors.blue[800]),
                          title: Text(
                            'Sankey Chart',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                          //trailing: Icon(Icons.more_vert, color: Colors.white),
                        ),
                        refreshChart(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
