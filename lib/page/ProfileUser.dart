import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
import 'package:saldodapenkujang/database/database_helper.dart';
import 'package:saldodapenkujang/main.dart';
import 'package:sqflite/sqflite.dart';

class ProfileUser extends StatefulWidget {
  @override
  _ProfileUserState createState() => _ProfileUserState();
}

class _ProfileUserState extends State<ProfileUser> {
  bool isOnline = false;
  int? idUser; // Menggunakan nullable jika idUser mungkin belum diinisialisasi
  late String token;
  late String namaLengkap;

  // final picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  get krubisData => null;

  DatabaseHelper databaseHelper = DatabaseHelper.instance;

  get fotoProfil => null;

  Future<void> _initUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idUser = prefs.getInt('idUser') ?? 0;
      token = prefs.getString('token') ?? '';
    });
  }

  Future<List<Map<String, dynamic>>> _getUserData() async {
    List<Map<String, dynamic>> users = [];
    DatabaseHelper databaseHelper = DatabaseHelper.instance;

    try {
      users = await databaseHelper.queryUsers();
    } catch (e) {
      print('Error while fetching user data: $e');
      // Menangani eksepsi yang mungkin terjadi
    }

    return users;
  }

  String generateHMAC(String data, String secret) {
    var key = utf8.encode(secret); // Konversi secret ke format byte
    var bytes = utf8.encode(data); // Konversi data ke format byte
    var hmacSha256 = Hmac(sha256, key); // Inisialisasi Hmac dengan SHA-256
    var digest = hmacSha256.convert(
        bytes); // Hitung hash dari data dengan secret
    return digest.toString(); // Kembalikan hash dalam format string
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updatepassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String namaUser = await prefs.getString('namaUser') ?? '';

    setState(() {
      _isLoading = true;
    });

    String password = _passwordController.text;
    String secret = 'mySecretKey';

    String hashedPassword = generateHMAC(password, secret);
    print('Hashed Password: $hashedPassword');

    try {
      final response = await http.put(
        Uri.parse(
            'https://backend.dapenkujang.co.id/api/updatepassword/$namaUser?password=$password'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Response variable: $token , $namaUser , $password');
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> responseBody = jsonDecode(response.body);
        print('Response body: ${responseBody}');
      } else {
        _showDialog('Anda gagal melakukan memperbaharui password.');
      }
    } catch (error) {
      print('Error: $error');
      _showDialog('Terjadi kesalahan saat memperbaharui password.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initUser(),
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        if (snapshot.hasError) {
          // Menampilkan pesan error jika terjadi kesalahan saat inisialisasi pengguna
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile Peserta'),
              backgroundColor: Colors.blue,
            ),
            drawer: idUser != null ? buildDrawer(context, idUser!) : null,
            body: Center(
              child: Text('Failed to load user data.'),
            ),
          );
        } else {
          // Tampilan utama jika inisialisasi pengguna berhasil
          return Scaffold(
            appBar: AppBar(
              title: Text('Profile Peserta'),
              backgroundColor: Colors.blue,
            ),
            drawer: idUser != null ? buildDrawer(context, idUser!) : null,
            body: Column(
              children: [
                SizedBox(height: 10.0),
                Text(
                  'Profil Peserta',
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10.0),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 4.0,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _getUserData(),
                        builder: (BuildContext context, AsyncSnapshot<
                            List<Map<String, dynamic>>> snapshot) {
                          if (snapshot.hasError) {
                            // Menampilkan pesan error jika terjadi kesalahan saat mengambil data pengguna
                            return Center(
                              child: Text(
                                  'Failed to fetch user data from database.'),
                            );
                          } else
                          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            // Menampilkan data pengguna jika ada
                            List<Map<String, dynamic>> users = snapshot.data!;
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: users.length,
                              itemBuilder: (BuildContext context, int index) {
                                Map<String, dynamic> user = users[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10.0),
                                    // Jarak antara setiap item
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        // Foto dengan frame lingkaran
                                        Column(
                                          children: [
                                            CircleAvatar(
                                              radius: 50,
                                              backgroundImage: AssetImage(
                                                  'assets/images/logo.png'),
                                            ),
                                            SizedBox(height: 8.0),
                                            // Jarak antara foto dan teks
                                            // Teks nama lengkap
                                            Text(
                                              '${user['nama_lengkap']}',
                                              style: TextStyle(
                                                fontSize: 16.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(height: 8.0),
                                            // Jarak antara nama lengkap dan NIK
                                            // Teks NIK
                                            Text(
                                              '${user['nik']}',
                                              // Menggunakan teks NIK di sini
                                              style: TextStyle(fontSize: 14.0),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment
                                          .center,
                                      children: [
                                        // Container yang berisi form username dan password
                                        Container(
                                          constraints: BoxConstraints(
                                              minWidth: 200.0, maxWidth: 300.0),
                                          // Memberikan batasan lebar minimal dan maksimal untuk container
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .start,
                                              children: [
                                                SizedBox(height: 8.0),
                                                // Jarak antara nama lengkap dan NIK
                                                // Teks Password
                                                TextFormField(
                                                  controller: _passwordController,
                                                  obscureText: true,
                                                  decoration: InputDecoration(
                                                    labelText: 'Password',
                                                    labelStyle: TextStyle(
                                                        fontSize: 20.0), // Menentukan ukuran font label
                                                  ),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter your password';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                                SizedBox(height: 8.0),
                                                // Jarak antara nama lengkap dan NIK
                                                // Tombol Update
                                                SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: _isLoading
                                                        ? null
                                                        : _updatepassword,
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      shape: RoundedRectangleBorder( // Menggunakan RoundedRectangleBorder untuk membuat tombol kotak
                                                        borderRadius: BorderRadius
                                                            .circular(
                                                            0), // Mengatur radius border menjadi 0 untuk membuatnya kotak
                                                      ),
                                                      backgroundColor: Colors
                                                          .blueAccent,
                                                    ),
                                                    child: Text('Update',
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                        color: Colors.white,
                                                        // Mengatur warna teks menjadi putih
                                                        fontWeight: FontWeight
                                                            .normal, // Mencetak teks tebal
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Menampilkan pesan jika tidak ada data pengguna
                            return Center(
                              child: Text('No user data found.'),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

void _showDialog(String s) {
}
