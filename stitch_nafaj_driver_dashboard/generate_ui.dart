import 'dart:io';
import 'dart:convert';

void main() {
  final content = File('analysis.json').readAsStringSync();
  final List<dynamic> data = jsonDecode(content);

  final screensDir = Directory('nafaj/lib/screens');
  if (!screensDir.existsSync()) {
    screensDir.createSync(recursive: true);
  }

  final routesFile = File('nafaj/lib/routes/app_routes.dart');
  if (!routesFile.parent.existsSync()) {
    routesFile.parent.createSync(recursive: true);
  }

  final StringBuffer routesBuffer = StringBuffer();
  routesBuffer.writeln('import \'package:flutter/material.dart\';');
  
  for (var screen in data) {
    final fileName = '${screen['dir_name']}.dart';
    routesBuffer.writeln('import \'../screens/$fileName\';');
    
    final screenFile = File('nafaj/lib/screens/${fileName}');
    final screenContent = '''
import 'package:flutter/material.dart';

class ${screen['class_name']} extends StatelessWidget {
  const ${screen['class_name']}({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('${screen['title']}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('${screen['class_name']} Placeholder'),
            const SizedBox(height: 20),
            ${screen['links'].map((l) => 'ElevatedButton(onPressed: () => Navigator.pushNamed(context, \'/${l.replaceAll('.html', '')}\'), child: const Text(\'Go to $l\')),').join('\n            ')}
          ],
        ),
      ),
    );
  }
}
''';
    screenFile.writeAsStringSync(screenContent);
  }

  routesBuffer.writeln();
  routesBuffer.writeln('class AppRoutes {');
  routesBuffer.writeln('  static Map<String, WidgetBuilder> get routes {');
  routesBuffer.writeln('    return {');
  for (var screen in data) {
    routesBuffer.writeln('      \'/${screen['dir_name']}\': (context) => const ${screen['class_name']}(),');
  }
  routesBuffer.writeln('    };');
  routesBuffer.writeln('  }');
  
  // Try to find splash or home for default route
  var initialRoute = '/nafaj_splash_screen_blinkit_style';
  routesBuffer.writeln();
  routesBuffer.writeln('  static String get initialRoute => \'$initialRoute\';');
  routesBuffer.writeln('}');

  routesFile.writeAsStringSync(routesBuffer.toString());

  print('Successfully generated \${data.length} screens and routes!');
}
