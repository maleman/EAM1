//+------------------------------------------------------------------+
//|                                             IchimokuStrategy.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include "..\tradesignal\IchimukuSignal.mqh"
#include "..\enum\Enums.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchimokuStrategy
  {
protected:
   bool longTrend;
   bool shortTrend;            
                     

public:
                     IchimokuStrategy(IchimukuSignal *psignal,StrategyMode pstrategyMode);
                    ~IchimokuStrategy();
                    
                    bool longCondition();
                    bool shortCondition();
                    bool breakCondition();
                    
                    IchimukuSignal *signal;
                    StrategyMode strategyMode;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuStrategy::IchimokuStrategy(IchimukuSignal *psignal,StrategyMode pstrategyMode)
  {
     signal = psignal;
     strategyMode = pstrategyMode;
     
     longTrend = false;
     shortTrend = false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuStrategy::~IchimokuStrategy()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|Check LongCondition buy                                           |
//+------------------------------------------------------------------+
bool IchimokuStrategy::longCondition(){
   
   if(strategyMode == WISE_MODE){
      
      if(signal.getTekanKijunTrend() == WEAK_BUY_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_BUY_BREAKOUT){
         longTrend = true;
         return true;
      }
   }
   
   return(false);
}

//+------------------------------------------------------------------+
//|Check short condition sell                                        |
//+------------------------------------------------------------------+
bool IchimokuStrategy::shortCondition(){
   if(strategyMode == WISE_MODE){
      
      if(signal.getTekanKijunTrend() == WEAK_SELL_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT){
         shortTrend = true;
         return true;
      }
   }
   return(false);
}
