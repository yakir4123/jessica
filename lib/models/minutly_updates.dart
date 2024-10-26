import 'package:json_annotation/json_annotation.dart';

part 'minutly_updates.g.dart';

@JsonSerializable()
class BotStateModel {
  final double balance;
  final double todayPnl;
  final double updateTime;
  final double availableMargin;

  BotStateModel({
    required this.balance,
    required this.todayPnl,
    required this.updateTime,
    required this.availableMargin,
  });

  factory BotStateModel.fromJson(Map<String, dynamic> json) => _$BotStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$BotStateModelToJson(this);
}

enum AlignState {
  ALIGN,
  MISS_IN_STRATEGIES,
  MISS_IN_ORDER_BOOK,
}

@JsonSerializable()
class StrategyOrderModel {
  final String strategyId;
  final double qty;
  final double ratioQty;
  final double price;
  final double expire;
  final bool isMimic;
  final AlignState alignState;

  StrategyOrderModel({
    required this.strategyId,
    required this.qty,
    required this.ratioQty,
    required this.price,
    required this.expire,
    required this.isMimic,
    required this.alignState,
  });

  factory StrategyOrderModel.fromJson(Map<String, dynamic> json) => _$StrategyOrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$StrategyOrderModelToJson(this);
}

@JsonSerializable()
class AverageEntryModel {
  final String strategyId;
  final double qty;
  final double ratioQty;
  final double price;
  final bool isMimic;
  final String side;
  final String type;
  final double timestamp;

  AverageEntryModel({
    required this.strategyId,
    required this.qty,
    required this.ratioQty,
    required this.price,
    required this.isMimic,
    required this.side,
    required this.type,
    required this.timestamp,
  });

  factory AverageEntryModel.fromJson(Map<String, dynamic> json) => _$AverageEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$AverageEntryModelToJson(this);
}

@JsonSerializable()
class RouteOrdersModel {
  final List<StrategyOrderModel> buy;
  final List<StrategyOrderModel> sell;
  final List<StrategyOrderModel> takeProfit;
  final List<StrategyOrderModel> stopLoss;
  final List<AverageEntryModel> averageEntry;
  final double currentPrice;

  RouteOrdersModel({
    this.buy = const [],
    this.sell = const [],
    this.takeProfit = const [],
    this.stopLoss = const [],
    this.averageEntry = const [],
    required this.currentPrice,
  });

  factory RouteOrdersModel.fromJson(Map<String, dynamic> json) => _$RouteOrdersModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteOrdersModelToJson(this);
}

enum PositionSide {
  NONE,
  LONG,
  SHORT,
}

enum OrderType {
  BUY,
  SELL,
  TAKE_PROFIT,
  STOP_LOSS,
}

@JsonSerializable()
class RouteStateModel {
  final double pnl;
  final double price;
  final PositionSide side;
  final double positionQty;
  final double positionAvgPrice;

  RouteStateModel({
    required this.pnl,
    required this.price,
    required this.side,
    required this.positionQty,
    required this.positionAvgPrice,
  });

  factory RouteStateModel.fromJson(Map<String, dynamic> json) => _$RouteStateModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteStateModelToJson(this);
}

@JsonSerializable()
class OrderModel {
  final double qty;
  final double price;

