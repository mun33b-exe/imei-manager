import 'package:flutter/material.dart';
import '../../../data/models/imei_device_model.dart';
import '../../../data/services/imei_service.dart';
import '../../../data/models/user_model.dart';

class AdminImeiManagementScreen extends StatefulWidget {
  final AppUser admin;

  const AdminImeiManagementScreen({super.key, required this.admin});

  @override
  State<AdminImeiManagementScreen> createState() =>
      _AdminImeiManagementScreenState();
}

class _AdminImeiManagementScreenState extends State<AdminImeiManagementScreen>
    with SingleTickerProviderStateMixin {
  final ImeiService _imeiService = ImeiService();
  late TabController _tabController;

  List<ImeiDevice> _allDevices = [];
  List<ImeiDevice> _pendingDevices = [];
  List<ImeiDevice> _approvedDevices = [];
  List<ImeiDevice> _rejectedDevices = [];

  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final allDevices = await _imeiService.getAllDevices();
      final stats = await _imeiService.getRegistrationStats();

      if (mounted) {
        setState(() {
          _allDevices = allDevices;
          _pendingDevices =
              allDevices
                  .where((d) => d.status == DeviceStatus.pending)
                  .toList();
          _approvedDevices =
              allDevices
                  .where((d) => d.status == DeviceStatus.approved)
                  .toList();
          _rejectedDevices =
              allDevices
                  .where((d) => d.status == DeviceStatus.rejected)
                  .toList();
          _stats = stats;
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
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateDeviceStatus(
    ImeiDevice device,
    DeviceStatus newStatus, {
    String? reason,
  }) async {
    try {
      await _imeiService.updateDeviceStatus(
        deviceId: device.id,
        status: newStatus,
        rejectionReason: reason,
        approvedBy:
            newStatus == DeviceStatus.approved ? widget.admin.fullName : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Device status updated to ${newStatus.displayName}'),
          backgroundColor: Colors.green,
        ),
      );

      _loadData(); // Refresh data
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating status: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showStatusUpdateDialog(ImeiDevice device) async {
    DeviceStatus? selectedStatus = device.status;
    String rejectionReason = '';

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Update Device Status'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${device.deviceBrand} ${device.deviceModel}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text('IMEI: ${device.imeiNumber}'),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<DeviceStatus>(
                    value: selectedStatus,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items:
                        DeviceStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedStatus = value;
                      });
                    },
                  ),
                  if (selectedStatus == DeviceStatus.rejected) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Rejection Reason',
                        hintText: 'Please provide a reason for rejection',
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        rejectionReason = value;
                      },
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedStatus == DeviceStatus.rejected &&
                        rejectionReason.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please provide a rejection reason'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(context, {
                      'status': selectedStatus,
                      'reason': rejectionReason.trim(),
                    });
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null && result['status'] != null) {
      await _updateDeviceStatus(
        device,
        result['status'],
        reason: result['reason'].isEmpty ? null : result['reason'],
      );
    }
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

  IconData _getStatusIcon(DeviceStatus status) {
    switch (status) {
      case DeviceStatus.pending:
        return Icons.schedule;
      case DeviceStatus.approved:
        return Icons.check_circle;
      case DeviceStatus.rejected:
        return Icons.cancel;
      case DeviceStatus.suspended:
        return Icons.pause_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IMEI Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              text: 'All (${_stats['total'] ?? 0})',
              icon: const Icon(Icons.list_alt),
            ),
            Tab(
              text: 'Pending (${_stats['pending'] ?? 0})',
              icon: const Icon(Icons.schedule),
            ),
            Tab(
              text: 'Approved (${_stats['approved'] ?? 0})',
              icon: const Icon(Icons.check_circle),
            ),
            Tab(
              text: 'Rejected (${_stats['rejected'] ?? 0})',
              icon: const Icon(Icons.cancel),
            ),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                controller: _tabController,
                children: [
                  _buildDeviceList(_allDevices, showAll: true),
                  _buildDeviceList(_pendingDevices),
                  _buildDeviceList(_approvedDevices),
                  _buildDeviceList(_rejectedDevices),
                ],
              ),
    );
  }

  Widget _buildDeviceList(List<ImeiDevice> devices, {bool showAll = false}) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.phone_android_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Devices Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No devices in this category yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          final device = devices[index];
          return _buildDeviceCard(device, showAll: showAll);
        },
      ),
    );
  }

  Widget _buildDeviceCard(ImeiDevice device, {bool showAll = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with device info and status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone_android,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${device.deviceBrand} ${device.deviceModel}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        device.deviceType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (showAll)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(device.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(device.status).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getStatusIcon(device.status),
                          size: 16,
                          color: _getStatusColor(device.status),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          device.status.displayName,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(device.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Device Details in organized sections
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  _buildInfoRow('IMEI', device.imeiNumber, isImportant: true),
                  const Divider(height: 16),
                  _buildInfoRow('Owner', device.userFullName),
                  _buildInfoRow('Email', device.userEmail),
                  _buildInfoRow('Phone', device.userPhone),
                  _buildInfoRow('CNIC', device.userCnic),
                ],
              ),
            ),

            if (device.deviceColor != null ||
                device.serialNumber != null ||
                device.purchaseDate != null ||
                device.retailerName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Device Details',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (device.deviceColor != null)
                      _buildInfoRow('Color', device.deviceColor!),
                    if (device.serialNumber != null)
                      _buildInfoRow('Serial Number', device.serialNumber!),
                    if (device.purchaseDate != null)
                      _buildInfoRow('Purchase Date', device.purchaseDate!),
                    if (device.retailerName != null)
                      _buildInfoRow('Retailer', device.retailerName!),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 12),

            // Registration details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Registration Info',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          'Registered',
                          '${device.registeredAt.day}/${device.registeredAt.month}/${device.registeredAt.year}',
                        ),
                      ),
                      if (device.approvedAt != null)
                        Expanded(
                          child: _buildInfoRow(
                            'Approved',
                            '${device.approvedAt!.day}/${device.approvedAt!.month}/${device.approvedAt!.year}',
                          ),
                        ),
                    ],
                  ),
                  if (device.approvedBy != null)
                    _buildInfoRow('Approved By', device.approvedBy!),
                ],
              ),
            ),

            // Rejection reason if rejected
            if (device.status == DeviceStatus.rejected &&
                device.rejectionReason != null)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejection Reason:',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                          Text(
                            device.rejectionReason!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.red.shade700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ), // Action buttons
            const SizedBox(height: 16),
            if (device.status == DeviceStatus.pending) ...[
              // Quick action buttons for pending devices
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          () => _updateDeviceStatus(
                            device,
                            DeviceStatus.approved,
                          ),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showStatusUpdateDialog(device),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Additional options button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusUpdateDialog(device),
                  icon: const Icon(Icons.more_horiz, size: 18),
                  label: const Text('More Options'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ] else ...[
              // General update button for non-pending devices
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showStatusUpdateDialog(device),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Update Status'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isImportant = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color:
                    isImportant
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
                fontWeight: isImportant ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: isImportant ? FontWeight.w600 : FontWeight.w500,
                color:
                    isImportant ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
