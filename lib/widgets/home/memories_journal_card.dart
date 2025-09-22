import 'package:flutter/material.dart';
import 'package:neubrutalism_ui/neubrutalism_ui.dart';
import '../../services/api_service.dart';
import '../../services/location_service.dart';

class MemoriesJournalCard extends StatefulWidget {
  const MemoriesJournalCard({super.key});

  @override
  State<MemoriesJournalCard> createState() => _MemoriesJournalCardState();
}

class _MemoriesJournalCardState extends State<MemoriesJournalCard> {
  final TextEditingController _journalController = TextEditingController();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  int get _characterCount => _journalController.text.length;

  @override
  void dispose() {
    _journalController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _locationService.init();
  }

  @override
  void didUpdateWidget(MemoriesJournalCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reinitialize location service when widget updates
    _locationService.init();
  }

  Future<void> _saveJournalEntry() async {
    if (_journalController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something before saving'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current location for the journal entry (this will use updated preferences)
      final locationName = await _locationService.getLocationName();
      
      final entryData = {
        'content': _journalController.text.trim(),
        'date': DateTime.now().toIso8601String(),
        'location': locationName,
        'mood': null, // Can be added later for mood tracking
        'tags': <String>[], // Can be added later for tagging system
      };

      print('Saving journal entry: $entryData');

      final response = await _apiService.saveJournalEntry(entryData);

      print('Journal save response: $response');

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? 'Journal entry saved successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          _journalController.clear();
          setState(() {});
          
          // No need for navigation manipulation - profile will refresh when opened
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['error'] ?? 'Failed to save entry'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('Exception saving journal entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return NeuContainer(
      color: const Color(0xFFFDEABF),
      borderColor: Colors.black,
      borderWidth: 3,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Memories & Journal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                fontFamily: 'gilroy',
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            // Purple gradient container matching the design
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF9C88FF),
                    Color(0xFF7B68EE),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black, width: 3),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'What did you love today....',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontFamily: 'gilroy',
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Text input field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                    child: TextField(
                      controller: _journalController,
                      maxLines: 4,
                      maxLength: 1000,
                      onChanged: (value) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Share your thoughts here...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'gilroy',
                          fontWeight: FontWeight.w300,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(12),
                        counterText: '', // Hide the default counter
                      ),
                      style: const TextStyle(
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Character counter
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$_characterCount/1000',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                        fontFamily: 'gilroy',
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Action buttons row
                  Row(
                    children: [
                      // Photo button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement photo picker
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo picker coming soon!'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.photo_camera, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Photo',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'gilroy',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Voice button
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: InkWell(
                          onTap: () {
                            // TODO: Implement voice recorder
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Voice recorder coming soon!'),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mic, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Voice',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'gilroy',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Save button
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: InkWell(
                          onTap: _isLoading ? null : _saveJournalEntry,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'SAVE',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontFamily: 'gilroy',
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
