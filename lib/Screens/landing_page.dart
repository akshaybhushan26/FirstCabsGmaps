import 'package:flutter/material.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  // Controller to manage the search bar input
  TextEditingController searchController = TextEditingController();

  // Example: List of destinations (this could come from an API later)
  final List<String> destinations = [
    "Indira Gandhi International Airport",
    "Rohini Sector 18,19",
    "HUDA City Centre Metro Station"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        title: Row(
          children: [
            Image.asset(
              'lib/assets/logo.png',
              height: 36,
              width: 168,
            ),
          ],
        ),
        centerTitle: true, 
      ),
      body: Column(
        children: [  
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) {
                        print("Search Query: $value");
                      },
                      decoration: InputDecoration(
                        hintText: 'Type Your Destination',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 20,),
          Container(
            height: 180,
            padding: EdgeInsets.symmetric(horizontal: 8.0), 
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Ad 1
                Container(
                  width: 300,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage('lib/assets/ad1.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ad 2
                Container(
                  width: 300,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage('lib/assets/ad2.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Ad 3
                Container(
                  width: 300,
                  margin: EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                      image: AssetImage('lib/assets/ad3.png'), 
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 5,),
              Text("Suggestions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),),
            ],
          ),
          SizedBox(height: 4,),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Image.asset("lib/assets/cab.png"),
          ),

          Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Destination Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search Destination',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    onChanged: (value) {
                      // Placeholder: You can filter/search results here
                      print("Search query: $value");
                    },
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Add functionality for "Later" button
                    print("Later button pressed");
                  },
                  icon: const Icon(Icons.watch_later, size: 18),
                  label: const Text("Later"),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Destination List
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: destinations.map((destination) => Column(
                      children: [
                        DestinationItem(
                          title: destination,
                          icon: Icons.location_pin,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ))
                .toList(),
          ),
        ),
      ],
      ),
        ],
      ),
      
        
    );
  }
}



class DestinationItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const DestinationItem({
    Key? key,
    required this.title,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.grey,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
      ],
    );
  }
}