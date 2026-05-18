import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('tarefasBox');

  runApp(
    ChangeNotifierProvider(
      create: (context) => TarefaProvider(),
      child: const TodoApp(),
    ),
  );
}

class TarefaProvider extends ChangeNotifier {
  late Box _box;
  List<String> _tarefas = [];

  List<String> get tarefas => _tarefas;

  TarefaProvider() {
    _box = Hive.box('tarefasBox');
    _carregarTarefas();
  }

  void _carregarTarefas() {
    final tarefasSalvas = _box.get('lista_tarefas', defaultValue: <String>[]);
    if (tarefasSalvas != null) {
      _tarefas = List<String>.from(tarefasSalvas);
    }
    notifyListeners();
  }

  void adicionarTarefa(String tarefa) {
    if (tarefa.trim().isEmpty) return;
    _tarefas.add(tarefa.trim());
    _box.put('lista_tarefas', _tarefas);
    notifyListeners();
  }

  void removerTarefa(int index) {
    _tarefas.removeAt(index);
    _box.put('lista_tarefas', _tarefas);
    notifyListeners();
  }
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tarefas'),
      ),
      body: Consumer<TarefaProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Nova tarefa',
                          border: OutlineInputBorder(),
                        ),
                        onSubmitted: (value) {
                          provider.adicionarTarefa(value);
                          _controller.clear();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        provider.adicionarTarefa(_controller.text);
                        _controller.clear();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      child: const Text('Adicionar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = provider.tarefas[index];
                    return ListTile(
                      title: Text(tarefa),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => provider.removerTarefa(index),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
