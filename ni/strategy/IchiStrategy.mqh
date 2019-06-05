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
#include "..\indicator\Adx.mqh"
#include "..\trade\EaTrade.mqh"
#include "..\indicator\Ichimoku.mqh"
#include "..\indicator\IndicatorFactory.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class IchiStrategy : public Strategy
  {
private:

   int               EaMagic;
   int               lastSinalDsSize;
   int               atrPeriod;

   bool              longCondition();
   bool              shortCondition();
   bool              trailingMode;
   bool              kumoBreakBuy;
   bool              kumoBreakSell;

   IchiDataSet      *signalSet;
   Adx              *adx;
   Ichimoku         *ichi;
   EaTrade          *trade;

   string            symbol;
   ENUM_TIMEFRAMES   period;
   TRADE_MODE        trade_mode;
   double            stopLost;
   double            atrStopLost;
   double            takeProfit;
   double            volume;
   double            closePositionOnProfit;

   MarketTrend       kumoPriceTrend;
   MarketTrend       SenkouTrend;

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
                           ,double totalProfit);
   virtual int       onTick();
   void              deInit();
   void setEaMagic(int magic){EaMagic=magic;}

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
void IchiStrategy::deInit(void)
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
                        ,double totalProfit)
  {

   kumoBreakBuy=false;
   kumoBreakSell=false;

   symbol=psymbol;
   period= timeFrames;

   if(ichi==NULL)
      ichi= new Ichimoku(psymbol,timeFrames,tenkanSen,kijunSen,senkouSpan);


   volume=tradeVolume;
   stopLost=tradeStopLost;
   takeProfit=tradeTakeProfit;
   //trade_mode= tradeTradeMode;
   trailingMode=tradeTrailingMode;

   closePositionOnProfit=totalProfit;

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int IchiStrategy::onTick()
  {

   if(trade==NULL)
     {
      trade=new EaTrade();
      trade.setEaMagic(EaMagic);
     }
   if(ichi!=NULL)
      ichi.onTick();

   if(trailingMode)
      trade.traillingStop();

//close all Position If raise prafit global
   if(closePositionOnProfit>0 && closePositionOnProfit<=trade.getProfitAllPosition())
      trade.closePositionAll();

//Check If trend did not change
   MarketTrend tr=ichi.getclosePriceTrend();
   if(tr!=kumoPriceTrend)
     {
      if(tr==UPTREND && kumoPriceTrend==DOWNTREND)
         trade.closePositionByType(POSITION_TYPE_SELL);

      if(tr==DOWNTREND && kumoPriceTrend==UPTREND)
         trade.closePositionByType(POSITION_TYPE_BUY);

      kumoPriceTrend=tr;
     }
   tr=ichi.getSenkouTrend();
   if(tr!=SenkouTrend)
     {
      if(tr==UPTREND && kumoPriceTrend==DOWNTREND)
         trade.closePositionByType(POSITION_TYPE_SELL);

      if(tr==DOWNTREND && kumoPriceTrend==UPTREND)
         trade.closePositionByType(POSITION_TYPE_BUY);

      SenkouTrend=tr;
     }

   int bars=Bars(symbol,period);

   if(lastBars!=bars)
      lastBars=bars;
   else
      return -1;

   IchiDataSet       signalSet[];
   ichi.copySignalUnProcessed(signalSet);

   int last=ArraySize(signalSet)-1;

   if(last<0)
      return false;

   for(int i=0; i<=last; i++)
     {

      bool isCurrentProc=signalSet[i].isProcessed();

      //BUY
      if(!isCurrentProc && ichi.getclosePriceTrend()==UPTREND)
        {
         string orderComent="BUY : "+ichimokuSignalsToString(signalSet[i].getSignal());

         if(signalSet[i].getSignal()==KUMO_BUY_BREAKOUT)
           {
            //trade.buy(symbol,orderComent,volume,stopLost*0.20,takeProfit);
            kumoBreakBuy=true;
            if(kumoBreakSell)
               kumoBreakSell=false;
           }

         if(kumoBreakBuy && ichi.getSenkouTrend()==UPTREND)
           {
            trade.buy(symbol,orderComent,volume,stopLost*0.30,takeProfit*50);
            trade.buy(symbol,orderComent,volume,stopLost*0.40,takeProfit*50);
            trade.buy(symbol,orderComent,volume,stopLost*0.50,takeProfit*70);
            trade.buy(symbol,orderComent,volume,stopLost,takeProfit);
            kumoBreakBuy=false;
           }
        }
      //SELL
      else if(!isCurrentProc && ichi.getclosePriceTrend()==DOWNTREND)
        {
         string orderComent="SELL : "+ichimokuSignalsToString(signalSet[i].getSignal());
         if(signalSet[i].getSignal()==KUMO_SELL_BREAKOUT)
           {
           // trade.sell(symbol,orderComent,volume,stopLost*0.20,takeProfit);
            kumoBreakSell=true;
            if(kumoBreakBuy)
               kumoBreakBuy=false;
           }

         if(kumoBreakSell && ichi.getSenkouTrend()==DOWNTREND)
           {
            trade.sell(symbol,orderComent,volume,stopLost*0.30,takeProfit*50);
            trade.sell(symbol,orderComent,volume,stopLost*0.40,takeProfit*50);
            trade.sell(symbol,orderComent,volume,stopLost*0.50,takeProfit*70);
            trade.sell(symbol,orderComent,volume,stopLost,takeProfit);
            kumoBreakSell=false;
           }
        }

      signalSet[i].Processed(true);
     }

   return 1;
  }

/*  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IchiStrategy::longCondition()
  {

   int last=ArraySize(ichi.signalSet)-1;

   if(last<0)
      return false;

   bool isCurrentProc=ichi.signalSet[last].isProcessed();

   bool long_=(!isCurrentProc
               && (((ichi.getclosePriceTrend()==UPTREND)
               &&(ichi.signalSet[last].getSignal()==STRONG_BUY_TS_KS_CROSS
               || ichi.signalSet[last].getSignal()==NEUTRAL_BUY_KIJUN_SEN_CROSS
               || ichi.signalSet[last].getSignal()==STRONG_BUY_KIJUN_SEN_CROSS))
               || ichi.signalSet[last].getSignal()==KUMO_BUY_BREAKOUT));

   if(long_)
      ichi.signalSet[last].Processed(true);

   return long_;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IchiStrategy::shortCondition()
  {
   int last=ArraySize(ichi.signalSet)-1;

   if(last<0)
      return false;

   bool isCurrentProc=ichi.signalSet[last].isProcessed();

   bool short_=(!isCurrentProc
                && (((getclosePriceTrend()==DOWNTREND)
                &&(ichi.signalSet[last].getSignal()==STRONG_SELL_TS_KS_CROSS
                || ichi.signalSet[last].getSignal()==NEUTRAL_SELL_KIJUN_SEN_CROSS
                || ichi.signalSet[last].getSignal()==STRONG_SELL_KIJUN_SEN_CROSS))
                || ichi.signalSet[last].getSignal()==KUMO_SELL_BREAKOUT));

   if(short_)
      ichi.signalSet[last].Processed(true);

   return short_;

  }
//+------------------------------------------------------------------+
*/
//+------------------------------------------------------------------+
