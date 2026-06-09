import 'env.dart';

class RouteFunctionConfig {
  static const _envGoogleRoutesFunctionUrl = Env.googleRoutesFunctionUrl;
  static const _defineGoogleRoutesFunctionUrl =
      String.fromEnvironment('GOOGLE_ROUTES_FUNCTION_URL');

  static const googleRoutesFunctionUrl = _envGoogleRoutesFunctionUrl != ''
      ? _envGoogleRoutesFunctionUrl
      : _defineGoogleRoutesFunctionUrl;
}
