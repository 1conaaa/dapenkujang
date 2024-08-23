import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saldodapenkujang/main.dart';

class HubungiKami extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HubungiKami> {
  bool _isLoading = false;
  TextEditingController _pesanController = TextEditingController();
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;

  late GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        idUser = prefs.getInt('idUser') ?? 0;
      });
    });
  }


  Future<void> _kirimpesan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String namaUser = prefs.getString('namaUser') ?? '';

    setState(() {
      _isLoading = true;
    });

    String pesan = _pesanController.text;

    try {
      final response = await http.post(
        Uri.parse('https://backend.dapenkujang.co.id/api/hubungikami'),
        headers: {
          'Authorization': 'Bearer $token',
        },
        body: {
          'nik': namaUser,
          'pesan': pesan,
        },
      );

      print('Response variable: $token , $namaUser , $pesan');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        _showDialog('Kirim pesan berhasil.');
      } else {
        _showDialog('Anda gagal mengirim pesan.');
      }
    } catch (error) {
      print('Error: $error');
      _showDialog('Anda gagal mengirim pesan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hubungi Kami'),
        backgroundColor: Colors.blue,
      ),
      drawer: idUser != null ? buildDrawer(context, idUser!) : null,
      body: Column(
        children: [
          SizedBox(height: 16.0),
          Text(
            'Silahkan Tinggalkan Pesan.',
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  constraints: BoxConstraints(minWidth: 200.0, maxWidth: 400.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8.0),
                        TextFormField(
                          controller: _pesanController,
                          maxLines: 5,
                          decoration: InputDecoration(
                            labelText: 'Tinggalkan pesan disini',
                            labelStyle: TextStyle(fontSize: 20.0),
                            border: OutlineInputBorder(),
                            hintText: 'Masukkan pesan Anda di sini',
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Ketikkan pesan Anda.';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 8.0),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _kirimpesan,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                              backgroundColor: Colors.blueAccent,
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Text('Send',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Info'),
          content: Text(message),
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
