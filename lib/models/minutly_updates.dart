import 'package:json_annotation/json_annotation.dart';

part 'minutly_updates.g.dart';

@JsonSerializable()
class BotStateModel {
  @JsonKey(name: 'balance')
  final double balance;

  @JsonKey(name: 'today_pnl')
  final double todayPnl;

  @JsonKey(name: 'update_time')
  final double updateTime;

  @JsonKey(name: 'available_margin')
  final double availableMargin;

  BotStateModel({
    required this.balance,
    required this.todayPnl,
    required this.updateTime,
    required this.availableMargin,
  });

  factory BotStateModel.fromJson(Map<String, dynamic> json) =>
      _$BotStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$BotStateModelToJson(this);
}

enum AlignState {
  align,
  miss_in_strategies,
  miss_in_order_book,
}

@JsonSerializable()
class StrategyOrderModel {
  @JsonKey(name: 'strategy_id')
  final String strategyId;

  @JsonKey(name: 'qty')
  final double qty;

  @JsonKey(name: 'ratio_qty')
  final double ratioQty;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'timestamp')
  final double timestamp;

  @JsonKey(name: 'is_mimic')
  final bool isMimic;

  @JsonKey(name: 'align_state')
  final AlignState alignState;

  @JsonKey(name: 'type')
  final OrderType type;

  @JsonKey(name: 'is_executed')
  final bool isExecuted;

  StrategyOrderModel({
    required this.strategyId,
    required this.qty,
    required this.ratioQty,
    required this.price,
    required this.timestamp,
    required this.isMimic,
    required this.alignState,
    required this.type,
    required this.isExecuted,
  });

  factory StrategyOrderModel.fromJson(Map<String, dynamic> json) =>
      _$StrategyOrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$StrategyOrderModelToJson(this);
}

@JsonSerializable()
class RouteOrdersModel {
  @JsonKey(name: 'orders')
  final List<StrategyOrderModel> orders;

  @JsonKey(name: 'current_price')
  final double currentPrice;

  RouteOrdersModel({
    this.orders = const [],
    required this.currentPrice,
  });

  factory RouteOrdersModel.fromJson(Map<String, dynamic> json) =>
      _$RouteOrdersModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteOrdersModelToJson(this);
}

enum PositionSide {
  none,
  long,
  short,
}

enum OrderType {
  buy,
  sell,
  take_profit,
  stop_loss,
}

@JsonSerializable()
class RouteStateModel {
  @JsonKey(name: 'pnl')
  final double pnl;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'side')
  final PositionSide side;

  @JsonKey(name: 'position_qty')
  final double positionQty;

  @JsonKey(name: 'position_avg_price')
  final double positionAvgPrice;

  RouteStateModel({
    required this.pnl,
    required this.price,
    required this.side,
    required this.positionQty,
    required this.positionAvgPrice,
  });

  factory RouteStateModel.fromJson(Map<String, dynamic> json) =>
      _$RouteStateModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteStateModelToJson(this);
}

@JsonSerializable()
class OrderModel {
  @JsonKey(name: 'qty')
  final double qty;

  @JsonKey(name: 'price')
  final double price;

  OrderModel({
    required this.qty,
    required this.price,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) =>
      _$OrderModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderModelToJson(this);
}

// OrdersListModel as a list of OrderModel
typedef OrdersListModel = List<OrderModel>;

@JsonSerializable()
class MiniStrategyPositionModel {
  @JsonKey(name: 'all_orders')
  final List<OrderModel> allOrders;

  @JsonKey(name: 'liquidate')
  final bool liquidate;

  @JsonKey(name: 'equity')
  final double equity;

  @JsonKey(name: 'in_position_ratio')
  final double inPositionRatio;

  MiniStrategyPositionModel({
    required this.allOrders,
    required this.liquidate,
    required this.equity,
    required this.inPositionRatio,
  });

  factory MiniStrategyPositionModel.fromJson(Map<String, dynamic> json) =>
      _$MiniStrategyPositionModelFromJson(json);

  Map<String, dynamic> toJson() => _$MiniStrategyPositionModelToJson(this);
}

@JsonSerializable()
class MiniStrategyParamsModel {
  @JsonKey(name: 'buy')
  final OrdersListModel buy;

  @JsonKey(name: 'sell')
  final OrdersListModel sell;

  @JsonKey(name: 'take_profit')
  final OrdersListModel takeProfit;

  @JsonKey(name: 'stop_loss')
  final OrdersListModel stopLoss;

  @JsonKey(name: 'position')
  final MiniStrategyPositionModel position;

  @JsonKey(name: 'expiration')
  final double expiration;

  @JsonKey(name: 'entry_expiration')
  final double entryExpiration;

  /// Map to store any extra fields not defined in the model
  @JsonKey(includeFromJson: false, includeToJson: false)
  final Map<String, dynamic> extraData;

  MiniStrategyParamsModel({
    required this.buy,
    required this.sell,
    required this.takeProfit,
    required this.stopLoss,
    required this.position,
    this.expiration = double.infinity,
    this.entryExpiration = double.infinity,
    this.extraData = const {},
  });

