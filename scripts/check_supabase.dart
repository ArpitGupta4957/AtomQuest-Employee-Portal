import 'dart:convert';
import 'dart:io';

Future<void> main() async {
  final envFile = File('.env');
  if (!await envFile.exists()) {
    print('No .env file found in project root.');
    exit(2);
  }

  final lines = await envFile.readAsLines();
  String supabaseUrl = '';
  String supabaseKey = '';
  for (var l in lines) {
    if (l.startsWith('SUPABASE_URL=')) supabaseUrl = l.split('=')[1].trim();
    if (l.startsWith('SUPABASE_ANON_KEY='))
      supabaseKey = l.substring(l.indexOf('=') + 1).trim();
  }

  if (supabaseUrl.isEmpty || supabaseKey.isEmpty) {
    print('Missing SUPABASE_URL or SUPABASE_ANON_KEY in .env');
    exit(2);
  }

  final uri = Uri.parse('$supabaseUrl/rest/v1/goals?select=*&limit=1');
  final client = HttpClient();
  try {
    print('Requesting: ${uri.toString()}');
    final req = await client.getUrl(uri);
    req.headers.set('apikey', supabaseKey);
    req.headers.set('Authorization', 'Bearer $supabaseKey');
    req.headers.set('Accept', 'application/json');

    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();

    print('HTTP ${res.statusCode} ${res.reasonPhrase}');
    print('Response headers:');
    res.headers.forEach(
      (name, values) => print('  $name: ${values.join(', ')}'),
    );
    print('\nBody:\n$body');
  } catch (e) {
    print('Request failed: $e');
    exit(1);
  } finally {
    client.close(force: true);
  }
}
