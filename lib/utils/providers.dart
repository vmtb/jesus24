
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/main_controller.dart';
import '../controllers/user_controller.dart';



final userController = Provider<UserController>((ref)=>UserController(ref));
final mainController = Provider<MainController>((ref)=>MainController(ref));

final lockApp = StateProvider<bool>((ref)=>false);

