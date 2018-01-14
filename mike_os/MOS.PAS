unit MOS;

interface

uses crt,vgraph,mouseunit;

const
     {Window Constants}
     MAX_WIN=10;
     WIN_STATE_NORMAL=0;
     WIN_STATE_MAX=1;
     WIN_STATE_MIN=2;
     WIN_STATE_MOVING=3;

     {Button Constants}
     MAX_BUTTON=15;
     BUTTON_STATE_NORMAL=0;
     BUTTON_STATE_SELECTED=1;

     {Text Box Constants}
     MAX_TEXT=10;
     TEXT_STATE_NORMAL=0;
     TEXT_STATE_SELECTED=1;

     {Scroll Bar Constants}
     MAX_SCROLL=10;
     SCROLL_STATE_NORMAL=0;
     SCROLL_STATE_MOVING=1;
     SCROLL_TYPE_HORZ=0;
     SCROLL_TYPE_VERT=1;

type Window=record
     x,y : integer;
     size_x,temp_sx : word;
     size_y,temp_sy : byte;
     state : byte;
     Bnum : byte;
     draw_proc : boolean;
     proc : procedure;
     str : ^string;
end;

type Button=record
     x,y : integer;
     size_x : word;
     txt_col,bg_col : byte;
     rel_x,rel_y : byte;
     state : byte;
     pressed : boolean;
     str : ^string;
     win : byte;
end;

type TextBox=record
     x,y : integer;
     size_x : word;
     rel_x,rel_y : byte;
     state : byte;
     str_pos : byte;
     max_char : byte;
     str : ^string;
     win : byte;
end;

type Scroll=record
     x,y : word;
     size : byte;
     rel_x,rel_y : byte;
     bnum,bnum2 : byte;
     val,max_val : word;
     typ : byte;
     win : byte;
end;

var
   {OS Variables}
   OS_BACK_COLOR : byte;
   OS_PREDRAW,OS_POSTDRAW : boolean;
   OS_PREDRAW_PROC,OS_POSTDRAW_PROC : procedure;
   Win_Temp_Proc : procedure;
   mouse : image;

   {Window Variables}
   WinCount : byte;
   WinSelected : byte;
   WinOn : boolean;
   WinMoving : boolean;
   WinA : array[1..MAX_WIN] of ^Window;
   WinUsed : array[1..MAX_WIN] of boolean;

   MConstX : word;

   {Button Variables}
   ButtonCount : byte;
   ButtonOn : boolean;
   ButtonA : array[1..MAX_BUTTON] of ^Button;
   ButtonUsed : array[1..MAX_BUTTON] of boolean;

   {Text Box Variables}
   TextCount : byte;
   TextOn : boolean;
   TextSelected : boolean;
   TextA : array[1..MAX_TEXT] of ^TextBox;
   TextUsed : array[1..MAX_TEXT] of boolean;

   {Scroll Bar Variables}
   ScrollCount : byte;
   ScrollOn : boolean;
   ScrollA : array[1..MAX_SCROLL] of ^Scroll;
   ScrollUsed : array[1..MAX_SCROLL] of boolean;

procedure InitOS;
procedure MakeWindow(x,y,size_x : word; size_y : byte; str : string);
procedure MakeButton(win : byte; x,y : word; str : string; bg_col,txt_col : byte);
procedure MakeTextBox(win : byte; x,y : word; max_char : byte);
procedure MakeScrollBar(win : byte; x,y : word; typ : byte; val,max_val : word);
procedure DrawWindow(anum : byte);
procedure DrawButton(anum : byte);
procedure DrawTextBox(anum : byte);
procedure DrawScrollBar(anum : byte);
procedure TextString(anum : byte; var str1 : string);
procedure UpdateOS;
procedure DrawOS;

implementation

