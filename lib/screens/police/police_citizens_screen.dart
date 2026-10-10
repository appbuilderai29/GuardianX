
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PoliceCitizensScreen extends StatelessWidget {
  const PoliceCitizensScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Registered Citizens'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('role', isEqualTo: 'citizen')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load citizens. Check Firebase permissions.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.red),
            );
          }

          final citizens = snapshot.data?.docs ?? [];

          if (citizens.isEmpty) {
            return const Center(
              child: Text(
                'No registered citizens found.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citizens.length,
            itemBuilder: (context, index) {
              final doc = citizens[index];
              final data = doc.data();

              final name = data['fullName'] ??
                  data['name'] ??
                  'Citizen';

              final phone = data['phone'] ?? 'Not provided';
              final email = data['email'] ?? 'Not provided';
              final address = data['address'] ?? 'Not provided';

              return Card(
                color: const Color(0xFF1E1E1E),
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Colors.white12),
                ),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.red,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(
                    name.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    phone.toString(),
                    style: const TextStyle(color: Colors.white60),
                  ),
                  iconColor: Colors.red,
                  collapsedIconColor: Colors.white70,
                  childrenPadding: const EdgeInsets.fromLTRB(
                    16, 0, 16, 16,
                  ),
                  children: [
                    _detail('Email', email.toString()),
                    _detail('Phone', phone.toString()),
                    _detail('Address', address.toString()),
                    _detail('Citizen ID', doc.id),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _detail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}