unit ButtonUnit;

interface

uses crt,vgraph2,mouseunit,anmunit;

type button=object
     x,y,length_x,length_y,pic : integer;
     pressed : boolean;
end;

var
   global_button_table : array[1..30] of button;
   occupied : array[1..30] of boolean;
   button_counter : integer;
   button_pics : array[1..10] of pointer;

procedure SetupButtons(filename : string);
procedure InitButton(cenx,ceny,length_x,length_y,pic : integer);
procedure DeleteButton(cenx,ceny : integer);
procedure DrawButtons(where : word);
function CheckButton(cenx,ceny : integer) : boolean;

implementation

procedure SetupButtons(filename : string);
var loop1 : integer;
begin
     Load_anm(filename);

     for loop1:=1 to 20 do
     begin
          put_anm(0,0,loop1);
          GetImage2(0,0,16,16,button_pics[loop1],true);
     end;

     for loop1:=1 to 20 do
     begin
          occupied[loop1]:=false;
          global_button_table[loop1].pressed:=false;
     end;

     cls(vga,0);
end;

procedure InitButton(cenx,ceny,length_x,length_y,pic : integer);
var loop1 : integer;
begin
     for loop1:=1 to 20 do
     begin
          if not(occupied[loop1]) then
          begin
               global_button_table[loop1].x:=cenx;
               global_button_table[loop1].y:=ceny;
               global_button_table[loop1].length_x:=length_x;
               global_button_table[loop1].length_y:=length_y;
               global_button_table[loop1].pic:=pic;
               Inc(button_counter);
               occupied[loop1]:=true;
               break;
          end;
     end;
end;

procedure DeleteButton(cenx,ceny : integer);
var loop1 : integer;
begin
     for loop1:=1 to 20 do
     begin
          if (global_button_table[loop1].x=cenx) and (global_button_table[loop1].y=ceny) then
          begin
               occupied[loop1]:=false;
               Dec(button_counter);
               break;
          end;
     end;
end;

procedure DrawButtons(where : word);
var loop1 : integer;
begin
     for loop1:=1 to 20 do
         if (occupied[loop1]) then
         begin
              Box(global_button_table[loop1].x,global_button_table[loop1].y,
                  global_button_table[loop1].length_x,global_button_table[loop1].length_y,7,where);

              if not(global_button_table[loop1].pressed) then
                 Box2(global_button_table[loop1].x,global_button_table[loop1].y,
                      global_button_table[loop1].length_x,global_button_table[loop1].length_x+2,
                      global_button_table[loop1].length_y,global_button_table[loop1].length_y+2,7,where)
              else
                  Box2(global_button_table[loop1].x,global_button_table[loop1].y,
                      global_button_table[loop1].length_x,global_button_table[loop1].length_x+2,
                      global_button_table[loop1].length_y,global_button_table[loop1].length_y+2,24,where);

              PutImage2(global_button_table[loop1].x-8,global_button_table[loop1].y-8,
                       button_pics[global_button_table[loop1].pic],NormalPut,where);
         end;
end;

function CheckButton(cenx,ceny : integer) : boolean;
var loop1 : integer;
begin
     if not(mouse_button1) then
     begin
          for loop1:=1 to 20 do
              global_button_table[loop1].pressed:=false;

          CheckButton:=false;
          exit;
     end;

     for loop1:=1 to 20 do
         if (global_button_table[loop1].x=cenx) and (global_button_table[loop1].y=ceny)
            and (occupied[loop1]) then
            if (mouse_x in [cenx-global_button_table[loop1].length_x..cenx+global_button_table[loop1].length_x])
               and (mouse_y in [cenx-global_button_table[loop1].length_y..cenx+global_button_table[loop1].length_y]) then
               begin
                    CheckButton:=true;
                    global_button_table[loop1].pressed:=true;
               end
               else
                   CheckButton:=false;
end;

end.