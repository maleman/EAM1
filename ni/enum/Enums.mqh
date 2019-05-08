//+------------------------------------------------------------------+
//|                                                        Enums.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


enum MarketTrend{
      NO_TREND,
      NEUTRAL_TREND,
      UPTREND,
      DOWNTREND,
      
      STRONG_UPTREND,
      STRONG_DOWNTREND,
      
      NEUTRAL_UPTREND,
      NEUTRAL_DOWNTREND,
      
      WEAK_UPTREND,
      WEAK_DOWNTREND,
 };
 
enum IchimokuSignals{
      NO_SIGNAL,
      NEUTRAL_SIGNAL,
      
      STRONG_BUY_TS_KS_CROSS,
      STRONG_SELL_TS_KS_CROSS,
      
      NEUTRAL_BUY_TS_KS_CROSS,
      NEUTRAL_SELL_TS_KS_CROSS,
      
      WEAK_BUY_TS_KS_CROSS,
      WEAK_SELL_TS_KS_CROSS,
      
      STRONG_BUY_KIJUN_SEN_CROSS,
      STRONG_SELL_KIJUN_SEN_CROSS,
      
      NEUTRAL_BUY_KIJUN_SEN_CROSS,
      NEUTRAL_SELL_KIJUN_SEN_CROSS,
      
      WEAK_BUY_KIJUN_SEN_CROSS,
      WEAK_SELL_KIJUN_SEN_CROSS,
      
      STRONG_BUY_SENKOU_SPAN_CROSS,
      STRONG_SELL_SENKOU_SPAN_CROSS,
      
      NEUTRAL_BUY_SENKOU_SPAN_CROSS,
      NEUTRAL_SELL_SENKOU_SPAN_CROSS,
      
      WEAK_BUY_SENKOU_SPAN_CROSS,
      WEAK_SELL_SENKOU_SPAN_CROSS,
      
      STRONG_BUY_CHIKOU_SPAN_CROSS,
      STRONG_SELL_CHIKOU_SPAN_CROSS,
            
      NEUTRAL_BUY_CHIKOU_SPAN_CROSS,
      NEUTRAL_SELL_CHIKOU_SPAN_CROSS,
      
      WEAK_BUY_CHIKOU_SPAN_CROSS,
      WEAK_SELL_CHIKOU_SPAN_CROSS,
      
      KUMO_BUY_BREAKOUT,
      KUMO_SELL_BREAKOUT,
   };
   
   enum StrategyMode{
      WISE_MODE,
      SAFE_MODE,
      ROOKIE_MODE,
   };

 string marketTrendToString(MarketTrend trend){
   if(trend == NO_TREND)
      return ("NO TREND");
   else if(trend == UPTREND)
      return ("UPTREND");
   else if(trend == DOWNTREND)
      return ("DOWNTREND");
   else if(trend == STRONG_UPTREND)
      return ("STRONG UPTREND");
   else if(trend == STRONG_DOWNTREND)
      return ("STRONG DOWNTREND");
   else if(trend == NEUTRAL_UPTREND)
      return ("NEUTRAL UPTREND");
   else if(trend == NEUTRAL_UPTREND)
      return ("NEUTRAL DOWTREND");
   else if(trend == WEAK_UPTREND)
      return ("WEAK UPTERND");
   else if(trend == WEAK_DOWNTREND)
      return ("WEAK DOWNTREND");
   else if(trend == NEUTRAL_TREND)
      return ("NEUTRAL TREND");
      
   return ("NEUTRAL TREND");
 }   
 
 
 string ichimokuSignalsToString(IchimokuSignals signal){
      
      //NO_SIGNAL,
      if(signal == NO_SIGNAL)
         return ("NO SIGNAL");
      else if(signal == STRONG_BUY_TS_KS_CROSS)
         return ("STRONG BUY TENKAN/KIJUN CROSS");
      else if(signal == STRONG_SELL_TS_KS_CROSS)
         return ("STRONG SELL TENKAN/KIJUN CROSS");
      else if(signal ==  NEUTRAL_BUY_TS_KS_CROSS)
         return ("NEUTRAL BUY TENKAN/KIJUN CROSS");
      else if(signal == NEUTRAL_SELL_TS_KS_CROSS)
         return ("NEUTRAL SELL TENKAN/KIJUN CROSS");
      else if(signal == WEAK_BUY_TS_KS_CROSS)
         return ("WEAK BUY TENKAN/KIJUN CROSS");
      else if(signal == WEAK_SELL_TS_KS_CROSS)
         return ("WEAK SELL TENKAN/KIJUN CROSS");
      else if(signal == STRONG_BUY_KIJUN_SEN_CROSS)
         return ("STRONG BUY KIJUN CROSS");
      else if(signal == STRONG_SELL_KIJUN_SEN_CROSS)
         return ("STRONG SELL KIJUN CROSS");
      else if(signal == NEUTRAL_BUY_KIJUN_SEN_CROSS)
         return ("NEUTRAL BUY KIJUN CROSS");
      else if(signal == NEUTRAL_SELL_KIJUN_SEN_CROSS)
         return ("NEUTRAL SELL KIJUN CROSS");
      else if(signal == WEAK_BUY_KIJUN_SEN_CROSS)
         return ("WEAK BUY KIJUN CROSS");
      else if(signal == WEAK_SELL_KIJUN_SEN_CROSS)
         return ("WEAK SELL KIJUN CROSS");
      else if(signal == STRONG_BUY_SENKOU_SPAN_CROSS)
         return ("STRONG BUY SENKOU CROSS");
      else if(signal == STRONG_SELL_SENKOU_SPAN_CROSS)
         return ("STRONG SELL SENKOU CROSS");
      else if(signal == NEUTRAL_BUY_SENKOU_SPAN_CROSS)
         return ("NEUTRAL BUY SENKOU CROSS");
      else if(signal == NEUTRAL_SELL_SENKOU_SPAN_CROSS)
         return ("NEUTRAL SELL SENKOU CROSS");
      else if(signal == WEAK_BUY_SENKOU_SPAN_CROSS)
         return ("WEAK BUY SENKOU CROSS");
      else if(signal == WEAK_SELL_SENKOU_SPAN_CROSS)
         return ("WEAK SELL SENKOU CROSS");
      else if(signal == STRONG_BUY_CHIKOU_SPAN_CROSS)
         return ("STRONG BUY CHIKOU CROSS");
      else if(signal == STRONG_SELL_CHIKOU_SPAN_CROSS)
         return ("STRONG SELL CHIKOU CROSS");
      else if(signal == NEUTRAL_BUY_CHIKOU_SPAN_CROSS)
         return ("NEUTRAL BUY CHIKOU CROSS");
      else if(signal == NEUTRAL_SELL_CHIKOU_SPAN_CROSS)
         return ("NEUTRAL SELL CHIKOU CROSS");
      else if(signal == WEAK_BUY_CHIKOU_SPAN_CROSS)
         return ("WEAK BUY CHIKOU CROSS");
      else if(signal == WEAK_SELL_CHIKOU_SPAN_CROSS)
         return ("WEAK SELL CHIKOU CROSS");
      else if(signal == KUMO_BUY_BREAKOUT)
         return ("KUMO BUY BREAKOUT");
      else if(signal == KUMO_SELL_BREAKOUT)
         return ("KUMO SELL BREAKOUT");
      else if(signal == NEUTRAL_SIGNAL)
         return ("NEUTRAL SIGNAL");
         
      return ("NEUTRAL SIGNAL");
 }