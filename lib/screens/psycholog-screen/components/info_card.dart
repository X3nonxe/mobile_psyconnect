import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:psyconnect/models/psychologist.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final PsychologistModel psychologist;
  final NumberFormat currencyFormat;

  const InfoCard({
    super.key,
    required this.title,
    required this.psychologist,
    required this.currencyFormat,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Biaya Konsultasi',
              currencyFormat.format(psychologist.consultationFee),
              Icons.payments_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Nomor Lisensi',
              psychologist.licenseNumber,
              Icons.badge_outlined,
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Email',
              psychologist.email,
              Icons.email_outlined,
            ),
            if (psychologist.address != null) ...[
              const SizedBox(height: 16),
              _buildInfoRow(
                'Alamat',
                psychologist.address!,
                Icons.location_on_outlined,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[700],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
