//+------------------------------------------------------------------+
//|                                                     Strategy.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Strategy
  {
private:

protected:
/*
   string            symbol;
   ENUM_TIMEFRAMES   period;
   double            stopLost;
   double            takeProfit;
   double            volume;
*/
int lastBars;
public:
                     Strategy();
                    ~Strategy();
   virtual int       start(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy::Strategy()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Strategy::~Strategy()
  {
  }
//+------------------------------------------------------------------+