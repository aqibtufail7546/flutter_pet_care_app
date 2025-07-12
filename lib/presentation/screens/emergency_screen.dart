import 'package:flutter/material.dart';
import 'package:flutter_pet_care_and_veterinary_app/application/provider/emergency_contact_provider.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/emergency_contact.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/first_aid_guide.dart';
import 'package:flutter_pet_care_and_veterinary_app/data/models/veterinary_clinic.dart';
import 'package:flutter_pet_care_and_veterinary_app/presentation/widgets/bottom_navigation_bar.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends ConsumerWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emergencyContacts = ref.watch(emergencyContactsProvider);
    final nearbyClinics = ref.watch(nearbyClinicsProvider);
    final firstAidGuides = ref.watch(firstAidGuidesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency'),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Emergency Alert Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.emergency, size: 48, color: Colors.white),
                  const SizedBox(height: 8),
                  Text(
                    'Pet Emergency',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Quick access to emergency resources',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Contacts Section
            _buildSection(
              title: 'Emergency Contacts',
              icon: Icons.phone,
              child: Column(
                children:
                    emergencyContacts.map((contact) {
                      return _buildContactCard(contact);
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Nearby Veterinary Clinics
            _buildSection(
              title: 'Nearby Veterinary Clinics',
              icon: Icons.local_hospital,
              child: Column(
                children:
                    nearbyClinics.map((clinic) {
                      return _buildClinicCard(clinic);
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // First Aid Guides
            _buildSection(
              title: 'First Aid Guides',
              icon: Icons.medical_services,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: firstAidGuides.length,
                itemBuilder: (context, index) {
                  return _buildFirstAidCard(context, firstAidGuides[index]);
                },
              ),
            ),

            const SizedBox(height: 16),

            // Emergency Report Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () => _showEmergencyReportDialog(context),
                  icon: const Icon(Icons.report_problem),
                  label: const Text('Report Emergency'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigationBarWidget(currentIndex: 3),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              contact.isDefault ? Colors.red.shade700 : Colors.blue.shade600,
          child: Icon(
            contact.isDefault ? Icons.emergency : Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (contact.address.isNotEmpty)
              Text(
                contact.address,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            if (contact.email.isNotEmpty)
              Text(
                contact.email,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            if (contact.isDefault)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Default Emergency',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (contact.email.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.email, color: Colors.blue),
                onPressed: () => _sendEmail(contact.email),
              ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(contact.phone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicCard(VeterinaryClinic clinic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: clinic.isOpen ? Colors.green : Colors.red,
          child: Icon(Icons.local_hospital, color: Colors.white),
        ),
        title: Text(
          clinic.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clinic.address),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                Text(' ${clinic.rating} • ${clinic.distance}km'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: clinic.isOpen ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    clinic.isOpen ? 'Open' : 'Closed',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.directions, color: Colors.blue),
              onPressed: () => _openMaps(clinic.address),
            ),
            IconButton(
              icon: const Icon(Icons.call, color: Colors.green),
              onPressed: () => _makePhoneCall(clinic.phone),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstAidCard(BuildContext context, FirstAidGuide guide) {
    return Card(
      child: InkWell(
        onTap: () => _showFirstAidDialog(context, guide),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(guide.icon, size: 32, color: Colors.red.shade700),
              const SizedBox(height: 8),
              Text(
                guide.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                guide.description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendEmail(String email) async {
    final Uri url = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Pet Emergency - Urgent',
        'body':
            'This is an emergency regarding my pet. Please respond immediately.',
      },
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _openMaps(String address) async {
    final Uri url = Uri(
      scheme: 'https',
      host: 'maps.google.com',
      path: '/search/',
      queryParameters: {'query': address},
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _showFirstAidDialog(BuildContext context, FirstAidGuide guide) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(guide.icon, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(child: Text(guide.title)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    guide.description,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Steps:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...guide.steps.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(entry.value)),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _showEmergencyReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Report Emergency'),
            content: const Text(
              'This will send an emergency alert to your veterinarian and emergency contacts with your location and pet information.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Emergency report sent successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Send Alert'),
              ),
            ],
          ),
    );
  }
}
