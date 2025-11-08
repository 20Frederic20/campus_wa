import 'dart:developer';

import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/repositories/classroom_repository.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/presentation/widgets/classroom_card.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';
import 'package:campus_wa/presentation/widgets/mapbox_map_widget.dart';
import 'package:campus_wa/presentation/widgets/searchbar_anchor_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final SearchController _searchController = SearchController();
  int? expandedIndex;

  LatLng? _userPosition;
  List<Classroom> _classrooms = [];
  String? _locationError;

  late PageController _pageController;

  // Clé pour rebuild map (seulement quand position prête)
  String _mapKey = 'loading';

  Future<void> _getUserLocation() async {
    setState(() {
      _locationError = null;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationError = 'Le service de localisation est désactivé.';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _locationError = 'Permission de localisation refusée.';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _locationError = 'Permission de localisation refusée définitivement.';
      });
      return;
    }

    try {
      final classrooms = await di
          .getIt<ClassroomRepository>()
          .getRandomClassrooms();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _userPosition = newPosition;
        _classrooms = classrooms!;
        _mapKey =
            '${newPosition.latitude}_${newPosition.longitude}'; // Change key → rebuild map
      });
    } catch (e) {
      setState(() {
        _locationError = 'Erreur lors de la récupération de la position: $e';
      });
    }
  }

  Future<void> _handleSearchResult(dynamic result) async {
    if (result.type == 'classroom') {
      final classroomId = result.id; // Assume SearchableItem has 'id' String
      if (classroomId == null) {
        log('Search result missing ID');
        return;
      }

      // Check if already in list
      final existingIndex = _classrooms.indexWhere((c) => c.id == classroomId);
      if (existingIndex != -1) {
        // Exists: Scroll to it and expand
        _pageController.jumpToPage(existingIndex);
        setState(() {
          expandedIndex = existingIndex;
        });
      } else {
        // Not exists: Fetch full Classroom and add at start
        try {
          final classroomRepo = di.getIt<ClassroomRepository>();
          final newClassroom = await classroomRepo.getClassroomById(
            classroomId,
          );
          if (newClassroom != null) {
            setState(() {
              _classrooms.insert(0, newClassroom); // Add as first element
              expandedIndex = 0; // Expand the new one
            });
            _pageController.jumpToPage(0); // Scroll to top
          } else {
            log('Failed to fetch classroom $classroomId');
          }
        } catch (e) {
          log('Error fetching classroom: $e');
          // Optional: Show snackbar error
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erreur lors du chargement de la salle: $e'),
              ),
            );
          }
        }
      }
    } else if (result.type == 'university') {
      // Added: Handle university tap – fetch and show its classrooms
      final universityId = result.id; // Assume 'id' is university's ID
      if (universityId == null) {
        log('Search result missing university ID');
        return;
      }

      try {
        final universityRepo = di.getIt<UniversityRepository>();
        final universityClassrooms = await universityRepo
            .getUniversityClassrooms(universityId);
        if (universityClassrooms != null && universityClassrooms.isNotEmpty) {
          setState(() {
            _classrooms =
                universityClassrooms; // Replace list with university's classrooms
            expandedIndex = null; // Reset expansion for fresh view
          });
          _pageController.jumpToPage(0); // Scroll to start
        } else {
          log('No classrooms found for university $universityId');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Aucune salle trouvée pour cette université'),
              ),
            );
          }
        }
      } catch (e) {
        log('Error fetching classrooms for university: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur lors du chargement des salles: $e')),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.8);
    _getUserLocation(); // Démarre la récup au init
  }

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _showAddMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.school),
                title: const Text('Ajouter une université'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/universities/add');
                },
              ),
              ListTile(
                leading: const Icon(Icons.meeting_room),
                title: const Text('Ajouter une salle'),
                onTap: () {
                  Navigator.pop(context);
                  context.push('/classrooms/add');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMap() {
    // Create a list of all marker positions
    final markerPositions = <LatLng>[];

    // Add user position if available
    if (_userPosition != null) {
      markerPositions.add(_userPosition!);
    }

    // Add all classroom positions
    // for (final classroom in _classrooms) {
    //   if (classroom.latitude != null && classroom.longitude != null) {
    //     markerPositions.add(LatLng(
    //       classroom.latitude!,
    //       classroom.longitude!,
    //     ));
    //   }
    // }

    return MapboxMapWidget(
      key: ValueKey(_mapKey),
      center: _userPosition ?? const LatLng(0, 0),
      zoom: _userPosition != null ? 15.0 : 2.0,
      markers: markerPositions,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final expandedHeight = screenHeight - 126 - 100 - 180;
    final anyExpanded = expandedIndex != null;
    final maxPanelHeight = screenHeight * 0.9; // leave a bit of margin
    final panelHeight = anyExpanded
        ? (expandedHeight + 100).clamp(180.0, maxPanelHeight)
        : 180.0;
    // SI position pas prête → écran de loading/erreur SEUL
    if (_userPosition == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Carte des Universités')),
        body: Center(
          child: _locationError != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.location_off, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    Text(
                      _locationError!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      onPressed: _getUserLocation,
                    ),
                  ],
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Récupération de votre position...'),
                  ],
                ),
        ),
      );
    }

    // SINON : position prête → affiche la map + tout le reste
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Carte des Universités'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
            ),
            child: Row(
              children: [
                Flexible(
                  child: SearchBarAnchorWidget(
                    controller: _searchController,
                    hintText: 'Rechercher sur la carte...',
                    onChanged: _handleSearchResult,
                  ),
                ),
                const Gap(10),
                const Icon(Icons.star_border, size: 32, color: AppColors.white),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildMap(),
          Align(
            alignment: Alignment.bottomLeft,
            child: Builder(
              builder: (context) {
                return SizedBox(
                  height: panelHeight, // <-- dynamic height here
                  child: PageView.builder(
                    clipBehavior: Clip.none,
                    controller: _pageController,
                    itemCount: _classrooms.length,
                    padEnds: false,
                    itemBuilder: (context, index) {
                      final isExpanded = expandedIndex == index;
                      final classroom = _classrooms[index];

                      return Center(
                        child: OverflowBox(
                          alignment: Alignment.bottomCenter,
                          maxHeight:
                              expandedHeight +
                              100, // allows card to grow beyond parent
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: isExpanded ? expandedHeight : 100,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ClassroomCard(
                              classroom: classroom,
                              isExpanded: isExpanded,
                              onTap: () => setState(() {
                                expandedIndex = isExpanded ? null : index;
                              }),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
