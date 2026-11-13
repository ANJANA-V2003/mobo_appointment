import 'package:odoo_rpc/odoo_rpc.dart';

class AuthService {
  Future<({OdooClient client ,OdooSession session })> login({
    required String serverUrl,
    required String database,
    required String username,
    required String password,
  }) async {
    final client = OdooClient(serverUrl);

    try{final session = await client.authenticate(
        database,
        username,
        password);

      return(
      client: client,
      session : session
      );

    } catch(e){
      client.close();
      rethrow;
    }
  }
}

