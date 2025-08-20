import 'dart:async';

import 'package:aplikasi_absensi/api/api_service.dart';
import 'package:aplikasi_absensi/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({super.key});
  static const String id = "/check_in_page";

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final AuthService _authService = AuthService();
  late GoogleMapController _mapController;
  bool _isLoading = false;
  String _statusMessage = 'Sedang mengambil lokasi...';
  Color _messageColor = Colors.black;
  Position? _currentPosition;
  String? _currentAddress;

  static const LatLng _ppkdLocation = LatLng(-6.2109, 106.8129);

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showMessage('Layanan lokasi nonaktif.', color: Colors.red);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          _showMessage('Izin lokasi ditolak.', color: Colors.red);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      setState(() => _currentPosition = position);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          setState(() {
            _currentAddress =
                '${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
          });
        }
      } catch (e) {
        setState(() {
          _currentAddress = 'Gagal mendapatkan alamat.';
        });
      }
    } catch (e) {
      _showMessage('Gagal mendapatkan lokasi: $e', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkIn() async {
    if (_currentPosition == null) return;
    setState(() => _isLoading = true);

    try {
      String address = _currentAddress ?? 'Alamat tidak diketahui';

      final now = DateTime.now();
      final response = await _authService.checkInAttendance(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        address: address,
        attendanceDate: DateFormat('yyyy-MM-dd').format(now),
        checkIn: DateFormat('HH:mm').format(now),
      );

      if (response.data != null) {
        _showMessage(
          response.message ?? 'Berhasil absen masuk.',
          color: Colors.green,
        );
        if (mounted) Navigator.pop(context, true);
      } else {
        _showMessage(
          response.message ?? 'Gagal absen masuk.',
          color: Colors.red,
        );
      }
    } catch (e) {
      _showMessage('Error saat absen: $e', color: Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {Color color = Colors.black}) {
    setState(() {
      _statusMessage = message;
      _messageColor = color;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          return Center(
            child: Container(
              width: isWideScreen ? 400 : double.infinity,
              decoration: isWideScreen
                  ? BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: Scaffold(
                backgroundColor: AppColor.neutral,
                appBar: AppBar(
                  title: const Text(
                    'Kehadiran',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  backgroundColor: AppColor.myblue,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  centerTitle: true,
                  flexibleSpace: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.myblue, AppColor.myblue1],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                body: _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          Expanded(
                            child: GoogleMap(
                              onMapCreated: (controller) =>
                                  _mapController = controller,
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  _currentPosition!.latitude,
                                  _currentPosition!.longitude,
                                ),
                                zoom: 17,
                              ),
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              markers: {
                                Marker(
                                  markerId: const MarkerId('current'),
                                  position: LatLng(
                                    _currentPosition!.latitude,
                                    _currentPosition!.longitude,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: _currentAddress ?? 'Lokasi Anda',
                                  ),
                                ),
                                Marker(
                                  markerId: const MarkerId('ppkd'),
                                  position: _ppkdLocation,
                                  infoWindow: const InfoWindow(
                                    title: 'PPKD Jakarta Pusat',
                                  ),
                                ),
                              },
                              circles: {
                                Circle(
                                  circleId: const CircleId("ppkd_radius"),
                                  center: _ppkdLocation,
                                  radius: 100,
                                  fillColor: Colors.blue.withOpacity(0.2),
                                  strokeColor: Colors.blueAccent,
                                  strokeWidth: 2,
                                ),
                              },
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, -4),
                                ),
                              ],
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_currentAddress != null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 12.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: AppColor.myblue,
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Text(
                                                "Lokasi Anda Saat Ini:",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                _currentAddress!,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: _isLoading ? null : _checkIn,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.myblue,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 8,
                                  ),
                                  child: _isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: const [
                                            Icon(
                                              Icons.login,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              "Absen Masuk",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
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
          );
        },
      ),
    );
  }
}
