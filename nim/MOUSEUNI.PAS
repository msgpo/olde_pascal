unit MouseUnit;

interface

uses crt,vgraph,anmunit;

var
   mouse_x,mouse_y : integer;
   mouse_on,mouse_button1,mouse_button2 : boolean;
   mouse_pointer : pointer;

procedure InitMouse;
procedure ShowMouse;
procedure HideMouse;
procedure GetMouse;
procedure Svga_GetMouse;

implementation

procedure InitMouse;
begin
     asm
        mov ax,0000h
        int 33h
     end;

     mouse_x:=0;
     mouse_y:=0;
     mouse_button1:=false;
     mouse_button2:=false;
     mouse_on:=false;
     ShowMouse;
end;

procedure ShowMouse;
begin
     if not(mouse_on) then
     begin
          asm
             mov ax,0001h
             int 33h
          end;
          mouse_on:=true;
     end;
end;

procedure HideMouse;
begin
     if (mouse_on) then
     begin
          asm
             mov ax,0002h
             int 33h
          end;
          mouse_on:=false;
     end;
end;

procedure GetMouse;
var buttons : integer;
begin
     asm
        mov ax,0003h
        int 33h
        mov mouse_x,cx
        mov mouse_y,dx
        mov buttons,bx
     end;

     mouse_x:=(mouse_x shr 1);
     mouse_y:=mouse_y-1;

     mouse_button1:=false;
     mouse_button2:=false;
     if (buttons=$01) then mouse_button1:=true;
     if (buttons=$02) then mouse_button2:=true;
end;

procedure Svga_GetMouse;
var buttons : integer;
begin
     asm
        mov ax,0003h
        int 33h
        mov mouse_x,cx
        mov mouse_y,dx
        mov buttons,bx
     end;

     mouse_y:=mouse_y-1;

     mouse_button1:=false;
     mouse_button2:=false;
     if (buttons=$01) then mouse_button1:=true;
     if (buttons=$02) then mouse_button2:=true;
end;


end.