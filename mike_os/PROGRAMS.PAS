unit Programs;

interface

uses crt,mouseunit,vgraph,os,sound;

const
     BOUND_COLOR=26;

var
   x,y,size_x,size_y : integer;
   screen,temp : image;
   mouse_color,inum : byte;
   filename,s1 : string;
   IMGPal,PCXpal : palette;

{.IMG Procedures}
procedure RunIMGEdit;
procedure DrawScreen;
procedure PutScreen;
procedure GrabScreen;
procedure UpdateMouse;
procedure CheckKey;
procedure UpdateEditor;
procedure SetupEditor;

{.PCX Procedures}
procedure RunPCXView;
procedure SetupPCX;
procedure UpdatePCXMouse;
procedure UpdatePCX;

implementation

procedure DrawScreen;
var loop1 : integer;
begin
     size_x:=(8*screen.size_x);
     size_y:=(8*screen.size_y);

     for loop1:=0 to screen.size_x do
         hline(x,x+size_x,y+(8*loop1),BOUND_COLOR,vaddr2);

     for loop1:=0 to screen.size_y do
         vline(y,y+size_y,x+(8*loop1),BOUND_COLOR,vaddr2);

     for loop1:=0 to 125 do
         vline(y+50,y+60,x+165+loop1,loop1,vaddr2);

     for loop1:=126 to 255 do
         vline(y+65,y+75,x+165+(loop1-126),loop1,vaddr2);

     Square(240,y,20,20,BOUND_COLOR,vaddr2);
end;

procedure PutScreen;
var loop1,loop2 : integer;
begin
     for loop1:=1 to screen.size_x do
         for loop2:=1 to screen.size_x do
             fill(1+x+((loop1-1)*8),1+y+((loop2-1)*8),screen.bits[loop1,loop2],BOUND_COLOR,vaddr2);
end;

procedure GrabScreen;
var loop1,loop2 : integer;
begin
     for loop1:=1 to screen.size_x do
         for loop2:=1 to screen.size_x do
             screen.bits[loop1,loop2]:=getpixel(1+x+((loop1-1)*8),1+y+((loop2-1)*8),vaddr2);
end;

procedure UpdateMouse;
var s2 : string;
    temp2 : byte;
