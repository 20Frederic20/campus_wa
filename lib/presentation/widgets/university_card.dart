import 'package:campus_wa/domain/models/university.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UniversityCard extends StatelessWidget {
  const UniversityCard({
    super.key,
    required this.university,
    required this.isExpanded,
    required this.onTap,
  });
  final University university;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        university.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (!isExpanded && university.address.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            university.address,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
                if (!isExpanded)
                  const Icon(Icons.expand_more, size: 20, color: Colors.grey)
                else
                  const Icon(Icons.expand_less, size: 20, color: Colors.grey),
              ],
            ),
            const Gap(8),

            if (isExpanded)
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // University slug and details
                      Text(
                        university.slug,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const Gap(8),

                      // Address and Google Maps button
                      if (university.address.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const Gap(4),
                            Expanded(
                              child: Text(
                                university.address,
                                style: Theme.of(context).textTheme.bodyMedium,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (university.lat.isNotEmpty &&
                                university.lng.isNotEmpty)
                              IconButton(
                                icon: const Icon(
                                  Icons.map,
                                  size: 20,
                                  color: Colors.blue,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _openGoogleMaps(university),
                              ),
                          ],
                        ),
                        const Gap(8),
                      ],

                      if (university.description.isNotEmpty)
                        Text(
                          university.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        )
                      else
                        const Text(
                          'Aucune description disponible.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey,
                          ),
                        ),
                      const Gap(12),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(University university) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${university.lat},${university.lng}';
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    }
  }
}
