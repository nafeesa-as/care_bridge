import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceDetailsPage extends StatelessWidget {
  final String category;
  final List<Map<String, String>> resources;

  ResourceDetailsPage({required this.category, required this.resources});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category), backgroundColor: Colors.blue[900]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            return ResourceItem(resource: resources[index]);
          },
        ),
      ),
    );
  }
}

class ResourceItem extends StatelessWidget {
  final Map<String, String> resource;

  ResourceItem({required this.resource});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource["name"]!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              resource["description"]!,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              onPressed: () async {
                final Uri url = Uri.parse(resource["link"]!);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Could not open the link")),
                  );
                }
              },
              child: Text("Open Resource"),
            ),
          ],
        ),
      ),
    );
  }
}
