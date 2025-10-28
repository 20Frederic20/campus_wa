import 'package:campus_wa/domain/models/classroom.dart';
import 'package:campus_wa/domain/models/university.dart';

final List<University> universities = [
  University(
    id: '1',
    nom: 'Université d’Abomey-Calavi (UAC)',
    slug: 'universite-abomey-calavi',
    lng: 2.3408,
    lat: 6.4444,
    classrooms: [
      Classroom(
        id: '1',
        nom: 'Amphi Idriss Déby Itno',
        slug: 'amphi-idriss-deby',
        lng: 2.3403,
        lat: 6.4440,
      ),
      Classroom(
        id: '2',
        nom: 'Amphi Houdegbe',
        slug: 'amphi-houdegbe',
        lng: 2.3412,
        lat: 6.4447,
      ),
      Classroom(
        id: '3',
        nom: 'Bibliothèque universitaire',
        slug: 'bibliotheque-uac',
        lng: 2.3399,
        lat: 6.4452,
      ),
    ],
  ),

  University(
    id: '2',
    nom: 'HECM Godomey',
    slug: 'hecm-godomey',
    lng: 2.3689,
    lat: 6.3843,
    classrooms: [
      Classroom(
        id: '4',
        nom: 'Salle informatique',
        slug: 'salle-informatique-hecm',
        lng: 2.3687,
        lat: 6.3841,
      ),
      Classroom(
        id: '5',
        nom: 'Amphi A',
        slug: 'amphi-a-hecm',
        lng: 2.3691,
        lat: 6.3845,
      ),
    ],
  ),

  University(
    id: '3',
    nom: 'École Supérieure de Gestion (ESGIS Calavi)',
    slug: 'esgis-calavi',
    lng: 2.3734,
    lat: 6.4327,
    classrooms: [
      Classroom(
        id: '6',
        nom: 'Salle de conférence',
        slug: 'salle-conference-esgis',
        lng: 2.3730,
        lat: 6.4325,
      ),
      Classroom(
        id: '7',
        nom: 'Laboratoire réseau',
        slug: 'lab-reseau-esgis',
        lng: 2.3736,
        lat: 6.4330,
      ),
    ],
  ),

  University(
    id: '4',
    nom: 'Institut Universitaire Pan-Africain (IUPA)',
    slug: 'iupa-akassato',
    lng: 2.3390,
    lat: 6.4720,
    classrooms: [
      Classroom(
        id: '8',
        nom: 'Salle principale',
        slug: 'salle-principale-iupa',
        lng: 2.3388,
        lat: 6.4718,
      ),
      Classroom(
        id: '9',
        nom: 'Amphi Cotonou',
        slug: 'amphi-cotonou-iupa',
        lng: 2.3393,
        lat: 6.4723,
      ),
    ],
  ),

  University(
    id: '5',
    nom: 'Université Polytechnique Internationale (UPI Onipko)',
    slug: 'upi-onipko',
    lng: 2.3522,
    lat: 6.4110,
    classrooms: [
      Classroom(
        id: '10',
        nom: 'Salle Polytech 1',
        slug: 'polytech-1',
        lng: 2.3524,
        lat: 6.4112,
      ),
      Classroom(
        id: '11',
        nom: 'Salle Polytech 2',
        slug: 'polytech-2',
        lng: 2.3520,
        lat: 6.4108,
      ),
    ],
  ),
];
