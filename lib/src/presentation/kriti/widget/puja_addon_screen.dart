
import 'dart:async';
import 'dart:convert';
import 'package:devalay_app/src/application/kirti/service/service_cubit.dart';
import 'package:devalay_app/src/core/config/env_config.dart';
import 'package:devalay_app/src/core/router/router.dart';
import 'package:devalay_app/src/core/router/router_constant.dart';
import 'package:devalay_app/src/core/shared_preference.dart';
import 'package:devalay_app/src/data/model/kirti/service_detail_model.dart' show ServiceDetailModel;
import 'package:devalay_app/src/data/repositories/profile_repositories.dart';
import 'package:devalay_app/src/presentation/core/constants/strings.dart';
import 'package:devalay_app/src/presentation/core/utils/colors.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../../application/kirti/service/service_state.dart';

class PujaAddonScreen extends StatefulWidget {
  final String pujaName;
  final String planName;
  final String planPrice;
  final String planId;
  final String serviceId;
  final ServiceDetailModel serviceModel;
  
  const PujaAddonScreen({
    super.key,
    required this.pujaName,
    required this.planName,
    required this.planPrice,
    required this.planId,
    required this.serviceId,
    required this.serviceModel,
  });

  @override
  State<PujaAddonScreen> createState() => _PujaAddonScreenState();
}

class _PujaAddonScreenState extends State<PujaAddonScreen> {
  String selectedCountryCode = "+91";
  Map<int, double> selectedAddons = {};
  String? selectedPlanId;
  double selectedPlanPrice = 0.0;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool isChecked = false;
  String? orderId;
  // Razorpay Variables
  Razorpay? _razorpay;
  final bool _isDownloadingInvoice = false;
  bool _isProcessingPayment = false; // Flag to prevent duplicate order creation
  bool _razorpayInitialized = false; // Flag to track if Razorpay is initialized
  
  // Location variables
  bool _isLoadingLocation = false;
  final TextEditingController _addressSearchController = TextEditingController();
  List<dynamic> _addressSearchResults = [];
  bool _showAddressDropdown = false;
  Timer? _addressDebounceTimer;


