//+------------------------------------------------------------------+
//|                                               IchimukuSignal.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\enum\Enums.mqh"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchimukuSignal
  {
private:

public:
   IchimukuSignal();
   ~IchimukuSignal();

   void search(double &Tenkan_sen_Buffer[],
                      double &Kijun_sen_Buffer[],
                      double &Senkou_Span_A_Buffer[],
                      double &Senkou_Span_B_Buffer[],
                      double &Chinkou_Span_Buffer[],
                      MqlRates &rates[]);
                      
   void toInfo();
 
protected:

   bool findTrend(double &Chinkou_Span_Buffer[]); 
   bool findNewSignal();
   bool registerSignal();
   
   void getTenkanSenKijunSenTrend(double &Tekan[],double &Kijun[],double &Senkou_A[],double &Senkou_B[]);
   void getKumoTrend(double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]);
   void getChinkouTrend(double &Chinkou[]);
   void getClosePriceTrend(double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]);
                             
   void kijunSenCross(double &Kijun[],double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]);                     
   void kumoBreak(double &Senkou_A[],double &Senkou_B[],MqlRates &rates[]);
   
   MarketTrend actualTrend;
   MarketTrend chinkouTrend;
   MarketTrend kumoTrend;
   MarketTrend closePriceTrend;
   MarketTrend TekanKijunTrend;
   
   IchimokuSignals signal;
   IchimokuSignals tenkanKijunCrossSignal;
   IchimokuSignals kijunCrossSignal;
   IchimokuSignals kumoBreakSignal;
   IchimokuSignals senkouCrossSignal;
   
   int IchimokuSignalcount;
   //IchimokuSignalsLog signals_logs[];
   IchimokuSignals signals_logs[];
   
                     
  };
  
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::IchimukuSignal()
  {
    actualTrend = NO_TREND;
    chinkouTrend = NO_TREND;
    TekanKijunTrend = NO_TREND;
    kumoTrend = NO_TREND;
    closePriceTrend = NO_TREND;
    
    signal = NO_SIGNAL;
    tenkanKijunCrossSignal = NO_SIGNAL;
    kijunCrossSignal = NO_SIGNAL;
    kumoBreakSignal = NO_SIGNAL;
    
    
    IchimokuSignalcount = 0;
  
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::~IchimukuSignal(){}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::search(double &Tenkan[],
                      double &Kijun[],
                      double &SenkouA[],
                      double &SenkouB[],
                      double &Chinkou[],
                      MqlRates &rates[]){
   
   getTenkanSenKijunSenTrend(Tenkan,Kijun,SenkouA,SenkouB);
   
   getChinkouTrend(Chinkou);
   
   getKumoTrend(SenkouA,SenkouB,rates);    
   
   getClosePriceTrend(SenkouA,SenkouB,rates);  
   
   kijunSenCross(Kijun,SenkouA,SenkouB,rates);     
   
   kumoBreak(SenkouA,SenkouB,rates);         
                      
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::getChinkouTrend(double &Chinkou[]){
   double lastValue = Chinkou[0];
   double compareValue = Chinkou[26];
   
   if(lastValue == compareValue)
      chinkouTrend = NO_TREND;
    
    if(lastValue > compareValue)
       chinkouTrend = UPTREND;
     
    if(lastValue < compareValue )
      chinkouTrend = DOWNTREND;   
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::getTenkanSenKijunSenTrend(double &Tenkan[],double &Kijun[],double &Senkou_A[],double &Senkou_B[]){
   int tenkan = ArraySize(Tenkan);
   int senkou = ArraySize(Senkou_A)-1;
   IchimokuSignals sig = NO_SIGNAL;
   
   MarketTrend ActualTekanKijunTrend = NO_TREND; 
   //IchimokuSignals actualSignal = NO_SIGNAL;                             
                                 
   if((Tenkan[tenkan-1] - Kijun[tenkan-1])> 0){
      ActualTekanKijunTrend =  UPTREND;
     // printf("Tekan_Kinjun_UpTrend [%d >= %d] ",Tenkan_sen_Buffer[Tenkan-1], Tenkan_sen_Buffer[Tenkan-1]);
    }else{
      ActualTekanKijunTrend = DOWNTREND;
      //printf("Tekan_Kinjun_DownTrend [%d < %d] ",Tenkan_sen_Buffer[Tenkan-1], Tenkan_sen_Buffer[Tenkan-1]);                               
    }
    
   if(TekanKijunTrend == NO_TREND){
      TekanKijunTrend = ActualTekanKijunTrend;
      return;
    }
   
   // tenkanKijunCross(ActualTekanKijunTrend);
   //IDENTIFICANDO CRUZ

   if(TekanKijunTrend != NO_TREND && TekanKijunTrend != ActualTekanKijunTrend){
      //printf("TEKAN KIJUN CROSS DONE");
      
      if(ActualTekanKijunTrend == UPTREND && TekanKijunTrend == DOWNTREND){ //CRUZ ALCISTA
        
         //KUMO OVER
         if(Tenkan[tenkan-1] > Senkou_A[senkou] && Kijun[tenkan-1] > Senkou_B[senkou])  //KUMO OVER
            sig = STRONG_BUY_TS_KS_CROSS;
         
         //INTO KUMO   
         if(((Tenkan[tenkan-1] < Senkou_A[senkou] && Kijun[tenkan-1] < Senkou_A[senkou]) && (Tenkan[tenkan-1] > Senkou_B[senkou] && Kijun[tenkan-1] > Senkou_B[senkou]))
             ||((Tenkan[tenkan-1] > Senkou_A[senkou] && Kijun[tenkan-1] > Senkou_A[senkou]) && (Tenkan[tenkan-1] < Senkou_B[senkou] && Kijun[tenkan-1] < Senkou_B[senkou])))
             sig = NEUTRAL_BUY_TS_KS_CROSS;
             
         //KUMO BELOW
         if(Tenkan[tenkan-1] < Senkou_A[senkou] && Kijun[tenkan-1] < Senkou_B[senkou])  //KUMO OVER
            sig = WEAK_BUY_TS_KS_CROSS;
       
      }else if(ActualTekanKijunTrend == DOWNTREND && TekanKijunTrend == UPTREND){ //DOWN CROSS
         
         //KUMO BELOW
         if(Tenkan[tenkan-1] < Senkou_A[senkou] && Kijun[tenkan-1] < Senkou_B[senkou])  //KUMO OVER
            sig = STRONG_SELL_TS_KS_CROSS;
            
         //INTO KUMO   
         if(((Tenkan[tenkan-1] < Senkou_A[senkou] && Kijun[tenkan-1] < Senkou_A[senkou]) && (Tenkan[tenkan-1] > Senkou_B[senkou] && Kijun[tenkan-1] > Senkou_B[senkou]))
             ||((Tenkan[tenkan-1] > Senkou_A[senkou] && Kijun[tenkan-1] > Senkou_A[senkou]) && (Tenkan[tenkan-1] < Senkou_B[senkou] && Kijun[tenkan-1] < Senkou_B[senkou])))
             sig = NEUTRAL_SELL_TS_KS_CROSS;
             
         //KUMO OVER
         if(Tenkan[tenkan-1] > Senkou_A[senkou] && Kijun[tenkan-1] > Senkou_B[senkou])  //KUMO OVER
            sig = WEAK_SELL_TS_KS_CROSS;
   
      }
        //setting new trend
        TekanKijunTrend = ActualTekanKijunTrend;
   }
   
   if(tenkanKijunCrossSignal != sig)
      tenkanKijunCrossSignal = sig;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::getKumoTrend(double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]){
   
   int Kijun = ArraySize(Senkou_A)-1;
   int rateSize = ArraySize(rates)-1;
   
   MarketTrend ActualKumoTrend = NO_TREND;    
   IchimokuSignals sig = NO_SIGNAL;                          
                                 
   if((Senkou_A[Kijun] > Senkou_B[Kijun]))
      ActualKumoTrend =  UPTREND;
    else
      ActualKumoTrend = DOWNTREND;
      
      
      
      if(kumoTrend == NO_TREND){
         kumoTrend = ActualKumoTrend;
         return;
      }else if(kumoTrend != ActualKumoTrend){
         if(rates[rateSize].close > Senkou_A[Kijun] && rates[rateSize].close < Senkou_B[Kijun] 
               && ActualKumoTrend == UPTREND && kumoTrend == DOWNTREND)
               sig = STRONG_BUY_SENKOU_SPAN_CROSS;
         else if(rates[rateSize].close < Senkou_A[Kijun] && rates[rateSize].close < Senkou_B[Kijun] 
                  && ActualKumoTrend == UPTREND && kumoTrend == DOWNTREND) 
               sig = WEAK_BUY_SENKOU_SPAN_CROSS;
         else if(rates[rateSize].close < Senkou_A[Kijun] && rates[rateSize].close < Senkou_B[Kijun] 
                  && ActualKumoTrend == DOWNTREND && kumoTrend == UPTREND) 
               sig = STRONG_SELL_SENKOU_SPAN_CROSS;
         else if(rates[rateSize].close > Senkou_A[Kijun] && rates[rateSize].close > Senkou_B[Kijun] 
                  && ActualKumoTrend == DOWNTREND && kumoTrend == UPTREND)
               sig = WEAK_SELL_SENKOU_SPAN_CROSS;
         else if(((rates[rateSize].close < Senkou_A[Kijun] && rates[rateSize].close > Senkou_B[Kijun] )
                  ||(rates[rateSize].close > Senkou_A[Kijun] && rates[rateSize].close < Senkou_B[Kijun]))
                  && ActualKumoTrend == DOWNTREND && kumoTrend == UPTREND)
                  sig = NEUTRAL_SELL_SENKOU_SPAN_CROSS;
         else if(((rates[rateSize].close < Senkou_A[Kijun] && rates[rateSize].close > Senkou_B[Kijun] )
                  ||(rates[rateSize].close > Senkou_A[Kijun] && rates[rateSize].close < Senkou_B[Kijun]))
                  && ActualKumoTrend == UPTREND && kumoTrend == DOWNTREND)
                  sig = NEUTRAL_BUY_SENKOU_SPAN_CROSS;
         
         kumoTrend = ActualKumoTrend;
         
         if(senkouCrossSignal != sig)
           senkouCrossSignal = sig;
      }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::getClosePriceTrend(double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]){
   
   int size = ArraySize(Senkou_A)-1;
   int ratesize = ArraySize(rates)-1;
   MarketTrend ActualClosePriceTrend = NO_TREND;   
   
   if((rates[ratesize].close < Senkou_A[size] && rates[ratesize].close > Senkou_B[size])
         || (rates[ratesize].close > Senkou_A[size] && rates[ratesize].close < Senkou_B[size]))
            ActualClosePriceTrend = NEUTRAL_TREND;
   
   
   if ((rates[ratesize].close > Senkou_A[size]) && (rates[ratesize].close > Senkou_B[size])){
      if ((rates[ratesize-1].close > Senkou_A[size-1]) && (rates[ratesize-1].close > Senkou_B[size-1])){
         if ((rates[ratesize-2].close > Senkou_A[size-2]) && (rates[ratesize-2].close > Senkou_B[size-2]))
            ActualClosePriceTrend = STRONG_UPTREND;
         else
            ActualClosePriceTrend = NEUTRAL_UPTREND;
      }else
         ActualClosePriceTrend = WEAK_UPTREND;
   }
      
   if ((rates[ratesize].close < Senkou_A[size]) && (rates[ratesize].close < Senkou_B[size])){
      if ((rates[ratesize-1].close < Senkou_A[size-1]) && (rates[ratesize-1].close < Senkou_B[size-1])){
         if ((rates[ratesize-2].close < Senkou_A[size-2]) && (rates[ratesize-2].close < Senkou_B[size-2]))
            ActualClosePriceTrend = STRONG_DOWNTREND;
         else
            ActualClosePriceTrend = NEUTRAL_DOWNTREND;
      }else
         ActualClosePriceTrend = WEAK_DOWNTREND;
   }
      
   
   //printf("CLOSE(0) : %G | CLOSE(26) : %G ", rates[0].close, rates[size+1].close);
   if(closePriceTrend != ActualClosePriceTrend){
      printf("SE REALIZO UN CAMBIO DE TENDENCIA CON RESPECTO AL PRECIO DE CIERRE Y EL KUMO");
      closePriceTrend = ActualClosePriceTrend;
   }
}



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::kijunSenCross(double &Kijun[],double &Senkou_A[],double &Senkou_B[], MqlRates &rates[]){
   int kijun   = ArraySize(Kijun)-1;
   int senkou  = ArraySize(Senkou_A)-1;
   int ratesize = ArraySize(rates)-1;
   
   IchimokuSignals sig = NO_SIGNAL;
   
   
   if(rates[ratesize].close > Senkou_A[senkou] && Kijun[kijun] > Senkou_A[senkou] 
      &&  rates[ratesize].close > Senkou_B[senkou] && Kijun[kijun] > Senkou_B[senkou]){//KUMO OVER
          
          //UPTREND CROSS
         if(rates[ratesize].open < Kijun[kijun] && rates[ratesize].close > Kijun[kijun])
            sig = STRONG_BUY_KIJUN_SEN_CROSS;
         else if(rates[ratesize].open > Kijun[kijun] && rates[ratesize].close < Kijun[kijun])
             sig = WEAK_SELL_KIJUN_SEN_CROSS;
             
   }else if(rates[ratesize].close < Senkou_A[senkou] && Kijun[kijun] < Senkou_A[senkou] 
      &&  rates[ratesize].close < Senkou_B[senkou] && Kijun[kijun] < Senkou_B[senkou]){ //KUMO BELOw
         
         //UPTREND CROSS
         if(rates[ratesize].open < Kijun[kijun] && rates[ratesize].close > Kijun[kijun])
            sig = WEAK_BUY_KIJUN_SEN_CROSS;
         else if(rates[ratesize].open > Kijun[kijun] && rates[ratesize].close < Kijun[kijun])
             sig = STRONG_SELL_KIJUN_SEN_CROSS;
             
   }else if(   (rates[ratesize].close < Senkou_A[senkou] && rates[ratesize].close > Senkou_B[senkou] 
                  && Kijun[kijun] < Senkou_A[senkou] && Kijun[kijun] > Senkou_B[senkou])
              ||(rates[ratesize].close > Senkou_A[senkou] && rates[ratesize].close < Senkou_B[senkou] 
               && Kijun[kijun] > Senkou_A[senkou] && Kijun[kijun] < Senkou_B[senkou]) ){     //BETWEEN KUMO
                  
                   if(rates[ratesize].open < Kijun[kijun] && rates[ratesize].close > Kijun[kijun])
                     sig = NEUTRAL_BUY_KIJUN_SEN_CROSS;
                  else if(rates[ratesize].open > Kijun[kijun] && rates[ratesize].close < Kijun[kijun])
                     sig = NEUTRAL_SELL_KIJUN_SEN_CROSS;
   }
   //else
   //kijunCrossSignal = NO_SIGNAL;
   
   if(kijunCrossSignal != sig)
      kijunCrossSignal = sig;    
                              
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::kumoBreak(double &Senkou_A[],double &Senkou_B[],MqlRates &rates[]){

   int senkou  = ArraySize(Senkou_A)-1;
   int rateSize = ArraySize(rates)-1;
   IchimokuSignals sig = NO_SIGNAL;
   
   if((rates[rateSize-2].open < Senkou_A[senkou-2] && rates[rateSize-2].open > Senkou_B[senkou-2]) 
      || (rates[rateSize-2].open > Senkou_A[senkou-2] && rates[rateSize-2].open < Senkou_B[senkou-2])){ //IF 3 LAST BARS EXISTS OPEN PRICE INSIDE OF KUMO
      
         if(rates[rateSize-2].close > Senkou_A[senkou-2] && rates[rateSize-2].close > Senkou_B[senkou-2]
            && rates[rateSize-1].close > Senkou_A[senkou-1] && rates[rateSize-1].close > Senkou_B[senkou-1]
            && rates[rateSize].close > Senkou_A[senkou] && rates[rateSize].close > Senkou_B[senkou])//KUMO BUY BREAK OUT
               sig = KUMO_BUY_BREAKOUT;
          else if(rates[rateSize-2].close < Senkou_A[senkou-2] && rates[rateSize-2].close < Senkou_B[senkou-2]
            && rates[rateSize-1].close < Senkou_A[senkou-1] && rates[rateSize-1].close < Senkou_B[senkou-1]
            && rates[rateSize].close < Senkou_A[senkou] && rates[rateSize].close < Senkou_B[senkou])     
               sig = KUMO_SELL_BREAKOUT; 
      
      }
      
      if(kumoBreakSignal != sig)
         kumoBreakSignal = sig;

}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimukuSignal::toInfo(){

   Comment("Senales de Indicador Ichimoku" ,"\n"
            "Tendencia Chikou(26)            : ",marketTrendToString(chinkouTrend),"\n",
            "Tendencia Tekan <> Kijun        : ",marketTrendToString(TekanKijunTrend),"\n",
            "Tendencia Kumo                  : ",marketTrendToString(kumoTrend),"\n",
            "Tendencia Precio de cierre Kumo : ",marketTrendToString(closePriceTrend),"\n",
            "TENKAN/KINJUN CROSS SIGNAL      : ",ichimokuSignalsToString(tenkanKijunCrossSignal),"\n",
            "KINJUN CROSS SIGNAL             : ",ichimokuSignalsToString(kijunCrossSignal),"\n",
            "KUMO BREAK SIGNAL               : ",ichimokuSignalsToString(kumoBreakSignal),"\n",
            "SENKOU CROSS SIGNAL             : ",ichimokuSignalsToString(senkouCrossSignal),"\n" );
}