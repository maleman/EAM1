//+------------------------------------------------------------------+
//|                                                    Indicator.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Indicator
  {
private:

protected:
   int handle;
   int lastBars;
   virtual int copyValues();
   virtual void lookforsigns();
   virtual void lookforTrend();
   
public:
                     Indicator();
                    ~Indicator();
                    virtual int init(string symbol,ENUM_TIMEFRAMES timeFrames);
                    virtual int onTick();
                    virtual int getHandle();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::Indicator()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Indicator::~Indicator()
  {
  }
//+------------------------------------------------------------------+
