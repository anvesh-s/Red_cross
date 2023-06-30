import 'package:flutter/material.dart';

//import 'package:carousel_slider/carousel_slider.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 219, 30, 30),
        title: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'lib/images/Red-cross-logo-B-600x600.jpg', 
                width: 60,
                height: 60,
              ),
            ),
            const Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Indian Red Cross Society',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        // Your homepage content here
      ),
    );
  }
}


