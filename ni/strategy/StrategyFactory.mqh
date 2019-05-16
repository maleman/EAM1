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
#include "IchimokuStrategy.mqh"

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
   
   if(method == 0)
      return new EmaStrategy();
      else if(method == 1)
         return new IchimokuStrategy;
      
   return NULL;
}
