import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:frontend/modules/catalog/application/catalog_option_labels_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pixelarticons/pixel.dart';

final _languageCodePattern = RegExp(r'^[a-zA-Z]{2}$');

class ItemFormInitialValues {
  const ItemFormInitialValues({
    required this.title,
    required this.creator,
    required this.publisher,
    required this.category,
    required this.format,
    required this.tags,
    required this.topic,
    required this.year,
    required this.description,
    required this.language,
    required this.imageUrl,
    required this.completed,
    required this.reference,
  });

  final String title;
  final List<String> creator;
  final String publisher;
  final String category;
  final List<String> format;
  final List<String> tags;
  final String topic;
  final int year;
  final String description;
  final List<String> language;
  final String imageUrl;
  final bool completed;
  final String reference;
}

class ItemFormView extends StatefulWidget {
  const ItemFormView({
    required this.formTitle,
    required this.submitLabel,
    required this.isSubmitting,
    required this.errorMessage,
    required this.onSubmit,
    required this.onCancel,
    this.initial,
    this.onDelete,
    super.key,
  });

  final String formTitle;
  final String submitLabel;
  final bool isSubmitting;
  final String? errorMessage;
  final ItemFormInitialValues? initial;
  final void Function({
    required String title,
    required List<String> creator,
    required String publisher,
    required String category,
    required List<String> format,
    List<String>? tags,
    String? topic,
    int? year,
    String? description,
    List<String>? language,
    Uint8List? imageBytes,
    bool removeImage,
    bool completed,
    String? reference,
  })
  onSubmit;
  final VoidCallback onCancel;
  final VoidCallback? onDelete;

  @override
  State<ItemFormView> createState() => _ItemFormViewState();
}

class _ItemFormViewState extends State<ItemFormView> {
  final _formKey = GlobalKey<FormState>();
  late final _titleController = TextEditingController(
    text: widget.initial?.title,
  );
  late final _creatorController = TextEditingController(
    text: widget.initial?.creator.join(', '),
  );
  late final _publisherController = TextEditingController(
    text: widget.initial?.publisher,
  );
  late final _referenceController = TextEditingController(
    text: widget.initial?.reference,
  );
  late final _tagsController = TextEditingController(
    text: widget.initial?.tags.join(', '),
  );
  late final _topicController = TextEditingController(
    text: widget.initial?.topic,
  );
  late final _yearController = TextEditingController(
    text: widget.initial != null && widget.initial!.year > 0
        ? '${widget.initial!.year}'
        : null,
  );
  late final _descriptionController = TextEditingController(
    text: widget.initial?.description,
  );
  late final _languageController = TextEditingController(
    text: widget.initial?.language.join(', '),
  );

  late String? _category = widget.initial?.category;
  late final Set<String> _format = {...?widget.initial?.format};
  String? _categoryError;
  String? _formatError;
  late bool _completed = widget.initial?.completed ?? false;
  Uint8List? _pickedImageBytes;
  bool _imageRemoved = false;

