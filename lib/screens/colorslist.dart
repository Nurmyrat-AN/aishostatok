import 'package:aishostatok/database/models/mcolor.dart';
import 'package:aishostatok/screens/colorsconf.dart';
import 'package:flutter/material.dart';

class ColorsList extends StatefulWidget {
  const ColorsList({super.key});

  @override
  State<StatefulWidget> createState() => _ColorsList();
}

class _ColorsList extends State<ColorsList> {
  Future<List<MColor>>? colorsFuture;

  @override
  initState() {
    super.initState();
    colorsFuture = MColor.getAll();
  }

  _showColorEditDialog(MColor? color) async {
    final isSaved = await showDialog(
      context: context,
      builder: (context) => ColorsConfiguration(color: color),
    );
    if (isSaved != null) {
      setState(() {
        colorsFuture = MColor.getAll();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reňkler"),
        actions: [
          IconButton(
            onPressed: () => _showColorEditDialog(null),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              onChanged: (value) {
                setState(() {
                  colorsFuture = MColor.getAll(query: value);
                });
              },
              decoration: InputDecoration(
                labelText: "Gözleg",
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Card(
                child: FutureBuilder(
                  future: colorsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text("Näsazlyk: ${snapshot.error}"));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("Maglumat ýok"));
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final color = snapshot.data![index];
                        return ListTile(
                          textColor: Color(
                            int.parse(
                              color.fontColor.substring(1, 9),
                              radix: 16,
                            ),
                          ),
                          tileColor: Color(
                            int.parse(
                              color.backgroundColor.substring(1, 9),
                              radix: 16,
                            ),
                          ),
                          title: Text(color.name),
                          subtitle: Text(
                            "${color.property_1}, ${color.property_2}, ${color.property_3}, ${color.property_4}, ${color.property_5}",
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () => _showColorEditDialog(color),
                                icon: Icon(Icons.edit, color: Colors.blue),
                                tooltip: "Üýtget",
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8),
                              IconButton(
                                onPressed: () async {
                                  await color.delete();
                                  setState(() {
                                    colorsFuture = MColor.getAll();
                                  });
                                },
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: "Poz",
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
