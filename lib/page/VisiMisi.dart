import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

import '../main.dart';

class VisiMisi extends StatefulWidget {
  @override
  _VisiMisiState createState() => _VisiMisiState();
}

class _VisiMisiState extends State<VisiMisi> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  late Map<String, dynamic> _seputarDapen;

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


  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('Token: $token');

    try {
      final responseMisi = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/seputardapen/2'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final responseVisi = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/seputardapen/1'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response misi status: ${responseMisi.statusCode}');
      print('Response misi body: ${responseMisi.body}');
      print('Response visi status: ${responseVisi.statusCode}');
      print('Response visi body: ${responseVisi.body}');

      if (responseMisi.statusCode == 200 && responseVisi.statusCode == 200) {
        Map<String, dynamic> responseBodyMisi = jsonDecode(responseMisi.body);
        Map<String, dynamic> responseBodyVisi = jsonDecode(responseVisi.body);

        setState(() {
          _seputarDapen = {
            'judulMisi': responseBodyMisi['seputardapen']['judul'],
            'deskripsiMisi': responseBodyMisi['seputardapen']['deskripsi'],
            'judulVisi': responseBodyVisi['seputardapen']['judul'],
            'deskripsiVisi': responseBodyVisi['seputardapen']['deskripsi'],
          };
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Visi & Misi'),
        backgroundColor: Colors.blue,
      ),
      drawer: idUser != null ? buildDrawer(context, idUser!) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: _seputarDapen['judulVisi'] ?? '',
              ),
              SizedBox(height: 16.0),
              Html(
                data: _seputarDapen['deskripsiVisi'] ?? '',
              ),
              Html(
                data: _seputarDapen['judulMisi'] ?? '',
              ),
              SizedBox(height: 16.0),
              Html(
                data: _seputarDapen['deskripsiMisi'] ?? '',
              ),
              SizedBox(height: 16.0),

            ],
          ),
        ),
      ),
    );
  }
}
