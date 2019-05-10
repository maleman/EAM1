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
   
   IchimokuSignals lastExitLong;
   IchimokuSignals lastExitShort;
                     

public:
                     IchimokuStrategy(IchimukuSignal *psignal,StrategyMode pstrategyMode);
                    ~IchimokuStrategy();
                    
                    bool longCondition();
                    bool exitLong();
                    bool shortCondition();
                    bool exitShort();
                    
             
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
      
      if((signal.getTenkanKijunCrossSignal() == WEAK_BUY_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_BUY_BREAKOUT)
         || (signal.getTenkanKijunCrossSignal() == NEUTRAL_BUY_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_BUY_BREAKOUT)
         || (signal.getTenkanKijunCrossSignal() == STRONG_BUY_TS_KS_CROSS)){
         longTrend = true;
         return true;
      }
      //else if(longTrend)
      //   longTrend = false;
      
   }
   
   if(strategyMode == ROOKIE_MODE){
      if ((signal.getTenkanKijunCrossSignal() == WEAK_BUY_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == NEUTRAL_BUY_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == STRONG_BUY_TS_KS_CROSS
         || signal.getKijunCrossSignal() == WEAK_BUY_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == NEUTRAL_BUY_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == STRONG_BUY_KIJUN_SEN_CROSS
         || signal.getSenkouCrossSignal() == WEAK_BUY_SENKOU_SPAN_CROSS  
         || signal.getSenkouCrossSignal() == NEUTRAL_BUY_SENKOU_SPAN_CROSS 
         || signal.getSenkouCrossSignal() == STRONG_BUY_SENKOU_SPAN_CROSS 
         || signal.getKumoBreakSignal() == KUMO_BUY_BREAKOUT)){
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
      
      if((signal.getTenkanKijunCrossSignal() == WEAK_SELL_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT)
            || (signal.getTenkanKijunCrossSignal() == NEUTRAL_SELL_TS_KS_CROSS && signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT)
            || (signal.getTenkanKijunCrossSignal() == STRONG_SELL_TS_KS_CROSS)){
         shortTrend = true;
         return true;
      }
      //else if(shortTrend)
         //shortTrend = false;
   }
   
   if(strategyMode == ROOKIE_MODE){
      if (signal.getTenkanKijunCrossSignal() == WEAK_SELL_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == NEUTRAL_SELL_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == STRONG_SELL_TS_KS_CROSS
         || signal.getKijunCrossSignal() == WEAK_SELL_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == NEUTRAL_SELL_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == STRONG_SELL_KIJUN_SEN_CROSS
         || signal.getSenkouCrossSignal() == WEAK_SELL_SENKOU_SPAN_CROSS  
         || signal.getSenkouCrossSignal() == NEUTRAL_SELL_SENKOU_SPAN_CROSS 
         || signal.getSenkouCrossSignal() == STRONG_SELL_SENKOU_SPAN_CROSS 
         || signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT){
            shortTrend = true;
         return true;
       }
   }
   
   return(false);
}


//+------------------------------------------------------------------+
//|exit long orders                                                  |
//+------------------------------------------------------------------+
bool IchimokuStrategy::exitLong(void){
      /*
      if ((longTrend)
         && (signal.getTenkanKijunCrossSignal() == WEAK_SELL_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == NEUTRAL_SELL_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == STRONG_SELL_TS_KS_CROSS
         || signal.getKijunCrossSignal() == WEAK_SELL_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == NEUTRAL_SELL_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == STRONG_SELL_KIJUN_SEN_CROSS
         || signal.getSenkouCrossSignal() == WEAK_SELL_SENKOU_SPAN_CROSS  
         || signal.getSenkouCrossSignal() == NEUTRAL_SELL_SENKOU_SPAN_CROSS 
         || signal.getSenkouCrossSignal() == STRONG_SELL_SENKOU_SPAN_CROSS 
         || signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT)){
         return true;
      }else 
         return false;
         */
         
         if(signal.getTenkanKijunCrossSignal() == WEAK_SELL_TS_KS_CROSS && lastExitLong != WEAK_SELL_TS_KS_CROSS){
            lastExitLong = WEAK_SELL_TS_KS_CROSS;
            return true; 
         }else if(signal.getTenkanKijunCrossSignal() == NEUTRAL_SELL_TS_KS_CROSS && lastExitLong != NEUTRAL_SELL_TS_KS_CROSS){
            lastExitLong = NEUTRAL_SELL_TS_KS_CROSS;
            return true; 
         }else if(signal.getTenkanKijunCrossSignal() == STRONG_SELL_TS_KS_CROSS && lastExitLong != STRONG_SELL_TS_KS_CROSS){
            lastExitLong = STRONG_SELL_TS_KS_CROSS;
            return true; 
         }else if(signal.getKijunCrossSignal() == WEAK_SELL_KIJUN_SEN_CROSS && lastExitLong != WEAK_SELL_KIJUN_SEN_CROSS){
            lastExitLong = WEAK_SELL_KIJUN_SEN_CROSS;
            return true; 
         }else if(signal.getKijunCrossSignal() == NEUTRAL_SELL_KIJUN_SEN_CROSS && lastExitLong != NEUTRAL_SELL_KIJUN_SEN_CROSS){
            lastExitLong = NEUTRAL_SELL_KIJUN_SEN_CROSS;
            return true; 
         }else if(signal.getKijunCrossSignal() == STRONG_SELL_KIJUN_SEN_CROSS && lastExitLong != STRONG_SELL_KIJUN_SEN_CROSS){
            lastExitLong = STRONG_SELL_KIJUN_SEN_CROSS;
            return true; 
         }else if(signal.getSenkouCrossSignal() == WEAK_SELL_SENKOU_SPAN_CROSS && lastExitLong != WEAK_SELL_SENKOU_SPAN_CROSS){
            lastExitLong = WEAK_SELL_SENKOU_SPAN_CROSS;
            return true; 
         }else if(signal.getSenkouCrossSignal() == NEUTRAL_SELL_SENKOU_SPAN_CROSS && lastExitLong != NEUTRAL_SELL_SENKOU_SPAN_CROSS){
            lastExitLong = NEUTRAL_SELL_SENKOU_SPAN_CROSS;
            return true;
         }else if(signal.getSenkouCrossSignal() == STRONG_SELL_SENKOU_SPAN_CROSS && lastExitLong != STRONG_SELL_SENKOU_SPAN_CROSS){
            lastExitLong = STRONG_SELL_SENKOU_SPAN_CROSS;
            return true; 
         }else if(signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT && lastExitLong != KUMO_SELL_BREAKOUT){
            lastExitLong = KUMO_SELL_BREAKOUT;
            return true; 
         }
         
         return false;
}


