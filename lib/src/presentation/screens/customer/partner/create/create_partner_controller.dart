import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsloution_mobile/common/api_factory/models/partner/partner_module.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/partner.dart';
import 'create_partner_state.dart';

class CreatePartnerController extends GetxController {
  final Rx<CreatePartnerState> state = CreatePartnerState().obs;

  final locationController = TextEditingController();
  final cityController = TextEditingController();
  final countryController = TextEditingController();
  final latController = TextEditingController();
  final longController = TextEditingController();

  Position? currentPosition;
  String? currentAddress;

  @override
  void onInit() {
    super.onInit();
    // لا نستدعي getCurrentLocation هنا - سيتم استدعاؤه يدوياً من الصفحة
    debugPrint('🟢 CreatePartnerController initialized');
  }

  @override
  void onClose() {
    locationController.dispose();
    cityController.dispose();
    countryController.dispose();
    latController.dispose();
    longController.dispose();
    super.onClose();
  }

  void togglePartnerType() {
    final newType = state.value.isClient
        ? PartnerType.contact
        : PartnerType.client;

    state.value = state.value.copyWith(partnerType: newType);

    if (state.value.isClient && currentPosition == null) {
      getCurrentLocation();
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'خطأ',
          'خدمة الموقع غير مفعلة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'خطأ',
            'تم رفض الإذن للوصول إلى الموقع',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'خطأ',
          'إذن الموقع مرفوض بشكل دائم',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      latController.text = currentPosition!.latitude.toString();
      longController.text = currentPosition!.longitude.toString();

      await getAddressFromCoordinates();
    } catch (e) {
      debugPrint('Error getting location: $e');
      Get.snackbar(
        'خطأ',
        'فشل في الحصول على الموقع: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> getAddressFromCoordinates() async {
    if (currentPosition == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        currentPosition!.latitude,
        currentPosition!.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        countryController.text = place.country ?? '';
        cityController.text = place.locality ?? '';

        currentAddress =
            '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
        locationController.text = currentAddress ?? '';
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
    }
  }

  void nextStep() {
    if (state.value.currentStep < 2) {
      state.value = state.value.copyWith(
        currentStep: state.value.currentStep + 1,
      );
    }
  }

  void previousStep() {
    if (state.value.currentStep > 0) {
      state.value = state.value.copyWith(
        currentStep: state.value.currentStep - 1,
      );
    }
  }

  void updateFormData(Map<String, dynamic> data) {
    final updatedData = Map<String, dynamic>.from(state.value.formData)
      ..addAll(data);
    state.value = state.value.copyWith(formData: updatedData);
  }

  Future<void> submitForm(Map<String, dynamic> finalData) async {
    state.value = state.value.copyWith(status: FormStatus.loading);

    try {
      Map<String, dynamic> submitData = Map.from(finalData);

      if (submitData['image_1920'] != null) {
        var images = submitData['image_1920'] as List<dynamic>;
        if (images.isNotEmpty) {
          String imageString = base64Encode(
            File(images[0].path).readAsBytesSync(),
          );
          submitData['image_1920'] = imageString;
        }
      }

      submitData['customer_rank'] = state.value.isClient ? 1 : 0;

      await PartnerModule.createPartners(
        maps: submitData,
        onResponse: (response) {
          PartnerModule.readPartners(
            ids: [response],
            onResponse: (onResponse) {
              PrefUtils.partners.addAll(onResponse);

              state.value = state.value.copyWith(status: FormStatus.success);

              Get.snackbar(
                'نجح',
                'تم إنشاء ${state.value.isClient ? 'العميل' : 'جهة الاتصال'} بنجاح',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );

              Future.delayed(const Duration(milliseconds: 500), () {
                Get.off(() => Partner(partner: onResponse[0]));
              });
            },
          );
        },
      );
    } catch (e) {
      state.value = state.value.copyWith(
        status: FormStatus.error,
        errorMessage: e.toString(),
      );

      Get.snackbar(
        'خطأ',
        'فشل في إنشاء ${state.value.isClient ? 'العميل' : 'جهة الاتصال'}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
