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
#include "..\signal\IchimukuSignal.mqh"
#include "..\signal\IchiSignals.mqh"
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
   double            tenkan[];
   double            kijun[];
   double            senkou_A[];
   double            senkou_B[];
   double            chinkou[];

   //MarketTrend actualTrend;
   MarketTrend       chinkouTrend;
   MarketTrend       kumoTrend;
   MarketTrend       closePriceTrend;
   MarketTrend       TekanKijunTrend;
   MarketTrend       SenkouTrend;

   IchimokuSignals   signal;
   IchimokuSignals   tenkanKijunCrossSignal;
   IchimokuSignals   kijunCrossSignal;
   IchimokuSignals   kumoBreakSignal;
   IchimokuSignals   senkouCrossSignal;

   IchimokuSignals   lastSignal;
   //IchimukuSignal   *ichiSignals;
   IchiSignals      *ichiSignal;

   //IchimokuSignals   signals[];

   string            symbol;
   ENUM_TIMEFRAMES   period;

protected:
   virtual int       copyValues();
   virtual void      lookforsigns();
   virtual void      lookforTrend();

   void              addSignal(IchimokuSignals sig);
   void              onTKCross();
   void              onKijunCross();
   void              onKumo();

public:
                     Ichimoku();
                    ~Ichimoku();
                     Ichimoku(string symbol,ENUM_TIMEFRAMES period,int Tenkan,int Kijun,int Senkou);

   virtual int       init(string symbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
   virtual int       getHandle();

   void              deInit();
   void              toInfo();

   bool              isWeakBuySignal(IchimokuSignals sig);
   bool              isNeutralBuySignal(IchimokuSignals sig);
   bool              isStrongBuySignal(IchimokuSignals sig);
   bool              isWeakSellSignal(IchimokuSignals sig);
   bool              isNeutralSellSignal(IchimokuSignals sig);
   bool              isStrongSellSignal(IchimokuSignals sig);

   IchiDataSet       signalSet[];

   //MarketTrend       getChinkouTrend(){return chinkouTrend;}
   //MarketTrend       getkumoTrend(){return kumoTrend;}
   //MarketTrend       getclosePriceTrend(){closePriceTrend;}
   //MarketTrend       getTekanKijunTrend(){TekanKijunTrend;}

   MarketTrend       getSenkouTrend(){return SenkouTrend;}

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
   if(CopyRates(NULL,0,1,Tenkan+2,rates)<=0)
      return (-1);
   if(CopyBuffer(handle,0,0,Tenkan+1,tenkan)<0)
      return (-1);
   if(CopyBuffer(handle,1,0,Tenkan+1,kijun)<0)
      return (-1);
   if(CopyBuffer(handle,2,-Kijun,Kijun+1,senkou_A)<0)
      return (-1);
   if(CopyBuffer(handle,3,-Kijun,Kijun+1,senkou_B)<0)
      return (-1);
   if(CopyBuffer(handle,4,0,Senkou,chinkou)<0)
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
Ichimoku::addSignal(IchimokuSignals sig)
  {

   if(sig==lastSignal || sig==NO_SIGNAL)
      return;

   int signalSize=ArraySize(signalSet);
   ArrayResize(signalSet,signalSize+1);
   signalSet[signalSize]=new IchiDataSet(sig,false);

   printf("New Signal Found >> %s",ichimokuSignalsToString(sig));

   lastSignal=sig;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::lookforsigns()
  {
   if(ichiSignal == NULL)
      ichiSignal = new IchiSignals();

   ichiSignal.toInfo();

   ichiSignal.search(tenkan,kijun,senkou_A,senkou_B,chinkou,rates);

   SenkouTrend=ichiSignal.getSenkouTrend();

   if(tenkanKijunCrossSignal!=ichiSignal.getTkc())
     {
      tenkanKijunCrossSignal=ichiSignal.getTkc();
      addSignal(tenkanKijunCrossSignal);
     }

   if(kijunCrossSignal!=ichiSignal.getkPc())
     {
      kijunCrossSignal=ichiSignal.getkPc();
      addSignal(kijunCrossSignal);
     }

   if(kumoBreakSignal!=ichiSignal.getKB())
     {
      kumoBreakSignal=ichiSignal.getKB();
      addSignal(kumoBreakSignal);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
Ichimoku::deInit()
  {
   delete ichiSignal;
  }
//+------------------------------------------------------------------+

bool Ichimoku::isWeakBuySignal(IchimokuSignals sig)
  {

   if(WEAK_BUY_TS_KS_CROSS==sig
      || WEAK_BUY_KIJUN_SEN_CROSS==sig
      || WEAK_BUY_SENKOU_SPAN_CROSS == sig
      || WEAK_BUY_CHIKOU_SPAN_CROSS == sig
      || KUMO_BUY_BREAKOUT==sig)
      return true;

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Ichimoku::isNeutralBuySignal(IchimokuSignals sig)
  {

   if(NEUTRAL_BUY_TS_KS_CROSS==sig
      || NEUTRAL_BUY_KIJUN_SEN_CROSS==sig
      || NEUTRAL_BUY_SENKOU_SPAN_CROSS == sig
      || NEUTRAL_BUY_CHIKOU_SPAN_CROSS == sig
      || KUMO_BUY_BREAKOUT==sig)
      return true;

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool              Ichimoku::isStrongBuySignal(IchimokuSignals sig)
  {

   if(STRONG_BUY_TS_KS_CROSS==sig
      || STRONG_BUY_KIJUN_SEN_CROSS==sig
      || STRONG_BUY_SENKOU_SPAN_CROSS == sig
      || STRONG_BUY_CHIKOU_SPAN_CROSS == sig
      || KUMO_BUY_BREAKOUT==sig)
      return true;

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Ichimoku::isWeakSellSignal(IchimokuSignals sig)
  {
   if(WEAK_SELL_TS_KS_CROSS==sig
      || WEAK_SELL_KIJUN_SEN_CROSS==sig
      || WEAK_SELL_SENKOU_SPAN_CROSS == sig
      || WEAK_SELL_CHIKOU_SPAN_CROSS == sig
      || KUMO_SELL_BREAKOUT==sig)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Ichimoku::isNeutralSellSignal(IchimokuSignals sig)
  {
   if(NEUTRAL_SELL_TS_KS_CROSS==sig
      || NEUTRAL_SELL_KIJUN_SEN_CROSS==sig
      || NEUTRAL_SELL_SENKOU_SPAN_CROSS == sig
      || NEUTRAL_SELL_CHIKOU_SPAN_CROSS == sig
      || KUMO_SELL_BREAKOUT==sig)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  Ichimoku::isStrongSellSignal(IchimokuSignals sig)
  {

   if(STRONG_SELL_KIJUN_SEN_CROSS==sig
      || STRONG_SELL_TS_KS_CROSS==sig
      || STRONG_SELL_SENKOU_SPAN_CROSS == sig
      || STRONG_SELL_CHIKOU_SPAN_CROSS == sig
      || KUMO_SELL_BREAKOUT==sig)
      return true;

   return false;

  }
//+------------------------------------------------------------------+
