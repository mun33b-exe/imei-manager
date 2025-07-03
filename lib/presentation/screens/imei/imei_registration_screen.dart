import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/imei_service.dart';

class ImeiRegistrationScreen extends StatefulWidget {
  final AppUser user;

  const ImeiRegistrationScreen({super.key, required this.user});

  @override
  State<ImeiRegistrationScreen> createState() => _ImeiRegistrationScreenState();
}

class _ImeiRegistrationScreenState extends State<ImeiRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imeiController = TextEditingController();
  final _deviceModelController = TextEditingController();
  final _deviceColorController = TextEditingController();
  final _purchaseDateController = TextEditingController();
  final _retailerNameController = TextEditingController();
  final _serialNumberController = TextEditingController();

  final ImeiService _imeiService = ImeiService();

  String? _selectedBrand;
  String? _selectedDeviceType;
  bool _isLoading = false;

  @override
  void dispose() {
    _imeiController.dispose();
    _deviceModelController.dispose();
    _deviceColorController.dispose();
    _purchaseDateController.dispose();
    _retailerNameController.dispose();
    _serialNumberController.dispose();
    super.dispose();
  }

  // IMEI validation
  String? _validateImei(String? value) {
    if (value == null || value.isEmpty) {
      return 'IMEI number is required';
    }

    final cleanImei = value.replaceAll(RegExp(r'[-\s]'), '');

    if (cleanImei.length != 15) {
      return 'IMEI must be exactly 15 digits (current: ${cleanImei.length})';
    }

    if (!RegExp(r'^\d+$').hasMatch(cleanImei)) {
      return 'IMEI must contain only numbers';
    }

    // For development/testing, we use lenient validation
    // The IMEI service will handle the detailed validation
    if (!ImeiService.isValidImei(cleanImei)) {
      return 'IMEI format validation failed';
    }

    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  Future<void> _selectPurchaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Select Purchase Date',
    );

    if (picked != null) {
      setState(() {
        _purchaseDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBrand == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select device brand'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedDeviceType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select device type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final cleanImei = _imeiController.text.replaceAll(RegExp(r'[-\s]'), '');

      await _imeiService.registerDevice(
        imeiNumber: cleanImei,
        deviceBrand: _selectedBrand!,
        deviceModel: _deviceModelController.text.trim(),
        deviceType: _selectedDeviceType!,
        deviceColor:
            _deviceColorController.text.trim().isNotEmpty
                ? _deviceColorController.text.trim()
                : null,
        purchaseDate:
            _purchaseDateController.text.trim().isNotEmpty
                ? _purchaseDateController.text.trim()
                : null,
        retailerName:
            _retailerNameController.text.trim().isNotEmpty
                ? _retailerNameController.text.trim()
                : null,
        serialNumber:
            _serialNumberController.text.trim().isNotEmpty
                ? _serialNumberController.text.trim()
                : null,
        user: widget.user,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Device registered successfully! Awaiting approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register New Device'),
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
                            Icons.phone_android,
                            color: Theme.of(context).primaryColor,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Device Registration',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please fill in all the required information about your device',
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

              // Device Information Section
              Text(
                'Device Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // IMEI Number Field
              TextFormField(
                controller: _imeiController,
                decoration: const InputDecoration(
                  labelText: 'IMEI Number *',
                  hintText: 'Enter 15-digit IMEI number',
                  prefixIcon: Icon(Icons.fingerprint),
                  helperText: 'Dial *#06# to find your IMEI',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: _validateImei,
              ),
              const SizedBox(height: 16),

              // Device Brand Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBrand,
                decoration: const InputDecoration(
                  labelText: 'Device Brand *',
                  prefixIcon: Icon(Icons.business),
                ),
                items:
                    ImeiService.getDeviceBrands().map((brand) {
                      return DropdownMenuItem(value: brand, child: Text(brand));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select device brand' : null,
              ),
              const SizedBox(height: 16),

              // Device Model Field
              TextFormField(
                controller: _deviceModelController,
                decoration: const InputDecoration(
                  labelText: 'Device Model *',
                  hintText: 'e.g., Galaxy S23, iPhone 14',
                  prefixIcon: Icon(Icons.phone_android),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'Device model'),
              ),
              const SizedBox(height: 16),

              // Device Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDeviceType,
                decoration: const InputDecoration(
                  labelText: 'Device Type *',
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    ImeiService.getDeviceTypes().map((type) {
                      return DropdownMenuItem(value: type, child: Text(type));
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDeviceType = value;
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Please select device type' : null,
              ),
              const SizedBox(height: 24),

              // Optional Information Section
              Text(
                'Optional Information',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),

              // Device Color Field
              TextFormField(
                controller: _deviceColorController,
                decoration: const InputDecoration(
                  labelText: 'Device Color',
                  hintText: 'e.g., Black, White, Blue',
                  prefixIcon: Icon(Icons.palette),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Serial Number Field
              TextFormField(
                controller: _serialNumberController,
                decoration: const InputDecoration(
                  labelText: 'Serial Number',
                  hintText: 'Device serial number',
                  prefixIcon: Icon(Icons.tag),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 16),

              // Purchase Date Field
              TextFormField(
                controller: _purchaseDateController,
                decoration: InputDecoration(
                  labelText: 'Purchase Date',
                  hintText: 'Select purchase date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectPurchaseDate,
                  ),
                ),
                readOnly: true,
                onTap: _selectPurchaseDate,
              ),
              const SizedBox(height: 16),

              // Retailer Name Field
              TextFormField(
                controller: _retailerNameController,
                decoration: const InputDecoration(
                  labelText: 'Retailer/Shop Name',
                  hintText: 'Where did you buy this device?',
                  prefixIcon: Icon(Icons.store),
                ),
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 32),

              // User Information Preview
              Card(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration Details',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      _buildUserInfoRow('Name', widget.user.fullName),
                      _buildUserInfoRow('Email', widget.user.email),
                      _buildUserInfoRow('Phone', widget.user.phoneNumber),
                      _buildUserInfoRow('CNIC', widget.user.cnic),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegistration,
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
                          : Text(
                            'Register Device',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
              const SizedBox(height: 16),

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
                          'Your device registration will be reviewed by our admin team. You will be notified once approved.',
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

  Widget _buildUserInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
