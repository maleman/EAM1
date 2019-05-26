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
   void              setSenkouTrend(double senkou_A,double senkou_b);

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
IchiSignals::setChikouPriceTrend(double closePrice,double chickou)
  {

   diff=chickou-closePrice;
//MarketTrend       trend=tekanKijunTrend;

   if(diff>0.0010)
      tekanKijunTrend=UPTREND;
   else
   if(diff<=-0.0010)
            tekanKijunTrend=DOWNTREND;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::setSenkouTrend(double senkou_A,double senkou_b)
  {
   diff=senkou_A-senkou_b;
   MarketTrend trend=SenkouTrend;

   if(diff>0.0010)
     {
      trend=UPTREND;
     }
   else if(diff<=-0.0010)
     {
      trend=DOWNTREND;
     }

   if(trend!=SenkouTrend)
      SenkouTrend=trend;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::setKumoPriceTrend(double close,double Senkou_A,double Senkou_B)
  {
   MarketTrend trend=kumoPriceTrend;

   if(close>Senkou_A && close>Senkou_B)
      trend=UPTREND;
   else if(close<Senkou_A && close<Senkou_B)
      trend=DOWNTREND;
//else
//   trend=NEUTRAL_TREND;



   if(trend!=kumoPriceTrend)
     {
      //CARGA INICIAL
      if(kumoPriceTrend==NO_TREND && trend!=NO_TREND)
        {
         kumoPriceTrend=trend;
         return;
        }

      if(kumoPriceTrend==DOWNTREND && trend==UPTREND && SenkouTrend==UPTREND)
        {
         kumoBreak=KUMO_BUY_BREAKOUT;
         kumoPriceTrend=trend;

        }
      if(kumoPriceTrend==UPTREND && trend==DOWNTREND && SenkouTrend==DOWNTREND)
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
IchiSignals::tekanKijunCross(double &Tenkan_sen_Buffer[],
                             double &Kijun_sen_Buffer[],
                             double Senkou_A,
                             double Senkou_B)
  {

   double tekan = Tenkan_sen_Buffer[ArraySize(Tenkan_sen_Buffer)-1];
   double kijun = Kijun_sen_Buffer[ArraySize(Kijun_sen_Buffer)-1];

   diff=tekan-kijun;

   MarketTrend       trend=tekanKijunTrend;

   if(diff>0.0010)
     {
      trend=UPTREND;
     }
   else if(diff<=-0.0010)
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
IchiSignals::kijunPriceCross(double open,double close,double kijun,double Senkou_A,double Senkou_B)
  {

//IchimokuSignals sig=kijunPriceCrossSignal;
   MarketTrend trend=kijunPriceTrend;

   diff=close-kijun;

   if(diff>0.0010)
      trend=UPTREND;
   if(diff<=-0.0010)
      trend=DOWNTREND;

   if(kijunPriceTrend!=trend)
     {
      if(kijunPriceTrend==UPTREND && trend==DOWNTREND)
        {

         if(kijun>Senkou_A && kijun>Senkou_B)
            kijunPriceCrossSignal=STRONG_SELL_KIJUN_SEN_CROSS;
         else if(kijun<Senkou_A && kijun<Senkou_B)
            kijunPriceCrossSignal=WEAK_SELL_KIJUN_SEN_CROSS;
         else
            kijunPriceCrossSignal=NEUTRAL_SELL_KIJUN_SEN_CROSS;

        }
      else if(kijunPriceTrend==DOWNTREND && trend==UPTREND)
        {
         if(kijun>Senkou_A && kijun>Senkou_B)
            kijunPriceCrossSignal=STRONG_BUY_KIJUN_SEN_CROSS;
         else if(kijun<Senkou_A && kijun<Senkou_B)
            kijunPriceCrossSignal=WEAK_BUY_KIJUN_SEN_CROSS;
         else
            kijunPriceCrossSignal=NEUTRAL_BUY_KIJUN_SEN_CROSS;
        }

      //if(kijunPriceCrossSignal!=sig)
      //   kijunPriceCrossSignal=sig;

      kijunPriceTrend=trend;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::search(double &Tenkan_sen_Buffer[],
                    double &Kijun_sen_Buffer[],
                    double &Senkou_Span_A_Buffer[],
                    double &Senkou_Span_B_Buffer[],
                    double &Chinkou_Span_Buffer[],
                    MqlRates &rates[])
  {

   int tekanSize = ArraySize(Tenkan_sen_Buffer)-1;
   int kijunSize = ArraySize(Kijun_sen_Buffer)-1;
   int senkouSize=ArraySize(Senkou_Span_A_Buffer)-1;
   int chinkouSize=ArraySize(Chinkou_Span_Buffer)-1;
   int rateSize=ArraySize(rates)-1;

   setSenkouTrend(Senkou_Span_A_Buffer[senkouSize],Senkou_Span_B_Buffer[senkouSize]);

   setKumoPriceTrend(rates[rateSize].close
                     ,Senkou_Span_A_Buffer[tekanSize+1]
                     ,Senkou_Span_B_Buffer[tekanSize+1]);

   setChikouPriceTrend(rates[rateSize].close,Chinkou_Span_Buffer[chinkouSize]);

   tekanKijunCross(Tenkan_sen_Buffer
                   ,Kijun_sen_Buffer
                   ,Senkou_Span_A_Buffer[senkouSize]
                   ,Senkou_Span_B_Buffer[senkouSize]);

   kijunPriceCross(rates[rateSize].open
                   ,rates[rateSize].close
                   ,Kijun_sen_Buffer[kijunSize]
                   ,Senkou_Span_A_Buffer[senkouSize]
                   ,Senkou_Span_B_Buffer[senkouSize]);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiSignals::toInfo()
  {

   Comment("Senales de Indicador Ichimoku","\n"
           //"Diferencia Tekan/Kijun            : ",diff,"\n",
           //"KINJUN/PRICE CROSS SIGNAL : ",ichimokuSignalsToString(kijunPriceCrossSignal),
           ", SENKOU TREND : ",marketTrendToString(SenkouTrend),"\n");
  }
//+------------------------------------------------------------------+
