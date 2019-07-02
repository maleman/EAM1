//+------------------------------------------------------------------+
//|                                                       EAM1LY.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//#include "ni.clasess\AccountInfo.mqh"


#include "ni\strategy\StrategyFactory.mqh"
#include "ni\strategy\EmaStrategy.mqh"
#include "ni\enum\Enums.mqh"


//+------------------------------------------------------------------+

input double stop_lost     = 0.0010;
input double take_profit   = 0.0050;
input double volume        = 0.10;

input bool trailing_stop=false;

input int ma_period_1 = 10;
input int ma_period_2 = 50;
input int ma_shift_1 = 0;
input int ma_shift_2 = 0;
input ENUM_MA_METHOD ma_method_1=MODE_EMA;
input ENUM_MA_METHOD ma_method_2=MODE_EMA;
input ENUM_APPLIED_PRICE applied_price_1=PRICE_CLOSE;
input ENUM_APPLIED_PRICE applied_price_2=PRICE_CLOSE;

input ENUM_TIMEFRAMES period=PERIOD_M15;

EmaStrategy *emaStrategy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   StrategyFactory sFactory=new StrategyFactory();
   emaStrategy=sFactory.getStrategy(0);
   emaStrategy.setValuesTrade(volume,
                              stop_lost,
                              take_profit,
                              ma_period_1,
                              ma_period_2,
                              ma_shift_1,
                              ma_shift_2,
                              ma_method_1,
                              ma_method_2,
                              applied_price_1,
                              applied_price_2);

   return emaStrategy.start(_Symbol,period);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete emaStrategy;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   emaStrategy.onTick();
  }
//+------------------------------------------------------------------+