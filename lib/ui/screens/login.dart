import 'package:app/constants/constants.dart';
import 'package:app/exceptions/exceptions.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:app/providers/providers.dart';
import 'package:app/ui/screens/screens.dart';
import 'package:app/ui/widgets/google_sign_in_button.dart';
import 'package:app/ui/widgets/qr_login_button.dart';
import 'package:app/ui/widgets/widgets.dart';
import 'package:app/utils/api_request.dart' as api;
import 'package:app/utils/preferences.dart' as preferences;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  static const routeName = '/login';

  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with StreamSubscriber {
  static const _host = String.fromEnvironment(
    'KOEL_HOST',
    defaultValue: 'https://localhost',
  );

  final formKey = GlobalKey<FormState>();
  var _authenticating = false;
  var _googleAuthenticating = false;
  var _showPassword = false;
  var _logoTapCount = 0;
  late final AuthProvider _auth;

  late String _email;
  late String _password;

  Map<String, dynamic>? _appData;

  @override
  void initState() {
    super.initState();
    _auth = context.read();

    // Try looking for stored values in local storage
    setState(() {
      _email = preferences.userEmail ?? '';
    });

    _fetchAppData();
  }

  Future<void> _fetchAppData() async {
    try {
      preferences.host = _host;
      final data = await api.get('app-data');
      if (mounted && data is Map<String, dynamic>) {
        setState(() => _appData = data);
      }
    } catch (_) {
      // Silently fail — legal URLs will be fetched from consent response as fallback
    }
  }

  @override
  void dispose() {
    unsubscribeAll();
    super.dispose();
  }

  Future<void> showErrorDialog(BuildContext context, {String? message}) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(
          message ?? 'There was a problem logging in. Please try again.',
        ),
        actions: <Widget>[
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void redirectToDataLoadingScreen() {
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushReplacementNamed(DataLoadingScreen.routeName);
  }

  Future<void> attemptLogin() async {
    final form = formKey.currentState!;
    var successful = false;

    if (!form.validate()) return;

    form.save();
    setState(() => _authenticating = true);

    try {
      await _auth.login(host: _host, email: _email, password: _password);
      await _auth.tryGetAuthUser();
      successful = true;
    } on HttpResponseException catch (error) {
      await showErrorDialog(
        context,
        message: error.response.statusCode == 401
            ? 'Invalid email or password.'
            : null,
      );
    } catch (error) {
      await showErrorDialog(context);
    } finally {
      setState(() => _authenticating = false);
    }

    if (successful) {
      preferences.host = _host;
      preferences.userEmail = _email;
      redirectToDataLoadingScreen();
    }
  }

  Future<void> attemptGoogleLogin() async {
    setState(() => _googleAuthenticating = true);
    var successful = false;

    try {
      final consentData = await _auth.loginWithGoogle();

      if (consentData != null) {
        // New user — navigate to consent screen
        if (mounted) {
          final rawSsoUser = consentData['sso_user'];
          final rawLegalUrls = _appData?['legal_urls'] ?? consentData['legal_urls'];
          if (rawSsoUser is! Map || rawLegalUrls is! Map) {
            await showErrorDialog(
              context,
              message: 'Invalid Google consent response. Please try again.',
            );
            return;
          }

          await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => GoogleConsentScreen(
                ssoUser: Map<String, dynamic>.from(rawSsoUser),
                legalUrls: Map<String, dynamic>.from(rawLegalUrls),
              ),
            ),
          );
          // If consent screen handled login, it already navigated away
          return;
        }
      } else {
        await _auth.tryGetAuthUser();
        successful = true;
      }
    } catch (e, stackTrace) {
      if (e.toString().contains('cancelled')) {
        // User cancelled — do nothing
      } else {
        assert(() {
          debugPrint('attemptGoogleLogin: $e\n$stackTrace');
          return true;
        }());
        await showErrorDialog(context);
      }
    } finally {
      if (mounted) setState(() => _googleAuthenticating = false);
    }

    if (successful) {
      redirectToDataLoadingScreen();
    }
  }

  Future<void> attemptLoginWithOtp({
    required String token,
  }) async {
    var successful = false;
    setState(() => _authenticating = true);

    try {
      await _auth.loginWithOneTimeToken(host: _host, token: token);
      await _auth.tryGetAuthUser();
      successful = true;
    } on HttpResponseException catch (error) {
      await showErrorDialog(
        context,
        message:
            error.response.statusCode == 401 ? 'Invalid login token.' : null,
      );
    } catch (error) {
      await showErrorDialog(context);
    } finally {
      setState(() => _authenticating = false);
    }

    if (successful) {
      redirectToDataLoadingScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    String? requireValue(String? value) =>
        value == null || value.trim().isEmpty ? 'This field is required' : null;

    return Scaffold(
      body: GradientDecoratedContainer(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.hPadding,
            ),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ...[
                    GestureDetector(
                      onTap: () {
                        setState(() => _logoTapCount++);
                        if (_logoTapCount >= 5) {
                          _logoTapCount = 0;
                          Navigator.pushNamed(context, LogScreen.routeName);
                        }
                      },
                      child: Image.asset('assets/images/logo.png', width: 160),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      autofillHints: [AutofillHints.email],
                      onChanged: (value) => _email = value,
                      onSaved: (value) => _email = value ?? '',
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@koel.music',
                      ),
                      controller: TextEditingController(text: _email),
                      validator: requireValue,
                    ),
                    TextFormField(
                      obscureText: !_showPassword,
                      keyboardType: TextInputType.visiblePassword,
                      autofillHints: [AutofillHints.password],
                      onChanged: (value) => _password = value,
                      onSaved: (value) => _password = value ?? '',
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? CupertinoIcons.eye_slash_fill
                                : CupertinoIcons.eye_fill,
                          ),
                          onPressed: () {
                            setState(() => _showPassword = !_showPassword);
                          },
                        ),
                      ),
                      validator: requireValue,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        child: _authenticating
                            ? const SpinKitThreeBounce(
                                color: Colors.white,
                                size: 16,
                              )
                            : const Text('Log In'),
                        onPressed: _authenticating ? null : attemptLogin,
                      ),
                    ),
                    GoogleSignInButton(
                      onPressed: _authenticating || _googleAuthenticating
                          ? null
                          : attemptGoogleLogin,
                      loading: _googleAuthenticating,
                    ),
                    _authenticating || _googleAuthenticating
                        ? SizedBox()
                        : QrLoginButton(
                            onResult: ({required String token}) {
                              attemptLoginWithOtp(token: token);
                            },
                          ),
                  ].expand((widget) => [widget, const SizedBox(height: 12)]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
