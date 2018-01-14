unit OS;

interface

uses crt,vgraph,mouseunit,dos;

const
     MAX_CHECKBOX=1;

     MAX_BUTTON=2;

     MAX_COMBOBOX=2;

     MAX_MENU=5;

     MAX_WINDOW=2;

     MAX_TEXTBOX=2;

     MAX_SCROLL=2;

     MAX_ICON=5;

type CheckBox=record
     x,y : integer;
     checked : boolean;
     str : string;
end;

type Button=record
     x,y : integer;
     size_x : byte;
     str : string;
     pressed : boolean;
end;

type ComboList=array[1..20] of string;

type ComboBox=record
     x,y : integer;
     top,selected,max_list,size_x : byte;
     List : ComboList;
     str : string;
end;

type Menu=record
     str : string;
     menu_num,selected,max_list,size_x : byte;
     List : ComboList;
end;

type Window=record
     x,y : integer;
     str : string;
     size_x,size_y : byte;
     Bnum : byte;
end;

type TextBox=record
     x,y : integer;
     str : string[50];
     size_x,str_pos : byte;
     selected : boolean;
end;

type Scroll=record
     x,y : integer;
     scroll_x,max_x : integer;
     value,max_value : integer;
     scrolling : boolean;
end;

type Icon=record
     x,y : integer;
     str : string;
     img : image;
     active,selected : boolean;
     col : byte;
end;

type Explorer_typ=record
     x,y : integer;
     List : ComboList;
     Max_File,Cnum,Wnum : byte;
     DirInfo : SearchRec;
     Path,FD : string;
end;

var
   mouse,Select : image;
   OS_Pal : array[0..15] of byte;
   OS_Show,OS_Mouse,OS_Mouse_Active : boolean;
   frame_counter,frame_temp : integer;

   dbl_on,dbl_off,dbl_click : boolean;
   dbl_counter : byte;

   CheckBoxA : array[1..MAX_CHECKBOX] of CheckBox;
   CheckBoxC : byte;
   CheckBoxOn : boolean;
   CheckBoxUsed : array[1..MAX_CHECKBOX] of boolean;

   ButtonA : array[1..MAX_BUTTON] of Button;
   ButtonC : byte;
   ButtonOn : boolean;
   ButtonUsed : array[1..MAX_BUTTON] of boolean;

   ComboBoxA : array[1..MAX_COMBOBOX] of ComboBox;
   ComboBoxC : byte;
   ComboBoxOn : boolean;
   ComboBoxUsed : array[1..MAX_COMBOBOX] of boolean;
   List : ComboList;

   MenuA : array[1..MAX_MENU] of Menu;
   MenuC : byte;
   MenuSelected : byte;
   MenuOn : boolean;

   WindowA : array[1..MAX_WINDOW] of Window;
   WindowC : byte;
   WindowOn : boolean;
   WindowUsed : array[1..MAX_WINDOW] of boolean;

   TextBoxA : array[1..MAX_TEXTBOX] of TextBox;
   TextBoxC : byte;
   TextBoxOn : boolean;
   TextBoxUsed : array[1..MAX_TEXTBOX] of boolean;

   QueryStr : ^String;
   QueryWnum,QueryTnum : byte;
   QueryOn,QueryDn : boolean;

   ScrollA : array[1..MAX_SCROLL] of Scroll;
   ScrollC : byte;
   ScrollOn : boolean;
   ScrollUsed : array[1..MAX_SCROLL] of boolean;

   IconA : array[1..MAX_ICON] of Icon;
   IconC : byte;
   IconOn : boolean;
   IconUsed : array[1..MAX_ICON] of boolean;

   Explorer : Explorer_typ;
   ExplorerOn : boolean;

