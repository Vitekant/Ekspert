//+------------------------------------------------------------------+
//|                                                 TickReporter.mq4 |
//|                                                            Vitek |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Vitek"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

const bool debug=false;
const bool verbose=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CloudColor
  {
   green=0,
   red=1
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(Volume[0]==1)
     {
      // ustawienie parametr㷠do metody Ichimoku
      int TS_parameter = 7;
      int KS_parameter = 28;
      int SSB_parameter= 119;
      //----------------------------------------

      double candle_open=Close[2]; // Hack, zeby poprawnie ustalic czy swieca opuscila chmure.
      double candle_close=Close[1];
      double senkou_spanA_current = iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,1);
      double senkou_spanB_current = iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,1);
      CloudColor cloudColor=senkou_spanA_current>senkou_spanB_current ? green : red;

      double tenkan_sen_current=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_TENKANSEN,1);
      double kijou_sen_current=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_KIJUNSEN,1);

      double chikou_span_past=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_CHIKOUSPAN,KS_parameter+1);
      double senkou_spanA_past=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,KS_parameter+1);
      double senkou_spanB_past=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,KS_parameter+1);
      double tenkan_sen_past=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_TENKANSEN,KS_parameter+1);
      double kijou_sen_past=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_KIJUNSEN,KS_parameter+1);

      double senkou_spanA_future=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANA,-KS_parameter+1);
      double senkou_spanB_future=iIchimoku(NULL,0,TS_parameter,KS_parameter,SSB_parameter,MODE_SENKOUSPANB,-KS_parameter+1);

      if(verbose)
        {
         Print("Open price of the current bar of the current chart=",candle_open);
         Print("Close price of the current bar of the current chart=",candle_close);
         Print("Tenkan-Sen the current bar of the current chart=",tenkan_sen_current);
         Print("Kijou-Sen of the current bar of the current chart=",kijou_sen_current);
         Print("SSA current=",senkou_spanA_current);
         Print("SSB current=",senkou_spanB_current);

         Print("Chikou Span from ",KS_parameter," periods ago=",chikou_span_past);
         Print("Price from ",KS_parameter," periods ago=",Close[KS_parameter+1]);
         Print("Tenkan-Sen from ",KS_parameter," periods ago=",tenkan_sen_past);
         Print("Kijou-Sen from ",KS_parameter," periods ago=",kijou_sen_past);
         Print("SSA from ",KS_parameter," periods ago=",senkou_spanA_past);
         Print("SSB from ",KS_parameter," periods ago=",senkou_spanB_past);
         Print("Cloud color is ",EnumToString(cloudColor));
        }

      int bull_bear_indicator=0;
      int weak_bull_bear_indicator=0;
      bool print_result=false;

      if(candle_close>candle_open && candle_close>senkou_spanA_current && candle_open<senkou_spanA_current && cloudColor==green)
        {
         if(debug)
           {
            Print("Swieca wyszla wzrostowo z chmury wzrostowej. ",Time[1]);
           }
         bull_bear_indicator++;
        }

      if(candle_close>candle_open && candle_close>senkou_spanB_current && candle_open<senkou_spanB_current && cloudColor==red)
        {
         if(debug)
           {
            Print("Swieca wyszla wzrostowo z chmury spadkowej. ",Time[1]);
           }
         weak_bull_bear_indicator++;
        }

      if(candle_close<candle_open && candle_close<senkou_spanA_current && candle_open>senkou_spanA_current && cloudColor==red)
        {
         if(debug)
           {
            Print("Swieca wyszla spadkowo z chmury spadkowej. ",Time[1]);
           }
         bull_bear_indicator--;
        }

      if(candle_close<candle_open && candle_close<senkou_spanB_current && candle_open>senkou_spanB_current && cloudColor==green)
        {
         if(debug)
           {
            Print("Swieca wyszla spadkowo z chmury wzrostowej. ",Time[1]);
           }
         weak_bull_bear_indicator--;
        }

      if(tenkan_sen_current>kijou_sen_current)
        {
         if(debug)
           {
            Print("Tenkan-Sen jest powyzej Kijou-Sen. Tendencja wzrostowa. ",Time[1]);
           }
         bull_bear_indicator++;
         weak_bull_bear_indicator++;
        }

      if(tenkan_sen_current<kijou_sen_current)
        {
         if(debug)
           {
            Print("Tenkan-Sen jest ponizej Kijou-Sen. Tendencja spadkowa. ",Time[1]);
           }
         bull_bear_indicator--;
         weak_bull_bear_indicator--;
        }

      if(chikou_span_past>senkou_spanA_past && chikou_span_past>senkou_spanB_past && chikou_span_past>kijou_sen_past && chikou_span_past>Close[KS_parameter+1])
        {
         if(debug)
           {
            Print("Chikou Span sprzed ",KS_parameter," okres㷠ponad wszystkimi wskaznikami. Tendencja wzrostowa. ",Time[1]);
           }
         bull_bear_indicator++;
         weak_bull_bear_indicator++;
        }

      if(chikou_span_past<senkou_spanA_past && chikou_span_past<senkou_spanB_past && chikou_span_past<kijou_sen_past && chikou_span_past<Close[KS_parameter+1])
        {
         if(debug)
           {
            Print("Chikou Span sprzed ",KS_parameter," okres㷠ponizej wszystkich wskaznik㷮 Tendencja spadkowa. ",Time[1]);
           }
         bull_bear_indicator--;
         weak_bull_bear_indicator--;
        }

      if(candle_close>tenkan_sen_current)
        {
         if(debug)
           {
            Print("Cena jest powyzej Tenkan-Sen. Tendencja wzrostowa. ",Time[1]);
           }
         bull_bear_indicator++;
         weak_bull_bear_indicator++;
        }

      if(candle_close<tenkan_sen_current)
        {
         if(debug)
           {
            Print("Cena jest ponizej Tenkan-Sen. Tendencja spadkowa. ",Time[1]);
           }
         bull_bear_indicator--;
         weak_bull_bear_indicator--;
        }

      if(senkou_spanA_future>senkou_spanB_future)
        {
         if(debug)
           {
            Print("Chmura wzrostowa w przyszlosci. Tendencja wzrostowa. ",Time[1]);
           }
         bull_bear_indicator++;
         weak_bull_bear_indicator++;
        }

      if(senkou_spanA_future<senkou_spanB_future)
        {
         if(debug)
           {
            Print("Chmura spadkowa w przyszlosci. Tendencja spadkowa. ",Time[1]);
           }
         bull_bear_indicator--;
         weak_bull_bear_indicator--;
        }

      // mechanizm kupowania dla silnej tendencji wzrostowej
      if(bull_bear_indicator>=5) // jezeli bull_bear_indicator = 5 tzn. ze spelnione wszystkie 5 warunk㷬 aby kupowac! zeby wylaczyc kupowanie wpisz liczbe wieksza od 5
        {
         Print("Silna tendencja wzrostowa. Kupuj!!! ",Time[1]);
         double price=Ask;
         Print("Ask=",Ask," Bid=",Bid);
         //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
         //minstoplevel = MathMax(20, minstoplevel);
         //Print("Minimum Stop Level=",minstoplevel," points");
         double stoploss=NormalizeDouble(Bid-60*Point,Digits);
         //double stoploss=NormalizeDouble(kijou_sen_current-30*Point,Digits); 
         double takeprofit=NormalizeDouble(Ask+60*Point,Digits);
         //double takeprofit=NormalizeDouble(Ask+200*Point,Digits);
         Print("Price=",price," SL=",stoploss," TP=",takeprofit);
         int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"Buy order",16384,0,clrGreen);
         if(ticket<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
           {
            Print("OrderSend placed successfully");
           }
        }
      //---------------------------------------------------

      // mechanizm sprzedawania dla silnej tendencji spadkowej
      if(bull_bear_indicator<=-5) // zeby wylaczyc sprzedawanie wpisz liczbe mniejsza od -5
        {
         Print("Silna tendencja spadkowa. Sprzedawaj!!! ",Time[1]);
         double price=Bid;

         Print("Ask=",Ask," Bid=",Bid);
         //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
         //minstoplevel = MathMax(20, minstoplevel);
         //Print("Minimum Stop Level=",minstoplevel," points");
         //Print("Points", Point);
         double stoploss=NormalizeDouble(Ask+60*Point,Digits);
         //double stoploss=NormalizeDouble(kijou_sen_current+30*Point,Digits); 
         double takeprofit=NormalizeDouble(Bid-60*Point,Digits);
         //double takeprofit=NormalizeDouble(Bid-200*Point,Digits);
         Print("Price=",price," SL=",stoploss," TP=",takeprofit);
         int ticket=OrderSend(Symbol(),OP_SELL,1,price,3,stoploss,takeprofit,"Sell order",16384,0,clrGreen);
         if(ticket<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
           {
            Print("OrderSend placed successfully");
           }
        }
      //---------------------------------------------------

      // mechanizm kupowania dla slabej tendencji wzrostowej
      if(weak_bull_bear_indicator>=5) // zeby wylaczyc sprzedawanie wpisz liczbe wieksza od 5
        {
         Print("Slaba tendencja wzrostowa. Kupuj!!! ",Time[1]);
         double price=Ask;
         Print("Ask=",Ask," Bid=",Bid);
         //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
         //minstoplevel = MathMax(20, minstoplevel);
         //Print("Minimum Stop Level=",minstoplevel," points");
         double stoploss=NormalizeDouble(Bid-60*Point,Digits);
         //double stoploss=NormalizeDouble(kijou_sen_current-30*Point,Digits); 
         double takeprofit=NormalizeDouble(Ask+60*Point,Digits);
         //double takeprofit=NormalizeDouble(Ask+200*Point,Digits);
         Print("Price=",price," SL=",stoploss," TP=",takeprofit);
         int ticket=OrderSend(Symbol(),OP_BUY,1,price,3,stoploss,takeprofit,"Buy order",16384,0,clrGreen);
         if(ticket<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
           {
            Print("OrderSend placed successfully");
           }
        }
      //---------------------------------------------------

      // mechanizm sprzedawania dla slabej tendencji spadkowej
      if(weak_bull_bear_indicator<=-5) // zeby wylaczyc sprzedawanie wpisz liczbe mniejsza od -5
        {
         Print("Slaba tendencja spadkowa. Sprzedawaj!!! ",Time[1]);
         double price=Bid;

         Print("Ask=",Ask," Bid=",Bid);
         //double minstoplevel=MarketInfo(Symbol(),MODE_STOPLEVEL);
         //minstoplevel = MathMax(20, minstoplevel);
         //Print("Minimum Stop Level=",minstoplevel," points");
         //Print("Points", Point);
         double stoploss=NormalizeDouble(Ask+60*Point,Digits);
         //double stoploss=NormalizeDouble(kijou_sen_current+30*Point,Digits); 
         double takeprofit=NormalizeDouble(Bid-60*Point,Digits);
         //double takeprofit=NormalizeDouble(Bid-200*Point,Digits);
         Print("Price=",price," SL=",stoploss," TP=",takeprofit);
         int ticket=OrderSend(Symbol(),OP_SELL,1,price,3,stoploss,takeprofit,"Sell order",16384,0,clrGreen);
         if(ticket<0)
           {
            Print("OrderSend failed with error #",GetLastError());
           }
         else
           {
            Print("OrderSend placed successfully");
           }
        }

      if(print_result)
        {
         Print("Tendencja silna: ",bull_bear_indicator);
         Print("Tendencja slaba: ",weak_bull_bear_indicator);
        }
     }
  }
//+------------------------------------------------------------------+
