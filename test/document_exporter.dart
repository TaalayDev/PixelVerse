import 'dart:io';

const documentFormats = [
  'pdf',
  'docx',
  'doc',
  'xlsx',
  'xls',
  'pptx',
  'txt',
  'html'
];

void main(List<String>? params) async {
  var path = params?.firstWhere((element) => element.contains('from'));
  path = path?.split('=')[1];
  if (path == null || path.isEmpty) {
    throw 'path not provided';
  }

  if (path.endsWith('/')) path = path.substring(0, path.length - 1);

  explore(path);
}

void explore(String path) {
  var dir = Directory(path);
  var entities = dir.listSync();
  for (var entity in entities) {
    if (entity is File) {
      var ext = entity.path.split('.').last;
      if (documentFormats.contains(ext)) {
        moveFile(entity, '/Users/admin/dev/docs');
      }
    } else if (entity is Directory) {
      explore(entity.path);
    }
  }
}

void moveFile(File file, String dest) {
  var newPath = dest + '/' + file.path.split('/').last;
  file.rename(newPath);
}
