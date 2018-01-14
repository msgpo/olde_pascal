unit INOS;

interface

uses crt,vgraph,mouseunit;

const
     MAX_BUTTON=10;
     MAX_TEXT=10;
     MAX_WIN=10;

type Button=record
     x,y : word;
     size_x,col,txt_col : byte;
     pressed,selected : boolean;
     str : ^string;
     win : byte;
     WinConstX,WinConstY : byte;
end;

type TextBox=record
     x,y : word;
     max_char,size_x,str_pos : byte;
     selected : boolean;
     str : ^string;
     win : byte;
     WinConstX,WinConstY : byte;
end;

type Window=record
     x,y : word;
     size_x,temp_sx : word;
     size_y,temp_sy : byte;
     Bnum : byte;
     max,bottom,selected : boolean;
     str : ^string;
end;

var
   mouse : image;
   frame_counter,frame_temp : integer;
   MConstX,MConstY : byte;
   dbl_on,dbl_off,dbl_click : boolean;
   dbl_counter : byte;

   TextA : array[1..MAX_TEXT] of ^TextBox;
   TextOn : boolean;
   TextUsed : array[1..MAX_TEXT] of boolean;

   ButtonA : array[1..MAX_BUTTON] of ^Button;
   ButtonOn : boolean;
   ButtonUsed : array[1..MAX_BUTTON] of boolean;

   WinA : array[1..MAX_WIN] of ^Window;
   WinOn : boolean;
   WinUsed : array[1..MAX_WIN] of boolean;
   WinSelected : byte;
   WinMoving : boolean;

procedure InitOS;
function DoubleClick : boolean;
procedure MakeButton(anum : byte; win : byte; x,y : integer; str : string; col,txt_col : byte);
procedure DrawButton(anum : byte);
procedure DeleteButton(anum : byte);
procedure MakeTextBox(anum : byte; win : byte; x,y : integer; max_char : byte);
procedure DrawTextBox(anum : byte);
procedure DeleteTextBox(anum : byte);
procedure MakeWindow(anum : byte; x,y : integer; size_y : byte; str : string; Bnum : byte);
procedure DrawWindow(anum : byte);
procedure DeleteWindow(anum : byte);
procedure TextString(anum : byte; var str : string);
procedure UpdateOS;

implementation

procedure InitOS;
var loop1 : byte;
begin
     frame_counter:=0;
     frame_temp:=0;

     dbl_on:=false;
     dbl_off:=true;
     dbl_counter:=0;

     LoadImage(mouse,'cursor.img',1);

     ButtonOn:=false;

     for loop1:=1 to MAX_BUTTON do
         ButtonUsed[loop1]:=false;

     TextOn:=false;

     for loop1:=1 to MAX_TEXT do
         TextUsed[loop1]:=false;

     WinOn:=false;

     for loop1:=1 to MAX_WIN do
         WinUsed[loop1]:=false;

     WinSelected:=0;
     WinMoving:=false;
end;

function DoubleClick : boolean;
begin
     if (dbl_click) then
     begin
          dbl_click:=false;
          DoubleClick:=true;
          exit;
     end;

     DoubleClick:=false;
end;

procedure MakeButton(anum : byte; win : byte; x,y : integer; str : string; col,txt_col : byte);
begin
     ButtonOn:=true;

     if (ButtonUsed[anum]) then
        DeleteButton(anum);

     New(ButtonA[anum]);

     ButtonUsed[anum]:=true;

     ButtonA[anum]^.x:=x;
     ButtonA[anum]^.y:=y;

     New(ButtonA[anum]^.str);

     ButtonA[anum]^.str^:=str;
     ButtonA[anum]^.selected:=false;
     ButtonA[anum]^.pressed:=false;

     ButtonA[anum]^.size_x:=Length(ButtonA[anum]^.str^)*7+2;

     ButtonA[anum]^.col:=col;
     ButtonA[anum]^.txt_col:=txt_col;
     ButtonA[anum]^.win:=win;

     if (ButtonA[anum]^.win>0) then
     begin
          ButtonA[anum]^.WinConstX:=x-WinA[win]^.x;
          ButtonA[anum]^.WinConstY:=y-WinA[win]^.y;
     end;
