// ignore_for_file: unnecessary_nullable_for_final_variable_declarations

import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  String _authorizationEndpoint =
      'https://dev-tjxn80zm1mxdu6f6.uk.auth0.com/authorize';
  String _tokenEndpoint =
      'https://dev-tjxn80zm1mxdu6f6.uk.auth0.com/oauth/token';
  // String _issuer = 'https://dev-tjxn80zm1mxdu6f6.uk.auth0.com';
  // String _clientId = '0XdMUqGqk3IHFybO7rxAML6LGxfTUMZz';
  // String _redirectUrl = 'com.auth0.flutter://login-callback';
  String _postLogoutRedirectUrl = 'com.auth0.flutter://login-callback';
  String? _accessToken;
  String? _idToken;

  final String _clientId = '0XdMUqGqk3IHFybO7rxAML6LGxfTUMZz';
final String _redirectUrl = 'com.auth0.flutter://login-callback';
final String _issuer = 'https://dev-tjxn80zm1mxdu6f6.uk.auth0.com';
  Future<void> _loginAction() async {
    try {
      final AuthorizationTokenResponse? result =
          await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer, // Auth0 domain acts as the issuer
          scopes: ['openid', 'profile', 'email'],
          // No need to specify authorizationEndpoint and tokenEndpoint
        ),
      );

      setState(() {
        _accessToken = result?.accessToken;
        _idToken = result?.idToken;
      });
    } catch (e) {
      print('Error during login: $e');
    }
  }

  Future<void> _logoutAction() async {
    try {
      final EndSessionResponse? result = await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: _idToken!,
          postLogoutRedirectUrl: _postLogoutRedirectUrl,
          issuer: _issuer,
        ),
      );

      setState(() {
        _accessToken = null;
        _idToken = null;
      });
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  Future<Map<String, dynamic>> _getUserInfo(String accessToken) async {
    final url = 'https://dev-tjxn80zm1mxdu6f6.uk.auth0.com/userinfo';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );
    return jsonDecode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth0 Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_accessToken != null)
              FutureBuilder(
                future: _getUserInfo(_accessToken!),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasData) {
                    final userInfo = snapshot.data as Map<String, dynamic>;
                    return Column(
                      children: [
                        Text('Logged in as: ${userInfo['name']}'),
                        ElevatedButton(
                          onPressed: _logoutAction,
                          child: Text('Logout'),
                        ),
                      ],
                    );
                  } else {
                    return Text('Error loading user info');
                  }
                },
              )
            else
              ElevatedButton(
                onPressed: _loginAction,
                child: Text('Login with Auth0'),
              ),
          ],
        ),
      ),
    );
  }
}