procedure InitOS;
var loop1 : byte;
begin
     {Init OS Variables}
     OS_BACK_COLOR:=0;
     OS_PREDRAW:=false;
     OS_POSTDRAW:=false;
     LoadPalette(Pal1,'game.pal');
     RestorePalette(Pal1);
     LoadImage(mouse,'cursor.img',1);

     {Init Window Variables}
     WinCount:=0;
     WinOn:=false;
     WinMoving:=false;
     WinSelected:=0;

     for loop1:=1 to MAX_WIN do
         WinUsed[loop1]:=false;

     MConstX:=0;

     {Init Button Variables}
     ButtonCount:=0;
     ButtonOn:=false;

     for loop1:=1 to MAX_BUTTON do
         ButtonUsed[loop1]:=false;

     {Init Text Box Variables}
     TextCount:=0;
     TextOn:=false;
     TextSelected:=false;

     for loop1:=1 to MAX_TEXT do
         TextUsed[loop1]:=false;

     {Init Scroll Bar Variables}
     ScrollCount:=0;
     ScrollOn:=false;

     for loop1:=1 to MAX_SCROLL do
         ScrollUsed[loop1]:=false;

end;

procedure MakeWindow(x,y,size_x : word; size_y : byte; str : string);
var loop1 : byte;
begin
     WinOn:=true;

     Inc(WinCount);

     if (WinCount>MAX_WIN) then
     begin
          WinCount:=MAX_WIN;

          for loop1:=1 to MAX_WIN do
              if not(WinUsed[loop1]) then
              begin
                   WinCount:=loop1;
                   break;
              end;
     end;

     WinUsed[WinCount]:=true;

     New(WinA[WinCount]);

     WinA[WinCount]^.x:=x;
     WinA[WinCount]^.y:=y;
     WinA[WinCount]^.size_x:=Length(str)*8+15+size_x;
     WinA[WinCount]^.size_y:=size_y;

     WinA[WinCount]^.state:=WIN_STATE_NORMAL;
     WinA[WinCount]^.draw_proc:=false;
     WinA[WinCount]^.proc:=nil;

     New(WinA[WinCount]^.str);

     WinA[WinCount]^.str^:=str;

     MakeButton(WinCount,WinA[WinCount]^.size_x-10,1,'X',29,220);

     WinA[WinCount]^.Bnum:=ButtonCount;
end;

procedure MakeButton(win : byte; x,y : word; str : string; bg_col,txt_col : byte);
var loop1 : byte;
begin
     ButtonOn:=true;

     Inc(ButtonCount);

     if (ButtonCount>MAX_BUTTON) then
     begin
          ButtonCount:=MAX_BUTTON;

          for loop1:=1 to MAX_BUTTON do
              if not(ButtonUsed[loop1]) then
              begin
                   ButtonCount:=loop1;
                   break;
              end;
     end;

     ButtonUsed[ButtonCount]:=true;

     New(ButtonA[ButtonCount]);

     if (win=0) then
     begin
          ButtonA[ButtonCount]^.x:=x;
          ButtonA[ButtonCount]^.y:=y;
     end
     else
     begin
          ButtonA[ButtonCount]^.x:=WinA[win]^.x+x;
          ButtonA[ButtonCount]^.y:=WinA[win]^.y+y;
          ButtonA[ButtonCount]^.rel_x:=x;
          ButtonA[ButtonCount]^.rel_y:=y;
     end;

     ButtonA[ButtonCount]^.size_x:=Length(str)*7+2;

     ButtonA[ButtonCount]^.state:=BUTTON_STATE_NORMAL;
     ButtonA[ButtonCount]^.pressed:=false;

     ButtonA[ButtonCount]^.bg_col:=bg_col;
     ButtonA[ButtonCount]^.txt_col:=txt_col;

     New(ButtonA[ButtonCount]^.str);

     ButtonA[ButtonCount]^.str^:=str;
     ButtonA[ButtonCount]^.win:=win;
end;

procedure MakeTextBox(win : byte; x,y : word; max_char : byte);
var loop1 : byte;
begin
     TextOn:=true;

     Inc(TextCount);

     if (TextCount>MAX_TEXT) then
     begin
          TextCount:=MAX_TEXT;

          for loop1:=1 to MAX_TEXT do
              if not(TextUsed[loop1]) then
              begin
                   TextCount:=loop1;
                   break;
              end;
     end;

     TextUsed[TextCount]:=true;

     New(TextA[TextCount]);

     if (win=0) then
     begin
          TextA[TextCount]^.x:=x;
          TextA[TextCount]^.y:=y;
     end
     else
     begin
          TextA[TextCount]^.x:=WinA[win]^.x+x;
          TextA[TextCount]^.y:=WinA[win]^.y+y;
          TextA[TextCount]^.rel_x:=x;
          TextA[TextCount]^.rel_y:=y;
     end;

     TextA[TextCount]^.size_x:=max_char*7+6;
     TextA[TextCount]^.max_char:=max_char;
     TextA[TextCount]^.str_pos:=1;
     TextA[TextCount]^.state:=TEXT_STATE_NORMAL;

     TextA[TextCount]^.win:=win;

     New(TextA[TextCount]^.str);