end;

procedure MakeTextBox(anum : byte; win : byte; x,y : integer; max_char : byte);
begin
     TextOn:=true;

     if (TextUsed[anum]) then
        DeleteTextBox(anum);

     New(TextA[anum]);

     TextUsed[anum]:=true;

     TextA[anum]^.x:=x;
     TextA[anum]^.y:=y;
     TextA[anum]^.max_char:=max_char;
     TextA[anum]^.size_x:=max_char*7+6;
     TextA[anum]^.str_pos:=1;
     TextA[anum]^.selected:=false;

     New(TextA[anum]^.str);

     TextA[anum]^.win:=win;

     if (TextA[anum]^.win>0) then
     begin
          TextA[anum]^.WinConstX:=x-WinA[win]^.x;
          TextA[anum]^.WinConstY:=y-WinA[win]^.y;
     end;
end;

procedure MakeWindow(anum : byte; x,y : integer; size_y : byte; str : string; Bnum : byte);
begin
     WinOn:=true;

     if (WinUsed[anum]) then
        DeleteWindow(anum);

     New(WinA[anum]);

     WinUsed[anum]:=true;

     WinA[anum]^.x:=x;
     WinA[anum]^.y:=y;
     WinA[anum]^.size_x:=Length(str)*8+15;
     WinA[anum]^.size_y:=size_y;
     WinA[anum]^.temp_sx:=Length(str)*8+10;;
     WinA[anum]^.temp_sy:=size_y;
     WinA[anum]^.selected:=false;
     WinA[anum]^.bottom:=false;
     WinA[anum]^.max:=false;

     New(WinA[anum]^.str);

     WinA[anum]^.str^:=str;

     MakeButton(Bnum,anum,x+WinA[anum]^.size_x-10,y+1,'X',29,220);

     WinA[anum]^.Bnum:=Bnum;
end;

procedure DrawButton(anum : byte);
var loop1,tmp_col : byte;
begin
     if not(ButtonA[anum]^.selected) then
     begin
          hline(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y,220,vaddr);
          vline(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x,220,vaddr);
          hline(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y+9,200,vaddr);
          vline(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x+ButtonA[anum]^.size_x,200,vaddr);
     end
     else
     begin
          hline(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y,200,vaddr);
          vline(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x,200,vaddr);
          hline(ButtonA[anum]^.x,ButtonA[anum]^.x+ButtonA[anum]^.size_x,ButtonA[anum]^.y+9,220,vaddr);
          vline(ButtonA[anum]^.y,ButtonA[anum]^.y+9,ButtonA[anum]^.x+ButtonA[anum]^.size_x,220,vaddr);
     end;

     for loop1:=ButtonA[anum]^.y+1 to ButtonA[anum]^.y+8 do
         hline(ButtonA[anum]^.x+1,ButtonA[anum]^.x+ButtonA[anum]^.size_x-1,loop1,ButtonA[anum]^.col,vaddr);

     Text(ButtonA[anum]^.x+2,ButtonA[anum]^.y+2,ButtonA[anum]^.str^,ButtonA[anum]^.txt_col,vaddr);
end;

procedure DrawTextBox(anum : byte);
var loop1 : byte;
    c : char;
