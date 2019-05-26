//+------------------------------------------------------------------+
//|                                             IchimokuStrategy.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Strategy.mqh"
#include "..\enum\Enums.mqh"
#include "..\indicator\Ichimoku.mqh"
#include "..\indicator\IndicatorFactory.mqh"
#include "..\trade\EaTrade.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchimokuStrategy : public Strategy
  {
protected:

   int               lastSinalDsSize;
   bool              longCondition();
   bool              shortCondition();

   bool              trailingMode;

   IchiDataSet      *signalSet;
   Ichimoku         *ichi;
   EaTrade          *trade;

   string            symbol;
   ENUM_TIMEFRAMES   period;
   TRADE_MODE        trade_mode;
   double            stopLost;
   double            takeProfit;
   double            volume;

public:
                     IchimokuStrategy();
                    ~IchimokuStrategy();

   virtual int       start(string psymbol,ENUM_TIMEFRAMES timeFrames);
   virtual int       onTick();
   void              deInit();

   int               start(string psymbol,ENUM_TIMEFRAMES timeFrames,int t,int k,int s,double v,double sl,double tp,bool tram,TRADE_MODE trm);

   void              setValuesTrade(double pvol,double psl,double ptp)
     {
      volume=pvol;
      stopLost=psl;
      takeProfit=ptp;
     }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuStrategy::IchimokuStrategy()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuStrategy::~IchimokuStrategy()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchimokuStrategy::start(string psymbol,ENUM_TIMEFRAMES timeFrames)
  {

   symbol=psymbol;
   period= timeFrames;
   IndicatorFactory ifactory=new IndicatorFactory();
   if(ichi==NULL)
      ichi=ifactory.getIndicator(ICHIMOKU);

   ichi.init(symbol,period);

   return INIT_SUCCEEDED;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchimokuStrategy::start(string psymbol,ENUM_TIMEFRAMES timeFrames,int t,int k,int s,double v,double sl,double tp,bool tram,TRADE_MODE trm)
  {

   symbol=psymbol;
   period= timeFrames;

   if(ichi==NULL)
      ichi= new Ichimoku(psymbol,timeFrames,t,k,s);

   volume=v;
   stopLost=sl;
   takeProfit=tp;
   trade_mode= trm;
   trailingMode=tram;

   return INIT_SUCCEEDED;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchimokuStrategy::onTick()
  {

   if(trade==NULL)
      trade=new EaTrade();
   if(ichi!=NULL)
      ichi.onTick();

   if(trailingMode)
      trade.traillingStop();

   int bars=Bars(symbol,period);

   if(lastBars!=bars)
      lastBars=bars;
   else
      return -1;

   int sisetsize=ArraySize(ichi.signalSet)-1;
   if(lastSinalDsSize!=sisetsize)
      lastSinalDsSize=sisetsize;
   else
      return -1;

   if(longCondition())
     {
      string orderComent="BUY : ["+ichimokuSignalsToString(ichi.signalSet[lastSinalDsSize].getSignal())+"]";
      trade.buy(symbol,orderComent,volume,stopLost,takeProfit);
     }
   else if(shortCondition())
     {
      string orderComent="SELL : ["+ichimokuSignalsToString(ichi.signalSet[lastSinalDsSize].getSignal())+"]";
      trade.sell(symbol,orderComent,volume,stopLost,takeProfit);
     }

   return 1;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchimokuStrategy::deInit()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Check LongCondition buy                                           |
//+------------------------------------------------------------------+
bool IchimokuStrategy::longCondition()
  {
   int last=ArraySize(ichi.signalSet)-1;

   if(last>=0 && trade_mode==ROOKIE_MODE)
     {
      if(!ichi.signalSet[last].isProcessed()
         && (ichi.signalSet[last].getSignal()==WEAK_BUY_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_BUY_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == WEAK_BUY_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_BUY_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == WEAK_BUY_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_BUY_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal()==KUMO_BUY_BREAKOUT))
        {
         ichi.signalSet[last].Processed(true);
         return true;
        }
     }
   else if(last>=1 && trade_mode==WISE_MODE)
     {

      bool isCurrentProc=ichi.signalSet[last].isProcessed();
      bool isLastProc=ichi.signalSet[last-1].isProcessed();

      if(!isCurrentProc && ichi.isStrongBuySignal(ichi.signalSet[last].getSignal()))
        {
         ichi.signalSet[last].Processed(true);
         return true;
        }

      bool current=isCurrentProc
                   &&(ichi.isStrongBuySignal(ichi.signalSet[last].getSignal())
                   || ichi.isNeutralBuySignal(ichi.signalSet[last].getSignal())
                   || ichi.isWeakBuySignal(ichi.signalSet[last].getSignal()));

                   bool previous=isLastProc
                   &&(ichi.isStrongBuySignal(ichi.signalSet[last-1].getSignal())
                   || ichi.isNeutralBuySignal(ichi.signalSet[last-1].getSignal())
                   || ichi.isWeakBuySignal(ichi.signalSet[last-1].getSignal()));

                   if(current && previous)
        {
         ichi.signalSet[last].Processed(true);
         ichi.signalSet[last-1].Processed(true);
         return true;
        }
     }
   else if(last>=0 && trade_mode==SAFE_MODE)
     {
      if(!ichi.signalSet[last].isProcessed()
         && (ichi.signalSet[last].getSignal()==STRONG_BUY_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_BUY_KIJUN_SEN_CROSS))
        {
         ichi.signalSet[last].Processed(true);
         return true;
        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|Check short condition sell                                        |
//+------------------------------------------------------------------+
bool IchimokuStrategy::shortCondition()
  {

   int last=ArraySize(ichi.signalSet)-1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(last>=0 && trade_mode==ROOKIE_MODE)
     {
      if(!ichi.signalSet[last].isProcessed()
         && (ichi.signalSet[last].getSignal()==WEAK_SELL_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_SELL_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == WEAK_SELL_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_SELL_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == WEAK_SELL_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == NEUTRAL_SELL_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal()==KUMO_SELL_BREAKOUT))
        {
         ichi.signalSet[last].Processed(true);
         return true;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(last>=1 && trade_mode==WISE_MODE)
     {

      bool isCurrentProc=ichi.signalSet[last].isProcessed();
      bool isLastProc=ichi.signalSet[last-1].isProcessed();

      bool current=!isCurrentProc
                   &&(ichi.isStrongSellSignal(ichi.signalSet[last].getSignal())
                   || ichi.isNeutralSellSignal(ichi.signalSet[last].getSignal())
                   || ichi.isWeakSellSignal(ichi.signalSet[last].getSignal()));

                   bool previous=!isLastProc
                   &&(ichi.isStrongSellSignal(ichi.signalSet[last-1].getSignal())
                   || ichi.isNeutralSellSignal(ichi.signalSet[last-1].getSignal())
                   || ichi.isWeakSellSignal(ichi.signalSet[last-1].getSignal()));

                   if(current && previous)
        {
         ichi.signalSet[last].Processed(true);
         ichi.signalSet[last-1].Processed(true);
         return true;
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(last>=0 && trade_mode==SAFE_MODE)
     {
      if(!ichi.signalSet[last].isProcessed()
         && (ichi.signalSet[last].getSignal()==STRONG_SELL_TS_KS_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_KIJUN_SEN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_SENKOU_SPAN_CROSS
         || ichi.signalSet[last].getSignal() == STRONG_SELL_KIJUN_SEN_CROSS))
        {
         ichi.signalSet[last].Processed(true);
         return true;
        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
