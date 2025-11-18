// widgets/custom_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomBottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onItemTapped;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  State<CustomBottomNav> createState() => _CustomBottomNavState();
}

class _CustomBottomNavState extends State<CustomBottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            // ✅ Hanya 4 item sekarang
            final icons = [
              Icons.home,
              Icons.timer,
              Icons.notifications,
              Icons.settings,
            ];
            final labels = ['Home', 'Activity', 'Remainders', 'Settings'];

            return Expanded(
              child: InkWell(
                // ✅ Ganti GestureDetector dengan InkWell untuk area sentuh lebih besar
                onTap: () {
                  HapticFeedback.lightImpact(); // Getar halus saat diklik
                  widget.onItemTapped(index);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                  ), // ✅ Area sentuh diperbesar
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors
                          .transparent, // ✅ Background transparan saat aktif
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icons[index],
                          color: widget.currentIndex == index
                              ? Colors
                                    .blue // ✅ Warna biru saat aktif
                              : Colors.grey[700], // Warna abu saat tidak aktif
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          labels[index],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: widget.currentIndex == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: widget.currentIndex == index
                                ? Colors
                                      .blue // ✅ Warna biru saat aktif
                                : Colors
                                      .grey[700], // Warna abu saat tidak aktif
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