end;

procedure MakeScrollBar(win : byte; x,y : word; typ : byte; val,max_val : word);
var loop1 : byte;
begin
     ScrollOn:=true;

     Inc(ScrollCount);

     if (ScrollCount>MAX_SCROLL) then
     begin
          ScrollCount:=MAX_SCROLL;

          for loop1:=1 to MAX_SCROLL do
              if not(ScrollUsed[loop1]) then
              begin
                   ScrollCount:=loop1;
                   break;
              end;
     end;

     ScrollUsed[ScrollCount]:=true;

     New(ScrollA[ScrollCount]);

     if (win=0) then
     begin
          ScrollA[ScrollCount]^.x:=x;
          ScrollA[ScrollCount]^.y:=y;
     end
     else
     begin
          ScrollA[ScrollCount]^.x:=WinA[win]^.x+x;
          ScrollA[ScrollCount]^.y:=WinA[win]^.y+y;
          ScrollA[ScrollCount]^.rel_x:=x;
          ScrollA[ScrollCount]^.rel_y:=y;
     end;

     ScrollA[ScrollCount]^.typ:=typ;
     ScrollA[ScrollCount]^.val:=val;
     ScrollA[ScrollCount]^.max_val:=max_val;
     ScrollA[ScrollCount]^.win:=win;

     MakeButton(win,x-10,y,'<',210,220);
     ScrollA[ScrollCount]^.bnum:=ButtonCount;

     MakeButton(win,x+max_val,y,'>',210,220);
     ScrollA[ScrollCount]^.bnum2:=ButtonCount;
end;

procedure DrawWindow(anum : byte);
var loop1 : integer;
begin
     Square_Clip(WinA[anum]^.x,WinA[anum]^.y,WinA[anum]^.size_x,WinA[anum]^.size_y,200,vaddr2);

     if (WinSelected=anum) then
        for loop1:=WinA[anum]^.y+1 to WinA[anum]^.y+9 do
            hline_clip(WinA[anum]^.x+1,WinA[anum]^.x+WinA[anum]^.size_x-1,loop1,75,vaddr2)
     else
         for loop1:=WinA[anum]^.y+1 to WinA[anum]^.y+9 do
             hline_clip(WinA[anum]^.x+1,WinA[anum]^.x+WinA[anum]^.size_x-1,loop1,200,vaddr2);

     hline_clip(WinA[anum]^.x+1,WinA[anum]^.x+WinA[anum]^.size_x-1,WinA[anum]^.y+10,200,vaddr2);

     for loop1:=WinA[anum]^.y+11 to WinA[anum]^.y+WinA[anum]^.size_y-1 do
         hline_clip(WinA[anum]^.x+1,WinA[anum]^.x+WinA[anum]^.size_x-1,loop1,210,vaddr2);

     Text(WinA[anum]^.x+2,WinA[anum]^.y+2,WinA[anum]^.str^,220,vaddr2);

     DrawButton(WinA[anum]^.Bnum);

     if (WinA[anum]^.draw_proc) then
     begin
          Win_Temp_Proc:=WinA[anum]^.proc;

          asm
             call Win_Temp_Proc
          end;
     end;
end;

procedure DrawButton(anum : byte);
var loop1 : integer;
begin
     if (ButtonA[anum]^.state=BUTTON_STATE_SELECTED) then
     begin
          hline_clip(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y,200,vaddr2);
          hline_clip(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y+9,220,vaddr2);
          vline_clip(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x,200,vaddr2);
          vline_clip(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x+ButtonA[anum]^.size_x,220,vaddr2);
     end
     else
     begin
          hline_clip(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y,220,vaddr2);
          hline_clip(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y+9,200,vaddr2);
          vline_clip(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x,220,vaddr2);
          vline_clip(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x+ButtonA[anum]^.size_x,200,vaddr2);
     end;

     for loop1:=ButtonA[anum]^.y+1 to ButtonA[anum]^.y+8 do
         hline_clip(ButtonA[anum]^.x+1,ButtonA[anum]^.x+ButtonA[anum]^.size_x-1,loop1,ButtonA[anum]^.bg_col,vaddr2);

     Text(ButtonA[anum]^.x+2,ButtonA[anum]^.y+2,ButtonA[anum]^.str^,ButtonA[anum]^.txt_col,vaddr2);