  OrderModel({
    required this.qty,
    required this.price,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

// OrdersListModel as a list of OrderModel
typedef OrdersListModel = List<OrderModel>;

@JsonSerializable()
class MiniStrategyPositionModel {
  final List<OrderModel> allOrders;
  final bool liquidate;
  final double equity;
  final double inPositionRatio;

  MiniStrategyPositionModel({
    required this.allOrders,
    required this.liquidate,
    required this.equity,
    required this.inPositionRatio,
  });

  factory MiniStrategyPositionModel.fromJson(Map<String, dynamic> json) => _$MiniStrategyPositionModelFromJson(json);
  Map<String, dynamic> toJson() => _$MiniStrategyPositionModelToJson(this);
}


@JsonSerializable()
class MiniStrategyParamsModel {
  final OrdersListModel buy;
  final OrdersListModel sell;
  final OrdersListModel takeProfit;
  final OrdersListModel stopLoss;
  final MiniStrategyPositionModel position;
  final double expiration;
  final double entryExpiration;

  MiniStrategyParamsModel({
    required this.buy,
    required this.sell,
    required this.takeProfit,
    required this.stopLoss,
    required this.position,
    this.expiration = double.infinity,
    this.entryExpiration = double.infinity,
  });

  factory MiniStrategyParamsModel.fromJson(Map<String, dynamic> json) => _$MiniStrategyParamsModelFromJson(json);
  Map<String, dynamic> toJson() => _$MiniStrategyParamsModelToJson(this);
}

@JsonSerializable()
class OrderBookParamsEntryModel {
  final String strategyId;
  final OrderType type;
  final PositionSide position;
  final double price;
  final double ratioQty;
  final double qty;
  final bool isMimic;

  OrderBookParamsEntryModel({
    required this.strategyId,
    required this.type,
    required this.position,
    required this.price,
    required this.ratioQty,
    required this.qty,
    required this.isMimic,
  });

  factory OrderBookParamsEntryModel.fromJson(Map<String, dynamic> json) => _$OrderBookParamsEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderBookParamsEntryModelToJson(this);
}

// OrderBookParamsModel as a list of OrderBookParamsEntryModel
typedef OrderBookParamsModel = List<OrderBookParamsEntryModel>;

@JsonSerializable()
class BalanceAllocationEntryModel {
  final double qtyAllocation;
  final double availableMargin;
  final double dollarAllocation;
  final double allocationTimestamp;
  final double freeAllocation;
  final double reservedAllocation;
  final double usedAllocated;

  BalanceAllocationEntryModel({
    required this.qtyAllocation,
    required this.availableMargin,
    required this.dollarAllocation,
    required this.allocationTimestamp,
    required this.freeAllocation,
    required this.reservedAllocation,
    required this.usedAllocated,
  });

  factory BalanceAllocationEntryModel.fromJson(Map<String, dynamic> json) => _$BalanceAllocationEntryModelFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceAllocationEntryModelToJson(this);
}

@JsonSerializable()
class BalanceAllocationModel {
  final Map<String, BalanceAllocationEntryModel> allocations;
  final double baseRisk;

  BalanceAllocationModel({
    required this.allocations,
    required this.baseRisk,
  });

  factory BalanceAllocationModel.fromJson(Map<String, dynamic> json) => _$BalanceAllocationModelFromJson(json);
  Map<String, dynamic> toJson() => _$BalanceAllocationModelToJson(this);
}

@JsonSerializable()
class SchedulerParamsModel {
  final double riskMargin;
  final int qtyPrecision;
  final int pricePrecision;
  final List<OrderBookParamsEntryModel> ordersBook; // OrderBookParamsModel as a list
  final BalanceAllocationModel balanceAllocator;
  final Map<String, MiniStrategyParamsModel> strategies;

  SchedulerParamsModel({
    required this.riskMargin,
    required this.qtyPrecision,
    required this.pricePrecision,
    required this.ordersBook,
    required this.balanceAllocator,
    required this.strategies,
  });

  factory SchedulerParamsModel.fromJson(Map<String, dynamic> json) => _$SchedulerParamsModelFromJson(json);
  Map<String, dynamic> toJson() => _$SchedulerParamsModelToJson(this);
}

@JsonSerializable()
class RouteWithOrdersModel {
  final String strategyName;
  final String exchange;
  final String symbol;
  final RouteOrdersModel routeOrders;
  final RouteStateModel routeParams;
  final SchedulerParamsModel schedulerParams;

  RouteWithOrdersModel({
    required this.strategyName,
    required this.exchange,
    required this.symbol,
    required this.routeOrders,
    required this.routeParams,
    required this.schedulerParams,
  });

  factory RouteWithOrdersModel.fromJson(Map<String, dynamic> json) => _$RouteWithOrdersModelFromJson(json);
  Map<String, dynamic> toJson() => _$RouteWithOrdersModelToJson(this);
}

@JsonSerializable()
class MinutelyOutputModel {
  final BotStateModel botParams;
  final List<RouteWithOrdersModel> routesParams;

  MinutelyOutputModel({
    required this.botParams,
    required this.routesParams,
  });

  factory MinutelyOutputModel.fromJson(Map<String, dynamic> json) => _$MinutelyOutputModelFromJson(json);
  Map<String, dynamic> toJson() => _$MinutelyOutputModelToJson(this);
}