begin
     Square(TextA[anum]^.x,TextA[anum]^.y,TextA[anum]^.size_x,9,200,vaddr);

     for loop1:=TextA[anum]^.y+1 to TextA[anum]^.y+8 do
         hline(TextA[anum]^.x+1,TextA[anum]^.x+TextA[anum]^.size_x-1,loop1,220,vaddr);

     if (TextA[anum]^.selected) then
     begin
          if ((frame_counter mod 2)=0) then
             vline(TextA[anum]^.y+2,TextA[anum]^.y+7,TextA[anum]^.x+TextA[anum]^.str_pos*7-5,0,vaddr);

          if (KeyReady) then
          begin
               c:=GetKey;

               if (c=#13) then
               begin
                    TextA[anum]^.selected:=false;
                    exit;
               end;

               if (c=#8) then
                  if (TextA[anum]^.str_pos>1) then
                     Dec(TextA[anum]^.str_pos);

               if not(TextA[anum]^.str_pos=TextA[anum]^.max_char+1) then
               begin
                    TextA[anum]^.str^[TextA[anum]^.str_pos]:=c;

                    if not(c=#8) then
                       Inc(TextA[anum]^.str_pos);
               end;
          end;
     end;

     for loop1:=1 to TextA[anum]^.str_pos-1 do
         Text(TextA[anum]^.x+2+(loop1-1)*7,TextA[anum]^.y+2,TextA[anum]^.str^[loop1],0,vaddr);
end;

procedure DrawWindow(anum : byte);
var loop1,col : byte;
begin
     if (WinA[anum]^.selected) then
     begin
          if (((mouse_x-MConstX)+WinA[anum]^.size_x)>310) then mouse_x:=310-WinA[anum]^.size_x+MConstX;
          if ((mouse_x-MconstX)<5) then mouse_x:=5+MConstX;
          if ((mouse_y+5)>190) then mouse_y:=185;
          if (mouse_y<5) then mouse_y:=5;

          WinA[anum]^.x:=mouse_x-MConstX;
          WinA[anum]^.y:=mouse_y-5;

          ButtonA[WinA[anum]^.Bnum]^.x:=WinA[anum]^.x+WinA[anum]^.size_x-10;
          ButtonA[WinA[anum]^.Bnum]^.y:=WinA[anum]^.y+1;

          for loop1:=1 to MAX_BUTTON do
              if ((ButtonA[loop1]^.win=anum) and not(loop1=WinA[anum]^.Bnum)) then
              begin
                   ButtonA[loop1]^.x:=WinA[anum]^.x+ButtonA[loop1]^.WinConstX;
                   ButtonA[loop1]^.y:=WinA[anum]^.y+ButtonA[loop1]^.WinConstY;
              end;

          for loop1:=1 to MAX_TEXT do
              if (TextA[loop1]^.win=anum) then
              begin
                   TextA[loop1]^.x:=WinA[anum]^.x+TextA[loop1]^.WinConstX;
                   TextA[loop1]^.y:=WinA[anum]^.y+TextA[loop1]^.WinConstY;
              end;

          Square(WinA[anum]^.x,WinA[anum]^.y,WinA[anum]^.size_x,10,200,vaddr);
     end
     else
         if (WinA[anum]^.bottom) then
            Square(WinA[anum]^.x,WinA[anum]^.y,WinA[anum]^.size_x,10,200,vaddr)
     else
         Square(WinA[anum]^.x,WinA[anum]^.y,WinA[anum]^.size_x,WinA[anum]^.size_y,200,vaddr);

     if not(WinA[anum]^.selected) then
     begin
          for loop1:=WinA[anum]^.y+1 to (WinA[anum]^.y+WinA[anum]^.size_y-1) do
          begin
               if (loop1<WinA[anum]^.y+10) then
               begin
                    if (WinSelected=anum) then
                       col:=75
                    else
                        col:=200;
               end
               else col:=210;

               if ((WinA[anum]^.bottom) and (loop1>=WinA[anum]^.y+10)) then
                  break;
                  hline(WinA[anum]^.x+1,WinA[anum]^.x+WinA[anum]^.size_x-1,loop1,col,vaddr);
          end;

          Text(WinA[anum]^.x+5,WinA[anum]^.y+2,WinA[anum]^.str^,220,vaddr);

          if not(WinA[anum]^.bottom) then
          begin
               for loop1:=1 to MAX_BUTTON do
                   if ((ButtonA[loop1]^.win=anum) and not(loop1=WinA[anum]^.Bnum)) then
                      DrawButton(loop1);

               for loop1:=1 to MAX_TEXT do
                   if (TextA[loop1]^.win=anum) then
                      DrawTextBox(loop1);
          end;
     end;

     DrawButton(WinA[anum]^.Bnum);

     if (ButtonA[WinA[anum]^.Bnum]^.pressed) then
     begin
          WinSelected:=0;
          DeleteButton(WinA[anum]^.Bnum);

          for loop1:=1 to MAX_BUTTON do
              if (ButtonA[loop1]^.win=anum) then
                 DeleteButton(loop1);

          for loop1:=1 to MAX_TEXT do
              if (TextA[loop1]^.win=anum) then
                 DeleteTextBox(loop1);
          DeleteWindow(anum);
     end;
end;

procedure DeleteButton(anum : byte);
begin
     if (ButtonUsed[anum]) then
     begin
          Dispose(ButtonA[anum]);
          ButtonUsed[anum]:=false;
     end;
end;

procedure DeleteTextBox(anum : byte);
begin
     if (TextUsed[anum]) then
     begin
          Dispose(TextA[anum]);
          TextUsed[anum]:=false;
     end;
end;

procedure DeleteWindow(anum : byte);
begin
     if (WinUsed[anum]) then
     begin
          Dispose(WinA[anum]);
          WinUsed[anum]:=false;
     end;
end;

procedure TextString(anum : byte; var str : string);
var loop1 : byte;
begin
     str:='';

     for loop1:=1 to TextA[anum]^.str_pos-1 do
         str:=str+TextA[anum]^.str^[loop1];
end;

procedure WinFormat(anum : byte);
begin
     if ((WinA[anum]^.y+WinA[anum]^.size_y)>199) then
     begin
          WinA[anum]^.y:=175;
          ButtonA[WinA[anum]^.Bnum]^.x:=(WinA[anum]^.x+WinA[anum]^.size_x)-10;
          ButtonA[WinA[anum]^.Bnum]^.y:=WinA[anum]^.y+1;
          WinA[anum]^.bottom:=true;
     end
     else
         WinA[anum]^.bottom:=false;
end;

procedure UpdateOS;
var loop1 : byte;
begin

     GetMouse;

     if (mouse_x>318) then mouse_x:=318;
     if (mouse_x<0) then mouse_x:=0;
     if (mouse_y>199) then mouse_y:=199;
     if (mouse_y<0) then mouse_y:=0;

     if (mouse_button1) then
     begin
          if (WinOn) then
             for loop1:=1 to MAX_WIN do
             begin
                  if not(WinUsed[loop1]) then continue;
                  if (WinA[loop1]^.max) then continue;
                  if (WinMoving) then break;
                  if (((mouse_x>=WinA[loop1]^.x) and (mouse_x<=WinA[loop1]^.x+WinA[loop1]^.size_x-10) and
                       (mouse_y>=WinA[loop1]^.y) and (mouse_y<=WinA[loop1]^.y+WinA[loop1]^.size_y))) then
                       begin
                            if (mouse_y<=WinA[loop1]^.y+10) then
                            begin
                                 if ((WinSelected=0) or (WinSelected=loop1)) then
                                 begin
                                      WinA[loop1]^.selected:=true;
                                      MConstX:=mouse_x-WinA[loop1]^.x;
                                      WinMoving:=true;
                                 end;
                            end;

                            if (WinSelected=0) then
                               WinSelected:=loop1;
                       end
                       else
                           if (WinSelected=loop1) then
                              WinSelected:=0;
             end;

          if (ButtonOn) then
             for loop1:=1 to MAX_BUTTON do
             begin
                  if ((WinSelected>0) and (WinA[WinSelected]^.max)) then break;
                  if (WinMoving) then break;
                  if not(ButtonUsed[loop1]) then continue;
                  if (((mouse_x>=ButtonA[loop1]^.x) and (mouse_x<=ButtonA[loop1]^.x+ButtonA[loop1]^.size_x) and
                       (mouse_y>=ButtonA[loop1]^.y) and (mouse_y<=ButtonA[loop1]^.y+9))) then
                           ButtonA[loop1]^.selected:=true
                  else
                      ButtonA[loop1]^.selected:=false;
             end;

          if (TextOn) then
             for loop1:=1 to MAX_TEXT do
             begin
                  if ((WinSelected>0) and (WinA[WinSelected]^.max)) then break;
                  if (WinMoving) then break;
                  if ((TextA[loop1]^.win>0) and not(WinSelected=TextA[loop1]^.win)) then break;
                  if not(TextUsed[loop1]) then continue;
                  if (((mouse_x>=TextA[loop1]^.x) and (mouse_x<=TextA[loop1]^.x+TextA[loop1]^.size_x) and
                       (mouse_y>=TextA[loop1]^.y) and (mouse_y<=TextA[loop1]^.y+9))) then
                           TextA[loop1]^.selected:=true
                  else
                      TextA[loop1]^.selected:=false;
             end;

          if (dbl_off) then
          begin
               if ((frame_counter-frame_temp)>20) then
                  dbl_counter:=0;

               dbl_on:=true;
               dbl_off:=false;
          end;
     end
     else
     begin
          if (dbl_on) then
          begin
               dbl_on:=false;
               dbl_off:=true;
               Inc(dbl_counter);

               if (dbl_counter=1) then
                  frame_temp:=frame_counter;

               if (dbl_counter=2) then
               begin
                    dbl_click:=true;
                    dbl_counter:=0;
               end;
          end;

          if (dbl_click) then
          begin
               if (not(WinMoving) and (WinSelected>0)) then
               begin
                    if (WinA[WinSelected]^.max) then
                    begin
                         WinA[WinSelected]^.size_x:=WinA[WinSelected]^.temp_sx;
                         WinA[WinSelected]^.size_y:=WinA[WinSelected]^.temp_sy;
                         ButtonA[WinA[WinSelected]^.Bnum]^.x:=0+WinA[WinSelected]^.size_x-10;
                         WinA[WinSelected]^.max:=false;
                    end
                    else
                    begin
                         WinA[WinSelected]^.x:=0;
                         WinA[WinSelected]^.y:=0;
                         WinA[WinSelected]^.size_y:=199;
                         WinA[WinSelected]^.size_x:=319;
                         ButtonA[WinA[WinSelected]^.Bnum]^.x:=0+WinA[WinSelected]^.size_x-10;
                         ButtonA[WinA[WinSelected]^.Bnum]^.y:=0;
                         WinA[WinSelected]^.max:=true;
                    end;
               end;

               dbl_click:=false;
          end;

          if (ButtonOn) then
          begin
               for loop1:=1 to MAX_BUTTON do
                   ButtonA[loop1]^.pressed:=false;

               for loop1:=1 to MAX_BUTTON do
                   if (ButtonA[loop1]^.selected) then
                   begin
                        ButtonA[loop1]^.pressed:=true;
                        ButtonA[loop1]^.selected:=false;
                   end
                   else
                       ButtonA[loop1]^.pressed:=false;
          end;

          if (WinOn) then
             for loop1:=1 to MAX_WIN do
             begin
                  if (WinUsed[loop1]) then
                  begin
                       WinFormat(loop1);
                       WinA[loop1]^.selected:=false;
                  end;
             end;

          WinMoving:=false;
     end;

     if (ButtonOn) then
        for loop1:=1 to MAX_BUTTON do
            if ((ButtonUsed[loop1]) and (ButtonA[loop1]^.win=0)) then
               DrawButton(loop1);

     if (TextOn) then
        for loop1:=1 to MAX_TEXT do
            if ((TextUsed[loop1]) and (TextA[loop1]^.win=0)) then
               DrawTextBox(loop1);

     if (WinOn) then
        for loop1:=1 to MAX_WIN do
            if ((WinUsed[loop1]) and not(WinSelected=loop1)) then
               DrawWindow(loop1);

     if (WinSelected>0) then
        if (WinUsed[WinSelected]) then
           DrawWindow(WinSelected);

     PutImage(mouse,mouse_x,mouse_y,0,vaddr);
     Inc(frame_counter);
end;

end.