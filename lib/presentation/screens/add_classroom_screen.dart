import 'dart:io';
import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';


class AddClassroomScreen extends StatefulWidget {
  const AddClassroomScreen({
    super.key,
    this.universityId,
  });

  final String? universityId;

  @override
  State<AddClassroomScreen> createState() => __$AddClassroomScreenState();
}

class __$AddClassroomScreenState extends State<AddClassroomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _slugController = TextEditingController();
  final _lngController = TextEditingController();
  final _latController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingUniversities = true;
  String? _errorMessage;
  List<University> _universities = [];
  String? _selectedUniversityId;
  File? _mainImageFile;
  final List<File> _annexesImagesFiles = [];

  Future<void> _pickMainImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _mainImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickAnnexImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _annexesImagesFiles.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Vérifier si le service de localisation est activé
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les services de localisation sont désactivés.'),
        ),
      );
      return;
    }

    // Vérifier les permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Les permissions de localisation sont nécessaires.'),
          ),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les permissions de localisation sont définitivement refusées.'),
        ),
      );
      return;
    }

    // Récupérer la position actuelle
    try {
      final Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _latController.text = position.latitude.toString();
        _lngController.text = position.longitude.toString();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la récupération de la position: ${e.toString()}'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _slugController.dispose();
    _lngController.dispose();
    _latController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadUniversities();
  }

  Future<void> _loadUniversities() async {
    try {
      final universities = await di.getIt<UniversityRepository>().getUniversities();
      setState(() {
        _universities = universities;
        _selectedUniversityId = widget.universityId ?? 
            (universities.isNotEmpty ? universities.first.id : null);
        _isLoadingUniversities = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors du chargement des universités';
        _isLoadingUniversities = false;
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
        id: '',
        universityId: _selectedUniversityId!,
        name: _nameController.text.trim(),
        slug: _slugController.text.trim(),
        lng: _lngController.text.trim().isNotEmpty ? _lngController.text.trim() : '',
        lat: _latController.text.trim().isNotEmpty ? _latController.text.trim() : '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await di.getIt<ClassroomRepository>().createClassroom(
        classroom,
        _mainImageFile,
        annexesImages: _annexesImagesFiles
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Salle de classe créée avec succès')),
        );
        // Retour à l'écran précédent avec un résultat pour indiquer une mise à jour
        Navigator.of(context).pop(true);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter une salle'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      body: _isLoadingUniversities
      ? const Center(child: CircularProgressIndicator())
      : SingleChildScrollView(
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
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                DropdownButtonFormField<String>(
                  initialValue: _selectedUniversityId,
                  decoration: const InputDecoration(
                    labelText: 'Université*',
                    border: OutlineInputBorder(),
                  ),
                  items: _universities.map((university) {
                    return DropdownMenuItem<String>(
                      value: university.id,
                      child: Text(university.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUniversityId = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une université';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la salle*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nom';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _slugController,
                  decoration: const InputDecoration(
                    labelText: 'Libelle*',
                    hintText: 'ex: salle-101',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un libelle';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                const Text(
                  'Coordonnées (optionnel)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Récupérer ma position'),
                      onPressed: _getCurrentLocation,
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on, size: 20),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on, size: 20),
                        ),
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                const Text('Image principale', style: TextStyle(fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: _pickMainImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _mainImageFile != null
                        ? Image.file(_mainImageFile!, fit: BoxFit.cover)
                        : const Center(child: Icon(Icons.add_a_photo, size: 40)),
                  ),
                ),

                const SizedBox(height: 16),
                const Text('Images annexes', style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: [
                    ..._annexesImagesFiles.map((file) => Stack(
                      children: [
                        Image.file(file, width: 100, height: 100, fit: BoxFit.cover),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _annexesImagesFiles.remove(file);
                              });
                            },
                          ),
                        ),
                      ],
                    )),
                    GestureDetector(
                      onTap: _pickAnnexImage,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.add, size: 30),
                      ),
                    ),
                  ],
                ),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      inherit: true,
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white, 
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Ajouter la salle'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}