import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saldodapenkujang/main.dart';

class InfoTerkiniDetail extends StatefulWidget {
  final int id;

  InfoTerkiniDetail({required this.id});

  @override
  _InfoTerkiniDetailState createState() => _InfoTerkiniDetailState();
}

class _InfoTerkiniDetailState extends State<InfoTerkiniDetail> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  Map<String, dynamic> _infoTerkini = {};

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('Token: $token');

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/infoumum/${widget.id}'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        setState(() {
          _infoTerkini = responseBody['infoumum'];
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

  Future<String> _downloadPDF(String url, String filename) async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/$filename';
    final response = await http.get(Uri.parse(url));

    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
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
    return Scaffold(
      appBar: AppBar(
        title: Html(
          data: _infoTerkini['judul'] ?? '',
        ),
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
                data: _infoTerkini['judul'] ?? '',
              ),
              SizedBox(height: 16.0),
              Html(
                data: _infoTerkini['deskripsi'] ?? '',
              ),
              SizedBox(height: 16.0),
              if (_infoTerkini['file_name'].toString().endsWith('.jpg') ||
                  _infoTerkini['file_name'].toString().endsWith('.jpeg') ||
                  _infoTerkini['file_name'].toString().endsWith('.png') ||
                  _infoTerkini['file_name'].toString().endsWith('.gif'))
                Image.network(
                  'https://backend.dapenkujang.co.id/uploads/${_infoTerkini['file_name']}' ?? '',
                  fit: BoxFit.cover,
                  width: MediaQuery.of(context).size.width, // Sesuaikan lebar gambar dengan lebar layar
                )
              else if (_infoTerkini['file_name'].toString().endsWith('.pdf'))
                ElevatedButton(
                  onPressed: () async {
                    final filePath = await _downloadPDF(
                      'https://backend.dapenkujang.co.id/uploads/${_infoTerkini['file_name']}' ?? '',
                      _infoTerkini['file_name'] ?? '',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PDFView(
                          filePath: filePath,
                          // indicator: Center(child: CircularProgressIndicator()),
                          fitEachPage: true,
                        ),
                      ),
                    );
                  },
                  child: Text('Buka PDF'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
