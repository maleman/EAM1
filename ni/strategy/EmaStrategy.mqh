//+------------------------------------------------------------------+
//|                                                  EmaStrategy.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include "Strategy.mqh"
#include "..\indicator\Ema.mqh"
#include "..\indicator\IndicatorFactory.mqh"
#include "..\trade\EaTrade.mqh"
#include "..\dataset\signal\EmaDataSet.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EmaStrategy : public Strategy
  {
private:
   Ema              *ema;
   EmaSignals        lastSig;
   EaTrade          *trade;

   bool              trailingStop;
   string            symbol;
   double            sl;
   double            tp;
   double            vol;
   int               period_1;
   int               period_2;
   int               shift_1;
   int               shift_2;
   ENUM_MA_METHOD    method_1;
   ENUM_MA_METHOD    method_2;
   ENUM_APPLIED_PRICE app_price_1;
   ENUM_APPLIED_PRICE app_price_2;

public:
                     EmaStrategy();
                    ~EmaStrategy();

   virtual int       start(string psymbol,ENUM_TIMEFRAMES timeFrames);
   int               start(double pvol,
                           double psl,
                           double ptp,
                           string psymbol,
                           ENUM_TIMEFRAMES timeFrames,
                           int ma_period_1,
                           int ma_period_2,
                           int ma_shift_1 = 0,
                           int ma_shift_2 = 0,
                           ENUM_MA_METHOD ma_method_1=MODE_EMA,
                           ENUM_MA_METHOD ma_method_2=MODE_EMA,
                           ENUM_APPLIED_PRICE applied_price_1=PRICE_CLOSE,
                           ENUM_APPLIED_PRICE applied_price_2=PRICE_CLOSE,
                           bool trstp=false);
   virtual int       onTick();

   void              setValuesTrade(double pvol,double psl,double ptp,
                                    int ma_period_1,
                                    int ma_period_2,
                                    int ma_shift_1 = 0,
                                    int ma_shift_2 = 0,
                                    ENUM_MA_METHOD ma_method_1=MODE_EMA,
                                    ENUM_MA_METHOD ma_method_2=MODE_EMA,
                                    ENUM_APPLIED_PRICE applied_price_1=PRICE_CLOSE,
                                    ENUM_APPLIED_PRICE applied_price_2=PRICE_CLOSE)


     {

      vol   = pvol;
      sl    = psl;
      tp    = ptp;
      period_1 = ma_period_1;
      period_2 = ma_period_2;
      shift_1  = ma_shift_1;
      shift_2=ma_shift_2;
      method_1 = ma_method_1;
      method_2 = ma_method_2;
      app_price_1 = applied_price_1;
      app_price_2 = applied_price_2;
     }

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaStrategy::EmaStrategy()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EmaStrategy::~EmaStrategy(){}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmaStrategy::start(string psymbol,ENUM_TIMEFRAMES timeFrames)
  {
   symbol=psymbol;
   IndicatorFactory ifactory=new IndicatorFactory();
   if(ema == NULL)
      ema = ifactory.getIndicator(DEMA);

   ema.setIndicatorData(period_1,period_2,shift_1,shift_2,method_1,method_2,app_price_1,app_price_2);
   return ema.init(symbol,timeFrames);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmaStrategy::start(double pvol,
                       double psl,
                       double ptp,
                       string psymbol,
                       ENUM_TIMEFRAMES timeFrames,
                       int ma_period_1,
                       int ma_period_2,
                       int ma_shift_1 = 0,
                       int ma_shift_2 = 0,
                       ENUM_MA_METHOD ma_method_1=MODE_EMA,
                       ENUM_MA_METHOD ma_method_2=MODE_EMA,
                       ENUM_APPLIED_PRICE applied_price_1=PRICE_CLOSE,
                       ENUM_APPLIED_PRICE applied_price_2=PRICE_CLOSE,
                       bool trstp=false)
  {

   vol=pvol;
   sl    = psl;
   tp    = ptp;
   period_1 = ma_period_1;
   period_2 = ma_period_2;
   shift_1  = ma_shift_1;
   shift_2=ma_shift_2;
   method_1 = ma_method_1;
   method_2 = ma_method_2;
   app_price_1 = applied_price_1;
   app_price_2 = applied_price_2;
   trailingStop= trstp;

   return start(psymbol, timeFrames);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int EmaStrategy::onTick()
  {

   if(trade==NULL)
      trade=new EaTrade();
   if(trailingStop)
      trade.traillingStop();

   if(ema!=NULL)
      ema.onTick();

   EmaDataSet *sigDS=ema.getLastSigDs();

   if(sigDS!=NULL && lastSig!=sigDS.getSignal() && !sigDS.isProcessed())
     {
      if(sigDS.getSignal()==BUY)
        {
         string orderComent="BUY";
         trade.buy(symbol,orderComent,vol,sl,tp);
         sigDS.Processed(true);
           }else if(sigDS.getSignal()==SELL){
         string orderComent="SELL";
         trade.sell(symbol,orderComent,vol,sl,tp);
         sigDS.Processed(true);
        }
      lastSig=sigDS.getSignal();
     }

   return 1;
  }
//+------------------------------------------------------------------+