  @override
  void dispose() {
    _titleController.dispose();
    _creatorController.dispose();
    _publisherController.dispose();
    _referenceController.dispose();
    _tagsController.dispose();
    _topicController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    _languageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _pickedImageBytes = bytes;
      _imageRemoved = false;
    });
  }

  void _removeImage() {
    setState(() {
      _pickedImageBytes = null;
      _imageRemoved = true;
    });
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
                Text(
                  widget.formTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Title is required';
                    if (trimmed.length > 200)
                      return 'Title must be at most 200 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _creatorController,
                  decoration: const InputDecoration(
                    labelText: 'Creator',
                    helperText:
                        'Comma-separated names, e.g. "Author One, Author Two"',
                  ),
                  validator: (value) => _parseNames(value).isEmpty
                      ? 'At least one creator is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _publisherController,
                  decoration: const InputDecoration(labelText: 'Publisher'),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.isEmpty) return 'Publisher is required';
                    if (trimmed.length > 150)
                      return 'Publisher must be at most 150 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _referenceController,
                  decoration: const InputDecoration(
                    labelText: 'Reference (optional)',
                    helperText: 'ISBN or other reference number',
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length > 50)
                      return 'Reference must be at most 50 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownMenu<String>(
                  initialSelection: _category,
                  label: const Text('Category'),
                  errorText: _categoryError,
                  expandedInsets: EdgeInsets.zero,
                  dropdownMenuEntries: [
                    for (final entry in categoryLabels.entries)
                      DropdownMenuEntry(value: entry.key, label: entry.value),
                  ],
                  onSelected: (value) => setState(() {
                    _category = value;
                    _categoryError = null;
                  }),
                ),
                const SizedBox(height: 12),
                Text('Format', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final entry in formatLabels.entries)
                      FilterChip(
                        label: Text(entry.value),
                        selected: _format.contains(entry.key),
                        onSelected: (selected) => setState(() {
                          if (selected) {
                            _format.add(entry.key);
                          } else {
                            _format.remove(entry.key);
                          }
                          _formatError = null;
                        }),
                      ),
                  ],
                ),
                if (_formatError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _formatError!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
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
                  decoration: const InputDecoration(
                    labelText: 'Topic (optional)',
                  ),
                  validator: (value) {
                    final trimmed = value?.trim() ?? '';
                    if (trimmed.length > 100)
                      return 'Topic must be at most 100 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    labelText: 'Publication year (optional)',
                  ),
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
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 20,
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
                    helperText: 'Comma-separated 2-letter codes, e.g. "en, fr"',
                  ),
                  validator: (value) {
                    final languages = _parseLanguages(value);
                    if (languages.any(
                      (language) => !_languageCodePattern.hasMatch(language),
                    )) {
                      return 'Each language must be a 2-letter code';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _ImagePickerField(
                  pickedImageBytes: _pickedImageBytes,
                  existingImageUrl: _imageRemoved
                      ? ''
                      : (widget.initial?.imageUrl ?? ''),
                  onPick: _pickImage,
                  onRemove: _removeImage,
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Completed'),
                  value: _completed,
                  onChanged: (value) =>
                      setState(() => _completed = value ?? false),
                ),
                const SizedBox(height: 16),
                if (widget.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      widget.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
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
                          : Text(widget.submitLabel),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: widget.isSubmitting ? null : widget.onCancel,
                      child: const Text('Cancel'),
                    ),
                    if (widget.initial != null && widget.onDelete != null) ...[
                      const Spacer(),
                      OutlinedButton.icon(
                        onPressed: widget.isSubmitting ? null : widget.onDelete,
                        icon: Icon(
                          Pixel.trash,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    ],
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

  List<String> _parseLanguages(String? value) {
    return (value ?? '')
        .split(',')
        .map((language) => language.trim().toLowerCase())
        .where((language) => language.isNotEmpty)
        .toList();
  }

  void _submit() {
    final isFormValid = _formKey.currentState!.validate();
    setState(() {
      _categoryError = _category == null ? 'Category is required' : null;
      _formatError = _format.isEmpty ? 'Format is required' : null;
    });
    if (!isFormValid || _category == null || _format.isEmpty) return;
    final tags = _parseTags(_tagsController.text);
    final topic = _topicController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    final description = _descriptionController.text.trim();
    final language = _parseLanguages(_languageController.text);
    final reference = _referenceController.text.trim();
    widget.onSubmit(
      title: _titleController.text.trim(),
      creator: _parseNames(_creatorController.text),
      publisher: _publisherController.text.trim(),
      category: _category!,
      format: _format.toList(),
      tags: tags.isEmpty ? null : tags,
      topic: topic.isEmpty ? null : topic,
      year: year,
      description: description.isEmpty ? null : description,
      language: language.isEmpty ? null : language,
      imageBytes: _pickedImageBytes,
      removeImage: _imageRemoved,
      completed: _completed,
      reference: reference.isEmpty ? null : reference,
    );
  }
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.pickedImageBytes,
    required this.existingImageUrl,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? pickedImageBytes;
  final String existingImageUrl;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final hasImage = pickedImageBytes != null || existingImageUrl.isNotEmpty;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: 72,
            height: 72,
            child: pickedImageBytes != null
                ? Image.memory(pickedImageBytes!, fit: BoxFit.cover)
                : existingImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: existingImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      child: const Icon(Pixel.imagebroken),
                    ),
                  )
                : Container(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Icon(Pixel.imagebroken),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Pixel.image),
              label: const Text('Choose image'),
            ),
            if (hasImage)
              TextButton(
                onPressed: onRemove,
                child: const Text('Remove image'),
              ),
          ],
        ),
      ],
    );
  }
}
