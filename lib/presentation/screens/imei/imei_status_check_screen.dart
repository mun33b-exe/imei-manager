import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/imei_device_model.dart';
import '../../../data/services/imei_service.dart';

class ImeiStatusCheckScreen extends StatefulWidget {
  const ImeiStatusCheckScreen({super.key});

  @override
  State<ImeiStatusCheckScreen> createState() => _ImeiStatusCheckScreenState();
}

class _ImeiStatusCheckScreenState extends State<ImeiStatusCheckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeiController = TextEditingController();
  final ImeiService _imeiService = ImeiService();

  bool _isLoading = false;
  ImeiDevice? _searchResult;
  bool _hasSearched = false;

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }

  String? _validateImei(String? value) {
    if (value == null || value.isEmpty) {
      return 'IMEI number is required';
    }

    final cleanImei = value.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanImei.length != 15) {
      return 'IMEI must be 15 digits';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanImei)) {
      return 'IMEI must contain only numbers';
    }

    if (!ImeiService.isValidImei(cleanImei)) {
      return 'Invalid IMEI number';
    }

    return null;
  }

  Future<void> _checkImeiStatus() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _searchResult = null;
      _hasSearched = false;
    });

    try {
      final cleanImei = _imeiController.text.replaceAll(RegExp(r'[-\s]'), '');
      final result = await _imeiService.getDeviceByImei(cleanImei);

      if (mounted) {
        setState(() {
          _searchResult = result;
          _hasSearched = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking IMEI: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        title: const Text('Check IMEI Status'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'IMEI Status Check',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter an IMEI number to check its registration status',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // IMEI Input
              TextFormField(
                controller: _imeiController,
                decoration: const InputDecoration(
                  labelText: 'IMEI Number',
                  hintText: 'Enter 15-digit IMEI number',
                  prefixIcon: Icon(Icons.fingerprint),
                  helperText: 'Dial *#06# to find your IMEI',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.search,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validateImei,
                onFieldSubmitted: (_) => _checkImeiStatus(),
              ),
              const SizedBox(height: 24),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _checkImeiStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search),
                              const SizedBox(width: 8),
                              Text(
                                'Check Status',
                                style: Theme.of(
                                  context,
                                ).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 32),

              // Search Results
              if (_hasSearched) ...[
                if (_searchResult == null)
                  Card(
                    color: Colors.grey.shade100,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Registration Found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This IMEI number is not registered in our system.',
                            textAlign: TextAlign.center,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with status
                          Row(
                            children: [
                              Icon(
                                Icons.phone_android,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Device Found',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w600),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    _searchResult!.status,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(
                                      _searchResult!.status,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(_searchResult!.status),
                                      size: 16,
                                      color: _getStatusColor(
                                        _searchResult!.status,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      _searchResult!.status.displayName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall?.copyWith(
                                        color: _getStatusColor(
                                          _searchResult!.status,
                                        ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Device Details
                          _buildInfoRow('IMEI', _searchResult!.imeiNumber),
                          _buildInfoRow('Brand', _searchResult!.deviceBrand),
                          _buildInfoRow('Model', _searchResult!.deviceModel),
                          _buildInfoRow('Type', _searchResult!.deviceType),

                          if (_searchResult!.deviceColor != null)
                            _buildInfoRow('Color', _searchResult!.deviceColor!),

                          const Divider(),

                          _buildInfoRow(
                            'Registered On',
                            '${_searchResult!.registeredAt.day}/${_searchResult!.registeredAt.month}/${_searchResult!.registeredAt.year}',
                          ),

                          if (_searchResult!.approvedAt != null)
                            _buildInfoRow(
                              'Approved On',
                              '${_searchResult!.approvedAt!.day}/${_searchResult!.approvedAt!.month}/${_searchResult!.approvedAt!.year}',
                            ),

                          // Rejection reason if rejected
                          if (_searchResult!.status == DeviceStatus.rejected &&
                              _searchResult!.rejectionReason != null)
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                          _searchResult!.rejectionReason!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall?.copyWith(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],

              const SizedBox(height: 24),

              // Info Card
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This tool allows you to check the registration status of any IMEI number in our system.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.blue.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
