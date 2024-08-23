import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:saldodapenkujang/main.dart';
import 'package:intl/intl.dart';

class InfoSaldo extends StatefulWidget {
  @override
  _InfoSaldoState createState() => _InfoSaldoState();
}

class _InfoSaldoState extends State<InfoSaldo> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  List<Map<String, dynamic>> _InfoSaldoList = [];

  // Inisialisasi objek NumberFormat
  late NumberFormat numberFormat = NumberFormat("#,##0");


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
            _InfoSaldoList = saldoPensiunList.cast<Map<String, dynamic>>();
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

  @override
  Widget build(BuildContext context) {
    // String connectivityInfo = isOnline ? 'Terhubung ke Internet' : 'Tidak Terhubung ke Internet';
    return Scaffold(
      appBar: AppBar(
        title: Text('Saldo Pensiun'),
        backgroundColor: Colors.blue,
      ),
      drawer: idUser != null ? buildDrawer(context, idUser!) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              columnSpacing: 10.0,
              columns: [
                DataColumn(label: Text('Tgl.Saldo')),
                DataColumn(label: Text('Iuran Pstr')),
                DataColumn(label: Text('Iuran Pshn')),
                DataColumn(label: Text('Peng.Bbn Pshn')),
                DataColumn(label: Text('Saldo Akhir')),
              ],
              rows: _InfoSaldoList.map((info) {
                return DataRow(cells: [
                  DataCell(Text(info['tgl_saldo'] ?? '')),
                  DataCell(Text(numberFormat.format(info['iuran_peserta'] ?? 0))),
                  DataCell(Text(numberFormat.format(info['iuran_perusahaan'] ?? 0))),
                  DataCell(Text(numberFormat.format(info['pengembangan_beban_perusahaan'] ?? 0))),
                  DataCell(Text(numberFormat.format(info['saldo_akhir'] ?? 0))),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