  factory MiniStrategyParamsModel.fromJson(Map<String, dynamic> json) {
    // Parse known properties using the generated function
    final instance = _$MiniStrategyParamsModelFromJson(json);

    // Extract additional properties
    final extraData = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => instance.toJson().containsKey(key));

    return MiniStrategyParamsModel(
      buy: instance.buy,
      sell: instance.sell,
      takeProfit: instance.takeProfit,
      stopLoss: instance.stopLoss,
      position: instance.position,
      expiration: instance.expiration,
      entryExpiration: instance.entryExpiration,
      extraData: extraData,
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$MiniStrategyParamsModelToJson(this);
    // Add extraData to the JSON map
    json.addAll(extraData);
    return json;
  }
}

@JsonSerializable()
class OrderBookParamsEntryModel {
  @JsonKey(name: 'strategy_id')
  final String strategyId;

  @JsonKey(name: 'type')
  final OrderType type;

  @JsonKey(name: 'position')
  final PositionSide position;

  @JsonKey(name: 'price')
  final double price;

  @JsonKey(name: 'ratio_qty')
  final double ratioQty;

  @JsonKey(name: 'qty')
  final double qty;

  @JsonKey(name: 'is_mimic')
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

  factory OrderBookParamsEntryModel.fromJson(Map<String, dynamic> json) =>
      _$OrderBookParamsEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderBookParamsEntryModelToJson(this);
}

// OrderBookParamsModel as a list of OrderBookParamsEntryModel
typedef OrderBookParamsModel = List<OrderBookParamsEntryModel>;

@JsonSerializable()
class BalanceAllocationEntryModel {
  @JsonKey(name: 'qty_allocation')
  final double qtyAllocation;

  @JsonKey(name: 'available_margin')
  final double availableMargin;

  @JsonKey(name: 'dollar_allocation')
  final double dollarAllocation;

  @JsonKey(name: 'allocation_timestamp')
  final double allocationTimestamp;

  @JsonKey(name: 'free_allocation')
  final double freeAllocation;

  @JsonKey(name: 'reserved_allocation')
  final double reservedAllocation;

  @JsonKey(name: 'used_allocated')
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

  factory BalanceAllocationEntryModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceAllocationEntryModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceAllocationEntryModelToJson(this);
}

@JsonSerializable()
class BalanceAllocationModel {
  @JsonKey(name: 'allocations')
  final Map<String, BalanceAllocationEntryModel> allocations;

  @JsonKey(name: 'base_risk')
  final double baseRisk;

  BalanceAllocationModel({
    required this.allocations,
    required this.baseRisk,
  });

  factory BalanceAllocationModel.fromJson(Map<String, dynamic> json) =>
      _$BalanceAllocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$BalanceAllocationModelToJson(this);
}

@JsonSerializable()
class SchedulerParamsModel {
  @JsonKey(name: 'risk_margin')
  final double riskMargin;

  @JsonKey(name: 'qty_precision')
  final int qtyPrecision;

  @JsonKey(name: 'price_precision')
  final int pricePrecision;

  @JsonKey(name: 'orders_book')
  final List<OrderBookParamsEntryModel> ordersBook;

  @JsonKey(name: 'balance_allocator')
  final BalanceAllocationModel balanceAllocator;

  @JsonKey(name: 'strategies')
  final Map<String, MiniStrategyParamsModel> strategies;

  SchedulerParamsModel({
    required this.riskMargin,
    required this.qtyPrecision,
    required this.pricePrecision,
    required this.ordersBook,
    required this.balanceAllocator,
    required this.strategies,
  });

  factory SchedulerParamsModel.fromJson(Map<String, dynamic> json) =>
      _$SchedulerParamsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SchedulerParamsModelToJson(this);
}

@JsonSerializable()
class RouteWithOrdersModel {
  @JsonKey(name: 'strategy_name')
  final String strategyName;

  @JsonKey(name: 'exchange')
  final String exchange;

  @JsonKey(name: 'symbol')
  final String symbol;

  @JsonKey(name: 'route_orders')
  final RouteOrdersModel routeOrders;

  @JsonKey(name: 'route_params')
  final RouteStateModel routeParams;

  @JsonKey(name: 'scheduler_params')
  final SchedulerParamsModel schedulerParams;

  RouteWithOrdersModel({
    required this.strategyName,
    required this.exchange,
    required this.symbol,
    required this.routeOrders,
    required this.routeParams,
    required this.schedulerParams,
  });

  factory RouteWithOrdersModel.fromJson(Map<String, dynamic> json) =>
      _$RouteWithOrdersModelFromJson(json);

  Map<String, dynamic> toJson() => _$RouteWithOrdersModelToJson(this);
}

@JsonSerializable()
class MinutelyOutputModel {
  @JsonKey(name: 'bot_params')
  final BotStateModel botParams;

  @JsonKey(name: 'routes_params')
  final List<RouteWithOrdersModel> routesParams;

  MinutelyOutputModel({
    required this.botParams,
    required this.routesParams,
  });

  factory MinutelyOutputModel.fromJson(Map<String, dynamic> json) =>
      _$MinutelyOutputModelFromJson(json);

  Map<String, dynamic> toJson() => _$MinutelyOutputModelToJson(this);
}
