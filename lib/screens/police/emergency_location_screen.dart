
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EmergencyLocationScreen extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String citizenName;

  const EmergencyLocationScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.citizenName,
  });

  @override
  State<EmergencyLocationScreen> createState() =>
      _EmergencyLocationScreenState();
}

class _EmergencyLocationScreenState
    extends State<EmergencyLocationScreen> {
  GoogleMapController? mapController;

  bool get hasValidLocation {
    final lat = widget.latitude;
    final lng = widget.longitude;

    return lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90 &&
        lat <= 90 &&
        lng >= -180 &&
        lng <= 180;
  }

  LatLng get emergencyPosition => LatLng(
        widget.latitude!,
        widget.longitude!,
      );

  Future<void> openGoogleMapsDirections() async {
    if (!hasValidLocation) return;

    final lat = widget.latitude!;
    final lng = widget.longitude!;

    final url =
      'https://www.google.com/maps/dir/?api=1'
      '&destination=$lat,$lng';

    try {
      await Clipboard.setData(ClipboardData(text: url));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Directions link copied to clipboard.'),
        ),
      );
    } catch (e) {
      debugPrint('Error copying Google Maps directions link: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to copy directions link.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('Emergency Location'),
        backgroundColor: const Color(0xFF171717),
        foregroundColor: Colors.white,
      ),
      body: hasValidLocation
          ? Column(
              children: [
                Expanded(
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: emergencyPosition,
                      zoom: 16,
                    ),
                    markers: {
                      Marker(
                        markerId:
                            const MarkerId('emergency_location'),
                        position: emergencyPosition,
                        infoWindow: InfoWindow(
                          title: 'Emergency Location',
                          snippet: widget.citizenName,
                        ),
                      ),
                    },
                    mapType: MapType.normal,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF191919),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.citizenName.isEmpty
                            ? 'Emergency Location'
                            : widget.citizenName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SelectableText(
                        'Latitude: ${widget.latitude}\n'
                        'Longitude: ${widget.longitude}',
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: openGoogleMapsDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text('Get Directions'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_off,
                      color: Colors.redAccent,
                      size: 60,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'GPS location is unavailable for this emergency.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'The citizen may have denied location permission '
                      'or GPS coordinates may not have been saved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}