procedure InitOS;
function DoubleClick : boolean;
procedure MakeCheckBox(x,y : integer; str : string; checked : boolean);
procedure DrawCheckBox(anum : byte; where : word);
procedure DeleteCheckBox(anum : byte);
procedure MakeButton(x,y : integer; str : string);
procedure DrawButton(anum : byte; where : word);
procedure DeleteButton(anum : byte);
procedure MakeComboBox(x,y : integer; str : string; List : ComboList; max_list : byte);
procedure DrawComboBox(anum : byte; where : word);
procedure DeleteComboBox(anum : byte);
procedure MakeMenu(anum : byte; str : string; List : ComboList; max_list : byte);
procedure DrawMenu(where : word);
function MenuSelect(anum,snum : integer) : boolean;
procedure MakeWindow(x,y : integer; size_x,size_y : byte; str : string);
procedure DrawWindow(anum : byte; where : word);
procedure DeleteWindow(anum : byte);
procedure MakeTextBox(x,y : integer; size_x : byte);
procedure DrawTextBox(anum : byte; where : word);
procedure DeleteTextBox(anum : byte);
procedure TextString(anum : byte; var str : string);
procedure Query(x,y : integer; size_x,size_y : byte; str : string; var dest : string);
function QueryDone : boolean;
procedure MakeScroll(x,y : integer; value : integer; max_value : integer);
procedure DrawScroll(anum : integer; where : word);
procedure DeleteScroll(anum : byte);
procedure MakeIcon(x,y : integer; str : string; col : byte; var img : image);
procedure DrawIcon(anum : byte; where : word);
procedure DeleteIcon(anum : byte);
function IconSelect(anum : byte) : boolean;
procedure ShowExplorer(x,y : integer; path : string);
procedure UpdateOS;

implementation

procedure InitOS;
var loop1 : byte;
begin
     LoadImage(mouse,'mouse.img',1);
     LoadImage(select,'select.img',1);
     OS_Mouse:=true;
     OS_Show:=true;
     frame_counter:=0;
     frame_temp:=0;

     dbl_on:=false;
     dbl_off:=true;
     dbl_counter:=0;

     for loop1:=0 to 15 do
         OS_Pal[loop1]:=loop1;

     CheckBoxOn:=false;
     CheckBoxC:=0;

     for loop1:=1 to MAX_CHECKBOX do
         CheckBoxUsed[loop1]:=false;

     ButtonOn:=false;
     ButtonC:=0;

     for loop1:=1 to MAX_BUTTON do
     begin
          ButtonUsed[loop1]:=false;
          ButtonA[loop1].pressed:=false;
     end;

     ComboBoxOn:=false;
     ComboBoxC:=0;

     for loop1:=1 to MAX_COMBOBOX do
     begin
          ComboBoxUsed[loop1]:=false;
          ComboBoxA[loop1].size_x:=0;
     end;

     MenuOn:=false;
     MenuC:=0;

     for loop1:=1 to MAX_MENU do
         MenuA[loop1].size_x:=0;

     WindowOn:=false;
     WindowC:=0;

     for loop1:=1 to MAX_WINDOW do
         WindowUsed[loop1]:=false;

     TextBoxOn:=false;
     TextBoxC:=0;

     for loop1:=1 to MAX_TEXTBOX do
         TextBoxUsed[loop1]:=false;

     QueryOn:=false;
     QueryDn:=false;
     QueryWnum:=0;

     ScrollOn:=false;
     ScrollC:=0;

     for loop1:=1 to MAX_SCROLL do
         ScrollUsed[loop1]:=false;

     IconOn:=false;
     IconC:=0;

     for loop1:=1 to MAX_ICON do
     begin
          IconUsed[loop1]:=false;
          IconA[loop1].selected:=false;
          IconA[loop1].active:=false;
          IconA[loop1].col:=OS_Pal[15];
     end;

     ExplorerOn:=false;
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

procedure MakeCheckBox(x,y : integer; str : string; checked : boolean);
var loop1 : byte;
begin
     Inc(CheckBoxC);

     if (CheckBoxC>MAX_CHECKBOX) then
        for loop1:=1 to MAX_CHECKBOX do
            if(not(CheckBoxUsed[loop1])) then
                CheckBoxC:=loop1
            else CheckBoxC:=MAX_CHECKBOX;

     CheckBoxOn:=true;
     CheckBoxA[CheckBoxC].x:=x;
     CheckBoxA[CheckBoxC].y:=y;
     CheckBoxA[CheckBoxC].str:=str;
     CheckBoxA[CheckBoxC].checked:=checked;

     CheckBoxUsed[CheckBoxC]:=true;
end;

procedure DrawCheckBox(anum : byte; where : word);
begin
     Square(CheckBoxA[anum].x,CheckBoxA[anum].y,10,10,OS_Pal[8],where);

     if (CheckBoxA[anum].checked) then
     begin
          line(CheckBoxA[anum].x+1,CheckBoxA[anum].y+1,CheckBoxA[anum].x+9,CheckBoxA[anum].y+9,OS_Pal[7],where);
          line(CheckBoxA[anum].x+9,CheckBoxA[anum].y+1,CheckBoxA[anum].x+1,CheckBoxA[anum].y+9,OS_Pal[7],where);
     end;

     Text(CheckBoxA[anum].x+13,CheckBoxA[anum].y+2,CheckBoxA[anum].str,OS_Pal[15],where);
