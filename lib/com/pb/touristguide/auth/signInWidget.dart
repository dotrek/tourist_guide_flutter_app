import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tourist_guide/com/pb/touristguide/auth/baseAuth.dart';

class SignInWidget extends StatefulWidget {
  SignInWidget({this.auth, this.onSignedIn});

  final BaseAuth auth;
  final VoidCallback onSignedIn;

  @override
  SignInWidgetState createState() => SignInWidgetState();
}

class SignInWidgetState extends State<SignInWidget> {
  String _email;

  String _password;
  String _errorMessage = "";

  var _formKey = GlobalKey<FormState>();
  FormMode _formMode = FormMode.LOGIN;
  bool _isLoading = false;

  var crossFadeState = CrossFadeState.showFirst;

  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        crossFadeState = CrossFadeState.showSecond;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          AnimatedCrossFade(
            alignment: Alignment.center,
            firstChild: Container(),
            secondChild: _showBody(),
            duration: Duration(seconds: 3),
            crossFadeState: crossFadeState,
          ),
          _showCircularProgress()
        ],
      ),
    );
  }

  _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container(
      height: 0.0,
      width: 0.0,
    );
  }

  Widget _showBody() {
    return new Container(
      padding: EdgeInsets.all(16.0),
      child: new Form(
        key: _formKey,
        child: new ListView(
          shrinkWrap: true,
          children: <Widget>[
            _showLogo(),
            _showEmailInput(),
            _showPasswordInput(),
            _showPrimaryButton(),
            _showSecondaryButton(),
            _showErrorMessage(),
          ],
        ),
      ),
    );
  }

  Widget _showLogo() {
    return new Hero(
      tag: 'logo',
      child: ImageIcon(
        Image.asset('assets/appLogo.png').image,
        color: Colors.lightGreen,
        size: 300,
      ),
    );
  }

  Widget _showEmailInput() {
    return TextFormField(
      maxLines: 1,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
          hintText: 'Email',
          icon: new Icon(
            Icons.mail,
            color: Colors.grey,
          )),
      validator: (value) => value.isEmpty ? 'Email can\'t be empty' : null,
      onSaved: (value) => _email = value,
    );
  }

  Widget _showPasswordInput() {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0),
      child: new TextFormField(
        maxLines: 1,
        obscureText: true,
        autofocus: false,
        decoration: new InputDecoration(
            hintText: 'Password',
            icon: new Icon(
              Icons.lock,
              color: Colors.grey,
            )),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showPrimaryButton() {
    return new Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: new MaterialButton(
          elevation: 5.0,
          minWidth: 200.0,
          height: 42.0,
          color: Theme.of(context).primaryColor,
          child: _formMode == FormMode.LOGIN
              ? new Text('Login',
                  style: new TextStyle(
                      fontSize: 20.0, color: Theme.of(context).accentColor))
              : new Text('Create account',
                  style: new TextStyle(
                      fontSize: 20.0, color: Theme.of(context).primaryColor)),
          onPressed: _validateAndSubmit,
        ));
  }

  _validateAndSubmit() async {
    setState(() {
      _errorMessage = "";
      _isLoading = true;
    });
    try {
      if (_validateAndSave()) {
        String userId = "";
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          print('Signed up user: $userId');
        }
        if (userId.length > 0 && userId != null) {
          widget.onSignedIn();
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          _errorMessage = e.details;
        } else
          _errorMessage = e.message;
      });
    } finally {
      _isLoading = false;
    }
  }

  Widget _showSecondaryButton() {
    return new FlatButton(
      child: _formMode == FormMode.LOGIN
          ? new Text('Create an account',
              style: new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300))
          : new Text('Have an account? Sign in',
              style:
                  new TextStyle(fontSize: 18.0, fontWeight: FontWeight.w300)),
      onPressed: _formMode == FormMode.LOGIN
          ? _changeFormToSignUp
          : _changeFormToLogin,
    );
  }

  void _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = "";
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return new Text(
        _errorMessage,
        style: TextStyle(
            fontSize: 13.0,
            color: Colors.red,
            height: 1.0,
            fontWeight: FontWeight.w300),
      );
    } else {
      return new Container(
        height: 0.0,
      );
    }
  }

  bool _validateAndSave() {
    bool result = _formKey.currentState.validate();
    if (result) {
      _formKey.currentState.save();
    }
    return result;
  }
}

enum FormMode { LOGIN, SIGNUP }
