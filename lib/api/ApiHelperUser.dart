
class ApiResponseUser {
  final int success;
  final String token;
  final User user;

  ApiResponseUser({
    required this.success,
    required this.token,
    required this.user,
  });

  factory ApiResponseUser.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('json must not be null');
    }

    return ApiResponseUser(
      success: json['success'] ?? 0,
      token: json['token'] ?? '',
      user: User.fromJson(json['user'] ?? {}),
    );
  }
}

class User {
  final int idUser;
  final int idGroup;
  final int idCompany;
  final int idCabang;
  final String namaLengkap;
  final String nik;
  final String tglMasukKerja;
  final String noKtp;
  final String tmpLahir;
  final String tglLahir;
  final String email;
  final String noTelepon;
  final String alamat;
  final String namaUser;
  final String password;
  final String foto;
  final String aktif;

  User({
    required this.idUser,
    required this.idGroup,
    required this.idCompany,
    required this.idCabang,
    required this.namaLengkap,
    required this.nik,
    required this.tglMasukKerja,
    required this.noKtp,
    required this.tmpLahir,
    required this.tglLahir,
    required this.email,
    required this.noTelepon,
    required this.alamat,
    required this.namaUser,
    required this.password,
    required this.foto,
    required this.aktif,
  });

  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('json must not be null');
    }

    return User(
      idUser: json['id'] ?? 0,
      idGroup: json['id_group'] ?? 0,
      idCompany: json['id_company'] ?? 0,
      idCabang: json['id_cabang'] ?? 0,
      namaLengkap: json['nama_lengkap'] ?? '',
      nik: json['nik'] ?? '',
      tglMasukKerja: json['tgl_masuk_kerja'] ?? '',
      noKtp: json['no_ktp'] ?? '',
      tmpLahir: json['tmp_lahir'] ?? '',
      tglLahir: json['tgl_lahir'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      alamat: json['alamat'] ?? '',
      namaUser: json['nama_user'] ?? '',
      password: json['password'] ?? '',
      foto: json['foto'] ?? '',
      aktif: json['aktif'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': idUser,
      'id_group': idGroup,
      'id_company': idCompany,
      'id_cabang': idCabang,
      'nama_lengkap': namaLengkap,
      'nik': nik,
      'tgl_masuk_kerja': tglMasukKerja,
      'no_ktp': noKtp,
      'tmp_lahir': tmpLahir,
      'tgl_lahir': tglLahir,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'nama_user': namaUser,
      'password': password,
      'foto': foto,
      'aktif': aktif,
    };
  }
}
