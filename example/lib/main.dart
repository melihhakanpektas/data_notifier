import 'package:data_notifier/data_notifier.dart';
import 'package:example/counter_notifier.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Data Notifier Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final counterNotifier = CounterNotifier.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: NotifierBuilder(
          valueNotifier: counterNotifier,
          builder: (context, value, child) {
            // Use the when method to handle different states of the notifier
            // This will return a widget based on the current state
            return value.when(
              loading: () => const CircularProgressIndicator(),
              error: (message) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: $message', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: counterNotifier.errorOrFix,
                    child: const Text('Fix Error'),
                  ),
                ],
              ),
              loaded: (data) => Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text('You have pushed the button this many times:'),
                  Text('$data', style: Theme.of(context).textTheme.headlineMedium),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'Decrement',
                        icon: const Icon(Icons.remove),
                        onPressed: counterNotifier.decrement,
                      ),
                      IconButton(
                        tooltip: 'Error or Fix',
                        icon: const Icon(Icons.error),
                        onPressed: counterNotifier.errorOrFix,
                      ),
                      IconButton(
                        tooltip: 'Loading for a second',
                        icon: const Icon(Icons.refresh),
                        onPressed: counterNotifier.loadingForASecond,
                      ),
                      IconButton(
                        tooltip: 'Increment',
                        icon: const Icon(Icons.add),
                        onPressed: counterNotifier.increment,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