end;

procedure DeleteCheckBox(anum : byte);
begin
     CheckBoxUsed[anum]:=false;
end;

procedure MakeButton(x,y : integer; str : string);
var loop1 : byte;
begin
     Inc(ButtonC);

     if (ButtonC>MAX_BUTTON) then
        for loop1:=1 to MAX_BUTTON do
            if (not(ButtonUsed[loop1])) then
               ButtonC:=loop1
            else ButtonC:=MAX_BUTTON;

     ButtonOn:=true;
     ButtonA[ButtonC].x:=x;
     ButtonA[ButtonC].y:=y;
     ButtonA[ButtonC].str:=str;
     ButtonA[ButtonC].size_x:=Length(str)*7+3;

     ButtonUsed[ButtonC]:=true;
end;

procedure DrawButton(anum : byte; where : word);
var loop1 : byte;
begin
     if (not(ButtonA[anum].pressed)) then
        Square(ButtonA[anum].x,ButtonA[anum].y,ButtonA[anum].size_x,9,OS_Pal[15],where)
     else
         Square(ButtonA[anum].x,ButtonA[anum].y,ButtonA[anum].size_x,9,OS_Pal[8],where);

     for loop1:=ButtonA[anum].y+1 to ButtonA[anum].y+8 do
         hline(ButtonA[anum].x+1,ButtonA[anum].x+ButtonA[anum].size_x-1,loop1,OS_Pal[7],where);

     Text(ButtonA[anum].x+2,ButtonA[anum].y+2,ButtonA[anum].str,OS_Pal[15],where);
end;

procedure DeleteButton(anum : byte);
begin
     ButtonUsed[anum]:=false;
end;

procedure MakeComboBox(x,y : integer; str : string; List : ComboList; max_list : byte);
var loop1 : byte;
begin
     Inc(ComboBoxC);

     if (ComboBoxC>MAX_COMBOBOX) then
        for loop1:=1 to MAX_COMBOBOX do
            if (not(ComboBoxUsed[loop1])) then
               ComboBoxC:=loop1
            else ComboBoxC:=MAX_COMBOBOX;

     ComboBoxOn:=true;
     ComboBoxA[ComboBoxC].x:=x;
     ComboBoxA[ComboBoxC].y:=y;
     ComboBoxA[ComboBoxC].str:=str;
     ComboBoxA[ComboBoxC].top:=1;
     ComboBoxA[ComboBoxC].size_x:=0;

     for loop1:=1 to max_list do
     begin
          ComboBoxA[ComboBoxC].List[loop1]:=List[loop1];

          if ((Length(List[loop1])*7+6)>ComboBoxA[ComboBoxC].size_x) then
             ComboBoxA[ComboBoxC].size_x:=Length(List[loop1])*7+6;
     end;

     ComboBoxA[ComboBoxC].max_list:=max_list;

     ComboBoxUsed[ComboBoxC]:=true;
end;

procedure DrawComboBox(anum : byte; where : word);
var loop1,sx : integer;
    counter : byte;
begin
     sx:=ComboBoxA[anum].x+ComboBoxA[anum].size_x;

     Square(ComboBoxA[anum].x,ComboBoxA[anum].y+8,ComboBoxA[anum].size_x+8,30,OS_Pal[8],where);

     for loop1:=ComboBoxA[anum].y+9 to ComboBoxA[anum].y+37 do
     begin
          hline(ComboBoxA[anum].x+1,sx-1,loop1,OS_Pal[1],where);
          hline(sx+1,sx+7,loop1,OS_Pal[4],where);
     end;

     vline(ComboBoxA[anum].y+8,ComboBoxA[anum].y+38,sx,OS_Pal[8],where);
     hline(sx,sx+8,ComboBoxA[anum].y+23,OS_Pal[8],where);

     counter:=0;

     for loop1:=ComboBoxA[anum].top to ComboBoxA[anum].top+3 do
     begin
          if (not(ComboBoxA[anum].selected=loop1)) then
             Text(ComboBoxA[anum].x+1,ComboBoxA[anum].y+9+(counter*7),ComboBoxA[anum].List[loop1],OS_Pal[15],where)
          else
              Text(ComboBoxA[anum].x+1,ComboBoxA[anum].y+9+(counter*7),ComboBoxA[anum].List[loop1],OS_Pal[14],where);
          Inc(counter);
     end;

     Text(ComboBoxA[anum].x,ComboBoxA[anum].y,ComboBoxA[anum].str,OS_Pal[15],where);
end;

