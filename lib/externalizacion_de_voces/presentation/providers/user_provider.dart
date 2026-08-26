import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final userChatIaProvider = Provider<User>((ref) {
  final user = ref.watch(authProvider).user;
  return User(id: user?.id ?? "", name: user?.name ?? "");
});

final iaChatIaProvider = Provider<User>((ref) {
  return User(id: "ia-id", name: "Mindsave");
});
