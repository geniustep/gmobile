import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../create_partner_controller.dart';

class LocationForm extends StatefulWidget {
  final GlobalKey<FormBuilderState> formKey;

  const LocationForm({super.key, required this.formKey});

  @override
  State<LocationForm> createState() => _LocationFormState();
}

class _LocationFormState extends State<LocationForm> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = HashSet<Marker>();

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreatePartnerController>();

    return FormBuilder(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),

          Obx(() {
            final position = controller.currentPosition;

            return Card(
              elevation: 2,
              child: SizedBox(
                height: 300,
                child: position == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            const Text('جاري تحميل الخريطة...'),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => controller.getCurrentLocation(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('إعادة المحاولة'),
                            ),
                          ],
                        ),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(position.latitude, position.longitude),
                          zoom: 14.5,
                        ),
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        zoomControlsEnabled: true,
                        mapToolbarEnabled: false,
                        onMapCreated: (GoogleMapController mapController) {
                          if (_mapController == null) {
                            _mapController = mapController;

                            setState(() {
                              _markers.add(
                                Marker(
                                  markerId: const MarkerId('current_location'),
                                  position: LatLng(
                                    position.latitude,
                                    position.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: 'الموقع الحالي',
                                    snippet: controller.currentAddress ?? '',
                                  ),
                                ),
                              );
                            });
                          }
                        },
                        markers: _markers,
                      ),
              ),
            );
          }),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () async {
              await controller.getCurrentLocation();
              if (controller.currentPosition != null) {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLng(
                    LatLng(
                      controller.currentPosition!.latitude,
                      controller.currentPosition!.longitude,
                    ),
                  ),
                );

                setState(() {
                  _markers.clear();
                  _markers.add(
                    Marker(
                      markerId: const MarkerId('current_location'),
                      position: LatLng(
                        controller.currentPosition!.latitude,
                        controller.currentPosition!.longitude,
                      ),
                      infoWindow: InfoWindow(
                        title: 'الموقع الحالي',
                        snippet: controller.currentAddress ?? '',
                      ),
                    ),
                  );
                });
              }
            },
            icon: const Icon(Icons.my_location),
            label: const Text('تحديث الموقع'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),

          const SizedBox(height: 16),

          FormBuilderTextField(
            name: 'street',
            controller: controller.locationController,
            decoration: const InputDecoration(
              labelText: 'العنوان *',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
            validator: FormBuilderValidators.required(errorText: 'الحقل مطلوب'),
            maxLines: 2,
            textInputAction: TextInputAction.next,
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'city',
                  controller: controller.cityController,
                  decoration: const InputDecoration(
                    labelText: 'المدينة *',
                    prefixIcon: Icon(Icons.location_city),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'الحقل مطلوب',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderTextField(
                  name: 'country',
                  controller: controller.countryController,
                  decoration: const InputDecoration(
                    labelText: 'الدولة *',
                    prefixIcon: Icon(Icons.flag),
                    border: OutlineInputBorder(),
                  ),
                  validator: FormBuilderValidators.required(
                    errorText: 'الحقل مطلوب',
                  ),
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: FormBuilderTextField(
                  name: 'partner_latitude',
                  controller: controller.latController,
                  decoration: const InputDecoration(
                    labelText: 'خط العرض',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FormBuilderTextField(
                  name: 'partner_longitude',
                  controller: controller.longController,
                  decoration: const InputDecoration(
                    labelText: 'خط الطول',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
