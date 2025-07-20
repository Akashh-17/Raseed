import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ReceiptForm extends StatefulWidget {
  final void Function(Map<String, dynamic>) onSubmit;
  const ReceiptForm({super.key, required this.onSubmit});

  @override
  State<ReceiptForm> createState() => _ReceiptFormState();
}

class _ReceiptFormState extends State<ReceiptForm> {
  Future<void> scanReceiptAndFillFields(File imageFile) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    final baseUrl = dotenv.env['GEMINI_API_URL'];
    if (apiKey == null || baseUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemini API key or URL not found in .env file.')),
      );
      return;
    }
    final url = '$baseUrl?key=$apiKey';
    final imageBytes = await imageFile.readAsBytes();
    final imageBase64 = base64Encode(imageBytes);
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'inline_data': {'mime_type': 'image/jpeg', 'data': imageBase64}},
            {'text': 'Extract receipt details from this image. Respond ONLY with a valid JSON object with keys: title, amount, date. Do not include any explanation or extra text.'}
          ]
        }
      ]
    });
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 200) {
      final resp = jsonDecode(response.body);
      // Gemini returns text in resp['candidates'][0]['content']['parts'][0]['text']
      final text = resp['candidates']?[0]?['content']?['parts']?[0]?['text'] ?? '';
      try {
        // Try to extract JSON from the response text, even if it contains extra text
        final jsonStart = text.indexOf('{');
        final jsonEnd = text.lastIndexOf('}');
        if (jsonStart != -1 && jsonEnd != -1 && jsonEnd > jsonStart) {
          final jsonString = text.substring(jsonStart, jsonEnd + 1);
          final jsonData = jsonDecode(jsonString);
          _titleController.text = jsonData['title']?.toString() ?? '';
          _amountController.text = jsonData['amount']?.toString() ?? '';
          _dateController.text = jsonData['date']?.toString() ?? '';
        } else {
          throw Exception('No JSON found');
        }
      } catch (e) {
        // Show the raw Gemini response for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not extract receipt details. Raw response: $text')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gemini API error: ${response.statusCode}')),
      );
    }
  }
  XFile? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Receipt'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
              ),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Enter amount' : null,
              ),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _dateController.text = picked.toIso8601String().split('T').first;
                  }
                },
                validator: (v) => v == null || v.isEmpty ? 'Enter date' : null,
              ),
              const SizedBox(height: 16),
              Text('Attach Receipt Image:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      onPressed: () async {
                        final image = await _picker.pickImage(source: ImageSource.camera);
                        if (image != null) {
                          setState(() {
                            _pickedImage = image;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      onPressed: () async {
                        final image = await _picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          setState(() {
                            _pickedImage = image;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_pickedImage != null) ...[
                const SizedBox(height: 12),
                Center(
                  child: SizedBox(
                    height: 120,
                    child: Image.file(
                      File(_pickedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.scanner),
                    label: const Text('Scan & Fill'),
                    onPressed: () async {
                      // Add http import if not present
                      await scanReceiptAndFillFields(File(_pickedImage!.path));
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onSubmit({
                'title': _titleController.text,
                'amount': double.tryParse(_amountController.text) ?? 0,
                'date': _dateController.text,
              });
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
