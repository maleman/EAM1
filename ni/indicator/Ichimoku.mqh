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

   IchimokuSignals   lastSignal;

   //IchimokuSignals   signals[];

   string            symbol;
   ENUM_TIMEFRAMES   period;

protected:
   virtual int       copyValues();
   virtual void      lookforsigns();
   virtual void      lookforTrend();

   void              addSignal(IchimokuSignals sig);
   void              onTKCross();
   void              onChikouCross();
   void              onKumo();

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
Ichimoku::onTKCross()
  {

   int tenkanSize=ArraySize(tenkanSenBuffer)-1;
   int kijunSize=ArraySize(kijunSenBuffer)-1;
   int sekouSize= ArraySize(senkouSpanABuffer)-1;

   double tklast=tenkanSenBuffer[tenkanSize];
   double tkmiddle=tenkanSenBuffer[tenkanSize-1];
   double tknext=tenkanSenBuffer[tenkanSize -2];

   double kjlast=kijunSenBuffer[kijunSize];
   double kjmiddle=kijunSenBuffer[kijunSize-1];
   double kjnext=kijunSenBuffer[kijunSize-2];

   double ska = senkouSpanABuffer[sekouSize];
   double skb = senkouSpanABuffer[sekouSize];
   MarketTrend localTrend=NO_TREND;

   bool uptrendTK    = (tklast>kjlast);
   bool downtrendTK  = (tklast<=kjlast);

   localTrend=(uptrendTK && !downtrendTK)?UPTREND:DOWNTREND;

   bool uptrendKumo=(tkmiddle>ska && tkmiddle>skb && kjmiddle>ska && kjmiddle>skb);
   bool downtrendKumo=(tkmiddle<ska && tkmiddle<skb && kjmiddle<ska && kjmiddle<skb);

   if(localTrend!=TekanKijunTrend) //SI HAY CAMBIO DE TENDENCIA
     {
      if(uptrendTK)
        {
         TekanKijunTrend=UPTREND;

         if(uptrendKumo)
            addSignal(STRONG_BUY_TS_KS_CROSS);
         else if(downtrendKumo)
            addSignal(WEAK_BUY_TS_KS_CROSS);
         else
            addSignal(NEUTRAL_BUY_TS_KS_CROSS);
        }
      else if(downtrendTK)
        {
         TekanKijunTrend=DOWNTREND;

         if(uptrendKumo)
            addSignal(WEAK_SELL_TS_KS_CROSS);
         else if(downtrendKumo)
            addSignal(STRONG_BUY_TS_KS_CROSS);
         else
            addSignal(NEUTRAL_BUY_TS_KS_CROSS);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::onChikouCross(void)
  {
   int kijunSize   = ArraySize(kijunSenBuffer)-1;
   int rateSize    = ArraySize(rates)-1;

   bool uptrendCross=(rates[rateSize].open<kijunSenBuffer[kijunSize] && rates[rateSize].close>kijunSenBuffer[kijunSize]);
   bool downTrendCross=(rates[rateSize].open>kijunSenBuffer[kijunSize] && rates[rateSize].close<kijunSenBuffer[kijunSize]);

   if(uptrendCross)
     { // UPTREND CROSS

      if(kumoTrend == UPTREND)       addSignal(STRONG_BUY_KIJUN_SEN_CROSS);
      if(kumoTrend == DOWNTREND)     addSignal(WEAK_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == NEUTRAL_TREND) addSignal(NEUTRAL_BUY_KIJUN_SEN_CROSS);


     }
   else if(downTrendCross)
     { //DOWNTREND CROSS

      if(kumoTrend == UPTREND)       addSignal(WEAK_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == DOWNTREND)     addSignal(STRONG_SELL_KIJUN_SEN_CROSS);
      if(kumoTrend == NEUTRAL_TREND) addSignal(NEUTRAL_SELL_KIJUN_SEN_CROSS);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::onKumo(void)
  {

   int rateSize    = ArraySize(rates)-1;
   int sekouSize   = ArraySize(senkouSpanABuffer)-1;

   double skal = senkouSpanABuffer[sekouSize];
   double skam = senkouSpanABuffer[sekouSize-1];
   double skan = senkouSpanABuffer[sekouSize-2];

   double skbl = senkouSpanBBuffer[sekouSize];
   double skbm = senkouSpanBBuffer[sekouSize-1];
   double skbn = senkouSpanBBuffer[sekouSize-2];

   double rcl=rates[rateSize].close;
   double rcm=rates[rateSize-1].close;

   double rol=rates[rateSize].open;
   double rom=rates[rateSize-1].open;

//looking for kumotrend
   if(skan<skbn && skal>skbl)
      kumoTrend=UPTREND;
   else if(skan>skbn && skal<skbl)
      kumoTrend=DOWNTREND;

// Looking for senkou span +

   if(skan<skbn && skal>skbl)
     {// uptrend cross

      if(rcl>skal && rcl<skbl)
         addSignal(STRONG_BUY_SENKOU_SPAN_CROSS);
      else
      if(rcl<skal && rcl<skbl)
         addSignal(WEAK_BUY_SENKOU_SPAN_CROSS);
      else
      if(((rcl<skal && rcl>skbl) || (rcl>skal && rcl<skbl)))
         addSignal(NEUTRAL_BUY_SENKOU_SPAN_CROSS);

     }
   else
   if(skan>skbn && skal<skbl)
     {// uptrend cross

      if(rcl<skal && rcl<skbl)
         addSignal(STRONG_SELL_SENKOU_SPAN_CROSS);
      else
      if(rcl>skal && rcl>skbl)
         addSignal(WEAK_SELL_SENKOU_SPAN_CROSS);
      else
      if(((rcl<skal && rcl>skbl) || (rcl>skal && rcl<skbl)))
         addSignal(NEUTRAL_SELL_SENKOU_SPAN_CROSS);
     }

//KUMO Break
   if((rom<skal && rom>skbl) || (rcm>skal && rcm>skbl)
      && rol>skal && rol>skbl && rcl>skal && rcl>skbl)
      addSignal(KUMO_BUY_BREAKOUT);
   else
      if((rom>skal && rom<skbl) || (rcm<skal && rcm>skbl)
         && rol<skal && rol<skbl && rcl<skal && rcl<skbl)
         addSignal(KUMO_BUY_BREAKOUT);

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

   onKumo();
   onTKCross();
   onChikouCross();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::toInfo()
  {



  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::addSignal(IchimokuSignals sig)
  {

   if(sig==lastSignal)
      return;

   int signalSize=ArraySize(signalSet);
   ArrayResize(signalSet,signalSize+1);
   signalSet[signalSize]=new IchiDataSet(sig,false);

   lastSignal=sig;
  }
//+------------------------------------------------------------------+
