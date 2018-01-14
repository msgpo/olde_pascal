unit Sound;

interface

uses crt;

type snd=record
     buffer : pointer;
     size,freq : word;
end;

var
   ReadPort,
   WritePort,
   DataPort : word;

   BaseAddr : word;

   test : snd;

procedure SB_SetBaseAddr(Base : word);
function SB_DSPReset(Base : word) : boolean;
procedure SB_DetectBase;
procedure SB_Speaker(onoff : byte);
procedure SB_Load(filename : string; var sb_snd : snd);
procedure SB_Play(channel : byte; var sb_snd : snd);

implementation

procedure SB_SetBaseAddr(Base : word);
begin
     BaseAddr:=Base;
     ReadPort:=BaseAddr+$0A;
     WritePort:=BaseAddr+$0C;
     DataPort:=BaseAddr+$0E;
end;

function SB_DSPReset(Base : word) : boolean;
var loop1 : integer;
    bnum : byte;
begin
     Port[Base+6]:=1;

     for loop1:=1 to 6 do
         bnum:=Port[Base+$0E];

     Port[Base+6]:=0;

     for loop1:=1 to 6 do
         bnum:=Port[Base+$0E];

     loop1:=1000;

     repeat
           Dec(loop1);
     until ((Port[Base+$0A]=$AA) or (loop1=0));

     SB_DSPReset:=not(loop1=0);
end;

procedure SB_DetectBase;
var temp : word;
begin
     temp:=$100;

     while ((temp<=$10F) and (Not(SB_DSPReset(temp)))) do
           Inc(temp,$10);

     if (temp=$270) then
        BaseAddr:=0
     else
         SB_SetBaseAddr(temp);
end;

procedure SB_Speaker(onoff : byte);
begin
     repeat until ((Port[WritePort] and $80)=0);

     if (onoff=0) then
        Port[WritePort]:=$D3
     else
         Port[WritePort]:=$D1;
end;

procedure SB_Load(filename : string; var sb_snd : snd);
var fp : file;
begin
     assign(fp,filename);
     reset(fp,1);

     sb_snd.size:=FileSize(fp);
     GetMem(sb_snd.buffer,sb_snd.size);
     BlockRead(fp,sb_snd.buffer^,sb_snd.size);
     Seek(fp,24);
     BlockRead(fp,sb_snd.freq,2);

     close(fp);
end;

procedure SB_Play(channel : byte; var sb_snd : snd);
var dport : word;
    DMA_Page : word;
    DMA_Ofs : longint;
begin
     case channel of
          0 : dport:=$87;
          1 : dport:=$83;
          2 : dport:=$81;
          3 : dport:=$82;
     end;

     DMA_Page:=Word(Ofs(sb_snd.buffer^) shr 4);
     DMA_Page:=Seg(sb_snd.buffer^)+DMA_Page;
     DMA_Page:=Word(Hi(DMA_Page) shr 4);

     DMA_Ofs:=(Seg(sb_snd.buffer^) and $0FFF) shl 4;
     DMA_Ofs:=DMA_Ofs+Ofs(sb_snd.buffer^);
     DMA_Ofs:=DMA_Ofs mod $10000;

     Port[$0A]:=channel+4;
     Port[$0C]:=0;
     Port[$0B]:=$48+channel;

     Port[(channel shl 1)]:=Byte(DMA_Ofs and $00FF);
     Port[(channel shl 1)]:=Byte(DMA_Ofs shr 8);
     Port[dport]:=Byte(DMA_Page);
     Port[(channel shl 1)+1]:=Lo(sb_snd.size-1);
     Port[(channel shl 1)+1]:=Hi(sb_snd.size-1);
     Port[$0A]:=channel;

     repeat until ((Port[WritePort] and $80)=0);

     Port[WritePort]:=$40;

     repeat until ((Port[WritePort] and $80)=0);

     Port[WritePort]:=Byte(trunc(256-1000000 div sb_snd.freq));

     repeat until ((Port[WritePort] and $80)=0);

     Port[WritePort]:=$14;

     repeat until ((Port[WritePort] and $80)=0);

     Port[WritePort]:=Lo(sb_snd.size-1);

     repeat until ((Port[WritePort] and $80)=0);

     Port[WritePort]:=Hi(sb_snd.size-1);
end;

end.