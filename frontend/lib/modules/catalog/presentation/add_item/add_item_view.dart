import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/presentation/catalog_option_labels_util.dart';

final _languageCodePattern = RegExp(r'^[a-zA-Z]{2}$');

class AddItemView extends StatefulWidget {
  const AddItemView({
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
    required this.onCancel,
    super.key,
  });

  final bool isSubmitting;
  final String? errorMessage;
  final void Function({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required String format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    String? language,
    String? imageUrl,
  })
  onSubmit;
  final VoidCallback onCancel;

  @override
  State<AddItemView> createState() => _AddItemViewState();
}

class _AddItemViewState extends State<AddItemView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _creatorController = TextEditingController();
  final _publisherController = TextEditingController();
  final _tagsController = TextEditingController();
  final _topicController = TextEditingController();
  final _yearController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _languageController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String? _category;
  String? _format;

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _publisherController.dispose();
    _tagsController.dispose();
    _topicController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add item', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Title is required';
                    if (trimmed.length > 200) return 'Title must be at most 200 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _creatorController,
                  decoration: const InputDecoration(
                    labelText: 'Creator',
                    helperText: 'Comma-separated names, e.g. "Author One, Author Two"',
                  ),
                  validator: (value) =>
                      _parseNames(value).isEmpty ? 'At least one creator is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _publisherController,
                  decoration: const InputDecoration(labelText: 'Publisher'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Publisher is required';
                    if (trimmed.length > 150) return 'Publisher must be at most 150 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: [
                    for (final entry in categoryLabels.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                  ],
                  onChanged: (value) => setState(() => _category = value),
                  validator: (value) => value == null ? 'Category is required' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _format,
                  decoration: const InputDecoration(labelText: 'Format'),
                  items: [
                    for (final entry in formatLabels.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.value)),
                  ],
                  onChanged: (value) => setState(() => _format = value),
                  validator: (value) => value == null ? 'Format is required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(
                    labelText: 'Tags (optional)',
                    helperText: 'Comma-separated, up to 10',
                  ),
                  validator: (value) {
                    final tags = _parseTags(value);
                    if (tags.length > 10) return 'At most 10 tags are allowed';
                    if (tags.any((tag) => tag.length > 30)) {
                      return 'Each tag must be at most 30 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _topicController,
                  decoration: const InputDecoration(labelText: 'Topic (optional)'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length > 100) return 'Topic must be at most 100 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(labelText: 'Publication year (optional)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    final year = int.tryParse(trimmed);
                    final currentYear = DateTime.now().year;
                    if (year == null || year < 1000 || year > currentYear) {
                      return 'Enter a year between 1000 and $currentYear';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                  maxLines: 4,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length > 2000) {
                      return 'Description must be at most 2000 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _languageController,
                  decoration: const InputDecoration(
                    labelText: 'Language (optional)',
                    helperText: '2-letter code, e.g. "en"',
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    if (!_languageCodePattern.hasMatch(trimmed)) {
                      return 'Enter a 2-letter language code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL (optional)'),
                  keyboardType: TextInputType.url,
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return null;
                    final uri = Uri.tryParse(trimmed);
                    final isValid =
                        uri != null &&
                        (uri.scheme == 'http' || uri.scheme == 'https') &&
                        uri.host.isNotEmpty;
                    return isValid ? null : 'Enter a valid http/https URL';
                  },
                ),
                const SizedBox(height: 16),
                if (widget.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                Row(
                  children: [
                    FilledButton(
                      onPressed: widget.isSubmitting ? null : _submit,
                      child: widget.isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Add item'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.isSubmitting ? null : widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<String> _parseNames(String? value) {
    return (value ?? '')
        .split(',')
        .map((name) => name.trim())
        .where((name) => name.isNotEmpty)
        .toList();
  }

  List<String> _parseTags(String? value) {
    return (value ?? '')
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final tags = _parseTags(_tagsController.text);
    final topic = _topicController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final description = _descriptionController.text.trim();
    final language = _languageController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    widget.onSubmit(
      title: _titleController.text.trim(),
      creator: _parseNames(_creatorController.text),
      publisher: _publisherController.text.trim(),
      category: _category!,
      format: _format!,
      tags: tags.isEmpty ? null : tags,
      topic: topic.isEmpty ? null : topic,
      year: year,
      description: description.isEmpty ? null : description,
      language: language.isEmpty ? null : language.toLowerCase(),
      imageUrl: imageUrl.isEmpty ? null : imageUrl,
    );
  }
}
