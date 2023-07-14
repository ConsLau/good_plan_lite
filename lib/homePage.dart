import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database/database_helper.dart'; 
import 'TaskProgressChart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {

  final dbHelper = DatabaseHelper.instance;  // Your database helper instance

Stream<int> getTaskCompletionRateStream(int period) {
    switch (period) {
      case 1:
        return dbHelper.streamTasksCompletedToday();
      case 2:
        return dbHelper.streamTasksCompletedThisWeek(); 
      case 3:
        return dbHelper.streamTasksCompletedThisMonth(); 
      default:
        return Stream.value(0);
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.fromLTRB(16, 45, 0, 0),
              height: MediaQuery.of(context).size.height * 0.4,
              decoration:
                  BoxDecoration(color: Color.fromARGB(96, 41, 233, 201)),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Good Plan",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    Text(
                      DateFormat.yMMMd()
                          .format(DateTime.now()), // show current date
                      style: TextStyle(fontSize: 16),
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.2,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: CarouselSlider(
                  options: CarouselOptions(height: 300.0),
                  items: [1, 2, 3].map((i) {
                    String taskType;
                    switch (i) {
                      case 1:
                        taskType = "Daily Task";
                        break;
                      case 2:
                        taskType = "Weekly Task";
                        break;
                      case 3:
                        taskType = "Monthly Task";
                        break;
                      default:
                        taskType = "";
                    }
                    return Builder(
                      builder: (BuildContext context) {
                        return StreamBuilder<int>(
                          stream: getTaskCompletionRateStream(i),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              final progress = snapshot.data! / 100.0;
                              return Container(
                                width: MediaQuery.of(context).size.width,
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                decoration: BoxDecoration(color: Colors.amber),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    TaskProgressChart(taskProgress: progress),
                                    Text(
                                      "${(progress * 100).toStringAsFixed(0)}%", // Show percentage in the middle
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Positioned(
                                      top: 20, // Position the title at the top
                                      child: Text(
                                        taskType,
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
