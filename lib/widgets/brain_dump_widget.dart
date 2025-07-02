import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/mind_gym_viewmodel.dart';

class BrainDumpWidget extends StatefulWidget {
  @override
  _BrainDumpWidgetState createState() => _BrainDumpWidgetState();
}

class _BrainDumpWidgetState extends State<BrainDumpWidget> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MindGymViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Brain Dump',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Clear your mind by writing down all your thoughts and feelings',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Writing Area
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Text Input
                    Container(
                      padding: EdgeInsets.all(16),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: 8,
                        decoration: InputDecoration(
                          hintText: 'What\'s on your mind? Write freely without judgment...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                        style: TextStyle(fontSize: 16, height: 1.5),
                        onChanged: viewModel.updateBrainDumpText,
                      ),
                    ),
                    
                    // Action Bar
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_textController.text.length} characters',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  _textController.clear();
                                  viewModel.updateBrainDumpText('');
                                },
                                child: Text('Clear'),
                              ),
                              SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _textController.text.trim().isNotEmpty
                                    ? () async {
                                        await viewModel.saveBrainDumpEntry();
                                        _textController.clear();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text('Brain dump saved!'),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 24),
              
              // Emotion Tags
              Text(
                'How are you feeling?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildEmotionChip('😊', 'Happy', Colors.yellow),
                  _buildEmotionChip('😔', 'Sad', Colors.blue),
                  _buildEmotionChip('😰', 'Anxious', Colors.orange),
                  _buildEmotionChip('😡', 'Angry', Colors.red),
                  _buildEmotionChip('😴', 'Tired', Colors.purple),
                  _buildEmotionChip('🤔', 'Confused', Colors.grey),
                  _buildEmotionChip('😌', 'Calm', Colors.green),
                  _buildEmotionChip('🔥', 'Motivated', Colors.deepOrange),
                ],
              ),
              
              SizedBox(height: 24),
              
              // Recent Entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Entries',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show all entries
                    },
                    child: Text('View All'),
                  ),
                ],
              ),
              
              SizedBox(height: 12),
              
              // Entries List
              Expanded(
                child: viewModel.brainDumpEntries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.psychology_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No entries yet',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Start writing to clear your mind',
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: viewModel.brainDumpEntries.length,
                        itemBuilder: (context, index) {
                          final entry = viewModel.brainDumpEntries[index];
                          return _buildEntryCard(entry, index, viewModel);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmotionChip(String emoji, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(String entry, int index, MindGymViewModel viewModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entry ${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await viewModel.deleteBrainDumpEntry(index);
                },
                icon: Icon(Icons.delete_outline, size: 20),
                color: Colors.grey[500],
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            entry,
            style: TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.grey[800],
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

