import '../core/network/dio_client.dart';
import '../models/user_model.dart';
import 'storage_service.dart';

class AuthService {
  final DioClient _dio;
  AuthService(this._dio);

  Future<UserModel> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    final user = UserModel.fromJson(response.data);
    if (user.token != null) await StorageService.saveToken(user.token!);
    return user;
  }

  Future<UserModel> signup(String name, String email, String password) async {
    final response = await _dio.post('/auth/signup', data: {'name': name, 'email': email, 'password': password});
    final user = UserModel.fromJson(response.data);
    if (user.token != null) await StorageService.saveToken(user.token!);
    return user;
  }

  Future<void> logout() async {
    await _dio.post('/auth/logout');
    await StorageService.clearAll();
  }
}