  String get razorpayKeyId => EnvConfig.razorpayKeyId;
  @override
  void initState() {
    super.initState();
    context.read<ServiceCubit>().fetchAddOnsData();
    selectedPlanId = widget.planId;
    selectedPlanPrice =
        double.tryParse(widget.planPrice.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0;
    _prefillFromProfile();
    
    // Initialize address search listener
    _addressSearchController.addListener(_onAddressSearchChanged);
    
    // Initialize Razorpay
    _initializeRazorpay();

    
  }

  

  void _initializeRazorpay() {
    // Prevent multiple initializations unless forced
    if (_razorpayInitialized && _razorpay != null) {
      debugPrint('⚠️ Razorpay already initialized, skipping...');
      return;
    }
    
    debugPrint('🔄 Initializing Razorpay...');
    
    try {
      // Dispose existing instance if any
      if (_razorpay != null) {
        try {
          _razorpay!.clear();
        } catch (e) {
          // Ignore if already disposed or not initialized
          debugPrint('⚠️ Could not clear existing Razorpay instance: $e');
        }
      }
      
      // Create new Razorpay instance
      _razorpay = Razorpay();
      
      // Clear any existing listeners first (safety measure)
      _razorpay!.clear();
      
      // Set up event listeners
      _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      
      _razorpayInitialized = true;
      debugPrint('✅ Razorpay initialized successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to initialize Razorpay: $e');
      debugPrint('Stack trace: $stackTrace');
      _razorpayInitialized = false;
      _razorpay = null;
      
      // Show error to user only if widget is still mounted
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _showError(StringConstant.paymentInitFailed);
          }
        });
      }
    }
  }

  /// Ensures Razorpay is initialized, with retry logic
  Future<void> _ensureRazorpayInitialized() async {
    if (_razorpayInitialized && _razorpay != null) {
      return;
    }
    
    debugPrint('⚠️ Razorpay not initialized, initializing now...');
    _initializeRazorpay();
    
    // Wait for initialization to complete
    await Future.delayed(const Duration(milliseconds: 300));
    
    // If still not initialized, try one more time
    if (!_razorpayInitialized || _razorpay == null) {
      debugPrint('⚠️ First initialization attempt failed, retrying...');
      _razorpayInitialized = false;
      _razorpay = null;
      _initializeRazorpay();
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }


void _clearFormFields() {
  final cubit = context.read<ServiceCubit>();
  
  setState(() {
    // Clear all text controllers
    cubit.nameController.clear();
    cubit.phoneNumberController.clear();
    cubit.addressController.clear();
    cubit.dobController.clear();
    cubit.timeController.clear();
    cubit.instructionController.clear();
    
    // Reset selected values
    selectedCountryCode = "+91";
    selectedAddons.clear();
    selectedDate = null;
    selectedTime = null;
    isChecked = false;
    
    // Keep the plan selection as it was initially passed
    selectedPlanId = widget.planId;
    selectedPlanPrice = double.tryParse(
      widget.planPrice.replaceAll(RegExp(r'[^\d.]'), '')
    ) ?? 0;
  });
  
  debugPrint('✅ Form fields cleared');
}
void _handlePaymentSuccess(PaymentSuccessResponse response) async {
  // Prevent duplicate order creation
  if (_isProcessingPayment) {
    debugPrint('⚠️ Payment already being processed, ignoring duplicate callback');
    return;
  }

  // Set flag to prevent duplicate processing
  _isProcessingPayment = true;

  debugPrint('🔄 Processing payment success...');
  debugPrint('📋 Razorpay Payment Response:');
  debugPrint('   Payment ID: ${response.paymentId}');
  debugPrint('   Order ID: ${response.orderId}');
  debugPrint('   Signature: ${response.signature}');

  // Show loading dialog during backend processing
  if (mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(StringConstant.confirmingBooking),
              const SizedBox(height: 8),
              Text(
                StringConstant.pleaseWait,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  try {
    final cubit = context.read<ServiceCubit>();
    
    debugPrint('🔄 Creating order in backend...');

    // Validate required fields
    if (selectedDate == null || selectedTime == null) {
      throw Exception('Date and time must be selected');
    }

    // Format datetime to ISO 8601: 2025-11-26T02:21:00+05:30
    final String scheduledDatetime = _formatDateTimeForAPI(selectedDate!, selectedTime!);
    
    // Get plan ID as int
    final int planId = int.tryParse(selectedPlanId ?? widget.planId) ?? 0;
    if (planId == 0) {
      throw Exception('Invalid plan ID');
    }
    
    // Get service section as int
    final int serviceSectionId = int.tryParse(widget.serviceId) ?? 0;
    if (serviceSectionId == 0) {
      throw Exception('Invalid service section ID');
    }
    
    // Get add-ons as List<int>
    final List<int> addOnsList = selectedAddons.keys.toList();
    
    // Get mobile number with country code
    final String mobileNumber = selectedCountryCode + cubit.phoneNumberController.text.trim();
    
    // Get name and address
    final String name = cubit.nameController.text.trim();
    final String address = cubit.addressController.text.trim();

    // Validate required fields
    if (name.isEmpty) {
      throw Exception('Name is required');
    }
    if (address.isEmpty) {
      throw Exception('Address is required');
    }
    if (mobileNumber.isEmpty || mobileNumber == selectedCountryCode) {
      throw Exception('Mobile number is required');
    }

    // Create order in your backend with all required data
    await cubit.createOrder(
      razorpayOrderId: response.orderId ?? '',
      razorpayPaymentId: response.paymentId ?? '',
      paymentStatus: true,
      plan: planId,
      addOns: addOnsList,
      serviceSection: serviceSectionId,
      scheduledDatetime: scheduledDatetime,
      name: name,
      address: address,
      mobileNumber: mobileNumber,
    );

  
    // Close loading dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }

    // ✨ CLEAR FORM FIELDS AFTER SUCCESSFUL ORDER
    _clearFormFields();

    // Reset processing flag so user can book again
    _isProcessingPayment = false;

    _showSuccessDialogWithDownload(response.paymentId ?? 'N/A');
  } catch (e) {
    debugPrint('❌ Failed to create order: $e');
    
    // Reset flag on error so user can retry
    _isProcessingPayment = false;
    
    // Close loading dialog
    if (mounted) {
      Navigator.of(context, rootNavigator: true).maybePop();
    }
    
    _handleError(StringConstant.paymentSuccessOrderFailed(e.toString()));
  }
}
void _showSuccessDialogWithDownload(String transactionId) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 30),
          const SizedBox(width: 8),
          Text(StringConstant.paymentSuccessful),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(StringConstant.bookingConfirmed(widget.pujaName)),
          const SizedBox(height: 12),
          Text(
            '${StringConstant.transactionIdLabel}\n$transactionId',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          if (orderId != null) ...[
            const SizedBox(height: 8),
            Text(
              '${StringConstant.orderIdLabel}\n$orderId',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        // Download Invoice Button
        TextButton.icon(
          onPressed: _isDownloadingInvoice
              ? null
              : () async {
                  await   context.read<ServiceCubit>().downloadInvoice(orderId,mounted,context);
                },
          icon: _isDownloadingInvoice
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.download, size: 20),
          label: Text(
            _isDownloadingInvoice ? StringConstant.downloading : StringConstant.downloadInvoice,
          ),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        // OK Button
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close dialog
            // Navigate to dashboard (landing screen) after order completion
            AppRouter.go(RouterConstant.landingScreen);
          },
          child: Text(StringConstant.ok),
        ),
      ],
    ),
  );
}
  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment Failed!');
    debugPrint('   Code: ${response.code}');
    debugPrint('   Message: ${response.message}');

    String errorMessage = StringConstant.paymentFailed;
    
    // Handle specific error codes
    switch (response.code) {
      case Razorpay.PAYMENT_CANCELLED:
        errorMessage = StringConstant.paymentCancelledByUser;
        break;
      case Razorpay.NETWORK_ERROR:
        errorMessage = StringConstant.networkErrorCheckConnection;
        break;
      case Razorpay.INVALID_OPTIONS:
        errorMessage = StringConstant.invalidPaymentOptions;
        break;
      default:
        errorMessage = response.message ?? StringConstant.paymentFailedTryAgain;
    }

    _handleError(errorMessage);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('🔄 External Wallet Selected: ${response.walletName}');
    
    // Handle external wallet payment
    // You may need to implement additional logic here based on your requirements
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(StringConstant.selectedWallet(response.walletName ?? '')),
        backgroundColor: Colors.blue,
      ),
    );
  }







