// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _buyLinkController = TextEditingController();
  Uint8List? _imageBytes;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  Future<void> _uploadClothingItem() async {
    if (_imageBytes == null ||
        _nameController.text.isEmpty ||
        _categoryController.text.isEmpty ||
        _buyLinkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select an image')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('clothing_items').add({
        'name': _nameController.text,
        'category': _categoryController.text,
        'buyLink': _buyLinkController.text,
        'imageBytes': _imageBytes,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Clothing item added successfully')),
      );
      _nameController.clear();
      _categoryController.clear();
      _buyLinkController.clear();
      setState(() => _imageBytes = null);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Upload failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Clothing Name'),
            ),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _buyLinkController,
              decoration: const InputDecoration(labelText: 'Buy Link'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Select Image'),
            ),
            const SizedBox(height: 10),
            _imageBytes != null
                ? Image.memory(_imageBytes!, height: 150)
                : const Text('No image selected'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadClothingItem,
              child: const Text('Upload Item'),
            ),
            const SizedBox(height: 30),
            const Divider(),
            const Text('Uploaded Items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('clothing_items')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final items = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ListTile(
                      leading: item['imageBytes'] != null
                          ? Image.memory(item['imageBytes'].bytes, width: 50, height: 50, fit: BoxFit.cover)
                          : const Icon(Icons.image_not_supported),
                      title: Text(item['name'] ?? 'No Name'),
                      subtitle: Text(item['category'] ?? 'No Category'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => FirebaseFirestore.instance.collection('clothing_items').doc(item.id).delete(),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
