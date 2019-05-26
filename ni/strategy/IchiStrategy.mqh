//+------------------------------------------------------------------+
//|                                                 IchiStrategy.mqh |
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
class IchiStrategy : public Strategy
  {
private:

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
                     IchiStrategy();
                    ~IchiStrategy();

   virtual int       start(string psymbol,ENUM_TIMEFRAMES timeFrames);
   int               start(string psymbol
                           ,ENUM_TIMEFRAMES timeFrames
                           ,int tenkanSen
                           ,int kijunSen
                           ,int senkouSpan
                           ,double tradeVolume
                           ,double tradeStopLost
                           ,double tradeTakeProfit
                           ,bool tradeTrailingMode
                           ,TRADE_MODE tradeTradeMode);
   virtual int       onTick();
   void              deInit();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiStrategy::IchiStrategy()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiStrategy::~IchiStrategy()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
IchiStrategy::deInit(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchiStrategy::start(string psymbol
                        ,ENUM_TIMEFRAMES timeFrames
                        ,int tenkanSen
                        ,int kijunSen
                        ,int senkouSpan
                        ,double tradeVolume
                        ,double tradeStopLost
                        ,double tradeTakeProfit
                        ,bool tradeTrailingMode
                        ,TRADE_MODE tradeTradeMode)
  {

   symbol=psymbol;
   period= timeFrames;

   if(ichi==NULL)
      ichi= new Ichimoku(psymbol,timeFrames,tenkanSen,kijunSen,senkouSpan);

   volume=tradeVolume;
   stopLost=tradeStopLost;
   takeProfit=tradeTakeProfit;
   trade_mode= tradeTradeMode;
   trailingMode=tradeTrailingMode;

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchiStrategy::onTick()
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
      string orderComent="BUY : "+ichimokuSignalsToString(ichi.signalSet[sisetsize].getSignal());
      trade.buy(symbol,orderComent,volume,stopLost,takeProfit);
     }
   else if(shortCondition())
     {
      string orderComent="SELL : "+ichimokuSignalsToString(ichi.signalSet[sisetsize].getSignal());
      trade.sell(symbol,orderComent,volume,stopLost,takeProfit);
     }

   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IchiStrategy::longCondition()
  {

   int last=ArraySize(ichi.signalSet)-1;

   if(last<0)
      return false;

   bool isCurrentProc=ichi.signalSet[last].isProcessed();

   if(!isCurrentProc
      &&(ichi.signalSet[last].getSignal()==WEAK_BUY_TS_KS_CROSS
      || ichi.signalSet[last].getSignal()==NEUTRAL_BUY_TS_KS_CROSS
      || ichi.signalSet[last].getSignal()==STRONG_BUY_TS_KS_CROSS
      //|| ichi.signalSet[last].getSignal()==WEAK_BUY_KIJUN_SEN_CROSS
      || ichi.signalSet[last].getSignal()==NEUTRAL_BUY_KIJUN_SEN_CROSS
      || ichi.signalSet[last].getSignal()==STRONG_BUY_KIJUN_SEN_CROSS)
      )
     {
      ichi.signalSet[last].Processed(true);
      return true;
     }

   if(ichi.signalSet[last].getSignal()==KUMO_BUY_BREAKOUT && ichi.getSenkouTrend()==UPTREND)
     {
      ichi.signalSet[last].Processed(true);
      return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IchiStrategy::shortCondition()
  {
   int last=ArraySize(ichi.signalSet)-1;

   if(last<0)
      return false;

   bool isCurrentProc=ichi.signalSet[last].isProcessed();

   if(!isCurrentProc
      &&(ichi.signalSet[last].getSignal()==WEAK_SELL_TS_KS_CROSS
      || ichi.signalSet[last].getSignal()==NEUTRAL_SELL_TS_KS_CROSS
      || ichi.signalSet[last].getSignal()==STRONG_SELL_TS_KS_CROSS
      //|| ichi.signalSet[last].getSignal()==WEAK_SELL_KIJUN_SEN_CROSS
      || ichi.signalSet[last].getSignal()==NEUTRAL_SELL_KIJUN_SEN_CROSS
      || ichi.signalSet[last].getSignal()==STRONG_SELL_KIJUN_SEN_CROSS)
      )
     {
      ichi.signalSet[last].Processed(true);
      return true;
     }

   if(ichi.signalSet[last].getSignal()==KUMO_SELL_BREAKOUT && ichi.getSenkouTrend()==DOWNTREND)
     {
      ichi.signalSet[last].Processed(true);
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
