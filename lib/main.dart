import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Cost Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TripCostPage(),
    );
  }
}

class TripCostPage extends StatefulWidget {
  @override
  _TripCostPageState createState() => _TripCostPageState();
}

class _TripCostPageState extends State<TripCostPage> {
  TextEditingController pickupController = TextEditingController();
  TextEditingController destinationController = TextEditingController();
  double? cost;
  bool isLoading = false;

  Future<void> calculateCost() async {
    setState(() {
      isLoading = true;
    });

    String pickup = pickupController.text;
    String destination = destinationController.text;

    if (pickup.isEmpty || destination.isEmpty) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill in both fields")));
      return;
    }

    var url = Uri.parse('http://your-backend-api-url.com/calculate-cost');

    try {
      var response = await http.post(url, body: {
        'pickup': pickup,
        'destination': destination,
      });

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          cost = data['cost'];
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to get the cost")));
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trip Cost Calculator'),
        backgroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 300,
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Text('Map should be here (add Map if required)'),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pickup Location",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextField(
                      controller: pickupController,
                      decoration: InputDecoration(
                        hintText: 'Enter Pickup Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    Text(
                      "Destination Location",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    TextField(
                      controller: destinationController,
                      decoration: InputDecoration(
                        hintText: 'Enter Destination Location',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ChoiceButton(
                            text: 'Economy',
                            price: '8\$',
                            icon: Icons.directions_car),
                        ChoiceButton(
                            text: 'Comfort',
                            price: '12\$',
                            icon: Icons.directions_car_outlined),
                        ChoiceButton(
                            text: 'Business',
                            price: '18\$',
                            icon: Icons.directions_car_filled),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: calculateCost,
                      child: isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Calculate Cost'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 15),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                    SizedBox(height: 10),
                    if (cost != null) ...[
                      Text(
                        'Estimated Cost: \$${cost?.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChoiceButton extends StatelessWidget {
  final String text;
  final String price;
  final IconData icon;

  const ChoiceButton(
      {required this.text, required this.price, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        children: [
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.black), // Car icon
                SizedBox(width: 8),
                Text(
                  text,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          SizedBox(height: 5),
          Text(
            price,
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
