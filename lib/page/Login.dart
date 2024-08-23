import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saldodapenkujang/database/database_helper.dart';
import 'package:saldodapenkujang/api/ApiHelperUser.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Result'),
          content: Text(message),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Masuk'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text;
    String password = _passwordController.text;

    final response = await http.post(
      Uri.parse('https://backend.dapenkujang.co.id/api/auth/login'),
      body: {
        'email': username,
        'password': password,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      Map<String, dynamic> responseBody = jsonDecode(response.body);
      print('Response body: ${responseBody['login']}');

      bool loginSuccess = responseBody['login'] == 'true';
      if (loginSuccess) {
        String token = responseBody['token'];
        Map<String, dynamic> userJson = responseBody['user'];
        User user = User.fromJson(userJson);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setInt('idGroup', user.idGroup);
        await prefs.setInt('idUser', user.idUser);
        await prefs.setString('namaLengkap', user.namaLengkap);
        await prefs.setString('namaUser', user.namaUser);
        await prefs.setString('password', user.password);
        await prefs.setString('foto', user.foto);
        DatabaseHelper databaseHelper = DatabaseHelper();
        try {
          await databaseHelper.initDatabase();
          await databaseHelper.insertUser(user.toMap());
          print('Data berhasil disimpan:');
          await databaseHelper.closeDatabase();
        } catch (e) {
          print('Error: $e');
        }

        print('Navigasi ke halaman utama dimulai'); // Debugging sebelum navigasi
        Navigator.pushReplacementNamed(context, '/dashboard').then((_) {
          print('Navigasi berhasil'); // Debugging setelah navigasi berhasil
          _showDialog(context, 'Salam ${user.namaLengkap}, Anda berhasil login.');
        }).catchError((e) {
          print('Navigasi gagal: $e'); // Debugging jika terjadi error saat navigasi
        });
      } else {
        _showDialog(context, 'Anda gagal melakukan login. Silakan coba lagi.');
      }



    } else {
      _showDialog(context, 'Anda gagal melakukan login. Silakan coba lagi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aplikasi Saldo Dana Pensiun'),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue, // Menambahkan warna latar belakang
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              // Add logo here
              SizedBox(height: 10.0),
              Image.asset('assets/images/logo.png',),
              SizedBox(height: 20.0),
              Text(
                'DAPEN KUJANG', // Label text below the logo
                style: TextStyle(
                  fontSize: 35.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.0),
              Container(
                padding: EdgeInsets.all(20.0), // Add padding to create a frame
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey), // Add border
                  borderRadius: BorderRadius.circular(10.0), // Add border radius for rounded corners
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          labelStyle: TextStyle(fontSize: 20.0), // Menentukan ukuran font label
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(fontSize: 20.0), // Menentukan ukuran font label
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder( // Menggunakan RoundedRectangleBorder untuk membuat tombol kotak
                                  borderRadius: BorderRadius.circular(0), // Mengatur radius border menjadi 0 untuk membuatnya kotak
                                ),
                                backgroundColor: Colors.blueAccent,
                              ),
                              child: _isLoading
                                  ? CircularProgressIndicator()
                                  : Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white, // Mengatur warna teks menjadi putih
                                  fontWeight: FontWeight.normal, // Mencetak teks tebal
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


}
