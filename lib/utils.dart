import 'package:jessica/models/minutly_updates.dart';

RouteWithOrdersModel? getRouteFromSymbol(
    List<RouteWithOrdersModel>? routes, String symbol) {
  if (routes == null) {
    return null;
  }
  final matches = routes.where((route) => route.symbol == symbol);
  return matches.isNotEmpty ? matches.first : null;
}