import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gsloution_mobile/common/config/import.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';
import 'package:gsloution_mobile/location.dart';
import 'package:gsloution_mobile/src/presentation/screens/customer/partner/partner.dart';

class GoogleMapsPartners extends StatefulWidget {
  final List<PartnerModel> partners;
  final bool isSearch;
  const GoogleMapsPartners(
      {super.key, required this.partners, required this.isSearch});

  @override
  State<GoogleMapsPartners> createState() => _GoogleMapsPartnersState();
}

class _GoogleMapsPartnersState extends State<GoogleMapsPartners> {
  List<int> selectedItemsMultiDialog = [];
  var newPartners = <PartnerModel>[].obs;
  LatLng? showLocation;
  GoogleMapController? mapController;
  LatLng? newLoc;
  List<double> latList = [];
  List<double> longList = [];
  Set<Marker> markers = {};
  LatLng _initialLocation = LatLng(PrefUtils.latitude, PrefUtils.longitude);
  bool _isLoading = true;
  LatLngBounds? bounds;

  @override
  void initState() {
    _setInitialLocation();
    showLocation = LatLng(
      widget.partners[0].partnerLatitude,
      widget.partners[0].partnerLongitude,
    );
    getMarkers();
    _setBounds();
    super.initState();
  }

  Future<void> _setInitialLocation() async {
    try {
      await MyLocation.getLatAndLong(onUpdate: () {
        setState(() {
          _initialLocation = LatLng(
            MyLocation.cl!.latitude,
            MyLocation.cl!.longitude,
          );
          _isLoading = false;
        });
      });
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<LatLng> _getCurrentLocation() async {
    // MyLocation.getPermission;
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    PrefUtils.setLatitude(position.latitude);
    PrefUtils.setLongitude(position.longitude);

    return LatLng(position.latitude, position.longitude);
  }

  void _updateMapLocation(GoogleMapController controller, LatLng location) {
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: location, zoom: 15),
      ),
    );
  }

  Set<Marker> getMarkers() {
    markers.clear(); // تصفية العلامات السابقة

    for (int index = 0; index < widget.partners.length; index++) {
      // استبعاد الإحداثيات التي تساوي 0
      if (widget.partners[index].partnerLatitude != 0 &&
          widget.partners[index].partnerLongitude != 0) {
        if (selectedItemsMultiDialog.isEmpty ||
            selectedItemsMultiDialog.contains(index)) {
          var latlng = LatLng(
            widget.partners[index].partnerLatitude,
            widget.partners[index].partnerLongitude,
          );

          markers.add(Marker(
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            markerId: MarkerId(
                '${widget.partners[index].id}: ${widget.partners[index].name}'),
            position: latlng,
            infoWindow: InfoWindow(
              onTap: () {
                Get.to(() => Partner(partner: widget.partners[index]));
              },
              title: widget.partners[index].name!,
              snippet: widget.partners[index].email!.toString(),
            ),
          ));
        }
      }
    }

    return markers;
  }

  Set<Circle> getCircles() {
    Set<Circle> circles = {};

    // إضافة الدوائر الخاصة بالـ Markers
    for (int index = 0; index < widget.partners.length; index++) {
      if (selectedItemsMultiDialog.isEmpty ||
          selectedItemsMultiDialog.contains(index)) {
        var latlng = LatLng(
          widget.partners[index].partnerLatitude,
          widget.partners[index].partnerLongitude,
        );

        circles.add(Circle(
          circleId: CircleId("circle_${widget.partners[index].id}"),
          center: latlng,
          fillColor: Colors.blue.withOpacity(0.3),
          strokeWidth: 2,
          strokeColor: Colors.blue,
          radius: 100,
        ));
      }
    }

    // إضافة الدائرة الخاصة بموقعك الشخصي باستخدام MyLocation
    circles.add(Circle(
      circleId: const CircleId("user_location"),
      center: LatLng(MyLocation.cl!.latitude, MyLocation.cl!.longitude),
      fillColor: Colors.green.withOpacity(0.4),
      strokeWidth: 2,
      strokeColor: Colors.green,
      radius: 200,
    ));

    return circles;
  }

  void _setBounds() {
    if (widget.partners.isEmpty) return;

    double minLat = widget.partners
        .map((p) => p.partnerLatitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLat = widget.partners
        .map((p) => p.partnerLatitude)
        .reduce((a, b) => a > b ? a : b);
    double minLng = widget.partners
        .map((p) => p.partnerLongitude)
        .reduce((a, b) => a < b ? a : b);
    double maxLng = widget.partners
        .map((p) => p.partnerLongitude)
        .reduce((a, b) => a > b ? a : b);

    bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _moveCameraToBounds() {
    if (bounds == null || mapController == null) return;

    mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(bounds!, 50), // 50 لإضافة مسافة حول الحدود
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSearch = false;
    final args = Get.arguments as Map<String, dynamic>?; // قد تكون null
    if (args != null) {
      isSearch = args["isSearch"] ?? false;
    }
    return Scaffold(
      body: Center(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : GoogleMap(
                zoomControlsEnabled: true,
                markers: getMarkers(),
                initialCameraPosition: CameraPosition(
                  target: _initialLocation,
                  zoom: 10,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  _updateMapLocation(controller, _initialLocation);
                  if (isSearch) _moveCameraToBounds();
                },
                circles: getCircles(),
              ),
      ),
    );
  }
}
