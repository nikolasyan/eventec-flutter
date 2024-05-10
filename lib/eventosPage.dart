import 'package:flutter/material.dart';

class EventosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos'),
      ),
      body: ListView(
        children: <Widget>[
          eventoCard(context, 'Workshop de Flutter', 'Aprenda Flutter com experts e construa apps incríveis.', '25 de maio, 2024'),
          eventoCard(context, 'Seminário de IA', 'Explore o mundo da Inteligência Artificial e suas aplicações.', '10 de junho, 2024'),
          eventoCard(context, 'Conferência de Python', 'Venha discutir as últimas novidades e tendências do Python.', '15 de julho, 2024'),
        ],
      ),
    );
  }

  Widget eventoCard(BuildContext context, String titulo, String descricao, String data) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              descricao,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Text(
              data,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showSuccessModal(context),
                child: Text('Inscrever-se'),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showSuccessModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Inscrição Concluída'),
          content: Text('Você se inscreveu com sucesso no evento!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
