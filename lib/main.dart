import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mypersonalnote/constant/routes.dart';
import 'package:mypersonalnote/services/auth/auth_service.dart';
import 'package:mypersonalnote/services/auth/bloc/auth_bloc.dart';
import 'package:mypersonalnote/services/auth/firebase_auth_provider.dart';

import 'package:mypersonalnote/verify_email_view.dart';
import 'package:mypersonalnote/views/login_view.dart';
import 'package:mypersonalnote/views/note/create_update_note_view.dart';
import 'package:mypersonalnote/views/note/note_view.dart';
import 'package:mypersonalnote/views/register_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvide()),
        child: const HomePage(),
      ),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const Registerview(),
        noteRoute: (context) => const Noteview(),
        verifyEmailRoute: (context) => const VerifyEmailView(),
        createOrUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthServices.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthServices.firebase().currentUser;
            if (user != null) {
              if (user.isEmailVerified) {
                return const Noteview();
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();
            }
          default:
            return const CircularProgressIndicator();
        }
      },
    );
  }
}

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   late final TextEditingController _controller;
//   @override
//   void initState() {
//     _controller = TextEditingController();
//     super.initState();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (context) => CounterBloc(),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text(
//             'Testing Bloc',
//           ),
//         ),
//         body: BlocConsumer<CounterBloc, CounterState>(
//           listener: (context, state) {
//             _controller.clear();
//           },
//           builder: (context, state) {
//             final invalidValue =
//                 (state is CounterStateInvalidNumber) ? state.invalidValue : '';
//             return Column(
//               children: [
//                 Text(
//                   'Current value => ${state.value}',
//                 ),
//                 Visibility(
//                   visible: state is CounterStateInvalidNumber,
//                   child: Text(
//                     'invalid input is $invalidValue',
//                   ),
//                 ),
//                 const TextField(
//                   decoration: InputDecoration(
//                     hintText: 'pls enter your number',
//                   ),
//                   keyboardType: TextInputType.number,
//                 ),
//                 Row(
//                   children: [
//                     TextButton(
//                       onPressed: () {
//                         context.read()<CounterBloc>().add(
//                               DecrementEvent(_controller.text),
//                             );
//                       },
//                       child: const Text('-'),
//                     ),
//                     TextButton(
//                       onPressed: () {
//                         context.read()<CounterBloc>().add(
//                               IncrementEvent(_controller.text),
//                             );
//                       },
//                       child: const Text('+'),
//                     ),
//                   ],
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// @immutable
// abstract class CounterState {
//   final int value;
//   const CounterState(
//     this.value,
//   );
// }

// @immutable
// abstract class CounterEvent {
//   final String value;
//   const CounterEvent(
//     this.value,
//   );
// }

// class CounterStateValidNumber extends CounterState {
//   const CounterStateValidNumber(int value) : super(value);
// }

// class CounterStateInvalidNumber extends CounterState {
//   final String invalidValue;

//   const CounterStateInvalidNumber({
//     required this.invalidValue,
//     required int previousValue,
//   }) : super(previousValue);
// }

// class IncrementEvent extends CounterEvent {
//   const IncrementEvent(String value) : super(value);
// }

// class DecrementEvent extends CounterEvent {
//   const DecrementEvent(String value) : super(value);
// }

// class CounterBloc extends Bloc<CounterEvent, CounterState> {
//   CounterBloc()
//       : super(
//           const CounterStateValidNumber(0),
//         ) {
//     on<DecrementEvent>((event, value) {
//       final integer = int.tryParse(
//         event.value,
//       );
//       if (integer == null) {
//         // ignore: invalid_use_of_visible_for_testing_member
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       } else {
//         // ignore: invalid_use_of_visible_for_testing_member
//         emit(
//           CounterStateValidNumber(
//             state.value - integer,
//           ),
//         );
//       }
//     });
//     on<IncrementEvent>((event, value) {
//       final integer = int.tryParse(event.value);
//       if (integer == null) {
//         // ignore: invalid_use_of_visible_for_testing_member
//         emit(
//           CounterStateInvalidNumber(
//             invalidValue: event.value,
//             previousValue: state.value,
//           ),
//         );
//       } else {
//         // ignore: invalid_use_of_visible_for_testing_member
//         emit(
//           CounterStateValidNumber(
//             state.value + integer,
//           ),
//         );
//       }
//     });
//   }
// }
