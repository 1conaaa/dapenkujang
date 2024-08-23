import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:saldodapenkujang/main.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool _isLoading = false;
  bool isOnline = false;
  int idUser = 0;
  String namaLengkap = '';
  List<Map<String, dynamic>> _DashboardList = [];

  // Inisialisasi objek NumberFormat
  NumberFormat numberFormat = NumberFormat("#,##0");

  @override
  void initState() {
    super.initState();
    // Panggil _fetchData() di dalam initState
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    String namaUser = prefs.getString('namaUser') ?? '';
    idUser = prefs.getInt('idUser') ?? 0;
    print('Token: $token , $idUser , $namaUser');

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/saldopensiun/$namaUser'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        List<dynamic> saldoPensiunList = responseBody['saldopensiun'];
        if (saldoPensiunList.isNotEmpty) {
          setState(() {
            _DashboardList = saldoPensiunList.cast<Map<String, dynamic>>();
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to fetch data from API.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        _isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('An error occurred while fetching data.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  List<FlSpot> _generateDataSpots() {
    List<FlSpot> spots = [];
    for (var i = 0; i < _DashboardList.length; i++) {
      double y = i.toDouble();
      double x = _DashboardList[_DashboardList.length - 1 - i]['saldo_akhir'].toDouble();
      spots.add(FlSpot(y, x));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        backgroundColor: Colors.blue,
      ),
      drawer: buildDrawer(context, idUser),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: _DashboardList.length * 90.0, // Adjust the width as needed
                  height: 400,
                  child: LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: false,
                      ),
                      gridData: FlGridData(show: true),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 80, // Adjust the width of y-axis labels
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: true),
                        ),
                      ),
                      borderData: FlBorderData(
                        show: true,
                        border: Border.all(color: const Color(0xff37434d)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateDataSpots(),
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 1,
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.blue.withOpacity(0),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: DataTable(
                  columnSpacing: 10.0,
                  columns: [
                    DataColumn(label: Text('Tgl.Saldo')),
                    DataColumn(label: Text('Saldo Akhir')),
                  ],
                  rows: _DashboardList.map((info) {
                    return DataRow(cells: [
                      DataCell(Text(info['tgl_saldo'] ?? '')),
                      DataCell(Text(numberFormat.format(info['saldo_akhir'] ?? 0))),
                    ]);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
