import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_partner_controller.dart';

class PartnerTypeToggle extends StatelessWidget {
  const PartnerTypeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePartnerController>();

    return Obx(() {
      final isClient = controller.state.value.isClient;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'نوع الشريك:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 16),
            _ToggleButton(
              label: 'عميل',
              icon: Icons.person,
              isSelected: isClient,
              onTap: () {
                if (!isClient) controller.togglePartnerType();
              },
            ),
            const SizedBox(width: 12),
            _ToggleButton(
              label: 'جهة اتصال',
              icon: Icons.contacts,
              isSelected: !isClient,
              onTap: () {
                if (isClient) controller.togglePartnerType();
              },
            ),
          ],
        ),
      );
    });
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}