end;

procedure DrawTextBox(anum : byte);
var loop1 : integer;
begin
     Square(TextA[anum]^.x,TextA[anum]^.y,TextA[anum]^.size_x,9,200,vaddr2);

     for loop1:=TextA[anum]^.y+1 to TextA[anum]^.y+8 do
         hline_clip(TextA[anum]^.x+1,TextA[anum]^.x+TextA[anum]^.size_x-1,loop1,220,vaddr2);

     for loop1:=1 to TextA[anum]^.str_pos-1 do
         Text(TextA[anum]^.x+2+(loop1-1)*7,TextA[anum]^.y+2,TextA[anum]^.str^[loop1],0,vaddr2);

     if (TextA[anum]^.state=TEXT_STATE_SELECTED) then
        vline_clip(TextA[anum]^.y+2,TextA[anum]^.y+7,TextA[anum]^.x+TextA[anum]^.str_pos*7-5,210,vaddr2);
end;

procedure DrawScrollBar(anum : byte);
var loop1 : byte;
begin
     if (ScrollA[anum]^.typ=SCROLL_TYPE_HORZ) then
     begin
          Square(ScrollA[anum]^.x,ScrollA[anum]^.y,ScrollA[anum]^.max_val,9,200,vaddr2);

          for loop1:=ScrollA[anum]^.y+1 to ScrollA[anum]^.y+8 do
              hline(ScrollA[anum]^.x+1,ScrollA[anum]^.x+ScrollA[anum]^.max_val-2,loop1,210,vaddr2);

          vline(ScrollA[anum]^.y+1,ScrollA[anum]^.y+8,ScrollA[anum]^.x+1+ScrollA[anum]^.val,220,vaddr2);
     end;

     DrawButton(ScrollA[anum]^.bnum);
     DrawButton(ScrollA[anum]^.bnum2);
end;

procedure DeleteWindow(anum : byte);
begin
     WinUsed[anum]:=false;
     if (WinSelected=anum) then WinSelected:=0;
     Dispose(WinA[anum]);
end;

procedure DeleteButton(anum : byte);
begin
     ButtonUsed[anum]:=false;
     Dispose(ButtonA[anum]);
end;

procedure DeleteTextBox(anum : byte);
begin
     TextUsed[anum]:=false;
     Dispose(TextA[anum]);
end;

procedure TextString(anum : byte; var str1 : string);
var loop1 : byte;
begin
     str1:='';

     for loop1:=1 to TextA[anum]^.str_pos-1 do
         str1:=str1+TextA[anum]^.str^[loop1];
end;

procedure DrawOS;
var loop1,loop2 : byte;
begin
     cls(vaddr2,OS_BACK_COLOR);

     if (OS_PREDRAW) then
        asm
           call OS_PREDRAW_PROC
        end;

     if (ButtonOn) then
        for loop1:=1 to MAX_BUTTON do
            if ((ButtonUsed[loop1]) and (ButtonA[loop1]^.win=0)) then
               DrawButton(loop1);

     if (TextOn) then
        for loop1:=1 to MAX_TEXT do
            if ((TextUsed[loop1]) and (TextA[loop1]^.win=0)) then
               DrawTextBox(loop1);

     if (ScrollOn) then
        for loop1:=1 to MAX_SCROLL do
            if ((ScrollUsed[loop1]) and (ScrollA[loop1]^.win=0)) then
               DrawScrollBar(loop1);

     if (WinOn) then
        for loop1:=1 to MAX_WIN do
            if ((WinUsed[loop1]) and not(loop1=WinSelected)) then
            begin
                 DrawWindow(loop1);

                 for loop2:=1 to MAX_BUTTON do
                     if ((ButtonUsed[loop2]) and (ButtonA[loop2]^.win=loop1)) then
                        DrawButton(loop2);

                 for loop2:=1 to MAX_TEXT do
                     if ((TextUsed[loop2]) and (TextA[loop2]^.win=loop1)) then
                        DrawTextBox(loop2);
            end;

        if (WinSelected>0) then
        begin
             DrawWindow(WinSelected);

             for loop1:=1 to MAX_BUTTON do
                 if ((ButtonUsed[loop1]) and (ButtonA[loop1]^.win=WinSelected)) then
                    DrawButton(loop1);

             for loop1:=1 to MAX_TEXT do
                 if ((TextUsed[loop1]) and (TextA[loop1]^.win=WinSelected)) then
                    DrawTextBox(loop1);
        end;

     if (OS_POSTDRAW) then
        asm
           call OS_POSTDRAW_PROC
        end;
