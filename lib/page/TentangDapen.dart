import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

import '../main.dart';

class TentangDapen extends StatefulWidget {
  @override
  _TentangDapenState createState() => _TentangDapenState();
}

class _TentangDapenState extends State<TentangDapen> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  Map<String, dynamic> _seputarDapen = {};

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('Token: $token');

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/seputardapen/4'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _seputarDapen = responseBody['seputardapen'];
          _isLoading = false;
        });
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
  void initState() {
    super.initState();
    _fetchData();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        idUser = prefs.getInt('idUser') ?? 0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    String connectivityInfo = isOnline ? 'Terhubung ke Internet' : 'Tidak Terhubung ke Internet';
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang DAPEN'),
        backgroundColor: Colors.blue,
      ),
      drawer: idUser != null ? buildDrawer(context, idUser!) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Html(
              data: _seputarDapen['judul'] ?? '',
            ),
            SizedBox(height: 16.0),
            Html(
              data: _seputarDapen['deskripsi'] ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
