import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/composition_root.dart';
import 'package:frontend/modules/catalog/application/authors_state.dart';
import 'package:frontend/modules/catalog/application/authors_state_service.dart';
import 'package:frontend/modules/catalog/application/item_read_service.dart';
import 'package:frontend/modules/catalog/presentation/authors/authors_view.dart';
import 'package:go_router/go_router.dart';

class AuthorsContainer extends StatefulWidget {
  const AuthorsContainer({this.initialAuthor, super.key});

  final String? initialAuthor;

  @override
  State<AuthorsContainer> createState() => _AuthorsContainerState();
}

class _AuthorsContainerState extends State<AuthorsContainer> {
  late final AuthorsStateService _stateService;

  @override
  void initState() {
    super.initState();
    _stateService = AuthorsStateService(getIt<ItemReadService>(), initialAuthor: widget.initialAuthor);
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
      child: BlocBuilder<AuthorsStateService, AuthorsState>(
        builder: (context, state) => AuthorsView(
          state: state,
          onLetterTap: (letter) => context.read<AuthorsStateService>().selectLetter(letter),
          onAuthorTap: (author) => context.read<AuthorsStateService>().selectAuthor(author),
          onItemTap: (item) => context.push('/items/${item.id}'),
        ),
      ),
    );
  }
}
