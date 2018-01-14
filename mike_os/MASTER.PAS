program MasterOS;

uses vgraph,os,programs,sound;

var
   loop1 : byte;
   MasterPal : palette;
   snd : pointer;
   size,freq : word;

procedure LoadBackGround(filename : string);
begin
     ReadPCX(filename,0,0,vaddr2);
end;

procedure SetupMaster;
var test : image;
    pal64 : array[1..3] of pal64col;
begin
     InitOS;

     Text(1,1,'Loading OS...',255,vga);

     {Grab64pal(0,63,pal64[1]);
     Grab64pal(64,64+63,pal64[2]);
     Grab64pal(128,128+63,pal64[3]);}

     LoadBackGround('pics\clouds.pcx');
     LoadPalette(MasterPal,'main.pal');
     RestorePalette(MasterPal);
     {Restore64Pal(65,65+63,pal64[1]);
     Restore64Pal(128,128+63,pal64[2]);
     Restore64Pal(192,255,pal64[3]);}

     GrabPalette(MasterPal);

     for loop1:=64 to 64+15 do
         OS_Pal[loop1-65]:=loop1;

     List[1]:='Exit';
     MakeMenu(1,'Main',List,1);

     List[1]:='Save Palette';
     List[2]:='Load Palette';
     List[3]:='Show Palette';

     MakeMenu(2,'Palette',List,3);

     LoadImage(test,'imgedit.img',1);
     MakeIcon(20,20,'IMG Editor',81,test);

     LoadImage(test,'pcxview.img',1);
     MakeIcon(20,50,'PCX Viewer',81,test);

     BlackOut;
     flip(vaddr2,vga);

     LoadSound('sounds\comp1.wav',snd,size,freq);
     PlayBack(3,snd,size,freq);

     FadeUp(20,MasterPal);
     RestorePalette(MasterPal);
end;

procedure ShutDownMaster;
begin
     ShutDown;
end;

procedure CheckKey;
var c : char;
begin
     if (KeyReady) then
     begin
          c:=GetKey;

          case c of
               'o' : if (OS_Show) then OS_Show:=false else OS_Show:=true;
          end;
     end;
end;

procedure CheckMenus;
begin
     if (IconSelect(1)) then
     begin
          LoadSound('sounds\switch1.wav',snd,size,freq);
          PlayBack(3,snd,size,freq);
          RunIMGEdit;
          SetupMaster;
     end;

     if (IconSelect(2)) then
     begin
          LoadSound('sounds\orchid.wav',snd,size,freq);
          PlayBack(3,snd,size,freq);
          RunPCXView;
          SetupMaster;
     end;

     if (MenuSelect(2,1)) then
     begin
          SetMode($03);
          writeln('Enter Filename');
          readln(filename);
          SavePalette(MasterPal,filename);
          SetMode($13);
          RestorePalette(MasterPal);
     end;

     if (MenuSelect(2,2)) then
     begin
          SetMode($03);
          writeln('Enter Filename');
          readln(filename);
          LoadPalette(MasterPal,filename);
          SetMode($13);
          RestorePalette(MasterPal);
     end;

     if (MenuSelect(2,3)) then
     begin
          cls(vga,OS_Pal[0]);

          for loop1:=0 to 255 do
              vline(5,15,10+loop1,loop1,vga);

          putpixel(10,20,OS_Pal[15],vga);
          putpixel(265,20,OS_Pal[15],vga);
          Pause;
     end;
end;

procedure MasterLoop;
begin
     flip(vaddr2,vaddr);
     UpdateOS;
     CheckMenus;
     CheckKey;
     flip(vaddr,vga);
end;

begin
     Setup;
     GrabPalette(pal1);
     Grab16pal(0,15,pal16_1);
     SetupMaster;

     while not(MenuSelect(1,1)) do
           MasterLoop;

     LoadSound('sounds\protect2.wav',snd,size,freq);
     PlayBack(3,snd,size,freq);
     FadeDown(40);

     ShutDownMaster;
end.