void _handlePurchase() async {
  debugPrint('🚀 Starting payment flow...');

  // Validate form
  final cubit = context.read<ServiceCubit>();
  if (!cubit.serviceFormKey.currentState!.validate()) {
    debugPrint('⚠️ Form validation failed');
    return;
  }

  if (!validatePlanSelection()) {
    return;
  }

  if (!validateTermsAndConditions()) {
    return;
  }

  // Validate date and time are selected
  if (selectedDate == null || selectedTime == null) {
    _handleError(StringConstant.pleaseSelectDateAndTime);
    return;
  }

  try {
    // Format datetime to ISO 8601: 2025-11-26T02:21:00+05:30
    final String scheduledDatetime = _formatDateTimeForAPI(selectedDate!, selectedTime!);
     
    final response =
        await context.read<ServiceCubit>().createRazorpayOrder(
              serviceId: widget.serviceId,
              plan: selectedPlanId ?? widget.planId,
              addOns: selectedAddons.keys.toList(),
              address: cubit.addressController.text.trim(),
              name: cubit.nameController.text.trim(),
              mobileNumber: selectedCountryCode +
                  cubit.phoneNumberController.text.trim(),
              scheduledDatetime: scheduledDatetime,
            );

    if (response == null) {
      debugPrint('❌ Failed to create Razorpay order (null response)');
      _handleError(StringConstant.failedToStartPayment);
      return;
    }

    debugPrint('✅ Razorpay order response: $response');

    // Extract amount (in rupees) and convert to paise for Razorpay
    final num amount = (response['amount'] ?? 0) as num;
    final int amountInPaise = (amount * 100).round();
      /* my data Response data 
      {
    "razorpay_order_id": "order_Rn74j2sMdi5KED",
    "amount": 2502.0,
    "currency": "INR",
    "plan": 12,
    "add_ons": [
        1
    ],
    "scheduled_datetime": "2025-11-26T02:21:00+05:30",
    "name": "gresg",
    "address": "Delhi",
    "mobile_number": "+919876543210"
}
      
      */
    // Create Razorpay options
    var options = {
      'key': razorpayKeyId,
      'amount': amountInPaise,
      'name': 'Devalay',
      'description': '${widget.pujaName} - ${widget.planName}',
      // Razorpay checkout expects `order_id` when using Orders API
      'order_id': response['razorpay_order_id'],
      'currency': response['currency'] ?? 'INR',
      'prefill': {
        'contact':
            selectedCountryCode + cubit.phoneNumberController.text.trim(),
        'email': '',
        'name': cubit.nameController.text.trim(),
      },
      'notes': {
        'service_id': widget.serviceId,
        'plan_id': selectedPlanId ?? widget.planId,
        'puja_name': widget.pujaName,
      },
      'retry': {
        'enabled': true,
        'max_count': 3
      },
    };

    // Ensure Razorpay is initialized before opening payment
    await _ensureRazorpayInitialized();
    
    if (!_razorpayInitialized || _razorpay == null) {
      _handleError(StringConstant.paymentSystemNotReady);
      return;
    }
    
    // Add a small delay to ensure UI is ready
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Attempt to open payment with retry logic
    bool paymentOpened = false;
    int retryCount = 0;
    const maxRetries = 2;
    
    while (!paymentOpened && retryCount <= maxRetries) {
      try {
        if (_razorpay == null || !_razorpayInitialized) {
          debugPrint('⚠️ Razorpay not initialized, re-initializing...');
          await _ensureRazorpayInitialized();
          
          if (!_razorpayInitialized || _razorpay == null) {
            _handleError(StringConstant.paymentInitFailed);
            return;
          }
        }
        
        debugPrint('🔄 Attempting to open Razorpay (attempt ${retryCount + 1})...');
        _razorpay!.open(options);
        paymentOpened = true;
        debugPrint('✅ Razorpay payment opened successfully');
        
      } catch (razorpayError) {
        debugPrint('❌ Razorpay open error (attempt ${retryCount + 1}): $razorpayError');
        debugPrint('Error type: ${razorpayError.runtimeType}');
        
        // Check if it's a NotInitializedError
        final errorString = razorpayError.toString().toLowerCase();
        final isNotInitialized = errorString.contains('notinitialized') || 
                                 errorString.contains('not initialized') ||
                                 razorpayError.runtimeType.toString().contains('NotInitialized');
        
        if (isNotInitialized && retryCount < maxRetries) {
          debugPrint('🔄 NotInitializedError detected, re-initializing Razorpay...');
          _razorpayInitialized = false;
          _razorpay = null;
          
          // Wait before retry
          await Future.delayed(Duration(milliseconds: 300 * (retryCount + 1)));
          
          // Re-initialize
          await _ensureRazorpayInitialized();
          retryCount++;
        } else {
          // If not a NotInitializedError or max retries reached, show error
          _handleError(StringConstant.paymentGatewayFailed);
          return;
        }
      }
    }
    
    if (!paymentOpened) {
      _handleError(StringConstant.paymentGatewayRetry);
    }
    
  } catch (e, stackTrace) {
    debugPrint('❌ Payment Error: $e');
    debugPrint('Stack trace: $stackTrace');
    
    // Check if it's a NotInitializedError in the outer catch
    final errorString = e.toString().toLowerCase();
    if (errorString.contains('notinitialized') || 
        errorString.contains('not initialized') ||
        e.runtimeType.toString().toLowerCase().contains('notinitialized')) {
      debugPrint('🔄 NotInitializedError in outer catch, attempting recovery...');
      await _ensureRazorpayInitialized();
      
      if (_razorpayInitialized && _razorpay != null) {
        debugPrint('✅ Razorpay re-initialized, but cannot retry payment from here.');
        debugPrint('⚠️ Please try the payment again.');
        _handleError(StringConstant.paymentTryAgain);
        return;
      }
    }
    
    _handleError(StringConstant.failedToStartPaymentError(e.toString()));
  }
}

  void _handleError(String message) {
    debugPrint('❌ Error: $message');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🔄 Disposing payment screen...');
    // Clear Razorpay listeners and close
    if (_razorpayInitialized && _razorpay != null) {
      try {
        _razorpay!.clear(); // Clear all listeners
      } catch (e) {
        debugPrint('⚠️ Error clearing Razorpay: $e');
      }
    }
    _addressSearchController.dispose();
    _addressSearchResults.clear();
    _showAddressDropdown = false;
    _isLoadingLocation = false;
    _addressDebounceTimer?.cancel();
    _isProcessingPayment = false;
    _razorpayInitialized = false;
    _razorpay = null;
    super.dispose();
  }

  Future<void> _prefillFromProfile() async {
    try {
      final userId = await PrefManager.getUserDevalayId();
      if (userId == null || userId.isEmpty) return;

      final repo = ProfileRepositories();
      final result = await repo.fetchProfileInfoData(userId);
      result.fold((failure) {
        // ignore errors silently for prefill
      }, (success) {
        final data = success.response?.data as Map<String, dynamic>?;
        final fullName = (data?['name'] ?? '').toString().trim();
        final phone = (data?['phone'] ?? '').toString().trim();
        final city = (data?['biography'] ?? '').toString().trim();

        String derivedCode = selectedCountryCode;
        String derivedNumber = phone;
        if (phone.startsWith('+')) {
          if (phone.startsWith('+91')) {
            derivedCode = '+91';
            derivedNumber = phone.substring(3);
          }
        }

        final cubit = context.read<ServiceCubit>();
        setState(() {
          cubit.nameController.text = fullName;
          cubit.phoneNumberController.text = derivedNumber;
          cubit.addressController.text = city;
          selectedCountryCode = derivedCode;
        });
      });
    } catch (_) {
      // no-op
    }
  }

  double getSelectedPlanPrice() {
    if (selectedPlanId == null || widget.serviceModel.plans == null) return 0.0;

    try {
      final selectedPlan = widget.serviceModel.plans!.firstWhere(
        (plan) => plan.id.toString() == selectedPlanId,
      );
      final String raw = selectedPlan.price.toString();
      final String numeric = raw.replaceAll(RegExp(r'[^\d.]'), '');
      if (numeric.isEmpty) return 0.0;
      return double.parse(numeric);
    } catch (e) {
      return 0.0;
    }
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your full name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters long';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your phone number';
    }
    if (value.trim().length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Phone number can only contain digits';
    }
    return null;
  }

  String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your address';
    }
    if (value.trim().length < 10) {
      return 'Please enter a complete address';
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a date';
    }
    
    // Check if selected date + time is in the past
    if (selectedDate != null && selectedTime != null) {
      final DateTime combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      
      if (combinedDateTime.isBefore(DateTime.now())) {
        return 'Selected date and time cannot be in the past';
      }
    }
    
    return null;
  }

  String? validateTime(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select a time';
    }
    
    // Check if selected date + time is in the past
    if (selectedDate != null && selectedTime != null) {
      final DateTime combinedDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      
      if (combinedDateTime.isBefore(DateTime.now())) {
        return 'Selected date and time cannot be in the past';
      }
    }
    
    return null;
  }

  bool validateTermsAndConditions() {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept Terms and Conditions to proceed'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  bool validatePlanSelection() {
    if (selectedPlanId == null || selectedPlanId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a plan'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
    return true;
  }

  // Location methods
  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoadingLocation = true;
      });

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final placemark = placemarks.first;
          await _fillAddressFromPlacemark(placemark);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location filled successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No address found for this location'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error getting location: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _fillAddressFromPlacemark(Placemark placemark) async {
    final cubit = context.read<ServiceCubit>();

    String street = '';

    if (placemark.subThoroughfare != null &&
        placemark.subThoroughfare!.isNotEmpty) {
      street = placemark.subThoroughfare!;
    }

    if (placemark.thoroughfare != null && placemark.thoroughfare!.isNotEmpty) {
      street = street.isEmpty
          ? placemark.thoroughfare!
          : '$street, ${placemark.thoroughfare!}';
    }

    if (placemark.street != null &&
        placemark.street!.isNotEmpty &&
        street.isEmpty) {
      street = placemark.street!;
    }

    // Build complete address
    List<String> addressParts = [];
    if (street.isNotEmpty) addressParts.add(street);
    if (placemark.locality != null && placemark.locality!.isNotEmpty) {
      addressParts.add(placemark.locality!);
    }
    if (placemark.administrativeArea != null &&
        placemark.administrativeArea!.isNotEmpty) {
      addressParts.add(placemark.administrativeArea!);
    }
    if (placemark.postalCode != null && placemark.postalCode!.isNotEmpty) {
      addressParts.add(placemark.postalCode!);
    }
    if (placemark.country != null && placemark.country!.isNotEmpty) {
      addressParts.add(placemark.country!);
    }

    cubit.addressController.text = addressParts.join(', ');
    setState(() {
      _showAddressDropdown = false;
    });
  }

  void _onAddressSearchChanged() {
    _addressDebounceTimer?.cancel();
    _addressDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_addressSearchController.text.isNotEmpty) {
        _searchAddresses(_addressSearchController.text);
      } else {
        setState(() {
          _addressSearchResults = [];
          _showAddressDropdown = false;
        });
      }
    });
  }

  Future<void> _searchAddresses(String query) async {
    try {
      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$query'
        '&key=AIzaSyCyg1_60NlB-xtlzhGQcoJG6OCsE6UVAu8'
        '&components=country:in',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['predictions'] != null) {
          setState(() {
            _addressSearchResults = data['predictions'] as List;
            _showAddressDropdown = true;
          });
        } else {
          setState(() {
            _addressSearchResults = [];
            _showAddressDropdown = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error searching addresses: $e');
    }
  }

  Future<void> _onAddressSelected(String description, String placeId) async {
    final cubit = context.read<ServiceCubit>();
    
    try {
      setState(() {
        _isLoadingLocation = true;
        _showAddressDropdown = false;
      });

      final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&fields=address_components,formatted_address'
        '&key=AIzaSyCyg1_60NlB-xtlzhGQcoJG6OCsE6UVAu8',
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final addressComponents =
              data['result']['address_components'] as List;
          final formattedAddress = data['result']['formatted_address'] as String;

          String street = '';
          String city = '';
          String state = '';
          String country = '';
          String postalCode = '';

          for (var component in addressComponents) {
            final types = component['types'] as List;
            final longName = component['long_name'] as String;

            if (types.contains('street_number')) {
              street = '$longName $street';
            } else if (types.contains('route')) {
              street = '$street$longName';
            } else if (types.contains('locality')) {
              city = longName;
            } else if (types.contains('administrative_area_level_2') &&
                city.isEmpty) {
              city = longName;
            } else if (types.contains('administrative_area_level_1')) {
              state = longName;
            } else if (types.contains('country')) {
              country = longName;
            } else if (types.contains('postal_code')) {
              postalCode = longName;
            }
          }

          // Build complete address
          List<String> addressParts = [];
          if (street.trim().isNotEmpty) {
            addressParts.add(street.trim());
          }
          if (city.isNotEmpty) addressParts.add(city);
          if (state.isNotEmpty) addressParts.add(state);
          if (postalCode.isNotEmpty) addressParts.add(postalCode);
          if (country.isNotEmpty) addressParts.add(country);

          cubit.addressController.text = addressParts.isNotEmpty
              ? addressParts.join(', ')
              : formattedAddress;

          _addressSearchController.text = description;
        }
      }
    } catch (e) {
      debugPrint('Error getting address details: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading address: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  /// Formats date and time to ISO 8601 format: 2025-11-26T02:21:00+05:30
  String _formatDateTimeForAPI(DateTime date, TimeOfDay time) {
    // Combine date and time
    final DateTime combinedDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    
    // Format to ISO 8601 with timezone offset (+05:30 for IST)
    final String formatted = DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(combinedDateTime);
    return "$formatted+05:30";
  }

  // Figma design colors
  static const Color _labelColor = Color(0xD9344054); // rgba(52,64,84,0.85)
  static const Color _inputBorderColor = Color(0x2E3C3C43); // rgba(60,60,67,0.18)
  static const Color _radioBorderColor = Color(0xFF979797);
  static const Color _buttonColor = Color(0xBFFF9500); // rgba(255,149,0,0.75)

  @override
  Widget build(BuildContext context) {
    final double basePrice = getSelectedPlanPrice();
    final double addonsTotal =
        selectedAddons.values.fold(0, (sum, price) => sum + price);
    final double totalAmount = basePrice + addonsTotal;

    final cubit = BlocProvider.of<ServiceCubit>(context);
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColor.whiteColor,
        leadingWidth: 40,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: AppColor.blackColor, size: 24),
        ),
        titleSpacing: 0,
        title: Text(
          '${StringConstant.book} ${widget.pujaName}',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xE6000000), // rgba(0,0,0,0.9)
            letterSpacing: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
        child: Form(
          key: cubit.serviceFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                  // Enter your information label
                  Text(
                    StringConstant.enterYourInformation,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(15.h),
                  // Full Name Field
                  _buildFigmaTextField(
                    label: StringConstant.fullName,
                    controller: cubit.nameController,
                    validator: validateName,
                  ),
                  Gap(8.h),
                  // Phone Number Field
                  Text(
                    StringConstant.phoneNumber,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(8.h),
                  Container(
                    height: 42.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.r),
                      border: Border.all(color: _inputBorderColor),
                    ),
                    child: Row(
                      children: [
                        // Country code section with separator
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 14.w),
                          decoration: const BoxDecoration(
                            border: Border(
                              right: BorderSide(color: Color(0xFFDCDCDD)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/icon/flag_india.png',
                                width: 18.w,
                                height: 14.h,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 18.w,
                                  height: 14.h,
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              Gap(6.w),
                              Text(
                                '+91',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xDE0F0D0D), // rgba(15,13,13,0.87)
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Phone number input
                        Expanded(
                          child: TextFormField(
                            controller: cubit.phoneNumberController,
                            keyboardType: TextInputType.phone,
                            validator: validatePhoneNumber,
                            style: TextStyle(fontSize: 14.sp),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(8.h),
                  // Address Field with Location Search
                  Text(
                    StringConstant.address,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(8.h),
                  // Address Search Field
                  GestureDetector(
                    onTap: () {
                      // Close dropdown when tapping outside
                      setState(() {
                        _showAddressDropdown = false;
                      });
                    },
                    child: Stack(
                      children: [
                        TextFormField(
                          controller: _addressSearchController,
                          style: TextStyle(fontSize: 14.sp),
                          decoration: InputDecoration(
                            hintText: 'Search to autofill address',
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.h,
                              horizontal: 12.w,
                            ),
                            suffixIcon: _isLoadingLocation
                                ? Padding(
                                    padding: EdgeInsets.all(12.sp),
                                    child: SizedBox(
                                      width: 15.w,
                                      height: 15.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.grey,
                                        ),
                                      ),
                                    ),
                                  )
                                : IconButton(
                                    icon: Icon(
                                      Icons.my_location,
                                      size: 20.sp,
                                      color: AppColor.orangeColor,
                                    ),
                                    onPressed: _getCurrentLocation,
                                    tooltip: 'Use current location',
                                  ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: const BorderSide(color: _inputBorderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.r),
                              borderSide: const BorderSide(color: _inputBorderColor, width: 1.5),
                            ),
                            constraints: BoxConstraints(minHeight: 42.h, maxHeight: 60.h),
                          ),
                          onTap: () {
                            // Keep dropdown open when tapping on field
                          },
                        ),
                        // Address Dropdown
                        if (_showAddressDropdown && _addressSearchResults.isNotEmpty)
                          Positioned(
                            top: 42.h,
                            left: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                // Prevent closing when tapping inside dropdown
                              },
                              child: Container(
                                constraints: BoxConstraints(maxHeight: 200.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(5.r),
                                  border: Border.all(color: _inputBorderColor),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: _addressSearchResults.length,
                                  itemBuilder: (context, index) {
                                    final prediction = _addressSearchResults[index];
                                    final description = prediction['description'] as String;
                                    final placeId = prediction['place_id'] as String;
                                    
                                    return InkWell(
                                      onTap: () {
                                        _onAddressSelected(description, placeId);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.all(12.w),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.location_on,
                                              size: 20.sp,
                                              color: Colors.grey,
                                            ),
                                            Gap(8.w),
                                            Expanded(
                                              child: Text(
                                                description,
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Gap(8.h),
                  // Actual Address Field (populated by search or manual entry)
                  TextFormField(
                    controller: cubit.addressController,
                    validator: validateAddress,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Address (auto-filled or enter manually)',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 12.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      constraints: BoxConstraints(minHeight: 42.h, maxHeight: 60.h),
                    ),
                  ),
                  Gap(8.h),
                  // Select Date Field
                  Text(
                    StringConstant.selectDate,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(8.h),
                  TextFormField(
                    controller: cubit.dobController,
                    readOnly: true,
                    validator: validateDate,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Icon(
                          Icons.calendar_today_outlined,
                          size: 15.sp,
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 12.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      constraints: BoxConstraints(minHeight: 42.h, maxHeight: 60.h),
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          selectedDate = pickedDate;
                          String formattedDate =
                              DateFormat('dd MMM yyyy').format(pickedDate);
                          cubit.dobController.text = formattedDate;
                          // Clear time if date changes to ensure validation
                          if (selectedTime != null) {
                            final DateTime combinedDateTime = DateTime(
                              pickedDate.year,
                              pickedDate.month,
                              pickedDate.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            );
                            if (combinedDateTime.isBefore(DateTime.now())) {
                              selectedTime = null;
                              cubit.timeController.clear();
                            }
                          }
                        });
                      }
                    },
                  ),
                  Gap(10.h),
                  // Select Time Field
                  Text(
                    StringConstant.selectTime,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(8.h),
                  TextFormField(
                    validator: validateTime,
                    controller: cubit.timeController,
                    readOnly: true,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.all(12.sp),
                        child: Icon(
                          Icons.access_time,
                          size: 15.sp,
                          color: Colors.grey,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.h,
                        horizontal: 12.w,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Colors.red, width: 1.5),
                      ),
                      constraints: BoxConstraints(minHeight: 42.h, maxHeight: 60.h),
                    ),
                    onTap: () async {
                      // Set initial time based on selected date
                      TimeOfDay initialTime = TimeOfDay.now();
                      if (selectedDate != null) {
                        final today = DateTime.now();
                        if (selectedDate!.year == today.year &&
                            selectedDate!.month == today.month &&
                            selectedDate!.day == today.day) {
                          // If selected date is today, use current time
                          initialTime = TimeOfDay.now();
                        } else {
                          // If future date, use 9 AM as default
                          initialTime = const TimeOfDay(hour: 9, minute: 0);
                        }
                      }
                      
                      TimeOfDay? time = await showTimePicker(
                        context: context,
                        initialTime: initialTime,
                      );
                      if (time != null) {
                        // Validate that date + time is not in the past
                        if (selectedDate != null) {
                          final DateTime combinedDateTime = DateTime(
                            selectedDate!.year,
                            selectedDate!.month,
                            selectedDate!.day,
                            time.hour,
                            time.minute,
                          );
                          
                          if (combinedDateTime.isBefore(DateTime.now())) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Selected date and time cannot be in the past'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                        }
                        
                        setState(() {
                          selectedTime = time;
                          cubit.timeController.text = _formatTime(time);
                        });
                      }
                    },
                  ),
                  Gap(18.h),
                  // Special Instructions (Optional)
                  Text(
                    StringConstant.specialInstructions,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                    ),
                  ),
                  Gap(8.h),
                  TextFormField(
                    controller: cubit.instructionController,
                    maxLines: 4,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.all(12.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: _inputBorderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.r),
                        borderSide: const BorderSide(color: Color.fromARGB(45, 51, 51, 56), width: 1.5),
                      ),
                      constraints: BoxConstraints(minHeight: 103.h),
                    ),
                  ),
                  Gap(18.h),
                  // Select Plan Section
                  Text(
                    StringConstant.selectPlan,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                      letterSpacing: 1,
                    ),
                  ),
                  Gap(12.h),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.serviceModel.plans!.length,
                    itemBuilder: (context, index) {
                      final plan = widget.serviceModel.plans![index];
                      final isSelected = selectedPlanId == plan.id.toString();
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPlanId = plan.id.toString();
                          });
                        },
                        child: Row(
                          children: [
                            // Figma-style radio button (18px circle with #979797 border)
                            Container(
                              width: 18.w,
                              height: 18.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected ? AppColor.orangeColor : _radioBorderColor,
                                  width: isSelected ? 5 : 1,
                                ),
                              ),
                            ),
                            Gap(13.w),
                            Text(
                              plan.type ?? "",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: _labelColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '₹${plan.price!.round()}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w400,
                                color: _labelColor,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => Gap(10.h),
                  ),
                  Gap(18.h),
                  // Select Add-ons Section
                  Text(
                    StringConstant.selectAddOns,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w400,
                      color: _labelColor,
                      letterSpacing: 1,
                    ),
                  ),
                  Gap(12.h),
                  BlocBuilder<ServiceCubit, ServiceState>(
                    builder: (context, state) {
                      if (state is ServiceLoadedState) {
                        if (state.isLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (state.errorMessage.isNotEmpty) {
                          return Center(child: Text(state.errorMessage));
                        }
                        if (state.addOnsList == null ||
                            state.addOnsList!.isEmpty) {
                          return Center(
                            child: Text(
                              'No Addons Available',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.addOnsList!.length,
                          itemBuilder: (context, index) {
                            final addon = state.addOnsList![index];
                            final isSelected = selectedAddons.containsKey(addon.id);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    selectedAddons.remove(addon.id);
                                  } else {
                                    selectedAddons[addon.id ?? 0] = addon.price ?? 0;
                                  }
                                });
                              },
                              child: Row(
                                children: [
                                  // Figma-style checkbox (18px square with #979797 border)
                                  Container(
                                    width: 18.w,
                                    height: 18.h,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColor.orangeColor : Colors.white,
                                      border: Border.all(
                                        color: isSelected ? AppColor.orangeColor : _radioBorderColor,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                                        : null,
                                  ),
                                  Gap(13.w),
                                  Expanded(
                                    child: Text(
                                      addon.title ?? '',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w400,
                                        color: _labelColor,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '₹${addon.price?.round()}',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w400,
                                      color: _labelColor,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => Gap(10.h),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                  Gap(27.h),
                  // TOTAL Row
                  Row(
                    children: [
                      Text(
                        StringConstant.total.toUpperCase(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: _labelColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        "₹${totalAmount.round()}",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: _labelColor,
                        ),
                      ),
                    ],
                  ),
                  Gap(27.h),
                  // Terms and Conditions Row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Figma-style checkbox (18px square with #979797 border)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isChecked = !isChecked;
                          });
                        },
                        child: Container(
                          width: 18.w,
                          height: 18.h,
                          decoration: BoxDecoration(
                            color: isChecked ? AppColor.orangeColor : Colors.white,
                            border: Border.all(color: _radioBorderColor),
                          ),
                          child: isChecked
                              ? Icon(Icons.check, size: 14.sp, color: Colors.white)
                              : null,
                        ),
                      ),
                      Gap(10.w),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: _labelColor,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms and Conditions, ',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.sp,
                                  color: _labelColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint("Tapped Terms and Conditions");
                                  },
                              ),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.sp,
                                  color: const Color(0xFF344054),
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint("Tapped Privacy Policy");
                                  },
                              ),
                              TextSpan(
                                text: ', and EULA',
                                style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 12.sp,
                                  color: _labelColor,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    debugPrint("Tapped EULA");
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(27.h),
                  // Book Button (Figma style: orange #FF9500 75% opacity, 35h, 4r)
                  SizedBox(
                    width: double.infinity,
                    height: 35.h,
                    child: ElevatedButton(
                      onPressed: _handlePurchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '${StringConstant.book} ${widget.planName}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Gap(40.h),
                ],
              ),
            ),
          ),
      );
  }

  /// Figma-style text field with label
  Widget _buildFigmaTextField({
    required String label,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w400,
            color: _labelColor,
          ),
        ),
        Gap(8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: TextStyle(fontSize: 14.sp),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: 12.h,
              horizontal: 12.w,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: _inputBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: BorderSide(color: _inputBorderColor, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5.r),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            constraints: BoxConstraints(minHeight: 42.h, maxHeight: maxLines > 1 ? 120.h : 60.h),
          ),
        ),
      ],
    );
  }
}
