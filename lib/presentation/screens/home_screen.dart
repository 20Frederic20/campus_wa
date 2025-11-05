import 'package:campus_wa/core/injection.dart' as di;
import 'package:campus_wa/core/theme/app_theme.dart';
import 'package:campus_wa/domain/models/university.dart';
import 'package:campus_wa/domain/repositories/university_repository.dart';
import 'package:campus_wa/presentation/widgets/leaflet_map_widget.dart';
import 'package:campus_wa/presentation/widgets/searchbar_anchor_widget.dart';
import 'package:campus_wa/presentation/widgets/university_card.dart';
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
  String _searchQuery = '';
  int? expandedIndex;

  LatLng? _userPosition;
  List<University> _universities = [];
  String? _locationError;

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
      final universities = await di
          .getIt<UniversityRepository>()
          .getUniversities();
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() {
        _userPosition = newPosition;
        _universities = universities!;
        _mapKey =
            '${newPosition.latitude}_${newPosition.longitude}'; // Change key → rebuild map
      });
    } catch (e) {
      setState(() {
        _locationError = 'Erreur lors de la récupération de la position: $e';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Démarre la récup au init
  }

  @override
  void dispose() {
    _searchController.dispose();
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
    return LeafletMapWidget(
      key: ValueKey(_mapKey),
      center: _userPosition ?? const LatLng(0, 0),
      zoom: _userPosition != null ? 15.0 : 2.0,
      markers: _userPosition != null
          ? [
              Marker(
                point: _userPosition!,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.accentRed,
                  size: 48,
                ),
              ),
            ]
          : [],
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
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
        children: [
          _buildMap(),
          Align(
            alignment: Alignment.bottomLeft,
            child: SizedBox(
              height: 180, // parent height stays fixed
              child: PageView.builder(
                clipBehavior: Clip.none,
                controller: PageController(viewportFraction: 0.8),
                itemCount: 3,
                padEnds: false,
                itemBuilder: (context, index) {
                  final isExpanded = expandedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        expandedIndex = isExpanded ? null : index;
                      });
                    },
                    child: Center(
                      child: OverflowBox(
                        alignment: Alignment.bottomCenter,
                        maxHeight: 220, // allows card to grow beyond parent
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          height: isExpanded ? 350 : 100,
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
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
