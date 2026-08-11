import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/application/languages_state_service.dart';
import 'package:frontend/modules/catalog/presentation/languages/languages_view.dart';
import 'package:go_router/go_router.dart';

class LanguagesContainer extends StatefulWidget {
  const LanguagesContainer({this.initialLanguage, super.key});

  final String? initialLanguage;

  @override
  State<LanguagesContainer> createState() => _LanguagesContainerState();
}

class _LanguagesContainerState extends State<LanguagesContainer> {
  late final LanguagesStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = LanguagesStateService(
      getIt<ItemReadService>(),
      initialLanguage: widget.initialLanguage,
    );
  }

  @override
  void dispose() {
    _stateService.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _stateService,
      child: BlocBuilder<LanguagesStateService, LanguagesState>(
        builder: (context, state) => LanguagesView(
          state: state,
          onLetterTap: (letter) =>
              context.read<LanguagesStateService>().selectLetter(letter),
          onLanguageTap: (language) =>
              context.read<LanguagesStateService>().selectLanguage(language),
          onItemTap: (item) => context.push('/items/${item.id}'),
        ),
      ),
    );
  }
}
