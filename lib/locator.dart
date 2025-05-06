import 'package:get_it/get_it.dart';
import 'package:chatapp/chat/repo/chat_repo.dart';
import 'package:chatapp/home/repo/home_repo.dart';
import 'login/repository/login_repo.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerFactory<LoginRepository>(() => LoginRepositoryImpl());
  locator.registerFactory<HomeRepository>(() => HomeRepositoryImpl());
  locator.registerFactory<ChatRepository>(() => ChatRepositoryImpl());
}
