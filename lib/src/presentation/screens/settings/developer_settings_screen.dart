// ════════════════════════════════════════════════════════════
// Developer Settings - Enhanced with BridgeCore Stats
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gsloution_mobile/src/presentation/screens/settings/developer_settings_controller.dart';

class DeveloperSettingsScreen extends StatelessWidget {
  const DeveloperSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DeveloperSettingsController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer Settings'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // API Mode Selection
          _buildSection(
            title: '🔌 API Mode',
            children: [
              Obx(() => _buildModeSelector(controller)),
            ],
          ),

          const SizedBox(height: 24),

          // WebSocket Status
          _buildSection(
            title: '📡 WebSocket',
            children: [
              Obx(() => _buildWebSocketStatus(controller)),
              const SizedBox(height: 12),
              Obx(() => _buildWebSocketControls(controller)),
            ],
          ),

          const SizedBox(height: 24),

          // Circuit Breaker Stats
          Obx(() {
            if (controller.apiMode.value == 'BridgeCore') {
              return Column(
                children: [
                  _buildSection(
                    title: '🔴 Circuit Breaker',
                    children: [
                      Obx(() => _buildCircuitBreakerStats(controller)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Request Deduplication Stats
          Obx(() {
            if (controller.apiMode.value == 'BridgeCore') {
              return Column(
                children: [
                  _buildSection(
                    title: '🔄 Request Deduplication',
                    children: [
                      Obx(() => _buildDeduplicationStats(controller)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Connection Pool Stats
          Obx(() {
            if (controller.apiMode.value == 'BridgeCore') {
              return Column(
                children: [
                  _buildSection(
                    title: '🏊 Connection Pool',
                    children: [
                      Obx(() => _buildConnectionPoolStats(controller)),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              );
            }
            return const SizedBox.shrink();
          }),

          // Cache Statistics
          _buildSection(
            title: '💾 Cache Statistics',
            children: [
              Obx(() => _buildCacheStats(controller)),
            ],
          ),

          const SizedBox(height: 24),

          // Actions
          _buildSection(
            title: '⚙️ Actions',
            children: [
              _buildActionButton(
                icon: Icons.refresh,
                label: 'Refresh Stats',
                onTap: () => controller.refreshStats(),
                color: Colors.blue,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.clear_all,
                label: 'Clear Cache',
                onTap: () => controller.clearCache(),
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              _buildActionButton(
                icon: Icons.restore,
                label: 'Reset All Stats',
                onTap: () => controller.resetAllStats(),
                color: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Section Widget
  // ════════════════════════════════════════════════════════════

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // API Mode Selector
  // ════════════════════════════════════════════════════════════

  Widget _buildModeSelector(DeveloperSettingsController controller) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('BridgeCore (Production)'),
          subtitle: const Text('Fast, with all performance features'),
          value: 'BridgeCore',
          groupValue: controller.apiMode.value,
          onChanged: (value) {
            if (value != null) controller.setApiMode(value);
          },
          activeColor: Colors.green,
        ),
        RadioListTile<String>(
          title: const Text('Odoo Direct (Fallback)'),
          subtitle: const Text('Direct connection to Odoo'),
          value: 'Odoo Direct',
          groupValue: controller.apiMode.value,
          onChanged: (value) {
            if (value != null) controller.setApiMode(value);
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // WebSocket Status
  // ════════════════════════════════════════════════════════════

  Widget _buildWebSocketStatus(DeveloperSettingsController controller) {
    final isConnected = controller.webSocketConnected.value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.cancel,
            color: isConnected ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Connected' : 'Disconnected',
                  style: GoogleFonts.nunito(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  isConnected ? 'Real-time updates enabled' : 'No real-time updates',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebSocketControls(DeveloperSettingsController controller) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: controller.webSocketConnected.value
                ? null
                : () => controller.connectWebSocket(),
            icon: const Icon(Icons.power, size: 18),
            label: const Text('Connect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: !controller.webSocketConnected.value
                ? null
                : () => controller.disconnectWebSocket(),
            icon: const Icon(Icons.power_off, size: 18),
            label: const Text('Disconnect'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // Circuit Breaker Stats
  // ════════════════════════════════════════════════════════════

  Widget _buildCircuitBreakerStats(DeveloperSettingsController controller) {
    final stats = controller.circuitBreakerStats.value;

    return Column(
      children: [
        _buildStatRow('State', stats['state'] ?? 'N/A', _getStateColor(stats['state'])),
        _buildStatRow('Failures', '${stats['failures']}/${stats['threshold']}', Colors.black87),
        if (stats['lastFailure'] != null)
          _buildStatRow('Last Failure', stats['lastFailure'], Colors.grey),
      ],
    );
  }

  Color _getStateColor(String? state) {
    switch (state) {
      case 'closed':
        return Colors.green;
      case 'open':
        return Colors.red;
      case 'halfOpen':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  // ════════════════════════════════════════════════════════════
  // Deduplication Stats
  // ════════════════════════════════════════════════════════════

  Widget _buildDeduplicationStats(DeveloperSettingsController controller) {
    final stats = controller.deduplicationStats.value;

    return Column(
      children: [
        _buildStatRow('Total Requests', '${stats['totalRequests']}', Colors.black87),
        _buildStatRow('Deduplicated', '${stats['deduplicatedRequests']}', Colors.blue),
        _buildStatRow('Rate', stats['deduplicationRate'] ?? '0%', Colors.green),
        _buildStatRow('Currently Pending', '${stats['pendingRequests']}', Colors.orange),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // Connection Pool Stats
  // ════════════════════════════════════════════════════════════

  Widget _buildConnectionPoolStats(DeveloperSettingsController controller) {
    final stats = controller.connectionPoolStats.value;

    return Column(
      children: [
        _buildStatRow('Max Connections', '${stats['maxConnections']}', Colors.black87),
        _buildStatRow('Active', '${stats['activeConnections']}', Colors.green),
        _buildStatRow('Available', '${stats['availableConnections']}', Colors.blue),
        _buildStatRow('Total', '${stats['totalConnections']}', Colors.purple),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // Cache Stats
  // ════════════════════════════════════════════════════════════

  Widget _buildCacheStats(DeveloperSettingsController controller) {
    final stats = controller.cacheStats.value;

    return Column(
      children: [
        _buildStatRow('Products', '${stats['products']} items', Colors.blue),
        _buildStatRow('Partners', '${stats['partners']} items', Colors.green),
        _buildStatRow('Sales', '${stats['sales']} items', Colors.orange),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════
  // Stat Row
  // ════════════════════════════════════════════════════════════

  Widget _buildStatRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════
  // Action Button
  // ════════════════════════════════════════════════════════════

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
