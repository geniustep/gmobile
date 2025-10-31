import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_partner_controller.dart';

class ReviewSection extends StatelessWidget {
  final Map<String, dynamic> basicInfo;
  final Map<String, dynamic>? locationInfo;
  final VoidCallback onEditBasicInfo;
  final VoidCallback? onEditLocation;

  const ReviewSection({
    super.key,
    required this.basicInfo,
    this.locationInfo,
    required this.onEditBasicInfo,
    this.onEditLocation,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePartnerController>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          const Text(
            'مراجعة البيانات',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'تأكد من صحة البيانات قبل الحفظ',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),

          const SizedBox(height: 24),

          _InfoCard(
            title: 'المعلومات الأساسية',
            onEdit: onEditBasicInfo,
            children: [
              _InfoRow(
                label: 'النوع',
                value: controller.state.value.isClient ? 'عميل' : 'جهة اتصال',
                icon: Icons.category,
              ),
              if (basicInfo['name'] != null)
                _InfoRow(
                  label: 'الاسم',
                  value: basicInfo['name'],
                  icon: Icons.person,
                ),
              if (basicInfo['mobile'] != null)
                _InfoRow(
                  label: 'الهاتف',
                  value: basicInfo['mobile'],
                  icon: Icons.phone,
                ),
              if (basicInfo['email'] != null)
                _InfoRow(
                  label: 'البريد الإلكتروني',
                  value: basicInfo['email'],
                  icon: Icons.email,
                ),
              if (basicInfo['function'] != null)
                _InfoRow(
                  label: 'الوظيفة',
                  value: basicInfo['function'],
                  icon: Icons.work,
                ),
              if (basicInfo['website'] != null)
                _InfoRow(
                  label: 'الموقع الإلكتروني',
                  value: basicInfo['website'],
                  icon: Icons.language,
                ),
            ],
          ),

          if (controller.state.value.isClient && locationInfo != null) ...[
            const SizedBox(height: 16),

            _InfoCard(
              title: 'معلومات الموقع',
              onEdit: onEditLocation,
              children: [
                if (locationInfo!['street'] != null)
                  _InfoRow(
                    label: 'العنوان',
                    value: locationInfo!['street'],
                    icon: Icons.location_on,
                  ),
                if (locationInfo!['city'] != null)
                  _InfoRow(
                    label: 'المدينة',
                    value: locationInfo!['city'],
                    icon: Icons.location_city,
                  ),
                if (locationInfo!['country'] != null)
                  _InfoRow(
                    label: 'الدولة',
                    value: locationInfo!['country'],
                    icon: Icons.flag,
                  ),
                if (locationInfo!['partner_latitude'] != null)
                  _InfoRow(
                    label: 'الإحداثيات',
                    value:
                        '${locationInfo!['partner_latitude']}, ${locationInfo!['partner_longitude']}',
                    icon: Icons.gps_fixed,
                  ),
              ],
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final VoidCallback? onEdit;
  final List<Widget> children;

  const _InfoCard({required this.title, this.onEdit, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (onEdit != null)
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('تعديل'),
                  ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
