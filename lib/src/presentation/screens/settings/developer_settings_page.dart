// ═══════════════════════════════════════════════════════════
// Developer Settings Page - صفحة إعدادات المطورين
// ═══════════════════════════════════════════════════════════
//
// تتيح للمطورين:
// - التبديل بين Odoo Direct و BridgeCore
// - تفعيل/تعطيل A/B Testing
// - عرض إحصائيات الأداء
// - مسح Cache
//
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/analytics/performance_tracker.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/config/api_mode_config.dart';
import 'package:gsloution_mobile/common/api_factory/bridgecore/factory/api_client_factory.dart';

class DeveloperSettingsPage extends StatefulWidget {
  const DeveloperSettingsPage({Key? key}) : super(key: key);

  @override
  State<DeveloperSettingsPage> createState() => _DeveloperSettingsPageState();
}

class _DeveloperSettingsPageState extends State<DeveloperSettingsPage> {
  final ApiModeConfig _config = ApiModeConfig.instance;
  final PerformanceTracker _tracker = PerformanceTracker.instance;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    await _config.loadFromPrefs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إعدادات المطورين'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildApiModeSection(),
          const Divider(height: 32),
          _buildABTestingSection(),
          const Divider(height: 32),
          _buildPerformanceSection(),
          const Divider(height: 32),
          _buildCacheSection(),
          const Divider(height: 32),
          _buildInfoSection(),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // API Mode Section
  // ═══════════════════════════════════════════════════════════

  Widget _buildApiModeSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings_ethernet, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Text(
                  'وضع الاتصال API',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _config.useBridgeCore
                    ? Colors.green.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _config.useBridgeCore
                        ? Icons.cloud_done
                        : Icons.link,
                    color: _config.useBridgeCore ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _config.currentMode.description,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildModeToggle(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Column(
      children: [
        RadioListTile<ApiMode>(
          title: const Text('Odoo Direct'),
          subtitle: const Text('الاتصال المباشر بـ Odoo (النظام القديم)'),
          value: ApiMode.odooDirect,
          groupValue: _config.currentMode,
          onChanged: (value) => _switchMode(value!),
        ),
        RadioListTile<ApiMode>(
          title: const Text('BridgeCore'),
          subtitle: const Text('عبر BridgeCore middleware (محسّن)'),
          value: ApiMode.bridgeCore,
          groupValue: _config.currentMode,
          onChanged: (value) => _switchMode(value!),
        ),
      ],
    );
  }

  Future<void> _switchMode(ApiMode mode) async {
    try {
      await ApiClientFactory.switchMode(mode);
      setState(() {});

      Get.snackbar(
        'تم التبديل',
        'الآن يتم استخدام ${mode.name}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل التبديل: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════
  // A/B Testing Section
  // ═══════════════════════════════════════════════════════════

  Widget _buildABTestingSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'A/B Testing',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('تفعيل A/B Testing'),
              subtitle: const Text('التبديل التلقائي بناءً على User ID'),
              value: _config.enableABTesting,
              onChanged: (value) async {
                await _config.setABTesting(value);
                setState(() {});
              },
            ),
            if (_config.enableABTesting) ...[
              const SizedBox(height: 16),
              Text(
                'نسبة مستخدمي BridgeCore: ${(_config.bridgeCoreUserPercentage * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 14),
              ),
              Slider(
                value: _config.bridgeCoreUserPercentage,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label:
                    '${(_config.bridgeCoreUserPercentage * 100).toStringAsFixed(0)}%',
                onChanged: (value) async {
                  await _config.setBridgeCorePercentage(value);
                  setState(() {});
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Performance Section
  // ═══════════════════════════════════════════════════════════

  Widget _buildPerformanceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.speed, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'إحصائيات الأداء',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('عرض إحصائيات مفصلة'),
              subtitle: const Text('قياسات الأداء والمقارنة'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PerformanceStatsPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.print),
              title: const Text('طباعة التقرير'),
              subtitle: const Text('في Debug Console'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _tracker.printReport();
                Get.snackbar(
                  'تم',
                  'تم طباعة التقرير في Debug Console',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Cache Section
  // ═══════════════════════════════════════════════════════════

  Widget _buildCacheSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cleaning_services, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'إدارة Cache',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('مسح Performance Measurements'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showClearDialog(
                'مسح القياسات',
                'هل تريد مسح جميع قياسات الأداء؟',
                () {
                  _tracker.clearAll();
                  Get.back();
                  Get.snackbar('تم', 'تم مسح جميع القياسات');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Info Section
  // ═══════════════════════════════════════════════════════════

  Widget _buildInfoSection() {
    final factoryInfo = ApiClientFactory.getInfo();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  'معلومات النظام',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('النظام الحالي', factoryInfo['currentSystemName']),
            _buildInfoRow('الوضع', factoryInfo['currentMode']),
            _buildInfoRow('Has Client', factoryInfo['hasClient'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // Helpers
  // ═══════════════════════════════════════════════════════════

  void _showClearDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: onConfirm,
            child: const Text('تأكيد', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
// Performance Stats Page
// ═══════════════════════════════════════════════════════════

class PerformanceStatsPage extends StatelessWidget {
  const PerformanceStatsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final report = PerformanceTracker.instance.getReport();

    return Scaffold(
      appBar: AppBar(
        title: const Text('إحصائيات الأداء'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildOverviewCard(report),
          const SizedBox(height: 16),
          _buildComparisonCard(report),
          const SizedBox(height: 16),
          _buildOperationsCard(report),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(Map<String, dynamic> report) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'نظرة عامة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              'إجمالي القياسات',
              report['totalMeasurements'].toString(),
              Icons.analytics,
            ),
            _buildStatRow(
              'Odoo Direct',
              report['byMode']['odooDirect'].toString(),
              Icons.link,
            ),
            _buildStatRow(
              'BridgeCore',
              report['byMode']['bridgeCore'].toString(),
              Icons.cloud,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(Map<String, dynamic> report) {
    final comparison = report['comparison'];

    if (comparison['comparison'] == 'insufficient_data') {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.info_outline, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'بيانات غير كافية للمقارنة',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Odoo: ${comparison['odooCount']}, BridgeCore: ${comparison['bridgeCoreCount']}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'المقارنة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModeStats(
                    'Odoo Direct',
                    comparison['odooDirect'],
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModeStats(
                    'BridgeCore',
                    comparison['bridgeCore'],
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.trending_up, color: Colors.orange),
                  const SizedBox(width: 8),
                  Text(
                    'تحسين: ${comparison['improvement']['speedImprovement']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeStats(String title, Map<String, dynamic> stats, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${stats['avgMs']}ms',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${(stats['successRate'] * 100).toStringAsFixed(1)}% نجاح',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsCard(Map<String, dynamic> report) {
    final operations = report['operations'] as Map<String, dynamic>;

    if (operations.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('لا توجد عمليات محفوظة'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'العمليات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...operations.entries.map((entry) {
              final stats = entry.value as Map<String, dynamic>;
              return _buildOperationTile(entry.key, stats);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationTile(String operation, Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              operation,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('العدد: ${stats['count']}'),
                Text('متوسط: ${stats['avgMs']}ms'),
                Text('نجاح: ${(stats['successRate'] * 100).toStringAsFixed(1)}%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.blue),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }
}
