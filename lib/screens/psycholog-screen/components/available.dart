import 'package:flutter/material.dart';

class AvailabilityToggle extends StatefulWidget {
  final bool isAvailable;
  final Function(bool) onToggle;

  const AvailabilityToggle({
    super.key,
    required this.isAvailable,
    required this.onToggle,
  });

  @override
  State<AvailabilityToggle> createState() => _AvailabilityToggleState();
}

class _AvailabilityToggleState extends State<AvailabilityToggle> {
  bool _updating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Ketersediaan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isAvailable
                      ? 'Anda tersedia untuk konsultasi'
                      : 'Anda tidak menerima konsultasi baru',
                  style: TextStyle(
                    color: widget.isAvailable
                        ? Colors.green[700]
                        : Colors.red[700],
                  ),
                ),
              ],
            ),
          ),
          _updating
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: widget.isAvailable,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    setState(() {
                      _updating = true;
                    });

                    await Future.delayed(const Duration(milliseconds: 500));
                    widget.onToggle(value);

                    setState(() {
                      _updating = false;
                    });
                  },
                ),
        ],
      ),
    );
  }
}
