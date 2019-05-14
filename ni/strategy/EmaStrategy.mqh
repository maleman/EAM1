//+------------------------------------------------------------------+
//|                                                  EmaStrategy.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Strategy.mqh"
#include "..\indicator\Ema.mqh"
#include "..\indicator\IndicatorFactory.mqh"
#include "..\trade\EaTrade.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EmaStrategy : public Strategy
  {
private:
   Ema *ema;
   EmaSignals lastSig;
   EaTrade *trade;
   
   double sl;
   double tp;
   double vol;
   
public:
   EmaStrategy();
   ~EmaStrategy();
   
   virtual  int start(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual  int onTick();
   
   void setValuesTrade(double pvol, double psl, double ptp){
      vol   = pvol;
      sl    = psl;
      tp    = ptp; 
   }
   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaStrategy::EmaStrategy(){

      
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaStrategy::~EmaStrategy(){}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmaStrategy::start(string symbol,ENUM_TIMEFRAMES timeFrames){
   IndicatorFactory ifactory = new IndicatorFactory();
   if(ema == NULL)
      ema = ifactory.getIndicator(DEMA);
      
   ema.setEmaPeriod(10,50);
   return ema.init(symbol,timeFrames);
   
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmaStrategy::onTick(){
   if(ema != NULL)
      ema.onTick();
    
    EmaSignals sig = ema.getLastSignal();
    
    if(lastSig != sig){
    
      if(trade == NULL)
          trade = new EaTrade();
           
      //double sl = 0.0020;
      //double tp = 0.0015;
      //double vol = 0.010;
      
      
      if(sig == BUY){
         string orderComent = "BUY";
         trade.buy(orderComent,  vol,  sl,  tp);
      }else if(sig == SELL){
         string orderComent = "SELL";
         trade.sell( orderComent,  vol,  sl,  tp);
      }
      lastSig = sig;
    }
        
   return 1; 
}