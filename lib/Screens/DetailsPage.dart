import 'package:flutter/material.dart';
import 'package:quad_db_movieapp_assignment/Constant/API_Constant.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatefulWidget {
  final String movieName;

  DetailsPage({required this.movieName});

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  Map? movie;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails(widget.movieName);
  }

  Future<void> fetchMovieDetails(String movieName) async {
    try {
      final response = await http.get(Uri.parse(BASE_URL+'search/shows?q=$movieName'));
      if (response.statusCode == 200) {
        List<dynamic> results = json.decode(response.body);
        if (results.isNotEmpty) {
          setState(() {
            movie = results[0]['show'];
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to fetch movie details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.movieName,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      backgroundColor: Colors.black,
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(color: Colors.redAccent),
      )
          : movie == null
          ? Center(
        child: Text(
          "No details found for '${widget.movieName}'",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Image with Shimmer Effect
            movie!['image'] != null
                ? Stack(
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[500]!,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    color: Colors.grey[900],
                  ),
                ),
                Image.network(
                  movie!['image']['original'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
              ],
            )
                : Shimmer.fromColors(
              baseColor: Colors.grey[800]!,
              highlightColor: Colors.grey[500]!,
              child: Container(
                width: double.infinity,
                height: 300,
                color: Colors.grey[900],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Movie Title
                  Text(
                    movie!['name'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  // Rating Bar (Read-Only)
                  movie!['rating']['average'] != null
                      ? Row(
                    children: [
                      RatingBarIndicator(
                        rating: (movie!['rating']['average'] ?? 0.0) / 2,
                        itemCount: 5,
                        itemSize: 24,
                        unratedColor: Colors.grey,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        "${movie!['rating']['average'] ?? 'N/A'}/10",
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                      : SizedBox.shrink(),
                  SizedBox(height: 12),
                  // Movie Details (Language, Genres, Premiered)
                  Row(
                    children: [
                      Icon(Icons.language, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Language: ${movie!['language'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.category, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Genres: ${movie!['genres']?.join(', ') ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Premiered: ${movie!['premiered'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.update, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "Status: ${movie!['status'] ?? 'N/A'}",
                        style: TextStyle(color: Colors.grey[400], fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Summary Section
                  Text(
                    "Summary:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    movie!['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                        'No Summary Available',
                    style: TextStyle(color: Colors.grey[300], fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  // Official Site Button
                  movie!['officialSite'] != null
                      ? ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.redAccent,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      launch(movie!['officialSite']!);
                    },
                    icon: Icon(Icons.web),
                    label: Text("Visit Official Site"),
                  )
                      : SizedBox.shrink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
