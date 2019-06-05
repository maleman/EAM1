//+------------------------------------------------------------------+
//|                                                  IchiSignals.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "..\enum\Enums.mqh";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchiSignals
  {
private:

   double            diff;

   //Tekan kijun
   MarketTrend       tekanKijunTrend;
   MarketTrend       kijunPriceTrend;
   IchimokuSignals   tenkanKijunCrossSignal;
   IchimokuSignals   kijunPriceCrossSignal;

   double            diffConstant;

   bool              changeTrendTK;
   void              tekanKijunCross(double &Tenkan_sen_Buffer[],
                                     double &Kijun_sen_Buffer[],
                                     double Senkou_A,
                                     double Senkou_B);

   void              kijunPriceCross(double open,double close,double kijun,double Senkou_A,double Senkou_B);

   //chikou
   MarketTrend       chikouPriceTrend;
   void              setChikouPriceTrend(double closePrice,double chickou);

   //Kumo
   MarketTrend       kumoPriceTrend;
   MarketTrend       SenkouTrend;
   IchimokuSignals   kumoBreak;
   bool              iskTrendPriceChange;
   void              setKumoPriceTrend(double close,double Senkou_A,double Senkou_B);
   void              setSenkouTrend(double &senkou_A[],double &senkou_b[]);
   bool              flatBottomKumo;

public:
                     IchiSignals();
                    ~IchiSignals();

   void              toInfo();
   void              search(double &Tenkan_sen_Buffer[],
                            double &Kijun_sen_Buffer[],
                            double &Senkou_Span_A_Buffer[],
                            double &Senkou_Span_B_Buffer[],
                            double &Chinkou_Span_Buffer[],
                            MqlRates &rates[]);

   MarketTrend       getSenkouTrend(){return SenkouTrend;}
   MarketTrend       getkumoPriceTrend(){return kumoPriceTrend;}

   IchimokuSignals   getTkc(){return tenkanKijunCrossSignal;}
   IchimokuSignals   getkPc(){return kijunPriceCrossSignal;}
   IchimokuSignals   getKB(){return kumoBreak;}

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::IchiSignals()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::~IchiSignals()
  {
  }
//+------------------------------------------------------------------+

//Trend Signs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::setChikouPriceTrend(double closePrice,double chickou)
  {

   diff=chickou-closePrice;
//MarketTrend       trend=tekanKijunTrend;

   if(diff>diffConstant)
      tekanKijunTrend=UPTREND;
   else
   if(diff<=-diffConstant)
            tekanKijunTrend=DOWNTREND;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::setSenkouTrend(double &Senkou_Span_A_Buffer[],double &Senkou_Span_B_Buffer[])
  {

   int sz=ArraySize(Senkou_Span_A_Buffer)-1;
   double senkou_a = Senkou_Span_A_Buffer[sz];
   double senkou_b = Senkou_Span_B_Buffer[sz];


   diff=senkou_a-senkou_b;
   MarketTrend trend=SenkouTrend;

   if(diff>diffConstant)
     {
      trend=UPTREND;
      if(Senkou_Span_A_Buffer[sz]==Senkou_Span_A_Buffer[sz-1]
         && Senkou_Span_A_Buffer[sz-1] == Senkou_Span_A_Buffer[sz-2]
         && Senkou_Span_A_Buffer[sz-2] == Senkou_Span_A_Buffer[sz-3]
         && Senkou_Span_A_Buffer[sz-4] == Senkou_Span_A_Buffer[sz-4])
         flatBottomKumo=true;
      else
         flatBottomKumo=false;
     }
   else if(diff<-diffConstant)
     {
      trend=DOWNTREND;
      if(Senkou_Span_B_Buffer[sz]==Senkou_Span_B_Buffer[sz-1]
         && Senkou_Span_B_Buffer[sz-1] == Senkou_Span_B_Buffer[sz-2]
         && Senkou_Span_B_Buffer[sz-2] == Senkou_Span_B_Buffer[sz-3]
         && Senkou_Span_B_Buffer[sz-4] == Senkou_Span_B_Buffer[sz-4])
         flatBottomKumo=true;
      else
         flatBottomKumo=false;
     }

   if(trend!=SenkouTrend)
      SenkouTrend=trend;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::setKumoPriceTrend(double close,double Senkou_A,double Senkou_B)
  {
   MarketTrend trend=kumoPriceTrend;

   if(close>Senkou_A && close>Senkou_B)
      trend=UPTREND;
   else if(close<Senkou_A && close<Senkou_B)
      trend=DOWNTREND;

   if(trend!=kumoPriceTrend)
     {
      //CARGA INICIAL
      if(kumoPriceTrend==NO_TREND && trend!=NO_TREND)
        {
         kumoPriceTrend=trend;
         return;
        }

      if(kumoPriceTrend==DOWNTREND
         && trend==UPTREND
         && !flatBottomKumo
         //&& SenkouTrend==UPTREND
         )
        {
         kumoBreak=KUMO_BUY_BREAKOUT;
         kumoPriceTrend=trend;

        }
      if(kumoPriceTrend==UPTREND
         && trend==DOWNTREND
         && !flatBottomKumo
         //&& SenkouTrend==DOWNTREND
         )
        {
         kumoBreak=KUMO_SELL_BREAKOUT;
         kumoPriceTrend=trend;
        }

     }

  }
//Cross Signs
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::tekanKijunCross(double &Tenkan_sen_Buffer[],
                             double &Kijun_sen_Buffer[],
                             double Senkou_A,
                             double Senkou_B)
  {

   double tekan = Tenkan_sen_Buffer[ArraySize(Tenkan_sen_Buffer)-1];
   double kijun = Kijun_sen_Buffer[ArraySize(Kijun_sen_Buffer)-1];

   diff=tekan-kijun;

   MarketTrend       trend=tekanKijunTrend;

   if(diff>diffConstant)
     {
      trend=UPTREND;
     }
   else if(diff<=-diffConstant)
     {
      trend=DOWNTREND;
     }

//Si hay cambio de tendencia
   if(tekanKijunTrend!=trend)
     {
      if(trend==UPTREND && tekanKijunTrend==DOWNTREND)
        {
         //KUMO OVER
         if(tekan>Senkou_A && tekan>Senkou_B
            && kijun>Senkou_A && kijun>Senkou_B)
            tenkanKijunCrossSignal=STRONG_BUY_TS_KS_CROSS;

         //INTO KUMO   
         if((tekan<Senkou_A && kijun<Senkou_A && tekan>Senkou_B && kijun>Senkou_B)
            || (tekan>Senkou_A && kijun>Senkou_A && tekan<Senkou_B && kijun<Senkou_B))
            tenkanKijunCrossSignal=NEUTRAL_BUY_TS_KS_CROSS;

         //KUMO BELOW
         if(tekan<Senkou_A && kijun<Senkou_A
            && tekan<Senkou_B && kijun<Senkou_B)
            tenkanKijunCrossSignal=WEAK_BUY_TS_KS_CROSS;

         tekanKijunTrend=trend;
         changeTrendTK=true;
        }
      else if(trend==DOWNTREND && tekanKijunTrend==UPTREND)
        {
         if(tekan<Senkou_A && kijun<Senkou_B) //KUMO OVER
            tenkanKijunCrossSignal=STRONG_SELL_TS_KS_CROSS;

         //INTO KUMO   
         if((tekan<Senkou_A && kijun<Senkou_A && tekan>Senkou_B && kijun>Senkou_B)
            || (tekan>Senkou_A && kijun>Senkou_A && tekan<Senkou_B && kijun<Senkou_B))
            tenkanKijunCrossSignal=NEUTRAL_SELL_TS_KS_CROSS;

         //KUMO OVER
         if(tekan>Senkou_A && kijun>Senkou_A
            && tekan>Senkou_B && kijun>Senkou_B)
            tenkanKijunCrossSignal=WEAK_SELL_TS_KS_CROSS;
        }
      tekanKijunTrend=trend;
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::kijunPriceCross(double open,double close,double kijun,double Senkou_A,double Senkou_B)
  {

//IchimokuSignals sig=kijunPriceCrossSignal;
   MarketTrend trend=kijunPriceTrend;

   diff=close-kijun;

   if(diff>diffConstant)
      trend=UPTREND;
   if(diff<=-diffConstant)
      trend=DOWNTREND;

   if(kijunPriceTrend!=trend)
     {
      if(kijunPriceTrend==UPTREND && trend==DOWNTREND)
        {

         if(kijun<Senkou_A && kijun<Senkou_B)
            kijunPriceCrossSignal=STRONG_SELL_KIJUN_SEN_CROSS;
         else if(kijun>Senkou_A && kijun>Senkou_B)
            kijunPriceCrossSignal=WEAK_SELL_KIJUN_SEN_CROSS;
         else if((kijun<=Senkou_A && kijun>Senkou_B)
            || (kijun>Senkou_A && kijun<=Senkou_B))
            kijunPriceCrossSignal=NEUTRAL_SELL_KIJUN_SEN_CROSS;

        }
      else if(kijunPriceTrend==DOWNTREND && trend==UPTREND)
        {
         if(kijun>Senkou_A && kijun>Senkou_B)
            kijunPriceCrossSignal=STRONG_BUY_KIJUN_SEN_CROSS;
         else if(kijun<Senkou_A && kijun<Senkou_B)
            kijunPriceCrossSignal=WEAK_BUY_KIJUN_SEN_CROSS;
         else if((kijun<=Senkou_A && kijun>Senkou_B)
            || (kijun>Senkou_A && kijun<=Senkou_B))
            kijunPriceCrossSignal=NEUTRAL_BUY_KIJUN_SEN_CROSS;
        }

      kijunPriceTrend=trend;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::search(double &Tenkan_sen_Buffer[],
                    double &Kijun_sen_Buffer[],
                    double &Senkou_Span_A_Buffer[],
                    double &Senkou_Span_B_Buffer[],
                    double &Chinkou_Span_Buffer[],
                    MqlRates &rates[])
  {

   diffConstant=0.0010;

   int tekanSize = ArraySize(Tenkan_sen_Buffer)-1;
   int kijunSize = ArraySize(Kijun_sen_Buffer)-1;
   int senkouSize=ArraySize(Senkou_Span_A_Buffer)-1;
   int chinkouSize=ArraySize(Chinkou_Span_Buffer)-1;
   int rateSize=ArraySize(rates)-1;

   setSenkouTrend(Senkou_Span_A_Buffer,Senkou_Span_B_Buffer);

   setKumoPriceTrend(rates[rateSize].close
                     ,Senkou_Span_A_Buffer[tekanSize+1]
                     ,Senkou_Span_B_Buffer[tekanSize+1]);

   setChikouPriceTrend(rates[rateSize].close,Chinkou_Span_Buffer[chinkouSize]);

   tekanKijunCross(Tenkan_sen_Buffer
                   ,Kijun_sen_Buffer
                   ,Senkou_Span_A_Buffer[tekanSize+1]
                   ,Senkou_Span_B_Buffer[tekanSize+1]);

   kijunPriceCross(rates[rateSize].open
                   ,rates[rateSize].close
                   ,Kijun_sen_Buffer[kijunSize]
                   ,Senkou_Span_A_Buffer[tekanSize+1]
                   ,Senkou_Span_B_Buffer[tekanSize+1]);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void IchiSignals::toInfo()
  {
  
  

   Comment("Senales de Indicador Ichimoku","\n"
           //"Diferencia Tekan/Kijun            : ",diff,"\n",
          // "  LAST SIGNAL : ",ichimokuSignalsToString(kijunPriceCrossSignal),
           ", SENKOU TREND : ",marketTrendToString(SenkouTrend),"\n"
           ", PRICE  TREND : ",marketTrendToString(kumoPriceTrend),"\n"
           ", FLAT BOTTOM : ",(flatBottomKumo)?" SI ":" NO ","\n");
  }
//+------------------------------------------------------------------+
