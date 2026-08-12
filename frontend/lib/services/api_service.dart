import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<Booking>> fetchBookings() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/bookings')).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (e) {
      print("API fetch failed, loading default fallback bookings: $e");
    }

    // Default fallback bookings matching the 4 types with admin configurations
    return [
      Booking(
        id: "BK01",
        title: "Annual General Assembly",
        type: "Meeting Schedule",
        date: "2026-08-03",
        colorCode: "#1E3A8A", // Admin Dark Blue
        description: "Mandatory general assembly meeting for all active chapter members.",
        time: "10:00 AM - 01:00 PM",
      ),
      Booking(
        id: "BK02",
        title: "Suresh's 40th Birthday",
        type: "Birthday",
        date: "2026-08-12",
        colorCode: "#F59E0B", // Admin Yellow Gold
        description: "Join us in celebrating Suresh's birthday at the chapter hall.",
        time: "06:30 PM onwards",
      ),
      Booking(
        id: "BK03",
        title: "Muthu & Deepa Anniversary",
        type: "Wedding Day",
        date: "2026-08-18",
        colorCode: "#EC4899", // Admin Pink
        description: "Wishing a happy anniversary to Muthu and Deepa!",
        time: "All Day",
      ),
      Booking(
        id: "BK04",
        title: "Zion Office Open House",
        type: "Company Open Day",
        date: "2026-08-25",
        colorCode: "#10B981", // Admin Green
        description: "ZION Construction is opening its doors to partners and clients.",
        time: "09:00 AM - 05:00 PM",
      ),
      Booking(
        id: "BK05",
        title: "Evening Chapter Networking",
        type: "Meeting Schedule",
        date: "2026-08-25",
        colorCode: "#1E3A8A", // Admin Dark Blue
        description: "Standard networking session to pass referrals and testimonials.",
        time: "06:30 PM - 08:30 PM",
      ),
    ];
  }

  static Future<List<NewsEvent>> fetchNewsEvents() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/events')).timeout(
        const Duration(seconds: 3),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => NewsEvent.fromJson(json)).toList();
      }
    } catch (e) {
      print("API fetch failed for news events, loading default fallback: $e");
    }

    return [
      NewsEvent(
        id: "NE01",
        title: "RMBF National Business Conclave 2026",
        date: "August 28, 2026",
        imageUrl: "https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800&fit=crop&q=80",
        description: "The annual business conclave bringing together elite entrepreneurs across India. Keynote speakers, networking sessions, and referral exchange forums.",
        location: "Grand Hyatt, Mumbai",
      ),
      NewsEvent(
        id: "NE02",
        title: "Unity Chapter Charter Day Celebration",
        date: "August 20, 2026",
        imageUrl: "https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&fit=crop&q=80",
        description: "Celebrating 5 years of networking excellence. Awards ceremony for top referrers, followed by dinner.",
        location: "Royal Palms Palace, Gobi",
      ),
      NewsEvent(
        id: "NE03",
        title: "Workshop on Digital Business Scaling",
        date: "September 02, 2026",
        imageUrl: "https://images.unsplash.com/photo-1515187029135-18ee286d815b?w=800&fit=crop&q=80",
        description: "An intensive training session on leveraging online platforms, digital surveying, and automation tools to scale operations.",
        location: "Unity Seminar Room",
      ),
    ];
  }
}
