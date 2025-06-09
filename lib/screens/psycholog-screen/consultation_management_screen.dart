import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:psyconnect/blocs/consultation/consultation_bloc.dart';
import 'package:psyconnect/models/consultation_model.dart';

class ConsultationManagementScreen extends StatefulWidget {
  const ConsultationManagementScreen({super.key});

  @override
  State<ConsultationManagementScreen> createState() =>
      _ConsultationManagementScreenState();
}

class _ConsultationManagementScreenState
    extends State<ConsultationManagementScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadConsultations();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadConsultations();
    }
  }

  void _loadConsultations() {
    context.read<ConsultationBloc>().add(LoadConsultations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Konsultasi',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_alt_outlined),
            tooltip: 'Filter',
          ),
          IconButton(
            onPressed: _loadConsultations,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocConsumer<ConsultationBloc, ConsultationState>(
      listener: (context, state) {
        if (state is ConsultationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red.shade800,
            ),
          );
        } else if (state is ConsultationUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Status berhasil diperbarui'),
              backgroundColor: Colors.green.shade800,
            ),
          );
          _loadConsultations();
        }
      },
      builder: (context, state) {
        if (state is ConsultationLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is ConsultationLoaded) {
          return _buildContent(context, state.consultations);
        }
        return _buildEmptyState();
      },
    );
  }

  Widget _buildContent(BuildContext context, List<Consultation> consultations) {
    if (consultations.isEmpty) {
      return _buildEmptyState();
    }
    return Column(
      children: [
        _buildStatsHeader(consultations),
        Expanded(child: _buildConsultationList(context, consultations)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_month_outlined,
              size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'Tidak ada jadwal konsultasi',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(List<Consultation> consultations) {
    final statusCounts = _calculateStatusCounts(consultations);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.blue.shade50, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', consultations.length,
                  Icons.calendar_today, Colors.blue),
              _buildStatItem('Terkonfirmasi', statusCounts['confirmed'] ?? 0,
                  Icons.check_circle, Colors.green),
              _buildStatItem('Menunggu', statusCounts['pending'] ?? 0,
                  Icons.pending_actions, Colors.orange),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildConsultationList(
      BuildContext context, List<Consultation> consultations) {
    return RefreshIndicator(
      onRefresh: () async => _loadConsultations(),
      color: Colors.blue.shade800,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 16),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: consultations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final consultation = consultations[index];
          return _buildConsultationTile(context, consultation);
        },
      ),
    );
  }

  Widget _buildConsultationTile(
      BuildContext context, Consultation consultation) {
    String formattedDate;
    try {
      formattedDate = DateFormat('EEEE, dd MMM yyyy • HH:mm', 'id_ID')
          .format(consultation.scheduledTime);
    } catch (e) {
      formattedDate = DateFormat('EEEE, dd MMM yyyy • HH:mm')
          .format(consultation.scheduledTime);
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Text(
                    consultation.clientName ?? 'Rohman',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                _buildStatusDropdown(context, consultation),
              ],
            ),

            const SizedBox(height: 12),

            // Date and Time
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Status Section
            if (consultation.notes?.isNotEmpty ?? false)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan:',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    consultation.notes!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDropdown(BuildContext context, Consultation consultation) {
    return BlocBuilder<ConsultationBloc, ConsultationState>(
      builder: (context, state) {
        final isUpdating = state is ConsultationUpdating &&
            state.consultationId == consultation.id;

        return PopupMenuButton<String>(
          onSelected: (value) =>
              _confirmStatusChange(context, consultation.id, value),
          itemBuilder: (context) => [
            _buildPopupMenuItem('pending', 'Pending', Icons.pending),
            _buildPopupMenuItem(
                'confirmed', 'Terkonfirmasi', Icons.check_circle),
            _buildPopupMenuItem('cancelled', 'Dibatalkan', Icons.cancel),
            _buildPopupMenuItem('completed', 'Selesai', Icons.verified),
          ],
          child: isUpdating
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : _buildStatusChip(consultation.status),
        );
      },
    );
  }

  PopupMenuEntry<String> _buildPopupMenuItem(
      String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: _getStatusColor(value)),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }

  void _confirmStatusChange(BuildContext context, String id, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Perubahan Status'),
        content: Text('Yakin ingin mengubah status menjadi "$newStatus"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<ConsultationBloc>().add(
                    UpdateConsultation(id, newStatus),
                  );
            },
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Map<String, int> _calculateStatusCounts(List<Consultation> consultations) {
    final counts = <String, int>{};
    for (final consultation in consultations) {
      counts[consultation.status] = (counts[consultation.status] ?? 0) + 1;
    }
    return counts;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green.shade800;
      case 'cancelled':
        return Colors.red.shade800;
      case 'completed':
        return Colors.blue.shade800;
      default:
        return Colors.orange.shade800;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.verified;
      default:
        return Icons.pending;
    }
  }
}
