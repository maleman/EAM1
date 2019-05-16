//+------------------------------------------------------------------+
//|                                                     Ichimoku.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Indicator.mqh"
#include "..\enum\Enums.mqh"
#include "..\dataset\signal\IchiDataSet.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class Ichimoku : public Indicator
  {
private:
   // Main input parameters
   int               Tenkan; // Tenkan line period. The fast "moving average".
   int               Kijun; // Kijun line period. The slow "moving average".
   int               Senkou; // Senkou period. Used for Kumo (Cloud) spans.

   MqlRates          rates[];
   double            tenkanSenBuffer[];
   double            kijunSenBuffer[];
   double            senkouSpanABuffer[];
   double            senkouSpanBBuffer[];
   double            chinkouSpanBuffer[];

   //MarketTrend actualTrend;
   MarketTrend       chinkouTrend;
   MarketTrend       kumoTrend;
   MarketTrend       closePriceTrend;
   MarketTrend       TekanKijunTrend;

   //IchimokuSignals   signals[];

   string            symbol;
   ENUM_TIMEFRAMES   period;

protected:
   virtual int       copyValues();
   virtual void      lookforsigns();
   virtual void      lookforTrend();

   void              addSignal(IchimokuSignals sig);

public:
                     Ichimoku();
                    ~Ichimoku();
                     Ichimoku(string symbol,ENUM_TIMEFRAMES period,int Tenkan,int Kijun,int Senkou);

   virtual int       init(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
   virtual int       getHandle();

   void              toInfo();

   IchiDataSet       signalSet[];

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::Ichimoku(string psymbol,ENUM_TIMEFRAMES pperiod,int tenkan,int kijun,int senkou)
  {
   Tenkan=tenkan; // Tenkan line period. The fast "moving average".
   Kijun=  kijun; // Kijun line period. The slow "moving average".
   Senkou=senkou; // Senkou period. Used for Kumo (Cloud) spans.

   kumoTrend         = NO_TREND;
   chinkouTrend      = NO_TREND;
   closePriceTrend   = NO_TREND;
   TekanKijunTrend   = NO_TREND;

   init(psymbol,pperiod);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::Ichimoku()
  {
   Tenkan = 9; // Tenkan line period. The fast "moving average".
   Kijun = 26; // Kijun line period. The slow "moving average".
   Senkou= 52; // Senkou period. Used for Kumo (Cloud) spans.

   kumoTrend=NO_TREND;
   chinkouTrend=NO_TREND;
   closePriceTrend = NO_TREND;
   TekanKijunTrend = NO_TREND;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::~Ichimoku()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ichimoku::init(string psymbol,ENUM_TIMEFRAMES ptimeFrames)
  {

   symbol = psymbol;
   period = ptimeFrames;

   handle=iIchimoku(symbol,period,Tenkan,Kijun,Senkou);
   if(handle==INVALID_HANDLE)
     {
      PrintFormat("Fallo al crear el manejador del indicador iIchimoku ");
      return(INIT_FAILED);
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ichimoku::copyValues()
  {
   if(CopyRates(NULL,0,1,Kijun+2,rates)<=0)
      return (-1);
   if(CopyBuffer(handle,0,0,Kijun+1,tenkanSenBuffer)<0)
      return (-1);
   if(CopyBuffer(handle,1,0,Kijun+1,kijunSenBuffer)<0)
      return (-1);
   if(CopyBuffer(handle,2,0,Kijun+1,senkouSpanABuffer)<0)
      return (-1);
   if(CopyBuffer(handle,3,0,Kijun+1,senkouSpanBBuffer)<0)
      return (-1);
   if(CopyBuffer(handle,4,0,Senkou,chinkouSpanBuffer)<0)
      return (-1);

   return (1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ichimoku::onTick()
  {
   int bars=Bars(symbol,period);

   if(lastBars!=bars) lastBars=bars;
   else                  return -1;

   copyValues();
   lookforsigns();

   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::lookforsigns()
  {
   int rateSize    = ArraySize(rates)-1;
   int tenkanSize  = ArraySize(tenkanSenBuffer)-1;
   int kijunSize   = ArraySize(kijunSenBuffer)-1;
   int sekouSize   = ArraySize(senkouSpanABuffer)-1;
   int chinkouSize = ArraySize(chinkouSpanBuffer)-1;


//Looking for chinkouTrend
   double last  = chinkouSpanBuffer[0];
   double first = chinkouSpanBuffer[chinkouSize-2];

   if(last==first) chinkouTrend=NO_TREND;
   if(first > last)    chinkouTrend = UPTREND;
   if(first < last )   chinkouTrend = DOWNTREND;

//looking for kumotrend
   if(senkouSpanABuffer[0]<senkouSpanBBuffer[0]
      && senkouSpanABuffer[sekouSize]>senkouSpanBBuffer[sekouSize])
      kumoTrend=UPTREND;
   else if(senkouSpanABuffer[0]>senkouSpanBBuffer[0]
      && senkouSpanABuffer[sekouSize]<senkouSpanBBuffer[sekouSize])
      kumoTrend=DOWNTREND;

//Looking for tekan/kinjun + and tekan/kinjun trend
   if(tenkanSenBuffer[0]<kijunSenBuffer[0]
      && tenkanSenBuffer[tenkanSize]>kijunSenBuffer[kijunSize])
     {//uptrend cross finded

      TekanKijunTrend=UPTREND;

      if(tenkanSenBuffer[tenkanSize]>senkouSpanABuffer[sekouSize]
         && tenkanSenBuffer[tenkanSize]>senkouSpanBBuffer[sekouSize]
         && kijunSenBuffer[kijunSize]>senkouSpanABuffer[sekouSize]
         && kijunSenBuffer[kijunSize]>senkouSpanBBuffer[sekouSize])
        { // KUMO over 
         addSignal(STRONG_BUY_TS_KS_CROSS);
        }
      else
         if(tenkanSenBuffer[tenkanSize]<senkouSpanABuffer[sekouSize]// KUMO Below  
            && tenkanSenBuffer[tenkanSize]<senkouSpanBBuffer[sekouSize]
            && kijunSenBuffer[kijunSize]<senkouSpanABuffer[sekouSize]
            && kijunSenBuffer[kijunSize]<senkouSpanBBuffer[sekouSize])
           {
            addSignal(WEAK_BUY_TS_KS_CROSS);
           }
      else
         if(((tenkanSenBuffer[tenkanSize]<senkouSpanABuffer[sekouSize] && tenkanSenBuffer[tenkanSize]>senkouSpanBBuffer[sekouSize])
            || (tenkanSenBuffer[tenkanSize]>senkouSpanABuffer[sekouSize] && tenkanSenBuffer[tenkanSize]<senkouSpanBBuffer[sekouSize]))
            && ((kijunSenBuffer[kijunSize]<senkouSpanABuffer[sekouSize] && kijunSenBuffer[kijunSize]<senkouSpanBBuffer[sekouSize])
            || (kijunSenBuffer[kijunSize]>senkouSpanABuffer[sekouSize] && kijunSenBuffer[kijunSize]>senkouSpanBBuffer[sekouSize]))) //KUMO BETWEEN
            addSignal(NEUTRAL_BUY_TS_KS_CROSS);
     }
   else
      if(tenkanSenBuffer[0]>kijunSenBuffer[0]
         && tenkanSenBuffer[tenkanSize]<kijunSenBuffer[kijunSize])
        {//downtrend cross finded

         TekanKijunTrend=DOWNTREND;

         if(tenkanSenBuffer[tenkanSize]>senkouSpanABuffer[sekouSize]
            && tenkanSenBuffer[tenkanSize]>senkouSpanBBuffer[sekouSize]
            && kijunSenBuffer[kijunSize]>senkouSpanABuffer[sekouSize]
            && kijunSenBuffer[kijunSize]>senkouSpanBBuffer[sekouSize])
           { // KUMO over 
            addSignal(WEAK_SELL_TS_KS_CROSS);
           }
         else
            if(tenkanSenBuffer[tenkanSize]<senkouSpanABuffer[sekouSize]// KUMO Below  
               && tenkanSenBuffer[tenkanSize]<senkouSpanBBuffer[sekouSize]
               && kijunSenBuffer[kijunSize]<senkouSpanABuffer[sekouSize]
               && kijunSenBuffer[kijunSize]<senkouSpanBBuffer[sekouSize])
              {
               addSignal(STRONG_SELL_TS_KS_CROSS);
              }
         else
            if(((tenkanSenBuffer[tenkanSize]<senkouSpanABuffer[sekouSize] && tenkanSenBuffer[tenkanSize]>senkouSpanBBuffer[sekouSize])
               || (tenkanSenBuffer[tenkanSize]>senkouSpanABuffer[sekouSize] && tenkanSenBuffer[tenkanSize]<senkouSpanBBuffer[sekouSize]))
               && ((kijunSenBuffer[kijunSize]<senkouSpanABuffer[sekouSize] && kijunSenBuffer[kijunSize]<senkouSpanBBuffer[sekouSize])
               || (kijunSenBuffer[kijunSize]>senkouSpanABuffer[sekouSize] && kijunSenBuffer[kijunSize]>senkouSpanBBuffer[sekouSize]))) //KUMO BETWEEN
               addSignal(NEUTRAL_SELL_TS_KS_CROSS);
        }

// Looking for senkou span +

   if(senkouSpanABuffer[0]<senkouSpanBBuffer[0]
      && senkouSpanABuffer[sekouSize]>senkouSpanBBuffer[sekouSize])
     {// uptrend cross

      if(rates[rateSize].close>senkouSpanABuffer[sekouSize] && rates[rateSize].close<senkouSpanBBuffer[sekouSize])
         addSignal(STRONG_BUY_SENKOU_SPAN_CROSS);
      else if(rates[rateSize].close<senkouSpanABuffer[sekouSize] && rates[rateSize].close<senkouSpanBBuffer[sekouSize])
         addSignal(WEAK_BUY_SENKOU_SPAN_CROSS);
      else if(((rates[rateSize].close<senkouSpanABuffer[sekouSize] && rates[rateSize].close>senkouSpanBBuffer[sekouSize])
         || (rates[rateSize].close>senkouSpanABuffer[sekouSize] && rates[rateSize].close<senkouSpanBBuffer[sekouSize])))
         addSignal(NEUTRAL_BUY_SENKOU_SPAN_CROSS);

     }
   else
      if(senkouSpanABuffer[0]<senkouSpanBBuffer[0]
         && senkouSpanABuffer[sekouSize]>senkouSpanBBuffer[sekouSize])
        {// uptrend cross

         if(rates[rateSize].close<senkouSpanABuffer[sekouSize] && rates[rateSize].close<senkouSpanBBuffer[sekouSize])
            addSignal(STRONG_SELL_SENKOU_SPAN_CROSS);
         else if(rates[rateSize].close>senkouSpanABuffer[sekouSize] && rates[rateSize].close>senkouSpanBBuffer[sekouSize])
            addSignal(WEAK_SELL_SENKOU_SPAN_CROSS);
         else if(((rates[rateSize].close<senkouSpanABuffer[sekouSize] && rates[rateSize].close>senkouSpanBBuffer[sekouSize])
            || (rates[rateSize].close>senkouSpanABuffer[sekouSize] && rates[rateSize].close<senkouSpanBBuffer[sekouSize])))
            addSignal(NEUTRAL_SELL_SENKOU_SPAN_CROSS);
        }

//KUMO Break
   if(rates[rateSize-1].open<senkouSpanABuffer[sekouSize-1]
      && rates[rateSize - 1].open > senkouSpanBBuffer[sekouSize - 1 ]
      && rates[rateSize - 1].close > senkouSpanABuffer[sekouSize - 1]
      && rates[rateSize - 1].close > senkouSpanBBuffer[sekouSize - 1]
      && rates[rateSize].open > senkouSpanABuffer[sekouSize]
      && rates[rateSize].open > senkouSpanABuffer[sekouSize]
      && rates[rateSize].close > senkouSpanABuffer[sekouSize]
      && rates[rateSize].close>senkouSpanABuffer[sekouSize])
     {
      addSignal(KUMO_BUY_BREAKOUT);
     }
   else if(rates[rateSize-1].open>senkouSpanABuffer[sekouSize-1]
      && rates[rateSize - 1].open < senkouSpanBBuffer[sekouSize - 1]
      && rates[rateSize - 1].close < senkouSpanABuffer[sekouSize - 1]
      && rates[rateSize - 1].close < senkouSpanBBuffer[sekouSize - 1]
      && rates[rateSize].open < senkouSpanABuffer[sekouSize]
      && rates[rateSize].open < senkouSpanABuffer[sekouSize]
      && rates[rateSize].close < senkouSpanABuffer[sekouSize]
      && rates[rateSize].close < senkouSpanABuffer[sekouSize])
      addSignal(KUMO_BUY_BREAKOUT);

   if(rates[rateSize].open<kijunSenBuffer[kijunSize] && rates[rateSize].close>kijunSenBuffer[kijunSize])
     { // UPTREND CROSS

      if(kumoTrend == UPTREND)       addSignal(STRONG_BUY_KIJUN_SEN_CROSS);
      if(kumoTrend == DOWNTREND)     addSignal(WEAK_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == NEUTRAL_TREND) addSignal(NEUTRAL_BUY_KIJUN_SEN_CROSS);


        }else if(rates[rateSize].open>kijunSenBuffer[kijunSize] && rates[rateSize].close<kijunSenBuffer[kijunSize]){ //DOWNTREND CROSS

      if(kumoTrend == UPTREND)       addSignal(WEAK_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == DOWNTREND)     addSignal(STRONG_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == NEUTRAL_TREND) addSignal(NEUTRAL_SELL_KIJUN_SEN_CROSS);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::toInfo()
  {

//int signalSize=ArraySize(signals);

// for(int i=0; i<signalSize && signalSize>0; i++)
//   {
//    printf("[%d]:\t%s",i,ichimokuSignalsToString(signals[i]));
//  }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::addSignal(IchimokuSignals sig)
  {
//int signalSize  = ArraySize(signals);
//ArrayResize(signals,signalSize+1);
//signals[signalSize] = sig;

   int signalSize=ArraySize(signalSet);
   ArrayResize(signalSet,signalSize+1);
   signalSet[signalSize]=new IchiDataSet(sig,false);
  }
//+------------------------------------------------------------------+
