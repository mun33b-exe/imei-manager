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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        int crossAxisCount = 2;
        double childAspectRatio =
            1.6; // Increased from 2.2 to make cards taller
        double crossAxisSpacing = 12.0;
        double mainAxisSpacing = 12.0;

        if (constraints.maxWidth > 600) {
          crossAxisCount = 4;
          childAspectRatio = 1.2; // Slightly taller for wider screens
          crossAxisSpacing = 16.0;
          mainAxisSpacing = 16.0;
        } else if (constraints.maxWidth > 400) {
          childAspectRatio = 1.6; // Better aspect ratio for medium screens
        } else {
          childAspectRatio = 1.8; // Adjusted for very narrow screens
        }

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            _buildStatCard(
              'Total',
              '${_stats['total'] ?? 0}',
              Icons.phone_android,
              Colors.blue,
            ),
            _buildStatCard(
              'Pending',
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
      },
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 3, // Increased elevation for better visibility
      color: color.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(16.0), // Increased padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate sizes based on available space
            final iconSize = constraints.maxHeight * 0.2;
            final maxIconSize = 32.0; // Increased max icon size
            final actualIconSize =
                iconSize > maxIconSize ? maxIconSize : iconSize;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: actualIconSize, color: color),
                SizedBox(height: constraints.maxHeight * 0.08),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      value,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineMedium?.copyWith(
                        // Changed from titleLarge
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24, // Increased font size
                      ),
                    ),
                  ),
                ),
                SizedBox(height: constraints.maxHeight * 0.04),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        // Changed from bodySmall
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13, // Increased font size
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusDistribution() {
    final total = _stats['total'] ?? 0;
    if (total == 0) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Increased padding
          child: Center(
            child: Text(
              'No data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Changed from bodyMedium
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          children: [
            _buildStatusBar(
              'Pending',
              _stats['pending'] ?? 0,
              total,
              Colors.orange,
            ),
            const SizedBox(height: 12), // Increased spacing
            _buildStatusBar(
              'Approved',
              _stats['approved'] ?? 0,
              total,
              Colors.green,
            ),
            const SizedBox(height: 12), // Increased spacing
            _buildStatusBar(
              'Rejected',
              _stats['rejected'] ?? 0,
              total,
              Colors.red,
            ),
            const SizedBox(height: 12), // Increased spacing
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
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Changed from bodyMedium
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count ($percentage%)',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Changed from bodyMedium
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8), // Increased spacing
        ClipRRect(
          borderRadius: BorderRadius.circular(4), // Rounded progress bar
          child: LinearProgressIndicator(
            value: total > 0 ? count / total : 0,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8.0, // Increased height for better visibility
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRegistrations() {
    if (_recentRegistrations.isEmpty) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Increased padding
          child: Center(
            child: Text(
              'No recent registrations',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Changed from bodyMedium
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _recentRegistrations.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final device = _recentRegistrations[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ), // Increased padding
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.phone_android,
                color: Theme.of(context).primaryColor,
                size: 24, // Increased icon size
              ),
            ),
            title: Text(
              '${device.deviceBrand} ${device.deviceModel}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                // Better typography
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              '${device.userFullName} • ${device.imeiNumber}',
              style:
                  Theme.of(context).textTheme.bodyMedium, // Better typography
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(device.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _getStatusColor(device.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                device.status.displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(device.status),
                ),
              ),
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
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(32.0), // Increased padding
          child: Center(
            child: Text(
              'No brand data available',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                // Changed from bodyMedium
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
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0), // Increased padding
        child: Column(
          children:
              topBrands.map((entry) {
                final total = brandCounts.values.reduce((a, b) => a + b);
                final percentage = (entry.value / total * 100).round();

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                  ), // Increased spacing
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge // Changed from bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            4,
                          ), // Rounded progress bar
                          child: LinearProgressIndicator(
                            value: entry.value / total,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor,
                            ),
                            minHeight: 8.0, // Increased height
                          ),
                        ),
                      ),
                      const SizedBox(width: 16), // Increased spacing
                      Text(
                        '${entry.value} ($percentage%)',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          // Changed from bodySmall
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