procedure DeleteComboBox(anum : byte);
begin
     ComboBoxUsed[anum]:=false;
end;

procedure MakeMenu(anum : byte; str : string; List : ComboList; max_list : byte);
var loop1 : byte;
begin
     Inc(MenuC);
     MenuOn:=true;

     MenuA[anum].menu_num:=anum;
     MenuA[anum].str:=str;
     MenuA[anum].List:=List;
     MenuA[anum].max_list:=max_list;

     for loop1:=1 to max_list do
         if ((Length(List[loop1])*7)>MenuA[MenuC].size_x) then MenuA[MenuC].size_x:=Length(List[loop1])*7;
end;

procedure DrawMenu(where : word);
var
   loop1 : byte;
   x1,x2,y : integer;
begin
     hline(0,319,9,OS_Pal[8],where);

     for loop1:=1 to MenuC do
         if (not(MenuSelected=loop1)) then
            Text(5+((loop1-1)*52),1,MenuA[loop1].str,OS_Pal[15],where)
         else
             Text(5+((loop1-1)*52),1,MenuA[loop1].str,OS_Pal[14],where);

     if (MenuSelected=0) then exit;

     x1:=5+((MenuSelected-1)*52);
     x2:=5+((MenuSelected-1)*52)+MenuA[MenuSelected].size_x;
     y:=(MenuA[MenuSelected].max_list+1)*7+2;

     vline(9,y,x1,OS_Pal[8],where);
     vline(9,y,x2,OS_Pal[8],where);
     hline(x1,x2,y,OS_Pal[8],where);
     hline(x1,x2,10,OS_Pal[8],where);

     for loop1:=11 to y-1 do
         hline(x1+1,x2-1,loop1,OS_Pal[1],where);

     for loop1:=1 to MenuA[MenuSelected].max_list do
         if (not(MenuA[MenuSelected].selected=loop1)) then
            Text(x1+1,11+((loop1-1)*7),MenuA[MenuSelected].list[loop1],OS_Pal[15],where)
         else
             Text(x1+1,11+((loop1-1)*7),MenuA[MenuSelected].list[loop1],OS_Pal[14],where);
end;

function MenuSelect(anum,snum : integer) : boolean;
begin
     if ((MenuA[anum].selected=snum) and not(mouse_button1)) then
     begin
          MenuSelect:=true;
          MenuA[anum].selected:=0;
     end
     else MenuSelect:=false;
end;

procedure MakeWindow(x,y : integer; size_x,size_y : byte; str : string);
var loop1 : byte;
begin
     Inc(WindowC);

     if (WindowC>MAX_WINDOW) then
        for loop1:=1 to MAX_WINDOW do
            if (not(WindowUsed[loop1])) then
               WindowC:=loop1
            else WindowC:=MAX_WINDOW;

     WindowOn:=true;
     WindowA[WindowC].x:=x;
     WindowA[WindowC].y:=y;
     WindowA[WindowC].size_x:=size_x;
     WindowA[WindowC].size_y:=size_y;
     WindowA[WindowC].str:=str;

     MakeButton(x+size_x-10,y,'X');
     WindowA[WindowC].Bnum:=ButtonC;

     WindowUsed[WindowC]:=true;
end;

procedure DrawWindow(anum : byte; where : word);
var loop1 : byte;
begin
     Square(WindowA[anum].x,WindowA[anum].y,WindowA[anum].size_x,WindowA[anum].size_y,OS_Pal[15],where);

     for loop1:=WindowA[anum].y+1 to WindowA[anum].y+WindowA[anum].size_y-1 do
         hline(WindowA[anum].x+1,WindowA[anum].x+WindowA[anum].size_x-1,loop1,OS_Pal[7],where);

     vline(WindowA[anum].y+1,WindowA[anum].y+WindowA[anum].size_y-1,WindowA[anum].x+1,OS_Pal[8],where);
     vline(WindowA[anum].y+1,WindowA[anum].y+WindowA[anum].size_y-1,WindowA[anum].x+WindowA[anum].size_x-1,OS_Pal[8],where);

     Text(WindowA[anum].x+2,WindowA[anum].y+2,WindowA[anum].str,OS_Pal[15],where);
end;

procedure DeleteWindow(anum : byte);
begin
     DeleteButton(WindowA[WindowC].Bnum);
     WindowUsed[anum]:=false;
end;

