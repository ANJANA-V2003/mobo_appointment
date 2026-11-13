import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/database_model.dart';

class ServerService {
  Future<List<DatabaseModel>> fetchDatabases(
      String serverUrl,
      ) async {
    final url = Uri.parse('$serverUrl/web/database/list');

    try {
      print('Request URL: $url');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {},
          'id': 1,
        }),
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        // Odoo JSON-RPC response contains the result.
        final List<dynamic> data = decoded['result'];

        return data
            .map((item) => DatabaseModel.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Unable to fetch databases. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Database Fetch Error: $e');
      throw Exception('Server connection failed: $e');
    }
  }
}


