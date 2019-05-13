//+------------------------------------------------------------------+
//|                                             IndicatorFactory.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\enum\Enums.mqh"
#include "Indicator.mqh"
#include "Ichimoku.mqh"
#include "Adx.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IndicatorFactory
  {
private:

public:
      Indicator *getIndicator(ENUM_INDICATOR_TYPE type);
      
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator *IndicatorFactory::getIndicator(ENUM_INDICATOR_TYPE type){
    if(type == ICHIMOKU)
      return new Ichimoku();
    else if(type = ADX)
      return new Adx();
      
    return NULL;
}