begin
     if ((mouse_button1) and not(OS_Mouse_Active)) then
     begin
          if (((mouse_x>=x) and (mouse_x<=x+size_x)) and
              ((mouse_y>=y) and (mouse_y<=y+size_y))) then
             if ((getpixel(mouse_x,mouse_y,vaddr2)<>BOUND_COLOR) and
                 (getpixel(mouse_x,mouse_y,vaddr2)<>mouse_color)) then
             begin
                  CopyImage(screen,temp);
                  fill(mouse_x,mouse_y,mouse_color,BOUND_COLOR,vaddr2);
                  GrabScreen;
             end;
     end;

     if ((mouse_button2) and not(OS_Mouse_Active)) then
        if not(getpixel(mouse_x,mouse_y,vaddr2)=BOUND_COLOR) then
           mouse_color:=getpixel(mouse_x,mouse_y,vaddr2);

     if (MenuSelect(1,1)) then
     begin
          CopyImage(screen,temp);
          ResetImage(screen,20,20,0);
          cls(vaddr2,0);
          DrawScreen;
          PutScreen;
          filename:=' ';
     end;

     if (MenuSelect(1,2)) then
     begin
          CopyImage(screen,temp);
          ShowExplorer(1,20,'*.img');
          ComboBoxA[ComboBoxC].selected:=0;
     end;

     if ((ComboBoxA[ComboBoxC].selected<>0) and (ComboBoxUsed[ComboBoxC])) then
     begin
          LoadImage(screen,ComboBoxA[ComboBoxC].list[ComboBoxA[ComboBoxC].selected],1);
          filename:=ComboBoxA[ComboBoxC].list[ComboBoxA[ComboBoxC].selected];
          PutScreen;
     end;

     if (MenuSelect(1,3)) then
        if (filename=' ') then MenuA[1].selected:=3
        else SaveImage(screen,filename,inum);

     if (MenuSelect(1,4)) then
     begin
          CopyImage(screen,temp);
          SetMode($03);
          writeln('Enter Filename : ');
          readln(filename);
          writeln('Enter Image Number : ');
          readln(inum);
          GrabScreen;
          SaveImage(screen,filename,inum);
          SetMode($13);
          RestorePalette(IMGPal);
     end;

     if (MenuSelect(1,5)) then
     begin
          CopyImage(screen,temp);
          SetMode($03);
          writeln('Enter Filename : ');
          readln(filename);
          writeln('Enter Image Number : ');
          readln(inum);
          LoadImage(screen,filename,inum);
          PutScreen;
          SetMode($13);
          RestorePalette(IMGPal);
     end;

     if (MenuSelect(2,1)) then
     begin
          CopyImage(temp,screen);
          PutScreen;
     end;

     if (MenuSelect(3,1)) then
     begin
          CopyImage(screen,temp);
          Inc(screen.size_x);
          if (screen.size_x>20) then screen.size_x:=20;
          Inc(screen.size_y);
          if (screen.size_y>20) then screen.size_y:=20;
          cls(vaddr2,0);
          DrawScreen;
          PutScreen;
     end;

     if (MenuSelect(3,2)) then
     begin
          CopyImage(screen,temp);
          Dec(screen.size_x);
          if (screen.size_x<1) then screen.size_x:=1;
          Dec(screen.size_y);
          if (screen.size_y<1) then screen.size_y:=1;
          cls(vaddr2,0);
          DrawScreen;
          PutScreen;
     end;

     if (MenuSelect(3,3)) then
     begin
          Str(screen.size_x,s2);
          s1:='Screen Size is '+s2+'x'+s2;
          MakeWindow(10,10,160,50,s1);
     end;

     if (MenuSelect(3,4)) then
     begin
          CopyImage(screen,temp);
          ReverseImage(screen);
          PutScreen;
     end;

     if (MenuSelect(3,5)) then
     begin
          CopyImage(screen,temp);
          SetMode($03);
          writeln('Enter Filename : ');
          readln(filename);
          writeln('Enter Image Number : ');
          readln(inum);
          LoadImage(temp,filename,inum);
          TransCopyImage(temp,screen,0);
          PutScreen;
          SetMode($13);
          RestorePalette(IMGPal);
     end;

     if (MenuSelect(4,1)) then
     begin
          SetMode($03);
          writeln('Enter Filename :');
          readln(filename);
          LoadPalette(IMGPal,filename);
          SetMode($13);
          RestorePalette(IMGPal);
     end;
end;

procedure CheckKey;
var c : char;
    loop1,loop2 : byte;
