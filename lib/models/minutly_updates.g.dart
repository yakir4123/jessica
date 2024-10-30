// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'minutly_updates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BotStateModel _$BotStateModelFromJson(Map<String, dynamic> json) =>
    BotStateModel(
      balance: (json['balance'] as num).toDouble(),
      todayPnl: (json['today_pnl'] as num).toDouble(),
      updateTime: (json['update_time'] as num).toDouble(),
      availableMargin: (json['available_margin'] as num).toDouble(),
    );

Map<String, dynamic> _$BotStateModelToJson(BotStateModel instance) =>
    <String, dynamic>{
      'balance': instance.balance,
      'today_pnl': instance.todayPnl,
      'update_time': instance.updateTime,
      'available_margin': instance.availableMargin,
    };

StrategyOrderModel _$StrategyOrderModelFromJson(Map<String, dynamic> json) =>
    StrategyOrderModel(
      strategyId: json['strategy_id'] as String,
      qty: (json['qty'] as num).toDouble(),
      ratioQty: (json['ratio_qty'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      timestamp: (json['timestamp'] as num).toDouble(),
      isMimic: json['is_mimic'] as bool,
      alignState: $enumDecode(_$AlignStateEnumMap, json['align_state']),
      type: $enumDecode(_$OrderTypeEnumMap, json['type']),
      isExecuted: json['is_executed'] as bool,
    );

Map<String, dynamic> _$StrategyOrderModelToJson(StrategyOrderModel instance) =>
    <String, dynamic>{
      'strategy_id': instance.strategyId,
      'qty': instance.qty,
      'ratio_qty': instance.ratioQty,
      'price': instance.price,
      'timestamp': instance.timestamp,
      'is_mimic': instance.isMimic,
      'align_state': _$AlignStateEnumMap[instance.alignState]!,
      'type': _$OrderTypeEnumMap[instance.type]!,
      'is_executed': instance.isExecuted,
    };

const _$AlignStateEnumMap = {
  AlignState.align: 'align',
  AlignState.miss_in_strategies: 'miss_in_strategies',
  AlignState.miss_in_order_book: 'miss_in_order_book',
};

const _$OrderTypeEnumMap = {
  OrderType.buy: 'buy',
  OrderType.sell: 'sell',
  OrderType.take_profit: 'take_profit',
  OrderType.stop_loss: 'stop_loss',
};

RouteOrdersModel _$RouteOrdersModelFromJson(Map<String, dynamic> json) =>
    RouteOrdersModel(
      orders: (json['orders'] as List<dynamic>?)
              ?.map(
                  (e) => StrategyOrderModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      currentPrice: (json['current_price'] as num).toDouble(),
    );

Map<String, dynamic> _$RouteOrdersModelToJson(RouteOrdersModel instance) =>
    <String, dynamic>{
      'orders': instance.orders,
      'current_price': instance.currentPrice,
    };

RouteStateModel _$RouteStateModelFromJson(Map<String, dynamic> json) =>
    RouteStateModel(
      pnl: (json['pnl'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      side: $enumDecode(_$PositionSideEnumMap, json['side']),
      positionQty: (json['position_qty'] as num).toDouble(),
      positionAvgPrice: (json['position_avg_price'] as num).toDouble(),
    );

Map<String, dynamic> _$RouteStateModelToJson(RouteStateModel instance) =>
    <String, dynamic>{
      'pnl': instance.pnl,
      'price': instance.price,
      'side': _$PositionSideEnumMap[instance.side]!,
      'position_qty': instance.positionQty,
      'position_avg_price': instance.positionAvgPrice,
    };

const _$PositionSideEnumMap = {
  PositionSide.none: 'none',
  PositionSide.long: 'long',
  PositionSide.short: 'short',
};

OrderModel _$OrderModelFromJson(Map<String, dynamic> json) => OrderModel(
      qty: (json['qty'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
    );

Map<String, dynamic> _$OrderModelToJson(OrderModel instance) =>
    <String, dynamic>{
      'qty': instance.qty,
      'price': instance.price,
    };

MiniStrategyPositionModel _$MiniStrategyPositionModelFromJson(
        Map<String, dynamic> json) =>
    MiniStrategyPositionModel(
      allOrders: (json['all_orders'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      liquidate: json['liquidate'] as bool,
      equity: (json['equity'] as num).toDouble(),
      inPositionRatio: (json['in_position_ratio'] as num).toDouble(),
    );

Map<String, dynamic> _$MiniStrategyPositionModelToJson(
        MiniStrategyPositionModel instance) =>
    <String, dynamic>{
      'all_orders': instance.allOrders,
      'liquidate': instance.liquidate,
      'equity': instance.equity,
      'in_position_ratio': instance.inPositionRatio,
    };

MiniStrategyParamsModel _$MiniStrategyParamsModelFromJson(
        Map<String, dynamic> json) =>
    MiniStrategyParamsModel(
      buy: (json['buy'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      sell: (json['sell'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      takeProfit: (json['take_profit'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      stopLoss: (json['stop_loss'] as List<dynamic>)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      position: MiniStrategyPositionModel.fromJson(
          json['position'] as Map<String, dynamic>),
      expiration: (json['expiration'] as num?)?.toDouble() ?? double.infinity,
      entryExpiration:
          (json['entry_expiration'] as num?)?.toDouble() ?? double.infinity,
    );

Map<String, dynamic> _$MiniStrategyParamsModelToJson(
        MiniStrategyParamsModel instance) =>
    <String, dynamic>{
      'buy': instance.buy,
      'sell': instance.sell,
      'take_profit': instance.takeProfit,
      'stop_loss': instance.stopLoss,
      'position': instance.position,
      'expiration': instance.expiration,
      'entry_expiration': instance.entryExpiration,
    };

OrderBookParamsEntryModel _$OrderBookParamsEntryModelFromJson(
        Map<String, dynamic> json) =>
    OrderBookParamsEntryModel(
      strategyId: json['strategy_id'] as String,
      type: $enumDecode(_$OrderTypeEnumMap, json['type']),
      position: $enumDecode(_$PositionSideEnumMap, json['position']),
      price: (json['price'] as num).toDouble(),
      ratioQty: (json['ratio_qty'] as num).toDouble(),
      qty: (json['qty'] as num).toDouble(),
      isMimic: json['is_mimic'] as bool,
    );

Map<String, dynamic> _$OrderBookParamsEntryModelToJson(
        OrderBookParamsEntryModel instance) =>
    <String, dynamic>{
      'strategy_id': instance.strategyId,
      'type': _$OrderTypeEnumMap[instance.type]!,
      'position': _$PositionSideEnumMap[instance.position]!,
      'price': instance.price,
      'ratio_qty': instance.ratioQty,
      'qty': instance.qty,
      'is_mimic': instance.isMimic,
    };

BalanceAllocationEntryModel _$BalanceAllocationEntryModelFromJson(
        Map<String, dynamic> json) =>
    BalanceAllocationEntryModel(
      qtyAllocation: (json['qty_allocation'] as num).toDouble(),
      availableMargin: (json['available_margin'] as num).toDouble(),
      dollarAllocation: (json['dollar_allocation'] as num).toDouble(),
      allocationTimestamp: (json['allocation_timestamp'] as num).toDouble(),
      freeAllocation: (json['free_allocation'] as num).toDouble(),
      reservedAllocation: (json['reserved_allocation'] as num).toDouble(),
      usedAllocated: (json['used_allocated'] as num).toDouble(),
    );

Map<String, dynamic> _$BalanceAllocationEntryModelToJson(
        BalanceAllocationEntryModel instance) =>
    <String, dynamic>{
      'qty_allocation': instance.qtyAllocation,
      'available_margin': instance.availableMargin,
      'dollar_allocation': instance.dollarAllocation,
      'allocation_timestamp': instance.allocationTimestamp,
      'free_allocation': instance.freeAllocation,
      'reserved_allocation': instance.reservedAllocation,
      'used_allocated': instance.usedAllocated,
    };

BalanceAllocationModel _$BalanceAllocationModelFromJson(
        Map<String, dynamic> json) =>
    BalanceAllocationModel(
      allocations: (json['allocations'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, BalanceAllocationEntryModel.fromJson(e as Map<String, dynamic>)),
      ),
      baseRisk: (json['base_risk'] as num).toDouble(),
    );

Map<String, dynamic> _$BalanceAllocationModelToJson(
        BalanceAllocationModel instance) =>
    <String, dynamic>{
      'allocations': instance.allocations,
      'base_risk': instance.baseRisk,
    };

SchedulerParamsModel _$SchedulerParamsModelFromJson(
        Map<String, dynamic> json) =>
    SchedulerParamsModel(
      riskMargin: (json['risk_margin'] as num).toDouble(),
      qtyPrecision: (json['qty_precision'] as num).toInt(),
      pricePrecision: (json['price_precision'] as num).toInt(),
      ordersBook: (json['orders_book'] as List<dynamic>)
          .map((e) =>
              OrderBookParamsEntryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      balanceAllocator: BalanceAllocationModel.fromJson(
          json['balance_allocator'] as Map<String, dynamic>),
      strategies: (json['strategies'] as Map<String, dynamic>).map(
        (k, e) => MapEntry(
            k, MiniStrategyParamsModel.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$SchedulerParamsModelToJson(
        SchedulerParamsModel instance) =>
    <String, dynamic>{
      'risk_margin': instance.riskMargin,
      'qty_precision': instance.qtyPrecision,
      'price_precision': instance.pricePrecision,
      'orders_book': instance.ordersBook,
      'balance_allocator': instance.balanceAllocator,
      'strategies': instance.strategies,
    };

RouteWithOrdersModel _$RouteWithOrdersModelFromJson(
        Map<String, dynamic> json) =>
    RouteWithOrdersModel(
      strategyName: json['strategy_name'] as String,
      exchange: json['exchange'] as String,
      symbol: json['symbol'] as String,
      routeOrders: RouteOrdersModel.fromJson(
          json['route_orders'] as Map<String, dynamic>),
      routeParams: RouteStateModel.fromJson(
          json['route_params'] as Map<String, dynamic>),
      schedulerParams: SchedulerParamsModel.fromJson(
          json['scheduler_params'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$RouteWithOrdersModelToJson(
        RouteWithOrdersModel instance) =>
    <String, dynamic>{
      'strategy_name': instance.strategyName,
      'exchange': instance.exchange,
      'symbol': instance.symbol,
      'route_orders': instance.routeOrders,
      'route_params': instance.routeParams,
      'scheduler_params': instance.schedulerParams,
    };

MinutelyOutputModel _$MinutelyOutputModelFromJson(Map<String, dynamic> json) =>
    MinutelyOutputModel(
      botParams:
          BotStateModel.fromJson(json['bot_params'] as Map<String, dynamic>),
      routesParams: (json['routes_params'] as List<dynamic>)
          .map((e) => RouteWithOrdersModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$MinutelyOutputModelToJson(
        MinutelyOutputModel instance) =>
    <String, dynamic>{
      'bot_params': instance.botParams,
      'routes_params': instance.routesParams,
    };
