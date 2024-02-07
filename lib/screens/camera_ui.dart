import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ScreenCameraUi extends StatefulWidget {
  const ScreenCameraUi({super.key});

  @override
  State<ScreenCameraUi> createState() => _ScreenCameraUiState();
} 

class _ScreenCameraUiState extends State<ScreenCameraUi> {

  late String path;
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 159, 133, 255),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Photos',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 159, 133, 255),
        foregroundColor: Colors.white,
        onPressed: () async {
          await _pickImage();
        },
        child: const Icon(Icons.add_a_photo_outlined),
      ),
      body: FutureBuilder<List<File>>(
        future: _loadImages(),
        builder: (context, file) {
          Widget child;

          if (file.hasData) {
            if (file.data!.isEmpty) {
              child = const Center(
                child: Text(''),
              );
            } else {
              child = GridView.builder(
                itemCount: file.data!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  
                ),
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => InteractiveViewer(
                          child: Image.file(file.data![index]),
                        ),
                      );
                    },
                    child: Card(
                      child: GridTile(
                        child: Image.file(file.data![index]),
                      ),
                    ),
                  ),
                ),
              );
            }
          } else {
            child = const Center(
              child: Icon(
                Icons.image,
                size: 50,
                color: Colors.grey, // Customize the color as needed
              ),
            );
          }
          return child;
        },
      ),
    );
  }

  Future<String> createFolder() async {
    final path1 = Directory("storage/emulated/0/Photos_storage");
    var status = await Permission.storage.status;
    // print(status);

    if (!(status.isGranted)) {
      // print('object');
      await Permission.manageExternalStorage.request();
    }

    if (!(await path1.exists())) {
      await path1.create(recursive: true);
    }

    return path1.path;
  }

  Future<List<File>> _loadImages() async {
     path= await createFolder();
    final List<FileSystemEntity> files = Directory(path).listSync();

    List<File> imageFiles = files.whereType<File>().toList();
    return imageFiles;
  }

  _pickImage() async {
    ImagePicker picker = ImagePicker();
    XFile? image1 = await picker.pickImage(source: ImageSource.camera);

    if (image1 != null) {
      File tmpFile = File(image1.path);
      final String fileName = basename(image1.path);

      path = await createFolder();
      tmpFile = await tmpFile.copy('$path/$fileName');

      // Update the UI
      setState(() {});
    }
  }
}