begin
     if (keypressed) then
     begin
          c:=Readkey;

          case c of
               #72 :
               begin
                    CopyImage(screen,temp);
                    Inc(screen.size_x);
                    if (screen.size_x>20) then screen.size_x:=20;
                    Inc(screen.size_y);
                    if (screen.size_y>20) then screen.size_y:=20;
                    cls(vaddr2,0);
                    DrawScreen;
                    PutScreen;
               end;

               #80 :
               begin
                    CopyImage(screen,temp);
                    Dec(screen.size_x);
                    if (screen.size_x<1) then screen.size_x:=1;
                    Dec(screen.size_y);
                    if (screen.size_y<1) then screen.size_y:=1;
                    cls(vaddr2,0);
                    DrawScreen;
                    PutScreen;
               end;

               #77 :
               begin
                    Inc(mouse_color);
                    if (mouse_color>255) then mouse_color:=0;
               end;

               #75 :
               begin
                    Dec(mouse_color);
                    if (mouse_color<0) then mouse_color:=255;
               end;

               #60 :
               begin
                    CopyImage(screen,temp);
                    SetMode($03);
                    writeln('Enter Filename : ');
                    readln(filename);
                    writeln('Enter Image Number : ');
                    readln(inum);
                    GrabScreen;
                    SaveImage(screen,filename,inum);
                    SetMode($13);
                    RestorePalette(IMGPal);
               end;

               #61 :
               begin
                    CopyImage(screen,temp);
                    SetMode($03);
                    writeln('Enter Filename : ');
                    readln(filename);
                    writeln('Enter Image Number : ');
                    readln(inum);
                    LoadImage(screen,filename,inum);
                    PutScreen;
                    SetMode($13);
                    RestorePalette(IMGPal);
               end;

               'c' :
               begin
                    CopyImage(screen,temp);
                    ResetImage(screen,20,20,mouse_color);
                    PutScreen;
               end;

               #27 : MenuA[1].selected:=6;

               'k' :
               begin
                    SetMode($03);
                    writeln('Enter Constant');
                    readln(inum);
                    CopyImage(screen,temp);
                    AddImage(screen,inum);
                    PutScreen;
                    SetMode($13);
                    RestorePalette(IMGPal);
               end;

               's' :
               begin
                    CopyImage(screen,temp);
                    for loop1:=1 to screen.size_x do
                        for loop2:=1 to screen.size_y do
                            screen.bits[loop1,loop2]:=temp.bits[loop1+1,loop2];

                    for loop1:=1 to screen.size_y do
                        screen.bits[20,loop1]:=temp.bits[1,loop1];

                    PutScreen;
               end;

               'f' :
               begin
                    CopyImage(screen,temp);
                    for loop1:=1 to screen.size_x do
                        for loop2:=1 to screen.size_y do
                            screen.bits[loop1,loop2]:=temp.bits[loop1-1,loop2];

                    for loop1:=1 to screen.size_y do
                        screen.bits[1,loop1]:=temp.bits[20,loop1];

                    PutScreen;
               end;

               'e' :
               begin
                    CopyImage(screen,temp);
                    for loop1:=1 to screen.size_x do
                        for loop2:=1 to screen.size_y do
                            screen.bits[loop1,loop2]:=temp.bits[loop1,loop2+1];

                    for loop1:=1 to screen.size_x do
                        screen.bits[loop1,20]:=temp.bits[loop1,1];

                    PutScreen;
               end;

               'd' :
               begin
                    CopyImage(screen,temp);
                    for loop1:=1 to screen.size_x do
                        for loop2:=1 to screen.size_y do
                            screen.bits[loop1,loop2]:=temp.bits[loop1,loop2-1];

                    for loop1:=1 to screen.size_x do
                        screen.bits[loop1,1]:=temp.bits[loop1,20];

                    PutScreen;
               end;
          end;
     end;
end;

procedure UpdateEditor;
begin
     flip(vaddr2,vaddr);
     UpdateMouse;
     CheckKey;

     PutImage(screen,190,y,0,vaddr);
     Fill(250,y+10,mouse_color,BOUND_COLOR,vaddr);

     Str(mouse_color,s1);
     Text(240,y+25,s1,15,vaddr);

     UpdateOS;

     flip(vaddr,vga);
end;

procedure SetupEditor;
begin
     InitOS;
     List[1]:='New';
     List[2]:='Open';
     List[3]:='Save';
     List[4]:='Save As';
     List[5]:='Load';
     List[6]:='Exit';
     MakeMenu(1,'File',List,6);

     List[1]:='Undo ';

     MakeMenu(2,'Edit',List,1);

     List[1]:='Inc XY';
     List[2]:='Dec XY';
     List[3]:='GetSize';
     List[4]:='Reverse';
     List[5]:='Trans Load';

     MakeMenu(3,'Sprite',List,5);

     List[1]:='Load Palette';

     MakeMenu(4,'Palette',List,1);

     x:=5;
     y:=15;
     mouse_color:=1;
     filename:=' ';

     ResetImage(screen,20,20,0);
     ResetImage(temp,20,20,0);
     DrawScreen;
     PutScreen;
     GrabPalette(IMGPal);
end;

