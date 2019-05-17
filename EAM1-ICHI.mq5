//+------------------------------------------------------------------+
//|                                                    EAM1-ICHI.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "ni\strategy\StrategyFactory.mqh"
#include "ni\strategy\IchimokuStrategy.mqh"
#include "ni\enum\Enums.mqh"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

// Main input parameters
input TRADE_MODE trade_mode = WISE_MODE;
input ENUM_TIMEFRAMES period=PERIOD_H1;

input double stop_lost     = 0.0030;
input double take_profit   = 0.0100;
input double volume        = 0.10;
input bool trailing_stop_mode=true;

//Indicator Parameters
input int Tenkan = 9; // Tenkan line period. The fast "moving average".
input int Kijun = 26; // Kijun line period. The slow "moving average".
input int Senkou= 52; // Senkou period. Used for Kumo (Cloud) spans.

IchimokuStrategy *ichiStrategy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ichiStrategy=new IchimokuStrategy();
   ichiStrategy.start(_Symbol,period,Tenkan,Kijun,Senkou,volume,stop_lost,take_profit,trailing_stop_mode,trade_mode);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ichiStrategy.deInit();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ichiStrategy.onTick();
  }
//+------------------------------------------------------------------+
