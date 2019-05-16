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

   void              buy(string symbol,string orderComent,double vol,double sl,double tp);
   void              sell(string symbol,string orderComent,double vol,double sl,double tp);

   void              traillingStop();

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

//if(m_symbol == NULL)
//   m_symbol = new CSymbolInfo;

//--- initialize common information
//m_symbol.Name(Symbol());                  // symbol
   trade.SetExpertMagicNumber(MAGIC); // magic
   trade.SetMarginMode();
   trade.SetTypeFillingBySymbol(Symbol());
//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(Digits()==3 || Digits()==5)
      digits_adjust=10;
      
   double point =SymbolInfoDouble(Symbol(),SYMBOL_POINT);  
   m_adjusted_point=point*digits_adjust;

//trade.SetMarginMode();
//trade.SetTypeFillingBySymbol(m_symbol.Name());
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
EaTrade::buy(string symbol,string orderComent,double vol,double sl,double tp)
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
EaTrade::sell(string symbol,string orderComent,double vol,double sl,double tp)
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
//| Sell                                                             |
//+------------------------------------------------------------------+
EaTrade::traillingStop(void)
  {

   if(!TRAILING_STOP)
      TRAILING_STOP=true;

   int    InpTrailingStop=30;
   int    InpTakeProfit=50;

   double m_traling_stop=InpTrailingStop*m_adjusted_point;
   double m_take_profit=InpTakeProfit*m_adjusted_point;

   if(positionInfo.Select(Symbol()) && TRAILING_STOP)
     {
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
               if(trade.PositionModify(Symbol(),sl,tp))
                  printf("Long position by %s to be modified",Symbol());
               else
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
               if(trade.PositionModify(Symbol(),sl,tp))
                  printf("Short position by %s to be modified",Symbol());
               else
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
//+------------------------------------------------------------------+
