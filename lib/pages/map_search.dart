import 'package:flutter/material.dart';
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class MapSearch extends StatefulWidget {
  
   final Function(Map<String, String>) onAddressSelected; // Update the callback function type
  const MapSearch({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  State<MapSearch> createState() => _MapSearchState();
}

class _MapSearchState extends State<MapSearch> {
  String address = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Map"),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 50,
            child: Center(child: Text(address)),
          ),
          Expanded(
            child: OpenStreetMapSearchAndPick(
              buttonTextStyle: const TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.normal,
              ),
              buttonColor: Colors.blue,
              buttonText: 'Set Current Location',
              onPicked: (pickedData) {
                setState(() {
                  address = pickedData.addressName ?? 'No address found';
                });
                // print the separate address here
                print('Latitude: ${pickedData.latLong.latitude}');
                print('Longitude: ${pickedData.latLong.longitude}');
                print('Address Name: ${pickedData.addressName}');

                // Separate the address components
                final components = separateAddress(pickedData.addressName ?? '');
                
                print('Street Name: ${components['streetName']}');
                print('Town/City: ${components['town']}');
                print('Region: ${components['region']}'); // Changed 'Postcode' to 'Region'
                print('State: ${components['state']}');

                widget.onAddressSelected(components); // Pass selected address to callback function
                Navigator.pop(context, components); // Navigate back to AddEventPage with the selected address
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Dispose any resources here
    super.dispose();
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MapSearch(
      onAddressSelected: (Map<String, String> components) { // Updated callback function signature
        // Print the separated address components
        print('Street Name: ${components['streetName']}');
        print('Town/City: ${components['town']}');
        print('Region: ${components['region']}');
        print('State: ${components['state']}');
        // Handle the selected address here, if needed
      },
    ),
  ));
}




Map<String, String> separateAddress(String address) {
  // Split the address string by commas
  final parts = address.split(', ');

  // If the address does not contain all parts, return empty strings for missing components
  if (parts.length < 6) {
    return {
      'streetName': '',
      'town': '',
      'region': '',
      'state': '',
    };
  }

  // Extract the components from the split parts, starting from the end
  final state = parts[parts.length - 3];
  final region = parts[parts.length - 4];
  final town = parts[parts.length - 5];

  // Combine the remaining parts to form the street name
  final streetName = parts.sublist(0, parts.length - 5).join(', ');

  return {
    'streetName': streetName,
    'town': town,
    'region': region,
    'state': state,
  };
}





