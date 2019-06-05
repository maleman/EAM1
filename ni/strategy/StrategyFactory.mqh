//+------------------------------------------------------------------+
//|                                              StrategyFactory.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Strategy.mqh"
#include "EmaStrategy.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class StrategyFactory
  {
private:

public:
   
   Strategy *getStrategy(int method);
   
  };
  
  
Strategy *StrategyFactory::getStrategy(int method){

      
   return NULL;
}
