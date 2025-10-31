import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gsloution_mobile/common/config/prefs/pref_utils.dart';

class MyLocation {
  static LocationPermission? permission;
  static bool services = false;
  static Position? cl;
  static CameraPosition? kGooglePlex;
  static Set<Circle> circles = {};

  static Future<void> getLatAndLong({Function? onUpdate}) async {
    try {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          "Location permissions are denied or permanently denied.",
        );
      }

      cl = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          distanceFilter: 100,
        ),
      );

      double lat = cl!.latitude;
      double long = cl!.longitude;

      circles = {
        Circle(
          circleId: const CircleId("1"),
          fillColor: Colors.blue.withOpacity(0.3),
          strokeWidth: 2,
          strokeColor: Colors.blue,
          center: LatLng(lat, long),
          radius: 400,
        ),
      };

      kGooglePlex = CameraPosition(target: LatLng(lat, long), zoom: 14.4746);

      // تحديث البيانات في التخزين
      await PrefUtils.setLatitude(lat);
      await PrefUtils.setLongitude(long);

      // استدعاء تحديث الواجهة إن لزم
      if (onUpdate != null) {
        onUpdate();
      }
    } catch (e) {
      print("Error getting location: $e");
    }
  }
}
