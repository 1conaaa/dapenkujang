import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:saldodapenkujang/main.dart';
import 'package:saldodapenkujang/page/InfoTerkiniDetail.dart';

class InfoTerkini extends StatefulWidget {
  @override
  _InfoTerkiniState createState() => _InfoTerkiniState();
}

class _InfoTerkiniState extends State<InfoTerkini> {
  bool _isLoading = false;
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String namaLengkap;
  List<Map<String, dynamic>> _infoTerkiniList = [];


  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('token') ?? '';
    print('Token: $token');

    try {
      final response = await http.get(
        Uri.parse('https://backend.dapenkujang.co.id/api/infoumum'),
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
            _infoTerkiniList = responseBodyList.cast<Map<String, dynamic>>();
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

  Future<void> _downloadPDF(String url) async {
    // Implementasi download PDF
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
        title: Text('Info Terkini'),
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
              for (var info in _infoTerkiniList) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  InfoTerkiniDetail(id: info['id'])),
                        );
                      },
                      child: Html(
                        data: '<b>${info['judul'] ?? ''}</b>',
                        style: {
                          'font-size': Style(
                            fontSize: FontSize(28),
                          ),
                        },
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  InfoTerkiniDetail(id: info['id'])),
                        );
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (info['file_name'].toString().endsWith('.jpg') ||
                              info['file_name'].toString().endsWith('.jpeg') ||
                              info['file_name'].toString().endsWith('.png') ||
                              info['file_name'].toString().endsWith('.gif'))
                            Image.network(
                              'https://backend.dapenkujang.co.id/uploads/${info['file_name']}' ??
                                  '',
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width *
                                  0.3,
                            )
                          else if (info['file_name'].toString().endsWith('.pdf'))
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  0.3,
                              height: MediaQuery.of(context).size.width *
                                  0.3,
                              child: PDFView(
                                filePath:
                                'https://backend.dapenkujang.co.id/uploads/${info['file_name']}' ??
                                    '',
                                onError: (error) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content: Text('Failed to load PDF.'),
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
                                },
                              ),
                            ),
                          SizedBox(width: 10.0),
                          Expanded(
                            child: Html(
                              data: (info['deskripsi'] ?? '').length > 100
                                  ? (info['deskripsi'] ?? '').substring(0, 100) +
                                  '...'
                                  : (info['deskripsi'] ?? ''),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
