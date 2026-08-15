import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixelarticons/pixel.dart';

class PaginationControlView extends StatefulWidget {
  const PaginationControlView({
    required this.page,
    required this.totalPages,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPrevious,
    required this.onNext,
    required this.onPageChanged,
    super.key,
  });

  final int page;
  final int totalPages;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final ValueChanged<int> onPageChanged;

  @override
  State<PaginationControlView> createState() => _PaginationControlViewState();
}

class _PaginationControlViewState extends State<PaginationControlView> {
  late final _controller = TextEditingController(text: '${widget.page}');
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _controller.text = '${widget.page}';
    });
  }

  @override
  void didUpdateWidget(covariant PaginationControlView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.page != oldWidget.page && !_focusNode.hasFocus) {
      _controller.text = '${widget.page}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(String value) {
    final requested = int.tryParse(value);
    if (requested == null) {
      _controller.text = '${widget.page}';
      return;
    }
    final clamped = requested < 1
        ? 1
        : (requested > widget.totalPages ? widget.totalPages : requested);
    _controller.text = '$clamped';
    if (clamped != widget.page) widget.onPageChanged(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: widget.hasPreviousPage ? widget.onPrevious : null,
          icon: const Icon(Pixel.chevronleft),
          tooltip: 'Previous page',
        ),
        const Text('Page '),
        SizedBox(
          width: 44,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
            ),
            onSubmitted: _submit,
            onTapOutside: (_) => _submit(_controller.text),
          ),
        ),
        Text(' of ${widget.totalPages}'),
        IconButton(
          onPressed: widget.hasNextPage ? widget.onNext : null,
          icon: const Icon(Pixel.chevronright),
          tooltip: 'Next page',
        ),
      ],
    );
  }
}