//+------------------------------------------------------------------+
//|exit long orders                                                  |
//+------------------------------------------------------------------+
bool IchimokuStrategy::exitShort(void){
     /* if ((shortTrend)
         && (signal.getTenkanKijunCrossSignal() == WEAK_BUY_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == NEUTRAL_BUY_TS_KS_CROSS 
         || signal.getTenkanKijunCrossSignal() == STRONG_BUY_TS_KS_CROSS
         || signal.getKijunCrossSignal() == WEAK_BUY_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == NEUTRAL_BUY_KIJUN_SEN_CROSS 
         || signal.getKijunCrossSignal() == STRONG_BUY_KIJUN_SEN_CROSS
         || signal.getSenkouCrossSignal() == WEAK_BUY_SENKOU_SPAN_CROSS  
         || signal.getSenkouCrossSignal() == NEUTRAL_BUY_SENKOU_SPAN_CROSS 
         || signal.getSenkouCrossSignal() == STRONG_BUY_SENKOU_SPAN_CROSS 
         || signal.getKumoBreakSignal() == KUMO_BUY_BREAKOUT))
        return true;
      else
         return false;*/
         
        if(signal.getTenkanKijunCrossSignal() == WEAK_BUY_TS_KS_CROSS && lastExitShort != WEAK_BUY_TS_KS_CROSS){
            lastExitShort = WEAK_BUY_TS_KS_CROSS;
            return true;
         }else if(signal.getTenkanKijunCrossSignal() == NEUTRAL_BUY_TS_KS_CROSS && lastExitShort != NEUTRAL_BUY_TS_KS_CROSS){
            lastExitShort = NEUTRAL_BUY_TS_KS_CROSS;
            return true;
         }else if(signal.getTenkanKijunCrossSignal() == STRONG_BUY_TS_KS_CROSS && lastExitShort != STRONG_BUY_TS_KS_CROSS){
            lastExitShort = STRONG_BUY_TS_KS_CROSS;
            return true;
         }else if(signal.getKijunCrossSignal() == WEAK_BUY_KIJUN_SEN_CROSS && lastExitShort != WEAK_BUY_KIJUN_SEN_CROSS){
            lastExitShort = WEAK_BUY_KIJUN_SEN_CROSS;
            return true;
         }else if(signal.getKijunCrossSignal() == NEUTRAL_BUY_KIJUN_SEN_CROSS && lastExitShort != NEUTRAL_BUY_KIJUN_SEN_CROSS){
            lastExitShort = NEUTRAL_BUY_KIJUN_SEN_CROSS;
            return true; 
         }else if(signal.getKijunCrossSignal() == STRONG_BUY_KIJUN_SEN_CROSS && lastExitShort != STRONG_BUY_KIJUN_SEN_CROSS){
            lastExitShort = STRONG_BUY_KIJUN_SEN_CROSS;
            return true; 
         }else if(signal.getSenkouCrossSignal() == WEAK_BUY_SENKOU_SPAN_CROSS && lastExitShort != WEAK_BUY_SENKOU_SPAN_CROSS){
            lastExitShort = WEAK_BUY_SENKOU_SPAN_CROSS;
            return true;
         }else if(signal.getSenkouCrossSignal() == NEUTRAL_BUY_SENKOU_SPAN_CROSS && lastExitShort != NEUTRAL_BUY_SENKOU_SPAN_CROSS){
            lastExitShort = NEUTRAL_BUY_SENKOU_SPAN_CROSS;
            return true; 
         }else if(signal.getSenkouCrossSignal() == STRONG_BUY_SENKOU_SPAN_CROSS && lastExitShort != STRONG_BUY_SENKOU_SPAN_CROSS){
            lastExitShort = STRONG_BUY_SENKOU_SPAN_CROSS;
            return true; 
         }else if(signal.getKumoBreakSignal() == KUMO_SELL_BREAKOUT && lastExitShort != KUMO_SELL_BREAKOUT){
            lastExitShort = KUMO_SELL_BREAKOUT;
            return true; 
         }
         
         return false;
}

