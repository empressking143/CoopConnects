import 'package:flutter/material.dart';
import 'package:coopconnects/models/menu_item_model.dart';
import 'package:coopconnects/services/menu_service.dart';
import 'package:coopconnects/widgets/nav_bar.dart';
import 'package:coopconnects/widgets/app_bar.dart';import 'menu_detail_screen.dart';

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<MenuItem> allMenuItems = []; // Full list of menu items
  List<MenuItem> filteredMenuItems = []; // Filtered list based on selection
  bool isAscending = true; // Sorting state (true for ascending, false for descending)
  final MenuService menuService = MenuService(); // Instance of the service
  String selectedCategory = 'All'; // Store the selected category (initially 'All')
  bool _isDropdownOpen = false; // Track if the dropdown is open

  @override
  void initState() {
    super.initState();
    _loadMenuItems(); // Load menu items from Firestore
  }

  // Load menu items from Firestore
  void _loadMenuItems() async {
    try {
      List<MenuItem> items = await menuService.fetchMenuItems();
      setState(() {
        allMenuItems = items;
        filteredMenuItems = List.from(allMenuItems);
      });
    } catch (e) {
      print('Error loading menu: $e');
      // You can show an error message to the user here if needed
    }
  }

  // Function to filter items based on category
  void _filterMenu(String category) {
    setState(() {
      selectedCategory = category; // Update the selected category
      if (category == 'All') {
        filteredMenuItems = List.from(allMenuItems);
      } else {
        filteredMenuItems =
            allMenuItems.where((item) => item.category == category).toList();
      }
    });
  }

  // Function to sort by price (ascending or descending)
  void _sortByPrice() {
    setState(() {
      if (isAscending) {
        filteredMenuItems.sort((a, b) => double.parse(
                a.price.replaceAll('₱', '').trim())
            .compareTo(
                double.parse(b.price.replaceAll('₱', '').trim())));
      } else {
        filteredMenuItems.sort((a, b) => double.parse(
                b.price.replaceAll('₱', '').trim())
            .compareTo(
                double.parse(a.price.replaceAll('₱', '').trim())));
      }
      isAscending = !isAscending; // Toggle the sorting order
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(),
      backgroundColor: Color(0xFFFFF8E8), // Background color
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('KIOSK #', 24, FontWeight.w600),
            SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Sort container with a dropdown
                Container(
                  width: 152.90,
                  height: 41,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Color(0x3F000000),
                        blurRadius: 4,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: Colors.white,
                            hint: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                selectedCategory == 'All'
                                    ? 'Sort'
                                    : selectedCategory,
                                style: TextStyle(
                                  color: Color(0xFF800000),
                                  fontSize: 17,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            icon: SizedBox.shrink(), // Hide default dropdown icon
                            items: [
                              'All',
                              'Rice Meals',
                              'Pork Dishes',
                              'Chicken Dishes',
                              'Beef Dishes',
                              'Beverages',
                              'Combo Meals',
                              'Others'
                            ].map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: Color(0xFF800000),
                                      fontSize: 17,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (selectedCategory) {
                              _filterMenu(selectedCategory!);
                              setState(() {
                                _isDropdownOpen = false; // Close dropdown on selection
                              });
                            },
                            onTap: () {
                              setState(() {
                                _isDropdownOpen =
                                    !_isDropdownOpen; // Toggle dropdown state
                              });
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: Icon(
                          _isDropdownOpen
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: Color(0xFF800000),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price label with sort icons
                GestureDetector(
                  onTap: _sortByPrice,
                  child: Row(
                    children: [
                      _buildLabel('Price', 17, FontWeight.w400,
                          textAlign: TextAlign.right),
                      SizedBox(width: 5),
                      Icon(
                        isAscending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: Color(0xFF800000),
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),

            // Displaying filtered menu items
            Expanded(
              child: ListView.builder(
                itemCount: filteredMenuItems.length,
                itemBuilder: (context, index) {
                  final item = filteredMenuItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuDetailsScreen(
                            docId: item.id, // Pass Firestore docId
                          ),
                        ),
                      );
                    },
                    child: _buildMenuItem(item.name, item.price),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavBar(),
    );
  }

  // Helper function to build labels
  Widget _buildLabel(String text, double fontSize, FontWeight fontWeight,
      {TextAlign textAlign = TextAlign.left}) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        color: Color(0xFF800000),
        fontSize: fontSize,
        fontFamily: 'Poppins',
        fontWeight: fontWeight,
      ),
    );
  }

  // Helper function to build menu items
  Widget _buildMenuItem(String itemName, String price) {
  // Ensure the price string starts with the peso symbol (₱)
  String formattedPrice = price.startsWith('₱') ? price : '₱ $price';

  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        shadows: [
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              itemName,
              style: TextStyle(
                color: Color(0xFF800000),
                fontSize: 17,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Text(
              formattedPrice, // Use the formatted price with the peso symbol at the front
              style: TextStyle(
                color: Color(0xFF800000),
                fontSize: 17,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

}
