import 'dart:io';
import 'dart:convert';

void main() {
  final dir = Directory('.');
  final List<Map<String, dynamic>> screens = [];

  for (var entity in dir.listSync()) {
    if (entity is Directory) {
      final name = entity.path.split(Platform.pathSeparator).last;
      if (name == 'nafaj' || name == '.dart_tool' || name == '.idea' || name.startsWith('.')) continue;
      
      final file = File('${entity.path}/code.html');
      
      if (file.existsSync()) {
        final content = file.readAsStringSync();
        
        var title = name;
        final lines = content.split('\n');
        for (var line in lines) {
          if (line.contains('<title>')) {
            final start = line.indexOf('<title>') + 7;
            final end = line.indexOf('</title>');
            if (end > start) {
              title = line.substring(start, end).trim();
            }
          }
        }
        
        final links = <String>{};
        for (var l in lines) {
            final parts = l.split('"');
            for (var p in parts) {
                if (p.endsWith('.html')) {
                    links.add(p.split('/').last);
                }
            }
            final parts2 = l.split("'");
            for (var p in parts2) {
                if (p.endsWith('.html')) {
                    links.add(p.split('/').last);
                }
            }
        }
        
        final parts = name.split('_');
        final className = parts.map((e) => e.isNotEmpty ? '${e[0].toUpperCase()}${e.substring(1)}' : '').join('') + 'Screen';
        
        screens.add({
          'dir_name': name,
          'class_name': className,
          'title': title,
          'links': links.toList(),
        });
      }
    }
  }

  File('analysis.json').writeAsStringSync(const JsonEncoder.withIndent('  ').convert(screens));
  print('Analysis complete. Found ${screens.length} screens.');
}
