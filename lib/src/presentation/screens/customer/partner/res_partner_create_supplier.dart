import 'dart:collection';
import 'dart:io';

import 'package:form_builder_image_picker/form_builder_image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:image_picker/image_picker.dart';

class CreatePartnerSupplier extends StatefulWidget {
  const CreatePartnerSupplier({Key? key}) : super(key: key);

  @override
  State<CreatePartnerSupplier> createState() => _CreatePartnerSupplierState();
}

class _CreatePartnerSupplierState extends State<CreatePartnerSupplier> {
  var partners = <PartnerModel>[].obs;

  @override
  void initState() {
    super.initState();
    getLatAndLong();
  }

  var myMarkers = HashSet<Marker>();
  GoogleMapController? googleMapController;
  CameraPosition? _kGooglePlex;
  late Position position;
  var lat;
  var long;

  var placemarks;
  var place;
  String location = 'Null, Press Button';
  var Address;
  var _city;
  var _country;

  final ImagePicker _picker = ImagePicker();
  XFile? image;

  takePhoto(Image i) async {
    image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Image.file(File(image!.path));
    }
  }

  getLatAndLong() async {
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((value) => value);
    lat = position.latitude;
    long = position.longitude;

    if (mounted) {
      setState(() {
        _kGooglePlex = CameraPosition(target: LatLng(lat, long), zoom: 14.4746);
      });
    }
  }

  Future<void> getAddressFromLatLong() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );
    Placemark place = placemarks[0];
    _country = '${place.country}';
    _city = '${place.locality}';
    Address =
        '${place.name} ${place.street}, ${place.subThoroughfare} ${place.thoroughfare}, ${place.subLocality} ${place.locality}';

    if (mounted) {
      setState(() {});
    }
  }

  final _formKey = GlobalKey<FormBuilderState>();
  bool isVisible = true;
  bool autoValidate = true;
  bool readOnly = false;
  bool showSegmentedControl = true;
  bool _noteHasError = false;
  void _onChanged(dynamic val) => debugPrint(val.toString());

  final _controllerAddress = TextEditingController();
  final _controllerLat = TextEditingController();
  final _controllerLong = TextEditingController();
  final _controllerCity = TextEditingController();
  final _controllerCountry = TextEditingController();

  @override
  void dispose() {
    _controllerAddress.dispose();
    _controllerLat.dispose();
    _controllerLong.dispose();
    _controllerCity.dispose();
    _controllerCountry.dispose();
    googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MainContainer(
      actions: [
        IconButton(
          icon: Icon(
            isVisible ? Icons.store : Icons.business,
            color: const Color(0xFF3498DB),
          ),
          onPressed: () {
            setState(() {
              isVisible = !isVisible;
            });
          },
        ),
      ],
      appBarTitle: isVisible ? "Create Supplier" : 'Create Contact',
      drawer: CustomDrawer(),
      child: Container(
        color: const Color(0xFFF5F7FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Visibility(
                visible: isVisible,
                child: Container(
                  height: 280,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        _kGooglePlex == null
                            ? const Center(child: CircularProgressIndicator())
                            : GoogleMap(
                                myLocationEnabled: true,
                                myLocationButtonEnabled: true,
                                initialCameraPosition: _kGooglePlex!,
                                onMapCreated:
                                    (GoogleMapController googleMapController) {
                                      setState(() {
                                        myMarkers.add(
                                          Marker(
                                            onTap: () async {},
                                            markerId: const MarkerId(
                                              'marker 1',
                                            ),
                                            position: LatLng(lat, long),
                                            infoWindow: InfoWindow(
                                              title: 'TAP TO GET ADDRESS',
                                              onTap: () async {
                                                await getLatAndLong();

                                                location =
                                                    'Lat: ${position.latitude} , Long: ${position.longitude}';

                                                await getAddressFromLatLong();
                                                setState(() {
                                                  print(Address);
                                                  _controllerCountry
                                                      .value = TextEditingValue(
                                                    text: _country.toString(),
                                                  );
                                                  _controllerCity.value =
                                                      TextEditingValue(
                                                        text: _city.toString(),
                                                      );
                                                  _controllerAddress
                                                      .value = TextEditingValue(
                                                    text: Address.toString(),
                                                  );
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      });
                                    },
                                markers: myMarkers,
                              ),
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF3498DB),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                              ),
                              label: Text(
                                'Search Address',
                                style: GoogleFonts.raleway(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              icon: const Icon(Icons.search, size: 20),
                              onPressed: () async {
                                await getLatAndLong();
                                await getAddressFromLatLong();
                                setState(() {
                                  location =
                                      'Lat: ${position.latitude} , Long: ${position.longitude}';

                                  _controllerLat.value = TextEditingValue(
                                    text: position.latitude.toString(),
                                    selection: TextSelection.fromPosition(
                                      TextPosition(
                                        offset: position.latitude
                                            .toString()
                                            .length,
                                      ),
                                    ),
                                  );
                                  _controllerLong.value = TextEditingValue(
                                    text: position.longitude.toString(),
                                    selection: TextSelection.fromPosition(
                                      TextPosition(
                                        offset: position.longitude
                                            .toString()
                                            .length,
                                      ),
                                    ),
                                  );

                                  _controllerCountry.value = TextEditingValue(
                                    text: _country.toString(),
                                  );

                                  _controllerCity.value = TextEditingValue(
                                    text: _city.toString(),
                                  );

                                  _controllerAddress.value = TextEditingValue(
                                    text: Address.toString(),
                                  );
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: FormBuilder(
                  key: _formKey,
                  onChanged: () {
                    _formKey.currentState!.save();
                    debugPrint(_formKey.currentState!.value.toString());
                  },
                  autovalidateMode: AutovalidateMode.disabled,
                  skipDisabled: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isVisible
                            ? 'Supplier Information'
                            : 'Contact Information',
                        style: GoogleFonts.raleway(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2C3E50),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: isVisible,
                        child: FormBuilderTextField(
                          name: 'street',
                          controller: _controllerAddress,
                          style: GoogleFonts.nunito(fontSize: 15),
                          decoration: InputDecoration(
                            suffixIcon: const Icon(
                              Icons.location_on,
                              color: Color(0xFF3498DB),
                            ),
                            hintText: 'Enter address...',
                            labelText: 'Address',
                            labelStyle: GoogleFonts.raleway(
                              color: const Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3498DB),
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              _noteHasError =
                                  !(_formKey.currentState?.fields['street']
                                          ?.validate() ??
                                      false);
                            });
                          },
                        ),
                      ),
                      Visibility(
                        visible: !isVisible,
                        child: FormBuilderDropdown(
                          decoration: InputDecoration(
                            hintText: 'Select parent supplier',
                            labelText: 'Parent Supplier',
                            labelStyle: GoogleFonts.raleway(
                              color: const Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3498DB),
                                width: 2,
                              ),
                            ),
                          ),
                          name: "parent_id",
                          onChanged: _onChanged,
                          items: partners
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text(
                                    v.displayName ?? v.name ?? 'Unknown',
                                    style: GoogleFonts.nunito(),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FormBuilderTextField(
                        autovalidateMode: AutovalidateMode.always,
                        name: 'name',
                        style: GoogleFonts.nunito(fontSize: 15),
                        decoration: InputDecoration(
                          hintText: isVisible
                              ? 'Enter supplier name'
                              : 'Enter contact name',
                          labelText: isVisible
                              ? 'Supplier Name'
                              : 'Contact Name',
                          labelStyle: GoogleFonts.raleway(
                            color: const Color(0xFF2C3E50),
                            fontWeight: FontWeight.w500,
                          ),
                          suffixIcon: Icon(
                            _noteHasError ? Icons.error : Icons.check_circle,
                            color: _noteHasError
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFF27AE60),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF3498DB),
                              width: 2,
                            ),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: !isVisible,
                        child: FormBuilderTextField(
                          autovalidateMode: AutovalidateMode.always,
                          name: 'function',
                          style: GoogleFonts.nunito(fontSize: 15),
                          decoration: InputDecoration(
                            hintText: 'Enter contact function',
                            labelText: 'Contact Function',
                            labelStyle: GoogleFonts.raleway(
                              color: const Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                            suffixIcon: Icon(
                              _noteHasError ? Icons.error : Icons.check_circle,
                              color: _noteHasError
                                  ? const Color(0xFFE74C3C)
                                  : const Color(0xFF27AE60),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3498DB),
                                width: 2,
                              ),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      if (!isVisible) const SizedBox(height: 20),
                      Visibility(
                        visible: isVisible,
                        child: FormBuilderRadioGroup(
                          name: 'is_company',
                          initialValue: 'false',
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.all(12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFF3498DB),
                                width: 2,
                              ),
                            ),
                            labelText: 'Is Company?',
                            labelStyle: GoogleFonts.raleway(
                              color: const Color(0xFF2C3E50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onChanged: _onChanged,
                          options: ["True", "False"]
                              .map(
                                (v) => FormBuilderFieldOption(
                                  value: v.toLowerCase(),
                                  child: Text(v, style: GoogleFonts.nunito()),
                                ),
                              )
                              .toList(growable: true),
                        ),
                      ),
                      if (isVisible) const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: Column(
                              children: [
                                FormBuilderTextField(
                                  autovalidateMode: AutovalidateMode.always,
                                  name: 'phone',
                                  style: GoogleFonts.nunito(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Enter phone number',
                                    labelText: 'Phone',
                                    labelStyle: GoogleFonts.raleway(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    suffixIcon: Icon(
                                      _noteHasError
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color: _noteHasError
                                          ? const Color(0xFFE74C3C)
                                          : const Color(0xFF27AE60),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF3498DB),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _noteHasError =
                                          !(_formKey
                                                  .currentState
                                                  ?.fields['phone']
                                                  ?.validate() ??
                                              false);
                                    });
                                  },
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                ),
                                const SizedBox(height: 20),
                                FormBuilderTextField(
                                  keyboardType: TextInputType.emailAddress,
                                  autovalidateMode: AutovalidateMode.always,
                                  name: 'email',
                                  style: GoogleFonts.nunito(fontSize: 15),
                                  decoration: InputDecoration(
                                    hintText: 'Enter email address',
                                    labelText: 'Email',
                                    labelStyle: GoogleFonts.raleway(
                                      color: const Color(0xFF2C3E50),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    suffixIcon: Icon(
                                      _noteHasError
                                          ? Icons.error
                                          : Icons.check_circle,
                                      color: _noteHasError
                                          ? const Color(0xFFE74C3C)
                                          : const Color(0xFF27AE60),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF3498DB),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    setState(() {
                                      _noteHasError =
                                          !(_formKey
                                                  .currentState
                                                  ?.fields['email']
                                                  ?.validate() ??
                                              false);
                                    });
                                  },
                                  textInputAction: TextInputAction.next,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: FormBuilderImagePicker(
                              onSaved: (val) {
                                val = _formKey
                                    .currentState
                                    ?.fields['image_1920']!
                                    .value;
                              },
                              onChanged: (val) {
                                setState(() {
                                  _noteHasError =
                                      !(_formKey
                                              .currentState
                                              ?.fields['image_1920']
                                              ?.validate() ??
                                          false);
                                });
                              },
                              name: 'image_1920',
                              onImage: takePhoto,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.fromLTRB(
                                  16,
                                  10,
                                  10,
                                  10,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF3498DB),
                                    width: 2,
                                  ),
                                ),
                                labelText: 'Photo',
                                labelStyle: GoogleFonts.raleway(
                                  color: const Color(0xFF2C3E50),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              fit: BoxFit.fitWidth,
                              maxImages: 1,
                              preferredCameraDevice: CameraDevice.rear,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Visibility(
                        visible: isVisible,
                        child: Row(
                          children: [
                            Flexible(
                              child: FormBuilderTextField(
                                autovalidateMode: AutovalidateMode.always,
                                name: 'city',
                                controller: _controllerCity,
                                style: GoogleFonts.nunito(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Enter city',
                                  labelText: 'City',
                                  labelStyle: GoogleFonts.raleway(
                                    color: const Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  suffixIcon: Icon(
                                    _noteHasError
                                        ? Icons.error
                                        : Icons.check_circle,
                                    color: _noteHasError
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF27AE60),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3498DB),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _noteHasError =
                                        !(_formKey.currentState?.fields['city']
                                                ?.validate() ??
                                            false);
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FormBuilderTextField(
                                autovalidateMode: AutovalidateMode.always,
                                name: 'country_id',
                                controller: _controllerCountry,
                                style: GoogleFonts.nunito(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Enter country',
                                  labelText: 'Country',
                                  labelStyle: GoogleFonts.raleway(
                                    color: const Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  suffixIcon: Icon(
                                    _noteHasError
                                        ? Icons.error
                                        : Icons.check_circle,
                                    color: _noteHasError
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF27AE60),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3498DB),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _noteHasError =
                                        !(_formKey
                                                .currentState
                                                ?.fields['country_id']
                                                ?.validate() ??
                                            false);
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isVisible) const SizedBox(height: 20),
                      Visibility(
                        visible: isVisible,
                        child: Row(
                          children: <Widget>[
                            Flexible(
                              child: FormBuilderTextField(
                                enabled: true,
                                autovalidateMode: AutovalidateMode.always,
                                name: 'partner_latitude',
                                controller: _controllerLat,
                                style: GoogleFonts.nunito(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Latitude',
                                  labelText: 'Latitude',
                                  labelStyle: GoogleFonts.raleway(
                                    color: const Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  suffixIcon: Icon(
                                    _noteHasError
                                        ? Icons.error
                                        : Icons.check_circle,
                                    color: _noteHasError
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF27AE60),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3498DB),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _noteHasError =
                                        !(_formKey
                                                .currentState
                                                ?.fields['partner_latitude']
                                                ?.validate() ??
                                            false);
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: FormBuilderTextField(
                                enabled: true,
                                autovalidateMode: AutovalidateMode.always,
                                name: 'partner_longitude',
                                controller: _controllerLong,
                                style: GoogleFonts.nunito(fontSize: 15),
                                decoration: InputDecoration(
                                  hintText: 'Longitude',
                                  labelText: 'Longitude',
                                  labelStyle: GoogleFonts.raleway(
                                    color: const Color(0xFF2C3E50),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  suffixIcon: Icon(
                                    _noteHasError
                                        ? Icons.error
                                        : Icons.check_circle,
                                    color: _noteHasError
                                        ? const Color(0xFFE74C3C)
                                        : const Color(0xFF27AE60),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF3498DB),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  setState(() {
                                    _noteHasError =
                                        !(_formKey
                                                .currentState
                                                ?.fields['partner_longitude']
                                                ?.validate() ??
                                            false);
                                  });
                                },
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Flexible(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3498DB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          debugPrint(_formKey.currentState?.value.toString());
                          Map<String, dynamic>? secondMaps =
                              _formKey.currentState?.value;
                          Map<String, dynamic> newMap = Map.from(secondMaps!);
                          if (newMap['image_1920'] != null) {
                            var images = newMap['image_1920'] as List<dynamic>;
                            if (images.isNotEmpty) {
                              String imageString = base64Encode(
                                File(images[0].path).readAsBytesSync(),
                              );
                              newMap['image_1920'] = imageString;
                            }
                          }

                          newMap['supplier_rank'] = isVisible ? 1 : 0;
                          debugPrint('validation OK');
                        } else {
                          debugPrint(_formKey.currentState?.value.toString());
                          debugPrint('validation failed');
                        }
                      },
                      child: Text(
                        'Submit',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF3498DB),
                        side: const BorderSide(
                          color: Color(0xFF3498DB),
                          width: 2,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        _formKey.currentState?.reset();
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
