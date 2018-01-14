unit Keyboard;

interface

uses crt,dos;

const
     KEYINTERRUPT=9;
     KEYBUFFER=$60;

{Key Defines}
     ESC=1;
     NUM_1=2;
     NUM_2=3;
     NUM_3=4;
     NUM_4=5;
     NUM_5=6;
     NUM_6=7;
     NUM_7=8;
     NUM_8=9;
     NUM_9=10;
     NUM_0=11;

     PLUS=13;
     BACKSPACE=14;
     TAB=15;
     ENTER=28;
     UP=72;
     DOWN=80;
     RIGHT=77;
     LEFT=75;
     CTRL=29;
     SPACE=57;

     F1=59;
     F2=60;
     F3=61;
     F4=62;
     F5=63;
     F6=64;
     F7=65;
     F8=66;
     F9=67;
     F10=68;
     F11=87;
     F12=88;

     HOME=71;
     PGUP=73;
     PGDN=81;
     ND=79;
     INS=82;
     DEL=83;

     LETTER_A=30;
     LETTER_B=48;
     LETTER_C=46;
     LETTER_D=32;
     LETTER_E=18;
     LETTER_F=33;
     LETTER_G=34;
     LETTER_H=35;
     LETTER_I=23;
     LETTER_J=36;
     LETTER_K=37;
     LETTER_L=38;
     LETTER_M=50;
     LETTER_N=49;
     LETTER_O=24;
     LETTER_P=25;
     LETTER_Q=16;
     LETTER_R=19;
     LETTER_S=31;
     LETTER_T=20;
     LETTER_U=22;
     LETTER_V=47;
     LETTER_W=17;
     LETTER_X=45;
     LETTER_Y=21;
     LETTER_Z=44;
var
   keystate : array[1..128] of boolean;
   key_on : boolean;
   raw_scancode : word;
   Old_Keyboard : pointer;

procedure Keyboard_Install;
procedure Keyboard_Remove;
function GetKey : char;

function Alt : boolean;

implementation

procedure Keyboard_Driver; interrupt;
begin
     asm sti end;
     raw_scancode:=Port[KEYBUFFER];

     if (raw_scancode<=128) then
     begin
          keystate[raw_scancode]:=true;
          key_on:=true;
     end
     else
     begin
          keystate[raw_scancode-128]:=false;
          key_on:=false;
     end;

     Port[$20]:=$20;
end;

procedure Keyboard_Install;
var loop1 : integer;
begin
     for loop1:=1 to 128 do keystate[loop1]:=false;
     GetIntVec(KEYINTERRUPT,Old_Keyboard);
     SetIntVec(KEYINTERRUPT,Addr(Keyboard_Driver));
end;

procedure Keyboard_Remove;
begin
     SetIntVec(KEYINTERRUPT,Old_Keyboard);
end;

function GetKey : char;
var key : char;
begin
     asm
        @loop1 :
               mov dx,$60
               in al,dx
               cmp al,0
        je @loop1
        mov key,al
     end;
     GetKey:=key;
end;

function Alt : boolean;
var temp : byte;
begin
     asm
        mov ah,2
        int 16h
        mov temp,al

        and temp,00000100b
     end;

     if (temp>0) then Alt:=true else Alt:=false;
end;

end.