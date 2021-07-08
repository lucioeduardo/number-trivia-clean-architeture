import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/number_trivia_state.dart';

import '../../../../injection_container.dart';
import '../bloc/number_trivia_bloc.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(child: buildBody(context)),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(height: 12.0),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                return state.when(
                  empty: () => MessageDisplay(message: 'Start Searching'),
                  loading: () => LoadingWidget(),
                  loaded: (numberTrivia) =>
                      TriviaDisplay(numberTrivia: numberTrivia),
                  error: (message) => MessageDisplay(message: message),
                );
              },
            ),
            SizedBox(height: 20.0),
            TriviaControls(),
          ],
        ),
      ),
    );
  }
}
