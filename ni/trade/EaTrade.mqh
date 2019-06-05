//+------------------------------------------------------------------+
//|                                                      EaTrade.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
#include <Trade/PositionInfo.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class EaTrade
  {
private:

   bool              TRAILING_STOP;
   int               MAGIC;
   double            m_adjusted_point;

   CTrade           *trade;
   CPositionInfo    *positionInfo;
   //CSymbolInfo      *m_symbol;
   //TrailingStop     *trStop;

public:
                     EaTrade();
                    ~EaTrade();
   void              setEaMagic(int magic){MAGIC=magic;}
   void              closePositionByType();
   void              buy(string symbol,string orderComent,double vol,double sl,double tp);
   void              sell(string symbol,string orderComent,double vol,double sl,double tp);
   void              closePositionAll();
   void              closePositionByType(ENUM_POSITION_TYPE type);

   void              traillingStop();

   double            getProfitAllPosition();
   double            getAdjustedPoint(){return m_adjusted_point;}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EaTrade::EaTrade()
  {

   MAGIC=2251;

   if(trade== NULL)
      trade= new CTrade();

   if(positionInfo == NULL)
      positionInfo = new CPositionInfo;

//--- initialize common information
   trade.SetExpertMagicNumber(MAGIC); // magic
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;

   double point=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   m_adjusted_point=point*digits_adjust;
   trade.SetDeviationInPoints(3*digits_adjust);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EaTrade::~EaTrade()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy                                                              |
//+------------------------------------------------------------------+
void EaTrade::buy(string symbol,string orderComent,double vol,double sl,double tp)
  {

   if(trade == NULL)
      trade = new CTrade();

   double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   double localtp=(tp==0)? 0.00 : Ask+tp;
   if(trade.PositionOpen(symbol,ORDER_TYPE_BUY,vol,Ask,Ask-sl,localtp,orderComent))
      PlaySound("Ok.wav");

  }
//+------------------------------------------------------------------+
//| Sell                                                             |
//+------------------------------------------------------------------+
void EaTrade::sell(string symbol,string orderComent,double vol,double sl,double tp)
  {

   if(trade == NULL)
      trade = new CTrade();

   double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   double localtp=(tp==0)? 0.00 : Bid-tp;
   if(trade.PositionOpen(symbol,ORDER_TYPE_SELL,vol,Bid,Bid+sl,localtp,orderComent))
      PlaySound("Ok.wav");
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EaTrade::closePositionAll()
  {
   closePositionByType(POSITION_TYPE_BUY);
   closePositionByType(POSITION_TYPE_SELL);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EaTrade::closePositionByType(ENUM_POSITION_TYPE type)
  {

   int positionTotal=PositionsTotal();

   for(int i=positionTotal; i>=0; i--)
     {
      ulong positionTicket=PositionGetTicket(i);
      string positionSymbol=PositionGetString(POSITION_SYMBOL);
      ulong magic=PositionGetInteger(POSITION_MAGIC);
      ENUM_POSITION_TYPE positionType=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

      if(magic==MAGIC && type==positionType)
        {
         trade.PositionClose(positionTicket,5);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double EaTrade::getProfitAllPosition()
  {
   double profit=0.0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(positionInfo.SelectByIndex(i))
         profit+=(positionInfo.Commission()+positionInfo.Swap()+positionInfo.Profit());
     }
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EaTrade::traillingStop(void)
  {

   if(!TRAILING_STOP)
      TRAILING_STOP=true;

   int    InpTrailingStop=30;
   int    InpTakeProfit=50;

   double m_traling_stop=InpTrailingStop*m_adjusted_point;
   double m_take_profit=InpTakeProfit*m_adjusted_point;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


   int positionTotal=PositionsTotal();

   for(int i=positionTotal; i>=0; i--)
     {
      //if(positionInfo.Select(Symbol()) && TRAILING_STOP)
      if(positionInfo.SelectByIndex(i) && TRAILING_STOP)
        {
         ulong positionTicket=PositionGetTicket(i);
         if(positionInfo.PositionType()==POSITION_TYPE_BUY)
           {

            double localBid=SymbolInfoDouble(Symbol(),SYMBOL_BID);

            if(localBid-positionInfo.PriceOpen()>m_adjusted_point*InpTrailingStop)
              {

               double sl=NormalizeDouble(localBid-m_traling_stop,Digits());
               double tp=positionInfo.TakeProfit();
               if(positionInfo.StopLoss()<sl || positionInfo.StopLoss()==0.0)
                 {
                  //--- modify position
                  if(!trade.PositionModify(positionTicket,sl,tp))
                    {
                     printf("Error modifying position by %s : '%s'",Symbol(),trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f",sl,tp);
                    }
                  //--- modified and must exit from expert
                  //res=true;
                 }
              }

              }else if(positionInfo.PositionType()==POSITION_TYPE_SELL){

            double localAsk=SymbolInfoDouble(Symbol(),SYMBOL_ASK);

            if((positionInfo.PriceOpen()-localAsk)>(m_adjusted_point*InpTrailingStop))
              {
               double sl=NormalizeDouble(localAsk+m_traling_stop,Digits());
               double tp=positionInfo.TakeProfit();
               if(positionInfo.StopLoss()>sl || positionInfo.StopLoss()==0.0)
                 {
                  //--- modify position
                  if(!trade.PositionModify(positionTicket,sl,tp))
                    {
                     printf("Error modifying position by %s : '%s'",Symbol(),trade.ResultComment());
                     printf("Modify parameters : SL=%f,TP=%f",sl,tp);
                    }
                  //--- modified and must exit from expert
                  //res=true;
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
