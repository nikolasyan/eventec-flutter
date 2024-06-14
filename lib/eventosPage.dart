import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: EventosPage(),
    );
  }
}

class Evento {
  String id;
  String titulo;
  String descricao;
  String cep;
  String logradouro;
  String bairro;
  String cidade;
  String estado;

  Evento({this.id = '', this.titulo = '', this.descricao = '', this.cep = '', this.logradouro = '', this.bairro = '', this.cidade = '', this.estado = ''});

  factory Evento.fromMap(Map<String, dynamic> data, String id) {
    return Evento(
      id: id,
      titulo: data['titulo'],
      descricao: data['desc'],
      cep: data['cep'],
      logradouro: data['logradouro'],
      bairro: data['bairro'],
      cidade: data['cidade'],
      estado: data['estado'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titulo': titulo,
      'desc': descricao,
      'cep': cep,
      'logradouro': logradouro,
      'bairro': bairro,
      'cidade': cidade,
      'estado': estado,
    };
  }
}

class EventosPage extends StatefulWidget {
  @override
  _EventosPageState createState() => _EventosPageState();
}

class _EventosPageState extends State<EventosPage> {
  List<Evento> eventos = [];

  @override
  void initState() {
    super.initState();
    _carregarEventos();
  }

  void _carregarEventos() async {
    var snapshot = await FirebaseFirestore.instance.collection("eventos").get();
    var eventosFirestore = snapshot.docs.map((doc) => Evento.fromMap(doc.data(), doc.id)).toList();
    setState(() {
      eventos = eventosFirestore;
    });
  }

  Future<void> _buscarEndereco(String cep, TextEditingController logradouroController, TextEditingController bairroController, TextEditingController cidadeController, TextEditingController estadoController) async {
    final response = await http.get(Uri.parse('https://viacep.com.br/ws/$cep/json/'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      logradouroController.text = data['logradouro'];
      bairroController.text = data['bairro'];
      cidadeController.text = data['localidade'];
      estadoController.text = data['uf'];
    } else {
      // Handle the error
    }
  }

  void _adicionarEvento() {
    TextEditingController tituloController = TextEditingController();
    TextEditingController descricaoController = TextEditingController();
    TextEditingController cepController = TextEditingController();
    TextEditingController logradouroController = TextEditingController();
    TextEditingController bairroController = TextEditingController();
    TextEditingController cidadeController = TextEditingController();
    TextEditingController estadoController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Novo Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(labelText: 'Título do Evento'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição do Evento'),
                ),
                TextField(
                  controller: cepController,
                  decoration: InputDecoration(labelText: 'CEP'),
                  onChanged: (value) {
                    if (value.length == 8) {
                      _buscarEndereco(value, logradouroController, bairroController, cidadeController, estadoController);
                    }
                  },
                ),
                TextField(
                  controller: logradouroController,
                  decoration: InputDecoration(labelText: 'Logradouro'),
                ),
                TextField(
                  controller: bairroController,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextField(
                  controller: cidadeController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                ),
                TextField(
                  controller: estadoController,
                  decoration: InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Adicionar'),
              onPressed: () async {
                var novoEvento = Evento(
                  titulo: tituloController.text,
                  descricao: descricaoController.text,
                  cep: cepController.text,
                  logradouro: logradouroController.text,
                  bairro: bairroController.text,
                  cidade: cidadeController.text,
                  estado: estadoController.text,
                );
                await FirebaseFirestore.instance.collection("eventos").add(novoEvento.toMap());
                Navigator.of(context).pop();
                _carregarEventos();  // Recarrega a lista após adicionar
              },
            ),
          ],
        );
      },
    );
  }

  void _editarEvento(Evento evento) {
    TextEditingController tituloController = TextEditingController(text: evento.titulo);
    TextEditingController descricaoController = TextEditingController(text: evento.descricao);
    TextEditingController cepController = TextEditingController(text: evento.cep);
    TextEditingController logradouroController = TextEditingController(text: evento.logradouro);
    TextEditingController bairroController = TextEditingController(text: evento.bairro);
    TextEditingController cidadeController = TextEditingController(text: evento.cidade);
    TextEditingController estadoController = TextEditingController(text: evento.estado);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Evento'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(labelText: 'Título do Evento'),
                ),
                TextField(
                  controller: descricaoController,
                  decoration: InputDecoration(labelText: 'Descrição do Evento'),
                ),
                TextField(
                  controller: cepController,
                  decoration: InputDecoration(labelText: 'CEP'),
                  onChanged: (value) {
                    if (value.length == 8) {
                      _buscarEndereco(value, logradouroController, bairroController, cidadeController, estadoController);
                    }
                  },
                ),
                TextField(
                  controller: logradouroController,
                  decoration: InputDecoration(labelText: 'Logradouro'),
                ),
                TextField(
                  controller: bairroController,
                  decoration: InputDecoration(labelText: 'Bairro'),
                ),
                TextField(
                  controller: cidadeController,
                  decoration: InputDecoration(labelText: 'Cidade'),
                ),
                TextField(
                  controller: estadoController,
                  decoration: InputDecoration(labelText: 'Estado'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Salvar Alterações'),
              onPressed: () async {
                evento.titulo = tituloController.text;
                evento.descricao = descricaoController.text;
                evento.cep = cepController.text;
                evento.logradouro = logradouroController.text;
                evento.bairro = bairroController.text;
                evento.cidade = cidadeController.text;
                evento.estado = estadoController.text;
                await FirebaseFirestore.instance.collection("eventos").doc(evento.id).update(evento.toMap());
                Navigator.of(context).pop();
                _carregarEventos();  // Recarrega a lista após editar
              },
            ),
          ],
        );
      },
    );
  }

  void _excluirEvento(String eventId) async {
    await FirebaseFirestore.instance.collection("eventos").doc(eventId).delete();
    _carregarEventos();  // Recarrega a lista após deletar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: ListView.builder(
        itemCount: eventos.length,
        itemBuilder: (context, index) {
          final evento = eventos[index];
          return eventoCard(context, evento, index);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _adicionarEvento,
        tooltip: 'Adicionar Evento',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget eventoCard(BuildContext context, Evento evento, int index) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(evento.titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(evento.descricao, style: TextStyle(fontSize: 16)),
            SizedBox(height: 5),
            Text('Endereço: ${evento.logradouro}, ${evento.bairro}, ${evento.cidade} - ${evento.estado}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _editarEvento(evento),
                  child: Text('Editar'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.blue),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _excluirEvento(evento.id),
                  child: Text('Excluir'),
                  style: ElevatedButton.styleFrom(foregroundColor: Colors.white, backgroundColor: Colors.red),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
