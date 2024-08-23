import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saldodapenkujang/database/database_helper.dart';
import 'package:saldodapenkujang/page/logout_success_screen.dart';

class Logout extends StatelessWidget {
  Future<void> _clearData(BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('token');
      prefs.remove('idUser');
      prefs.remove('namaLengkap');

      DatabaseHelper databaseHelper = DatabaseHelper();
      await databaseHelper.initDatabase();
      await databaseHelper.clearUsersTable();
      await databaseHelper.closeDatabase();

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => LogoutSuccessScreen()));
    } catch (e) {
      print('Error clearing data: $e');
      throw Exception('Gagal menghapus data pengguna.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder(
          future: _clearData(context),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 16.0),
                  Image.asset('assets/images/logo.png',),
                  SizedBox(height: 16.0),
                  Text('Anda telah berhasil keluar.'),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: Text('Masuk kembali'),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
