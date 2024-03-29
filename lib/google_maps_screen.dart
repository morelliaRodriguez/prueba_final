import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_maps_app/utils/constans.dart';
import 'package:google_maps_app/utils/utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsScreenState();
}

class _GoogleMapsScreenState extends State<GoogleMapsScreen> {
  Completer<GoogleMapController> googleMapController = Completer();
  List<LatLng> posiciones = [
    const LatLng(-12.1973, -76.9702),
    const LatLng(-12.1977, -76.9678),
    const LatLng(-12.1980, -76.9658),
    const LatLng(-12.1994, -76.9659),
  ];
  Set<Polyline> polylines = {};
  Set<Marker> markers = {};
  late BitmapDescriptor icon;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    await setIcon();
    setMarkers();
    setPolylines();
  }

  Future<void> setIcon() async {
    Uint8List iconBytes = await Utils.getBytesFromAsset(marker, 120);
    icon = BitmapDescriptor.fromBytes(iconBytes);
  }

  void setMarkers() {
    markers = posiciones.map((posicion) {
      return Marker(
        markerId: MarkerId(posicion.toString()),
        position: posicion,
        icon: icon,
        infoWindow: InfoWindow(
          title: DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
        ),
      );
    }).toSet();
  }

  void setPolylines() {
    polylines = {
      Polyline(
        polylineId: const PolylineId('id'),
        points: posiciones,
        width: 4,
        color: Colors.purple,
      )
    };
    moverCamara(posiciones.last);
  }

  void addMarker(LatLng nuevaPosicion) {
    LatLng ultimaPosicion = markers.last.position;
    markers.add(
      Marker(
        markerId: MarkerId(nuevaPosicion.toString()),
        position: nuevaPosicion,
        icon: icon,
        infoWindow: InfoWindow(
          title: DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now()),
        ),
      ),
    );
    polylines.add(
      Polyline(
        polylineId: PolylineId(nuevaPosicion.toString()),
        points: [ultimaPosicion, nuevaPosicion],
        width: 4,
        color: Colors.green,
        patterns: [
          PatternItem.dot,
          PatternItem.gap(10),
        ],
      ),
    );
    moverCamara(nuevaPosicion);
  }

  Future<void> moverCamara(LatLng posicion) async {
    final controller = await googleMapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(posicion));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Google Maps'),
      ),
      body: SafeArea(
        child: GoogleMap(
          markers: markers,
          polylines: polylines,
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: posiciones.isNotEmpty ? posiciones.first : LatLng(0, 0),
            zoom: 16,
          ),
          onMapCreated: (GoogleMapController controller) {
            googleMapController.complete(controller);
          },
          onTap: (LatLng posicion) {
            addMarker(posicion);
          },
        ),
      ),
    );
  }
}
