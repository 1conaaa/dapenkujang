import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:saldodapenkujang/page/Login.dart';
import 'package:saldodapenkujang/page/Dashboard.dart';
import 'package:saldodapenkujang/page/Logout.dart';
import 'package:saldodapenkujang/page/TentangDapen.dart';
import 'package:saldodapenkujang/page/ProfileUser.dart';
import 'package:saldodapenkujang/page/VisiMisi.dart';
import 'package:saldodapenkujang/page/StrukturOrganisasi.dart';
import 'package:saldodapenkujang/page/HubungiKami.dart';
import 'package:saldodapenkujang/page/InfoSaldo.dart';
import 'package:saldodapenkujang/page/InfoTerkini.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DAPEN KUJANG',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: isLoggedIn ? '/' : '/login',
      routes: {
        '/login': (BuildContext context) => Login(),
        '/dashboard': (BuildContext context) => Dashboard(),
        '/logout': (BuildContext context) => Logout(),
        '/tentangdapen': (BuildContext context) => TentangDapen(),
        '/profileuser': (BuildContext context) => ProfileUser(),
        '/visimisi': (BuildContext context) => VisiMisi(),
        '/strukturorganisasi': (BuildContext context) => StrukturOrganisasi(),
        '/hubungikami': (BuildContext context) => HubungiKami(),
        '/infosaldo': (BuildContext context) => InfoSaldo(),
        '/infoterkini': (BuildContext context) => InfoTerkini(),
      },
    );
  }
}

Drawer buildDrawer(BuildContext context, int idUser) {
  String namaLengkap = ''; // Deklarasikan variabel namaLengkap
  SharedPreferences.getInstance().then((prefs) {
    // Ambil nilai namaLengkap dari SharedPreferences
    namaLengkap = prefs.getString('namaLengkap') ?? '';
  });

  return Drawer(
    child: Container(
      color: Colors.black87, // Ubah warna latar belakang drawer sesuai kebutuhan Anda
      child: ListView(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 10), // Atur jarak antara ListTile dengan Divider
            child: ListTile(
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 50, // Sesuaikan lebar gambar
                    height: 50, // Sesuaikan tinggi gambar
                  ),
                  SizedBox(width: 15), // Beri jarak antara gambar dan teks
                  Text(
                    'DAPEN KUJANG',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onTap: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ),
          Divider(),
          ListTile(
            title: Text('Dashboard', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.dashboard_rounded, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/dashboard');
            },
          ),
          ListTile(
            title: Text('Profile Peserta', style: TextStyle(color: Colors.white),), // Gunakan nilai namaLengkap di sini
            leading: Icon(
              Icons.supervised_user_circle_outlined,
              color: Colors.white,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profileuser');
            },
          ),
          ListTile(
            title: Text('Tentang DAPEN', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.home_filled, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/tentangdapen');
            },
          ),
          ListTile(
            title: Text('Visi & Misi', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.visibility, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/visimisi');
            },
          ),
          ListTile(
            title: Text('Struktur Organisasi', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.account_tree, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/strukturorganisasi');
            },
          ),
          ListTile(
            title: Text('Info Saldo', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.money, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/infosaldo');
            },
          ),
          ListTile(
            title: Text('Info Terkini', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.info, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/infoterkini');
            },
          ),
          ListTile(
            title: Text('Hubungi Kami', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.phone, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/hubungikami');
            },
          ),
          ListTile(
            title: Text('Keluar', style: TextStyle(color: Colors.white),),
            leading: Icon(Icons.logout, color: Colors.white,),
            onTap: () {
              Navigator.pushNamed(context, '/logout');
            },
          ),
          // Footer
          Container(
            margin: EdgeInsets.only(top: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // Spacer untuk mendorong teks ke bawah
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'www.dapenkujang.co.id',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Versi 2.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    ),
  );
}
