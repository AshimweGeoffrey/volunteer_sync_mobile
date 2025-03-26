import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<String?> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Create a local copy of the image
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = DateTime.now().millisecondsSinceEpoch.toString() + 
                             extension(image.path);
      final File localImage = File(join(appDir.path, 'product_images', fileName));
      
      // Create directory if it doesn't exist
      await Directory(join(appDir.path, 'product_images'))
          .create(recursive: true);
          
      // Copy the image to local storage
      await File(image.path).copy(localImage.path);
      
      return localImage.path;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }
}