end;

procedure UpdateOS;
var loop1,loop2,loop3 : byte;
    c : char;
begin
     GetMouse;

     if (mouse_x>318) then mouse_x:=318;
     if (mouse_x<0) then mouse_x:=0;
     if (mouse_y>199) then mouse_y:=199;
     if (mouse_y<0) then mouse_y:=0;

     if (mouse_button1) then
     begin
          if ((WinOn) and not(TextSelected)) then
             for loop1:=1 to MAX_WIN do
             begin
                  if not(WinUsed[loop1]) then continue;
                  if (WinMoving) then break;

                  if (((mouse_x>=WinA[loop1]^.x) and (mouse_x<=WinA[loop1]^.x+WinA[loop1]^.size_x)) and
                       (mouse_y>=WinA[loop1]^.y) and (mouse_y<=WinA[loop1]^.y+WinA[loop1]^.size_y)) then
                       begin
                            if ((mouse_y<=WinA[loop1]^.y+10) and (mouse_x<=WinA[loop1]^.x+WinA[loop1]^.size_x-10)) then
                               if ((WinSelected=0) or (WinSelected=loop1)) then
                               begin
                                    WinA[loop1]^.state:=WIN_STATE_MOVING;
                                    WinMoving:=true;
                                    MConstX:=mouse_x-WinA[loop1]^.x;
                               end;

                            if (WinSelected=0) then
                            begin
                                 WinSelected:=loop1;
                                 DrawOS;
                            end;
                       end
                       else
                           if (WinSelected=loop1) then
                           begin
                                WinSelected:=0;
                                DrawOS;
                           end;
             end;

          if ((ButtonOn) and not(TextSelected)) then
             for loop1:=1 to MAX_BUTTON do
             begin
                  if (WinMoving) then break;

                  if not(ButtonUsed[loop1]) then continue;
                  if (ButtonA[loop1]^.state=BUTTON_STATE_SELECTED) then continue;

                  if (((mouse_x>=ButtonA[loop1]^.x) and (mouse_x<=ButtonA[loop1]^.x+ButtonA[loop1]^.size_x)) and
                       (mouse_y>=ButtonA[loop1]^.y) and (mouse_y<=ButtonA[loop1]^.y+9)) then
                       begin
                            ButtonA[loop1]^.state:=BUTTON_STATE_SELECTED;
                            DrawOS;
                       end;
             end;

          if (TextOn) then
             for loop1:=1 to MAX_TEXT do
             begin
                  if (WinMoving) then break;
                  if not(TextUsed[loop1]) then continue;

                  if (((mouse_x>=TextA[loop1]^.x) and (mouse_x<=TextA[loop1]^.x+TextA[loop1]^.size_x)) and
                       (mouse_y>=TextA[loop1]^.y) and (mouse_y<=TextA[loop1]^.y+9)) then
                       begin
                            TextA[loop1]^.state:=TEXT_STATE_SELECTED;
                            TextSelected:=true;
                            DrawOS;
                       end
                       else
                           if not(TextA[loop1]^.state=TEXT_STATE_NORMAL) then
                           begin
                                TextA[loop1]^.state:=TEXT_STATE_NORMAL;
                                TextSelected:=false;
                                DrawOS;
                           end;

             end;

          if (ScrollOn) then
             for loop1:=1 to MAX_SCROLL do
             begin
                  if (WinMoving) then break;
                  if not(ScrollUsed[loop1]) then continue;

                  if (ButtonA[ScrollA[loop1]^.bnum]^.state=BUTTON_STATE_SELECTED) then
                  begin
                       Dec(ScrollA[loop1]^.val);

                       if (ScrollA[loop1]^.val<=1) then
                          ScrollA[loop1]^.val:=1;

                       DrawScrollBar(loop1);
                       delay(5);
                  end;

                  if (ButtonA[ScrollA[loop1]^.bnum2]^.state=BUTTON_STATE_SELECTED) then
                  begin
                       Inc(ScrollA[loop1]^.val);

                       if (ScrollA[loop1]^.val>=ScrollA[loop1]^.max_val) then
                          ScrollA[loop1]^.val:=ScrollA[loop1]^.max_val-1;

                       DrawScrollBar(loop1);
                       delay(5);
                  end;
          end;
     end
     else
     begin
          if (WinMoving) then
             DrawOS;

          WinMoving:=false;

          if (ButtonOn) then
             for loop1:=1 to MAX_BUTTON do
             begin
                  if not(ButtonUsed[loop1]) then continue;

                  ButtonA[loop1]^.pressed:=false;

                  if (ButtonA[loop1]^.state=BUTTON_STATE_SELECTED) then
                  begin
                       if (((mouse_x>=ButtonA[loop1]^.x) and (mouse_x<=ButtonA[loop1]^.x+ButtonA[loop1]^.size_x)) and
                            (mouse_y>=ButtonA[loop1]^.y) and (mouse_y<=ButtonA[loop1]^.y+9)) then
                            begin
                                 ButtonA[loop1]^.pressed:=true;
                                 ButtonA[loop1]^.state:=BUTTON_STATE_NORMAL;

                                 for loop2:=1 to MAX_WIN do
                                 begin
                                      if not(WinUsed[loop2]) then continue;

                                      if (WinA[loop2]^.Bnum=loop1) then
                                      begin
                                           DeleteButton(loop1);
                                           DeleteWindow(loop2);

                                           for loop3:=1 to MAX_BUTTON do
                                               if ((ButtonUsed[loop3]) and (ButtonA[loop3]^.win=loop2)) then
                                                  DeleteButton(loop3);
                                      end;
                                 end;
                            end
                            else
                            begin
                                 ButtonA[loop1]^.pressed:=false;
                                 ButtonA[loop1]^.state:=BUTTON_STATE_NORMAL;
                            end;
                       DrawOS;
                  end;
             end;

          if (TextOn) then
             for loop1:=1 to MAX_TEXT do
             begin
                  if not(TextUsed[loop1]) then continue;
                  if not(TextA[loop1]^.state=TEXT_STATE_SELECTED) then continue;

                  if (KeyReady) then
                  begin
                       c:=GetKey;

                       if (c=#13) then
                       begin
                            TextA[loop1]^.state:=TEXT_STATE_NORMAL;
                            TextSelected:=false;
                            DrawOS;
                            exit;
                       end;

                       if (c=#8) then
                          if (TextA[loop1]^.str_pos>1) then
                             Dec(TextA[loop1]^.str_pos);

                       if not(TextA[loop1]^.str_pos=TextA[loop1]^.max_char+1) then
                       begin
                            TextA[loop1]^.str^[TextA[loop1]^.str_pos]:=c;

                            if not(c=#8) then
                               Inc(TextA[loop1]^.str_pos);
                       end;

                       DrawTextBox(loop1);
                  end;
             end;
     end;

     if (WinMoving) then
     begin
          WinA[WinSelected]^.x:=mouse_x-MConstX;
          WinA[WinSelected]^.y:=mouse_y-5;

          for loop1:=1 to MAX_BUTTON do
              if ((ButtonUsed[loop1]) and (ButtonA[loop1]^.win=WinSelected)) then
              begin
                   ButtonA[loop1]^.x:=WinA[WinSelected]^.x+ButtonA[loop1]^.rel_x;
                   ButtonA[loop1]^.y:=WinA[WinSelected]^.y+ButtonA[loop1]^.rel_y;
              end;

          for loop1:=1 to MAX_TEXT do
              if ((TextUsed[loop1]) and (TextA[loop1]^.win=WinSelected)) then
              begin
                   TextA[loop1]^.x:=WinA[WinSelected]^.x+TextA[loop1]^.rel_x;
                   TextA[loop1]^.y:=WinA[WinSelected]^.y+TextA[loop1]^.rel_y;
              end;

          Square_Clip(WinA[WinSelected]^.x,WinA[WinSelected]^.y,WinA[WinSelected]^.size_x,10,200,vaddr);
     end;

     PutImage(mouse,mouse_x,mouse_y,0,vaddr);
end;

end.