procedure MakeTextBox(x,y : integer; size_x : byte);
var loop1 : byte;
begin
     Inc(TextBoxC);

     if (TextBoxC>MAX_TEXTBOX) then
        for loop1:=1 to MAX_TEXTBOX do
            if (not(TextBoxUsed[loop1])) then
               TextBoxC:=loop1
            else
                TextBoxC:=MAX_TEXTBOX;

     TextBoxOn:=true;
     TextBoxA[TextBoxC].x:=x;
     TextBoxA[TextBoxC].y:=y;
     TextBoxA[TextBoxC].size_x:=size_x;
     TextBoxA[TextBoxC].str_pos:=1;
     TextBoxA[TextBoxC].str:='';
     TextBoxA[TextBoxC].selected:=false;

     TextBoxUsed[TextBoxC]:=true;
end;

procedure DrawTextBox(anum : byte; where : word);
var loop1,col : byte;
    c : char;
begin
     Square(TextBoxA[anum].x,TextBoxA[anum].y,TextBoxA[anum].size_x,9,OS_Pal[8],where);

     for loop1:=TextBoxA[anum].y+1 to TextBoxA[anum].y+8 do
         hline(TextBoxA[anum].x+1,TextBoxA[anum].x+TextBoxA[anum].size_x-1,loop1,OS_Pal[15],where);

     if (TextBoxA[anum].selected) then
     begin
          OS_Mouse_Active:=true;
          if ((frame_counter mod 2)=0) then
             vline(TextBoxA[anum].y+2,TextBoxA[anum].y+7,TextBoxA[anum].x+TextBoxA[anum].str_pos*7-5,OS_Pal[0],where);
          if (KeyReady) then
          begin
               c:=GetKey;

               case c of
                    #13 :
                    begin
                         TextBoxA[anum].selected:=false;
                         exit;
                    end;

                    #8 : if (TextBoxA[anum].str_pos>1) then
                            Dec(TextBoxA[anum].str_pos);
               end;

               TextBoxA[anum].str[TextBoxA[anum].str_pos]:=c;

               if (not(c=#8)) then
                  Inc(TextBoxA[anum].str_pos);
          end;
     end;

     if ((c=' ') or (c=#8)) then col:=15 else col:=0;

     for loop1:=1 to TextBoxA[anum].str_pos-1 do
         Text(TextBoxA[anum].x+2+(loop1-1)*7,TextBoxA[anum].y+2,TextBoxA[anum].str[loop1],OS_Pal[col],where);
end;

procedure DeleteTextBox(anum : byte);
begin
     TextBoxUsed[anum]:=false;
end;

procedure TextString(anum : byte; var str : string);
var loop1 : byte;
begin
     str:='';

     for loop1:=1 to TextBoxA[anum].str_pos-1 do
         str:=str+TextBoxA[anum].str[loop1];
end;

procedure Query(x,y : integer; size_x,size_y : byte; str : string; var dest : string);
begin
     QueryOn:=true;
     QueryStr:=@dest;
     MakeWindow(x,y,size_x,size_y,str);
     QueryWnum:=WindowC;
     MakeTextBox(x+2,y+20,size_x-10);
     QueryTnum:=TextBoxC;
end;

function QueryDone : boolean;
begin
     if (QueryDn) then
     begin
          QueryDone:=true;
          QueryDn:=false;
     end
     else QueryDone:=false;
end;

procedure MakeScroll(x,y : integer; value : integer; max_value : integer);
var loop1 : byte;
begin
     Inc(ScrollC);

     if (ScrollC>MAX_SCROLL) then
        for loop1:=1 to MAX_SCROLL do
            if (not(ScrollUsed[loop1])) then
               ScrollC:=loop1
            else ScrollC:=MAX_SCROLL;

     ScrollOn:=true;
     ScrollA[ScrollC].x:=x;
     ScrollA[ScrollC].y:=y;
     ScrollA[ScrollC].value:=value;
     ScrollA[ScrollC].max_value:=max_value;
     ScrollA[ScrollC].max_x:=x+max_value;
     ScrollA[ScrollC].scroll_x:=x+value;
     ScrollA[ScrollC].scrolling:=false;

     ScrollUsed[ScrollC]:=true;
end;

procedure DrawScroll(anum : integer; where : word);
var
   loop1 : byte;
   sx : integer;
   s1 : string;
begin
     sx:=ScrollA[anum].x+ScrollA[anum].max_x;

     hline(ScrollA[anum].x,sx-5,ScrollA[anum].y,OS_Pal[8],where);
     hline(ScrollA[anum].x,sx-5,ScrollA[anum].y-1,OS_Pal[15],where);
     hline(ScrollA[anum].x,sx-5,ScrollA[anum].y+1,OS_Pal[15],where);

     Square(ScrollA[anum].scroll_x,ScrollA[anum].y-4,5,8,OS_Pal[15],where);

     for loop1:=ScrollA[anum].y-3 to ScrollA[anum].y+3 do
         hline(ScrollA[anum].scroll_x+1,ScrollA[anum].scroll_x+4,loop1,OS_Pal[7],where);

     Str(ScrollA[anum].value,s1);
     Text(ScrollA[anum].x,ScrollA[anum].y+8,s1,15,where);
end;

procedure DeleteScroll(anum : byte);
begin
     ScrollUsed[anum]:=false;
end;

procedure MakeIcon(x,y : integer; str : string; col : byte; var img : image);
var loop1 : byte;
begin
     Inc(IconC);

     if (IconC>MAX_ICON) then
        for loop1:=1 to MAX_ICON do
            if (not(IconUsed[loop1])) then
               IconC:=loop1
            else IconC:=MAX_ICON;

     IconOn:=true;
     IconA[IconC].x:=x;
     IconA[IconC].y:=y;
     IconA[IconC].str:=str;
     IconA[IconC].selected:=false;
     IconA[IconC].col:=col;

     ResetImage(IconA[IconC].img,20,20,0);
     CopyImage(img,IconA[IconC].img);

     IconUsed[IconC]:=true;
end;

procedure DrawIcon(anum : byte; where : word);
begin
     PutImage(IconA[anum].img,IconA[anum].x,IconA[anum].y,0,where);
     if (IconA[anum].selected) then
        PutImage(Select,IconA[anum].x,IconA[anum].y,0,where);

     Text(IconA[anum].x,IconA[anum].y+23,IconA[anum].str,IconA[anum].col,where);
end;

procedure DeleteIcon(anum : byte);
begin
     IconUsed[anum]:=false;
end;

function IconSelect(anum : byte) : boolean;
begin
     if (IconA[anum].active) then
     begin
          IconA[anum].active:=false;
          IconSelect:=true;
          exit;
     end;

     IconSelect:=false;
end;

procedure GetFiles(path : string);
var counter : integer;
begin
     FindFirst(path,Archive,Explorer.DirInfo);

     if (path='*.*') then
        Explorer.FD:='All Files';

     if ((path[Length(path)-2]='e') and (path[Length(path)-1]='x') and (path[Length(path)]='e')) then
        Explorer.FD:='Application(s)';

     if ((path[Length(path)-2]='i') and (path[Length(path)-1]='m') and (path[Length(path)]='g')) then
        Explorer.FD:='Image File(s)';

     if ((path[Length(path)-2]='t') and (path[Length(path)-1]='x') and (path[Length(path)]='t')) then
        Explorer.FD:='Text File(s)';

     counter:=0;

     while (DosError=0) do
     begin
          Inc(counter);
          Explorer.List[counter]:=Explorer.DirInfo.name;
          FindNext(Explorer.DirInfo);
     end;

     Inc(counter);
     Explorer.List[counter]:=Explorer.DirInfo.name;
     FindNext(Explorer.DirInfo);

     Explorer.max_file:=counter;
end;

procedure ShowExplorer(x,y : integer; path : string);
begin
     ExplorerOn:=true;

     Explorer.x:=x;
     Explorer.y:=y;
     Explorer.path:=path;
     Explorer.FD:='No Description';

     GetFiles(path);

     MakeWindow(x,y,150,100,'Explorer');
     MakeComboBox(x+2,y+15,Explorer.FD,Explorer.List,Explorer.Max_File-1);

     Explorer.Wnum:=WindowC;
     Explorer.Cnum:=ComboBoxC;
end;

procedure UpdateExplorer(where : word);
begin
     Text(Explorer.x+2,Explorer.y+60,Explorer.path,OS_Pal[15],vaddr);

     if (ButtonA[WindowA[Explorer.Wnum].Bnum].pressed) then
     begin
          DeleteComboBox(Explorer.Cnum);
          ExplorerOn:=false;
     end;
end;

procedure UpdateOS;
var loop1 : byte;
begin
     if (OS_Mouse) then
     begin
          GetMouse;

          if (mouse_x>299) then mouse_x:=299;
          if (mouse_x<3) then mouse_x:=3;
          if (mouse_y>179) then mouse_y:=179;
          if (mouse_y<3) then mouse_y:=3;
     end;

     if (OS_Show) then
     begin

     if (mouse_button1) then
     begin
          if (CheckBoxOn) then
             for loop1:=1 to CheckBoxC do
             begin
                  if not(CheckBoxUsed[loop1]) then continue;
                  if ((mouse_x in [CheckBoxA[loop1].x..CheckBoxA[loop1].x+10]) and
                      (mouse_y in [CheckBoxA[loop1].y..CheckBoxA[loop1].y+10])) then
                               if (CheckBoxA[loop1].checked) then
                               begin
                                    OS_Mouse_Active:=true;
                                    CheckBoxA[loop1].checked:=false;
                                    delay(100);
                                    break;
                               end
                               else
                               begin
                                    OS_Mouse_Active:=true;
                                    CheckBoxA[loop1].checked:=true;
                                    delay(100);
                                    break;
                               end;
             end;

          if ((ButtonOn) and not(OS_Mouse_Active)) then
             for loop1:=1 to ButtonC do
             begin
                  if not(ButtonUsed[loop1]) then continue;
                  if ((mouse_x in [ButtonA[loop1].x..ButtonA[loop1].x+ButtonA[loop1].size_x]) and
                      (mouse_y in [ButtonA[loop1].y..ButtonA[loop1].y+9])) then
                               ButtonA[loop1].pressed:=true;
             end;

          if (ComboBoxOn) then
             for loop1:=1 to ComboBoxC do
             begin
                  if not(ComboBoxUsed[loop1]) then continue;
                  if ((mouse_x in [ComboBoxA[loop1].x..ComboBoxA[loop1].x+ComboBoxA[loop1].size_x+8]) and
                      (mouse_y in [ComboBoxA[loop1].y+7..ComboBoxA[loop1].y+38])) then
                  begin
                       if (mouse_x>ComboBoxA[loop1].x+ComboBoxA[loop1].size_x) then
                       begin
                            OS_Mouse_Active:=true;
                            if (mouse_y<ComboBoxA[loop1].y+23) then
                               if (ComboBoxA[loop1].top>1) then Dec(ComboBoxA[loop1].top);
                            if (mouse_y>ComboBoxA[loop1].y+23) then
                               if (ComboBoxA[loop1].top<ComboBoxA[loop1].max_list) then
                            Inc(ComboBoxA[loop1].top);
                            delay(100);
                            break;
                       end;

                       if (mouse_y in [ComboBoxA[loop1].y+7..ComboBoxA[loop1].y+14]) then
                       begin
                            OS_Mouse_Active:=true;
                            ComboBoxA[loop1].selected:=ComboBoxA[loop1].top;
                            break;
                       end;

                       if (mouse_y in [ComboBoxA[loop1].y+15..ComboBoxA[loop1].y+22]) then
                       begin
                            OS_Mouse_Active:=true;
                            ComboBoxA[loop1].selected:=ComboBoxA[loop1].top+1;
                            if (ComboBoxA[loop1].selected>ComboBoxA[loop1].max_list) then
                               ComboBoxA[loop1].selected:=ComboBoxA[loop1].max_list;
                            break;
                       end;

                       if (mouse_y in [ComboBoxA[loop1].y+23..ComboBoxA[loop1].y+30]) then
                       begin
                            OS_Mouse_Active:=true;
                            ComboBoxA[loop1].selected:=ComboBoxA[loop1].top+2;
                            if (ComboBoxA[loop1].selected>ComboBoxA[loop1].max_list) then
                               ComboBoxA[loop1].selected:=ComboBoxA[loop1].max_list;
                            break;
                       end;

                       if (mouse_y in [ComboBoxA[loop1].y+31..ComboBoxA[loop1].y+39]) then
                       begin
                            OS_Mouse_Active:=true;
                            ComboBoxA[loop1].selected:=ComboBoxA[loop1].top+3;
                            if (ComboBoxA[loop1].selected>ComboBoxA[loop1].max_list) then
                               ComboBoxA[loop1].selected:=ComboBoxA[loop1].max_list;
                            break;
                       end;
                  end;
             end;

          if ((TextBoxOn) and not(OS_Mouse_Active)) then
             for loop1:=1 to TextBoxC do
             begin
                  if not(TextBoxUsed[loop1]) then continue;
                  if ((mouse_x in [TextBoxA[loop1].x..TextBoxA[loop1].x+TextBoxA[loop1].size_x]) and
                      (mouse_y in [TextBoxA[loop1].y..TextBoxA[loop1].y+9])) then
                               TextBoxA[loop1].selected:=true
                  else TextBoxA[loop1].selected:=false;
             end;

          if (MenuOn) then
             if ((mouse_y in [0..9])) then
             begin
                  OS_Mouse_Active:=true;
                  MenuSelected:=(mouse_x div 52)+1;

                  if (MenuSelected>MenuC) then MenuSelected:=0;

                  if (mouse_y<10) then
                     MenuA[MenuSelected].selected:=0;
             end
             else if ((mouse_y > 10) and (MenuSelected<>0)) then
                  if (mouse_y>10) then
                  begin
                       OS_Mouse_Active:=true;
                       MenuA[MenuSelected].selected:=mouse_y div 7;
                  end;

          if (ScrollOn) then
             for loop1:=1 to ScrollC do
             begin
                  if not(ScrollUsed[loop1]) then continue;

                  if (ScrollA[loop1].scrolling) then
                  begin
                       ScrollA[loop1].scroll_x:=mouse_x;
                       ScrollA[loop1].value:=ScrollA[loop1].scroll_x-ScrollA[loop1].x;
                       if (ScrollA[loop1].scroll_x<ScrollA[loop1].x) then ScrollA[loop1].scroll_x:=ScrollA[loop1].x;
                       if (ScrollA[loop1].scroll_x>ScrollA[loop1].max_x) then
                          ScrollA[loop1].scroll_x:=ScrollA[loop1].max_x;
                       ScrollA[loop1].value:=ScrollA[loop1].scroll_x-ScrollA[loop1].x;
                       break;
                  end;

                  if ((mouse_x in [ScrollA[loop1].scroll_x..ScrollA[loop1].scroll_x+4]) and
                      (mouse_y in [ScrollA[loop1].y-4..ScrollA[loop1].y+4])) then
                               ScrollA[loop1].scrolling:=true;
             end;

          if (IconOn) then
             for loop1:=1 to IconC do
             begin
                  if not(IconUsed[loop1]) then continue;

                  if ((mouse_x in [IconA[loop1].x..IconA[loop1].x+20]) and
                      (mouse_y in [IconA[loop1].y..IconA[loop1].y+20])) then
                               IconA[loop1].selected:=true
                  else
                      IconA[loop1].selected:=false;
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
          MenuSelected:=0;
          OS_Mouse_Active:=false;

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

               if (dbl_click) then
                  if (IconOn) then
                     for loop1:=1 to IconC do
                     begin
                          if not(IconUsed[loop1]) then continue;

                          if ((mouse_x in [IconA[loop1].x..IconA[loop1].x+20]) and
                              (mouse_y in [IconA[loop1].y..IconA[loop1].y+20])) then
                                       if (DoubleClick) then
                                          IconA[loop1].active:=true;
                     end;
          end;

          if (ButtonOn) then
             for loop1:=1 to ButtonC do
                 ButtonA[loop1].pressed:=false;
     end;

     if (WindowOn) then
     begin
          for loop1:=1 to WindowC do
              if (WindowUsed[loop1]) then
                 DrawWindow(loop1,vaddr);

          if (ButtonA[WindowA[loop1].Bnum].pressed) then
          begin
               DeleteWindow(loop1);
               delay(100);
          end;
     end;

     if (CheckBoxOn) then
        for loop1:=1 to CheckBoxC do
            if (CheckBoxUsed[loop1]) then
               DrawCheckBox(loop1,vaddr);

     if (ButtonOn) then
        for loop1:=1 to ButtonC do
            if (ButtonUsed[loop1]) then
               DrawButton(loop1,vaddr);

     if (ComboBoxOn) then
        for loop1:=1 to ComboBoxC do
            if (ComboBoxUsed[loop1]) then
               DrawComboBox(loop1,vaddr);

     if (TextBoxOn) then
        for loop1:=1 to TextBoxC do
            if (TextBoxUsed[loop1]) then
               DrawTextBox(loop1,vaddr);

     if (ScrollOn) then
        for loop1:=1 to ScrollC do
            if (ScrollUsed[loop1]) then
               DrawScroll(loop1,vaddr);

     if (IconOn) then
        for loop1:=1 to IconC do
            if (IconUsed[loop1]) then
               DrawIcon(loop1,vaddr);

     if (ExplorerOn) then
        UpdateExplorer(vaddr);

     if (MenuOn) then
        DrawMenu(vaddr);

     if (QueryOn) then
        if (not(WindowUsed[QueryWnum])) then
        begin
             QueryOn:=false;
             QueryDn:=true;
             TextString(QueryTnum,QueryStr^);
             DeleteTextBox(QueryTnum);
        end;

     end;

     if (OS_Mouse) then
        PutImage(mouse,mouse_x,mouse_y,0,vaddr);

     Inc(frame_counter);
end;

end.