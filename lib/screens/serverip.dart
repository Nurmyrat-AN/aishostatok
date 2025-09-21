import 'package:aishostatok/database/aishmanager.dart';
import 'package:flutter/material.dart';

class ServerIPConfiguration extends StatefulWidget {
  const ServerIPConfiguration({super.key});

  @override
  State<StatefulWidget> createState() => _ServerIPConfigurationState();
}

class _ServerIPConfigurationState extends State<ServerIPConfiguration> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _controller = TextEditingController();
  final _minstockController = TextEditingController();
  String _badgeSize = "100";

  @override
  void initState() {
    super.initState();
    _getServerIp();
  }

  _getServerIp() async {
    setState(() {
      _isLoading = true;
    });
    _badgeSize = await AishManager().badgeSize;
    _controller.text = await AishManager().serverIp;
    _minstockController.text = await AishManager().minStockAttribute;
    setState(() {
      _isLoading = false;
    });
  }

  _setServerIp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      await AishManager().setServerIp(_controller.text);
      await AishManager().setMinStockAttribute(_minstockController.text);
      await AishManager().setBadgeSize(_badgeSize);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: AlertDialog(
        title: Text("Serwer Sazlamalar"),
        content: Builder(
          builder: (context) {
            if (_isLoading) {
              return CircularProgressIndicator();
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: "Server Salgysy",
                      hintText: "http://127.0.0.1:5959/aish5/api/v1",
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Serwer salgysyny giriziň';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _minstockController,
                    decoration: InputDecoration(
                      labelText: "Minimum galyndy uçin goşmaça aýratynlyk ady",
                      hintText: "minstock",
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Radio(
                        value: _badgeSize,
                        onChanged: (value) {
                          setState(() {
                            _badgeSize = "100";
                          });
                        },
                        groupValue: "100",
                      ),
                      Text("100"),
                      Expanded(child: SizedBox()),
                      Radio(
                        value: _badgeSize,
                        onChanged: (value) {
                          setState(() {
                            _badgeSize = "500";
                          });
                        },
                        groupValue: "500",
                      ),
                      Text("500"),
                      Expanded(child: SizedBox()),
                      Radio(
                        value: _badgeSize,
                        onChanged: (value) {
                          setState(() {
                            _badgeSize = "1000";
                          });
                        },
                        groupValue: "1000",
                      ),
                      Text("1000"),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                await AishManager().clearDB();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Ýerli baza arassalandy"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Arassalamadaky näsazlyk: $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text("Ýerli bazany arassala", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("Goý bolsun"),
          ),
          TextButton(onPressed: _setServerIp, child: Text("Ýatda Sakla")),
        ],
      ),
    );
  }
}
