//+------------------------------------------------------------------+
//|                                                 TrailingStop.mqh |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh> 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class TrailingStop
  {
private:

   CPositionInfo     m_position;                   // trade position object
   CTrade            m_trade;                      // trading object
   CSymbolInfo       m_symbol;

   //--- input parameters
   ushort            digits;
   ushort            stopLoss;      //= 0;              
   ushort            takeProfit;    //= 0;           
   ushort            trailingStop;  //= 5;              
   ushort            trailingStart; //= 5;              
   ushort            trailingStep;  //= 1;  


   //--- HLine
   string            InpNameBuy;//="SL Buy";       // BUY Line name 
   string            InpNameSell;//="SL Sell";      // SELL Line name 
   ENUM_LINE_STYLE   InpStyle;//=STYLE_DASHDOTDOT;       // Line style 
   //---
   ulong             m_slippage;//=10;                // slippage
   double            TrallB;// =   0;
   double            TrallS;// =   0;

   double            ExtStoploss;//=0.0;
   double            ExtTakeprofit;//=0.0;
   double            ExtTrailingStop;//=0.0;
   double            ExtTrailingStart;//=0.0;
   double            ExtTrailingStep;//=0.0;

   double            m_adjusted_point;

   int               start();

   bool              HLineCreate(const long            chart_ID=0,// chart's ID 
                                 const string          name="HLine",      // line name 
                                 const int             sub_window=0,      // subwindow index 
                                 double                price=0,           // line price 
                                 const color           clr=clrRed,        // line color 
                                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                                 const int             width=1,           // line width 
                                 const bool            back=false,        // in the background 
                                 const bool            selection=false,   // highlight to move 
                                 const bool            hidden=true,       // hidden in the object list 
                                 const long            z_order=0);

   bool              HLineMove(const long   chart_ID=0,// chart's ID 
                               const string name="HLine",// line name 
                               double       price=0);

   bool              HLineDelete(const long   chart_ID=0,// chart's ID 
                                 const string name="HLine"); // line name 

   bool              RefreshRates(void);
   bool              IsPositionExists(void);

public:

                     TrailingStop();

                     TrailingStop(CSymbolInfo   *symbol
                                                    ,CTrade *trade
                                                    ,ushort Stoploss
                                                    ,ushort Takeprofit
                                                    ,ushort pTrailingStop
                                                    ,ushort TrailingStart
                                                    ,ushort TrailingStep);

                    ~TrailingStop();

   void              onCalculate();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrailingStop::TrailingStop()
  {

   digits=3;
   stopLoss      = 0;
   takeProfit    = 0;
   trailingStop  = 5;
   trailingStart = 5;
   trailingStep  = 1;

   start();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrailingStop::TrailingStop(CSymbolInfo   *symbol
                           ,CTrade *trade
                           ,ushort Stoploss
                           ,ushort Takeprofit
                           ,ushort pTrailingStop
                           ,ushort TrailingStart
                           ,ushort TrailingStep)
  {
   m_symbol=symbol;
   m_trade = trade;

   stopLoss      = Stoploss;
   takeProfit    = Takeprofit;
   trailingStop  = pTrailingStop;
   trailingStart = TrailingStart;
   trailingStep  = TrailingStep;

   start();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TrailingStop::~TrailingStop()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TrailingStop::start()
  {
   InpNameBuy="SL Buy";
   InpNameSell="SL Sell";
   InpStyle=STYLE_DASHDOTDOT;
//---
   m_slippage=10;
   TrallB =   0;
   TrallS =   0;

   ExtStoploss=0.0;
   ExtTakeprofit=0.0;
   ExtTrailingStop=0.0;
   ExtTrailingStart=0.0;
   ExtTrailingStep=0.0;

//--- tuning for 3 or 5 digits
   int digits_adjust=1;
   if(m_symbol.Digits()==3 || m_symbol.Digits()==5)
      digits_adjust=10;
   m_adjusted_point=m_symbol.Point()*digits_adjust;

   ExtStoploss       = stopLoss        * m_adjusted_point;
   ExtTakeprofit     = takeProfit      * m_adjusted_point;
   ExtTrailingStop   = trailingStop    * m_adjusted_point;
   ExtTrailingStart  = trailingStart   * m_adjusted_point;
   ExtTrailingStep   = trailingStart   * m_adjusted_point;

   if(!HLineCreate(0,InpNameBuy,0,0,clrBlue,InpStyle) || !HLineCreate(0,InpNameSell,0,0,clrRed,InpStyle))
      return(INIT_FAILED);

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool TrailingStop::HLineCreate(const long            chart_ID=0,// chart's ID 
                               const string          name="HLine",      // line name 
                               const int             sub_window=0,      // subwindow index 
                               double                price=0,           // line price 
                               const color           clr=clrRed,        // line color 
                               const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                               const int             width=1,           // line width 
                               const bool            back=false,        // in the background 
                               const bool            selection=false,   // highlight to move 
                               const bool            hidden=true,       // hidden in the object list 
                               const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool TrailingStop::HLineMove(const long   chart_ID=0,// chart's ID 
                             const string name="HLine", // line name 
                             double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool TrailingStop::HLineDelete(const long   chart_ID=0,// chart's ID 
                               const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//|                                                                  | 
//+------------------------------------------------------------------+ 
void TrailingStop::onCalculate()
  {
      int EXPERT_MAGIC = 2251;
      //--- declare and initialize the trade request and result of trade request
      MqlTradeRequest request;
      MqlTradeResult  result;
      int total=PositionsTotal(); // number of open positions   
      //--- iterate over all open positions
      for(int i=0; i<total; i++)
        {
         //--- parameters of the order
         ulong  position_ticket=PositionGetTicket(i);// ticket of the position
         string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol 
         int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
         ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
         double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
         double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
         double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position
         //--- output information about the position
         PrintFormat("#%I64u %s  %s  %.2f  %s  sl: %s  tp: %s  [%I64d]",
                     position_ticket,
                     position_symbol,
                     EnumToString(type),
                     volume,
                     DoubleToString(PositionGetDouble(POSITION_PRICE_OPEN),digits),
                     DoubleToString(sl,digits),
                     DoubleToString(tp,digits),
                     magic);
         //--- if the MagicNumber matches, Stop Loss and Take Profit are not defined
         //if(magic==EXPERT_MAGIC && sl==0 && tp==0)
         //  {
            //--- calculate the current price levels
            double price=PositionGetDouble(POSITION_PRICE_OPEN);
            double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            int    stop_level=(int)SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL);
            double price_level;
            //--- if the minimum allowed offset distance in points from the current close price is not set
            if(stop_level<=0)
               stop_level=150; // set the offset distance of 150 points from the current close price
            else
               stop_level+=50; // set the offset distance to (SYMBOL_TRADE_STOPS_LEVEL + 50) points for reliability

            //--- calculation and rounding of the Stop Loss and Take Profit values
            price_level=stop_level*SymbolInfoDouble(position_symbol,SYMBOL_POINT);
            if(type==POSITION_TYPE_BUY)
              {
               sl=NormalizeDouble(bid-price_level,digits);
               tp=NormalizeDouble(ask+price_level,digits);
              }
            else
              {
               sl=NormalizeDouble(ask+price_level,digits);
               tp=NormalizeDouble(bid-price_level,digits);
              }
            //--- zeroing the request and result values
            ZeroMemory(request);
            ZeroMemory(result);
            //--- setting the operation parameters
            request.action  =TRADE_ACTION_SLTP; // type of trade operation
            request.position=position_ticket;   // ticket of the position
            request.symbol=position_symbol;     // symbol 
            request.sl      =sl;                // Stop Loss of the position
            request.tp      =tp;                // Take Profit of the position
            request.magic=EXPERT_MAGIC;         // MagicNumber of the position
            //--- output information about the modification
            PrintFormat("Modify #%I64d %s %s",position_ticket,position_symbol,EnumToString(type));
            //--- send the request
            if(!OrderSend(request,result))
               PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
            //--- information about the operation   
            PrintFormat("retcode=%u  deal=%I64u  order=%I64u",result.retcode,result.deal,result.order);
           }
       // }

      //---
/*
   int b=0,s=0;
   ulong TicketB=0,TicketS=0;
   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name())
           {
            if(!RefreshRates())
               return;
            if(m_position.PositionType()==POSITION_TYPE_BUY)
              {
               b++;
               if(stopLoss!=0 && m_symbol.Bid()<=m_position.PriceOpen()-ExtStoploss)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               if(takeProfit!=0 && m_symbol.Bid()>=m_position.PriceOpen()+ExtTakeprofit)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               TicketB=m_position.Ticket();
               if(trailingStop>0)
                 {
                  double SL=m_symbol.Bid()-ExtTrailingStop;
                  if(SL>=m_position.PriceOpen()+ExtTrailingStart && (TrallB==0 || TrallB+ExtTrailingStep<SL))
                     TrallB=SL;
                 }
              }
            if(m_position.PositionType()==POSITION_TYPE_SELL)
              {
               s++;
               if(stopLoss!=0 && m_symbol.Ask()>=m_position.PriceOpen()+ExtStoploss)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               if(takeProfit!=0 && m_symbol.Ask()<=m_position.PriceOpen()-ExtTakeprofit)
                 {
                  if(m_trade.PositionClose(m_position.Ticket()))
                     continue;
                 }
               TicketS=m_position.Ticket();
               if(trailingStop>0)
                 {
                  double SL=m_symbol.Ask()+ExtTrailingStop;
                  if(SL<=m_position.PriceOpen()-ExtTrailingStart && (TrallS==0 || TrallS-ExtTrailingStep>SL))
                     TrallS=SL;
                 }
              }
           }
//---
   if(b!=0)
     {
      if(b>1)
         Comment("Трал корректно работает только с одной позицией");
      else
      if(TrallB!=0)
        {
         Comment("Тралим позицию ",TicketB);
         HLineMove(0,InpNameBuy,TrallB);
         if(m_symbol.Bid()<=TrallB)
           {
            if(m_position.SelectByTicket(TicketB))
               if(m_position.Profit()>0.0)
                  if(!m_trade.PositionClose(TicketB))
                     Comment("Ошибка закрытия позиции. Result Retcode: ",m_trade.ResultRetcode(),
                             ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
     }
   else
     {
      TrallB=0;
      HLineMove(0,InpNameBuy,0.1);
     }
//---
   if(s!=0)
     {
      if(s>1)
         Comment("Трал корректно работает только с одной позицией");
      else
      if(TrallS!=0)
        {
         Comment("Тралим позицию ",TicketS);
         HLineMove(0,InpNameSell,TrallS);
         if(m_symbol.Ask()>=TrallS)
           {
            if(m_position.SelectByTicket(TicketS))
               if(m_position.Profit()>0.0)
                  if(!m_trade.PositionClose(TicketS))
                     Comment("Ошибка закрытия позиции. Result Retcode: ",m_trade.ResultRetcode(),
                             ", description of result: ",m_trade.ResultRetcodeDescription());
           }
        }
     }
   else
     {
      TrallS=0;
      HLineMove(0,InpNameSell,0.1);
     }
//---
/*
   MQL_PROFILER
   The flag, that indicates the program operating in the code profiling mode
   
   MQL_TESTER
   The flag, that indicates the tester process
   
   MQL_OPTIMIZATION
   The flag, that indicates the optimization process
   
   MQL_VISUAL_MODE
   The flag, that indicates the visual tester process
*/
      //if((MQLInfoInteger(MQL_PROFILER) || MQLInfoInteger(MQL_TESTER) || 
      //   MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_VISUAL_MODE)) && !IsPositionExists())
      //  {
      //   m_trade.Buy(m_symbol.LotsMin(),m_symbol.Name());
      //   m_trade.Sell(m_symbol.LotsMin(),m_symbol.Name());
      //  }


     }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
   bool TrailingStop::RefreshRates(void)
     {
      //--- refresh rates
      if(!m_symbol.RefreshRates())
        {
         Print("RefreshRates error");
         return(false);
        }
      //--- protection against the return value of "zero"
      if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
         return(false);
      //---
      return(true);
     }
//+------------------------------------------------------------------+
//| Is position exists                                               |
//+------------------------------------------------------------------+
   bool TrailingStop::IsPositionExists(void)
     {
      for(int i=PositionsTotal()-1;i>=0;i--)
         if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
            if(m_position.Symbol()==m_symbol.Name())
               return(true);
      //---
      return(false);
     }
//+------------------------------------------------------------------+
