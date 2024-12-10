import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'dart:convert';

import 'DetailsPage.dart';

class MovieScreen extends StatefulWidget {
  @override
  _MovieScreenState createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
  List movies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final response = await http.get(Uri.parse('https://api.tvmaze.com/search/shows?q=all'));
    if (response.statusCode == 200) {
      setState(() {
        movies = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color
      body: Column(
        children: [
          SizedBox(height: 30), // Add space at the top
          Expanded(
            child: isLoading
                ? _buildShimmerEffect()
                : movies.isEmpty
                ? Center(
              child: Text(
                'No Movies Available',
                style: TextStyle(color: Colors.white),
              ),
            )
                : ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index]['show'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    clipBehavior: Clip.antiAlias,
                    color: Colors.grey[900],
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Movie Image
                        movie['image'] != null
                            ? Image.network(
                          movie['image']['medium'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 200,
                        )
                            : Container(
                          color: Colors.white,
                          height: 200,
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'No Image Available',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Movie Title
                              Text(
                                movie['name'] ?? 'No Title',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              // Language
                              Row(
                                children: [
                                  Icon(Icons.language, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    movie['language'] ?? 'N/A',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Genres
                              Row(
                                children: [
                                  Icon(Icons.category, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Genres: ${movie['genres']?.join(', ') ?? 'N/A'}",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Premiered Date
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    "Premiered: ${movie['premiered'] ?? 'N/A'}",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              // Rating
                              Row(
                                children: [
                                  Icon(Icons.add_chart, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  RatingBarIndicator(
                                    rating: movie['rating']['average']?.toDouble() ?? 0.0,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "${movie['rating']['average']?.toString() ?? 'N/A'}/10",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              // Summary
                              Text(
                                movie['summary']?.replaceAll(RegExp(r'<[^>]*>'), '') ??
                                    'No Summary Available',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                        // "More Details" Button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsPage(movieName: movie['name']),
                                  ),
                                );
                              },
                              child: Text("More Details"),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  // Shimmer Effect Widget
  // Shimmer Effect Widget
  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6, // Number of shimmer placeholders
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Shimmer for Image Section
                Shimmer.fromColors(
                  baseColor: Colors.grey[800]!,
                  highlightColor: Colors.grey[500]!,
                  child: Container(
                    color: Colors.grey[800],
                    width: double.infinity,
                    height: 200,
                  ),
                ),
                SizedBox(height: 8), // Space between sections
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shimmer for Title
                      Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        child: Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Shimmer for Genres
                      Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        child: Container(
                          width: 150,
                          height: 15,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12), // Space between sections
                      // Shimmer for Summary
                      Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        child: Container(
                          width: double.infinity,
                          height: 40,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Shimmer for Button
                      Shimmer.fromColors(
                        baseColor: Colors.grey[800]!,
                        highlightColor: Colors.grey[500]!,
                        child: Container(
                          width: 120,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
