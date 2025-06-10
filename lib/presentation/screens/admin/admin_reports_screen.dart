import 'package:flutter/material.dart';
import '../../../data/services/imei_service.dart';
import '../../../data/models/imei_device_model.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  final ImeiService _imeiService = ImeiService();

  Map<String, int> _stats = {};
  List<ImeiDevice> _recentRegistrations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final [stats, allDevices] = await Future.wait([
        _imeiService.getRegistrationStats(),
        _imeiService.getAllDevices(),
      ]);

      // Get recent registrations (last 10)
      final recentDevices = (allDevices as List<ImeiDevice>).take(10).toList();

      if (mounted) {
        setState(() {
          _stats = stats as Map<String, int>;
          _recentRegistrations = recentDevices;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading reports: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadReports,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Statistics
                      Text(
                        'System Statistics',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      _buildStatsGrid(),

                      const SizedBox(height: 32),

                      // Status Distribution
                      Text(
                        'Registration Status Distribution',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      _buildStatusDistribution(),

                      const SizedBox(height: 32),

                      // Recent Registrations
                      Text(
                        'Recent Registrations',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      _buildRecentRegistrations(),

                      const SizedBox(height: 32),

                      // Device Brand Distribution
                      Text(
                        'Popular Device Brands',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      _buildBrandDistribution(),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Registrations',
          '${_stats['total'] ?? 0}',
          Icons.phone_android,
          Colors.blue,
        ),
        _buildStatCard(
          'Pending Review',
          '${_stats['pending'] ?? 0}',
          Icons.schedule,
          Colors.orange,
        ),
        _buildStatCard(
          'Approved',
          '${_stats['approved'] ?? 0}',
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Rejected',
          '${_stats['rejected'] ?? 0}',
          Icons.cancel,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDistribution() {
    final total = _stats['total'] ?? 0;
    if (total == 0) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStatusBar(
              'Pending',
              _stats['pending'] ?? 0,
              total,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildStatusBar(
              'Approved',
              _stats['approved'] ?? 0,
              total,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildStatusBar(
              'Rejected',
              _stats['rejected'] ?? 0,
              total,
              Colors.red,
            ),
            const SizedBox(height: 8),
            _buildStatusBar(
              'Suspended',
              _stats['suspended'] ?? 0,
              total,
              Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
            Text(
              '$count ($percentage%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: total > 0 ? count / total : 0,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildRecentRegistrations() {
    if (_recentRegistrations.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No recent registrations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentRegistrations.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final device = _recentRegistrations[index];
          return ListTile(
            leading: Icon(
              Icons.phone_android,
              color: Theme.of(context).primaryColor,
            ),
            title: Text('${device.deviceBrand} ${device.deviceModel}'),
            subtitle: Text('${device.userFullName} • ${device.imeiNumber}'),
            trailing: Chip(
              label: Text(
                device.status.displayName,
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: _getStatusColor(device.status).withOpacity(0.1),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBrandDistribution() {
    // Count devices by brand
    final brandCounts = <String, int>{};
    for (final device in _recentRegistrations) {
      brandCounts[device.deviceBrand] =
          (brandCounts[device.deviceBrand] ?? 0) + 1;
    }

    if (brandCounts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Text(
              'No brand data available',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    // Sort by count and take top 5
    final sortedBrands =
        brandCounts.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
    final topBrands = sortedBrands.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              topBrands.map((entry) {
                final total = brandCounts.values.reduce((a, b) => a + b);
                final percentage = (entry.value / total * 100).round();

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: entry.value / total,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Color _getStatusColor(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.pending:
        return Colors.orange;
      case DeviceStatus.approved:
        return Colors.green;
      case DeviceStatus.rejected:
        return Colors.red;
      case DeviceStatus.suspended:
        return Colors.grey;
    }
  }
}
