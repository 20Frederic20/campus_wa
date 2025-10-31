import 'package:flutter/material.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/core/injection.dart' as di;

class AddClassroomScreen extends StatefulWidget {
  final String? universityId;
  const AddClassroomScreen({
    Key? key,
    this.universityId,
  }) : super(key: key);

  @override
  _AddClassroomScreenState createState() => _AddClassroomScreenState();
}

class _AddClassroomScreenState extends State<AddClassroomScreen> {
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
        mainImage: '',
        annexesImages: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await di.getIt<ClassroomRepository>().createClassroom(classroom);

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
                  value: _selectedUniversityId,
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
                
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _latController,
                        decoration: const InputDecoration(
                          labelText: 'Latitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lngController,
                        decoration: const InputDecoration(
                          labelText: 'Longitude',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text('Ajouter la salle'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}