import 'dart:io';
import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditClassroomScreen extends StatefulWidget {
  const EditClassroomScreen({super.key, required this.classroomId});
  final String classroomId;

  @override
  _EditClassroomScreenState createState() => _EditClassroomScreenState();
}

class _EditClassroomScreenState extends State<EditClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _lngController = TextEditingController();
  final _latController = TextEditingController();

  File? _mainImageFile;
  final List<File> _annexesImagesFiles = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedUniversityId;

  @override
  void initState() {
    super.initState();
    _loadClassroom();
  }

  Future<void> _loadClassroom() async {
    try {
      final classroom = await di.getIt<ClassroomRepository>().getClassroomById(
        widget.classroomId,
      );
      if (classroom != null) {
        setState(() {
          _nameController.text = classroom.name;
          _slugController.text = classroom.slug;
          _lngController.text = classroom.lng;
          _latController.text = classroom.lat;
          _selectedUniversityId = classroom.universityId;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement de la salle';
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _mainImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAnnexeImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _annexesImagesFiles.addAll(
          pickedFiles.map((file) => File(file.path)).toList(),
        );
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final classroom = Classroom(
        id: widget.classroomId,
        universityId: _selectedUniversityId!,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        lng: _lngController.text.trim().isNotEmpty
            ? _lngController.text.trim()
            : '',
        lat: _latController.text.trim().isNotEmpty
            ? _latController.text.trim()
            : '',
        createdAt: DateTime.now(), // Ces champs seront mis à jour côté serveur
        updatedAt: DateTime.now(),
      );

      final updated = await di.getIt<ClassroomRepository>().updateClassroom(
        widget.classroomId,
        classroom,
        _mainImageFile,
        annexesImages: _annexesImagesFiles,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salle de classe mise à jour avec succès'),
          ),
        );
        Navigator.of(context).pop(updated);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier la salle'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _submitForm),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom de la salle'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Ce champ est requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _slugController,
                decoration: const InputDecoration(
                  labelText: 'Libelle*',
                  hintText: 'ex: salle-101',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un libelle';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lngController,
                decoration: const InputDecoration(labelText: 'Longitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _latController,
                decoration: const InputDecoration(labelText: 'Latitude'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              const Text('Image principale:'),
              const SizedBox(height: 8),
              _mainImageFile != null
                  ? Image.file(_mainImageFile!, height: 150)
                  : ElevatedButton(
                      onPressed: _pickImage,
                      child: const Text('Sélectionner une image'),
                    ),
              const SizedBox(height: 24),
              const Text('Images annexes:'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._annexesImagesFiles.map(
                    (file) => Stack(
                      children: [
                        Image.file(
                          file,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _annexesImagesFiles.remove(file);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_photo_alternate, size: 50),
                    onPressed: _pickAnnexeImages,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Enregistrer les modifications'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _lngController.dispose();
    _latController.dispose();
    super.dispose();
  }
}