procedure UpdatePCXMouse;
var loop1 : byte;
begin
     if (mouse_button2) then Restore16pal(0,15,pal16_1);

     if (MenuSelect(1,1)) then
        cls(vaddr2,0);

     if (MenuSelect(1,2)) then
     begin
          ShowExplorer(1,20,'*.pcx');
          ComboBoxA[Explorer.Cnum].selected:=0;
     end;

     if (MenuSelect(1,3)) then
     begin
          cls(vga,0);

          for loop1:=0 to 255 do
              vline(5,15,10+loop1,loop1,vga);

          putpixel(10,20,15,vga);
          putpixel(265,20,15,vga);

          Pause;
     end;

     if (MenuSelect(2,1)) then
     begin
          IncColor(1,1,1,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,2)) then
     begin
          IncColor(1,1,0,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,3)) then
     begin
          IncColor(1,0,0,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,4)) then
     begin
          IncColor(0,0,1,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,5)) then
     begin
          IncColor(0,1,1,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,6)) then
     begin
          IncColor(0,1,0,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,7)) then
     begin
          IncColor(1,0,1,20);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,8)) then
     begin
          DecColor(1,1,1,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,9)) then
     begin
          DecColor(1,1,0,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,10)) then
     begin
          DecColor(1,0,0,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,11)) then
     begin
          DecColor(0,0,1,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,12)) then
     begin
          DecColor(0,1,1,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,13)) then
     begin
          DecColor(0,1,0,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(2,14)) then
     begin
          DecColor(1,0,1,20,PCXPal);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(3,1)) then
     begin
          SetMode($03);
          writeln('Enter Filename :');
          readln(filename);
          SavePalette(PCXPal,filename);
          SetMode($13);
          RestorePalette(PCXPal);
     end;

     if (MenuSelect(3,2)) then
     begin
          SetMode($03);
          writeln('Enter Filename :');
          readln(filename);
          LoadPalette(PCXPal,filename);
          SetMode($13);
          RestorePalette(PCXPal);
     end;

     if ((ComboBoxA[ComboBoxC].selected<>0) and (ComboBoxUsed[ComboBoxC])) then
     begin
          cls(vaddr2,0);
          filename:=ComboBoxA[ComboBoxC].list[ComboBoxA[ComboBoxC].selected];
          ReadPcx(filename,0,0,vaddr2);
          GrabPalette(PCXPal);
          ComboBoxA[ComboBoxC].selected:=0;
     end;
end;

procedure UpdatePCX;
begin
     flip(vaddr2,vaddr);
     UpdateOS;
     UpdatePCXMouse;
     CheckKey;
     flip(vaddr,vga);
end;

procedure SetupPCX;
begin
     InitOS;

     List[1]:='New';
     List[2]:='Open';
     List[3]:='Show Pal';
     List[4]:='Exit';

     MakeMenu(1,'File',List,4);

     List[1]:='Inc 1,1,1';
     List[2]:='Inc 1,1,0';
     List[3]:='Inc 1,0,0';
     List[4]:='Inc 0,1,1';
     List[5]:='Inc 0,0,1';
     List[6]:='Inc 0,1,0';
     List[7]:='Inc 1,0,1';
     List[8]:='Dec 1,1,1';
     List[9]:='Dec 1,1,0';
     List[10]:='Dec 1,0,0';
     List[11]:='Dec 0,1,1';
     List[12]:='Dec 0,0,1';
     List[13]:='Dec 0,1,0';
     List[14]:='Dec 1,0,1';

     MakeMenu(2,'Colors',List,14);

     List[1]:='Save Palette';
     List[2]:='Load Palette';

     MakeMenu(3,'Palette',List,2);
end;

procedure RunIMGEdit;
begin
     cls(vaddr2,0);
     SetupEditor;

     while (not(MenuSelect(1,6))) do
           UpdateEditor;

     cls(vga,0);
end;

procedure RunPCXView;
begin
     cls(vaddr2,0);
     SetupPCX;
     RestorePalette(pal1);
     GrabPalette(PCXPal);
     Restore16pal(0,15,pal16_1);

     while (not(MenuSelect(1,4))) do
           UpdatePCX;

     cls(vga,0);
end;

end.