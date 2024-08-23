import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';

import '../main.dart';

class StrukturOrganisasi extends StatefulWidget {
  @override
  _StrukturOrganisasiState createState() => _StrukturOrganisasiState();
}

class _StrukturOrganisasiState extends State<StrukturOrganisasi> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  Map<String, dynamic> _seputarDapen = {};
  List<Map<String, dynamic>> _ourTeam = [];

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('Token: $token');

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/seputardapen/5'),
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

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/ourteam'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        List<dynamic> responseBodyList = jsonDecode(response.body);
        if (responseBodyList.isNotEmpty) {
          setState(() {
            _ourTeam = responseBodyList.cast<Map<String, dynamic>>(); // Mengonversi List<dynamic> menjadi List<Map<String, dynamic>>
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
        title: Text('Struktur DAPEN'),
        backgroundColor: Colors.blue,
      ),
      drawer: idUser != null ? buildDrawer(context, idUser!) : null,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading? Center(
          child: CircularProgressIndicator(),
        ): SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Html(
                data: _seputarDapen['judul'] ?? '',
              ),
              SizedBox(height: 16.0),
              Html(
                data: _seputarDapen['deskripsi'] ?? '',
              ),
              SizedBox(height: 16.0),
              Image.network(
                'https://backend.dapenkujang.co.id/uploads/${_seputarDapen['file_name']}' ?? '',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
              SizedBox(height: 16.0),
              Text(
                'Our Team',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.0),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (var team in _ourTeam) ...[
                      Column(
                        children: [
                          Image.network(
                            'https://backend.dapenkujang.co.id/uploads/${team['file_name']}' ?? '',
                            fit: BoxFit.cover,
                            width: MediaQuery.of(context).size.width * 0.4,
                          ),
                          SizedBox(height: 4.0), // Jarak antara gambar dan teks
                          Text(
                            team['nama'] ?? '', // Ganti 'name' dengan key yang sesuai dari data teks
                            textAlign: TextAlign.center, // Posisi teks diatur menjadi center
                          ),
                          SizedBox(height: 4.0), // Jarak antara gambar dan teks
                          Text(
                            team['posisi'] ?? '', // Ganti 'name' dengan key yang sesuai dari data teks
                            textAlign: TextAlign.center, // Posisi teks diatur menjadi center
                          ),
                        ],
                      ),
                      SizedBox(width: 8.0),
                    ],
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


}
