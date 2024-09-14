// ignore_for_file: must_call_super

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:flutter/material.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  Credentials? _credentials;
  late Auth0 auth0;

  @override
  void initState() {
    // super.initState();
    print("initstate");
    auth0 = Auth0('dev-tjxn80zm1mxdu6f6.uk.auth0.com',
        '0XdMUqGqk3IHFybO7rxAML6LGxfTUMZz '); // Replace with your domain and client ID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auth0 Login Example'),
      ),
      body: Center(
        child: _credentials == null
            ? ElevatedButton(
                onPressed: () async {
                  try {
                    // Use a Universal Link callback URL on iOS 17.4+ / macOS 14.4+
                    // useHTTPS is ignored on Android
                    final credentials = await auth0.webAuthentication().login();

                    setState(() {
                      _credentials = credentials;
                    });
                  } catch (e) {
                    print('Error during login: $e');
                  }
                },
                child: const Text("Log in"),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('You are logged in!'),
                  ElevatedButton(
                    onPressed: () async {
                      await auth0.webAuthentication().logout();
                      setState(() {
                        _credentials = null;
                      });
                    },
                    child: const Text("Log out"),
                  ),
                ],
              ),
      ),
    );
  }
}
