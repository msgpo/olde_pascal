Unit modex;


INTERFACE

USES crt;
CONST VGA = $A000;
      Size : Byte = 80;      { Size =  40 = 1 across, 4 down }
                             { Size =  80 = 2 across, 2 down }
                             { Size = 160 = 4 across, 1 down }

Procedure Chain4;
Procedure C4PutPixel(X,Y : Word; Col : Byte);
Procedure Plane(Which : Byte);
procedure moveto(x, y : integer);


IMPLEMENTATION
Procedure Chain4; ASSEMBLER;
  {  This procedure gets you into Chain 4 mode }
Asm
    mov    ax, 13h
    int    10h         { Get into MCGA Mode }

    mov    dx, 3c4h    { Port 3c4h = Sequencer Address Register }
    mov    al, 4       { Index 4 = memory mode }
    out    dx, al
    inc    dx          { Port 3c5h ... here we set the mem mode }
    in     al, dx
    and    al, not 08h
    or     al, 04h
    out    dx, al
    mov    dx, 3ceh
    mov    al, 5
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 10h
    out    dx, al
    dec    dx
    mov    al, 6
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 02h
    out    dx, al
    mov    dx, 3c4h
    mov    ax, (0fh shl 8) + 2
    out    dx, ax
    mov    ax, 0a000h
    mov    es, ax
    sub    di, di
    mov    ax, 0000h {8080h}
    mov    cx, 32768
    cld
    rep    stosw            { Clear garbage off the screen ... }

    mov    dx, 3d4h
    mov    al, 14h
    out    dx, al
    inc    dx
    in     al, dx
    and    al, not 40h
    out    dx, al
    dec    dx
    mov    al, 17h
    out    dx, al
    inc    dx
    in     al, dx
    or     al, 40h
    out    dx, al

    mov    dx, 3d4h
    mov    al, 13h
    out    dx, al
    inc    dx
    mov    al, [Size]      { Size * 8 = Pixels across. Only 320 are visible}
    out    dx, al
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure C4PutPixel(X,Y : Word; Col : Byte); ASSEMBLER;
  { This puts a pixel on the chain 4 screen }
Asm
    mov    ax,[y]
    xor    bx,bx
    mov    bl,[size]
    imul   bx
    shl    ax,1
    mov    bx,ax
    mov    ax, [X]
    mov    cx, ax
    shr    ax, 2
    add    bx, ax
    and    cx, 00000011b
    mov    ah, 1
    shl    ah, cl
    mov    dx, 3c4h                  { Sequencer Register    }
    mov    al, 2                     { Map Mask Index        }
    out    dx, ax
    mov    ax, 0a000h
    mov    es, ax
    mov    al, [col]
    mov    es: [bx], al
End;

{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
Procedure Plane(Which : Byte); ASSEMBLER;
  { This sets the plane to write to in Chain 4}
Asm
   mov     al, 2h
   mov     ah, 1
   mov     cl, [Which]
   shl     ah, cl
   mov     dx, 3c4h                  { Sequencer Register    }
   out     dx, ax
End;


{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴}
procedure moveto(x, y : integer);
  { This moves to position x*4,y on a chain 4 screen }
var o : word;
begin
  o := y*size*2+x;
  asm
    mov    bx, [o]
    mov    ah, bh
    mov    al, 0ch

    mov    dx, 3d4h
    out    dx, ax

    mov    ah, bl
    mov    al, 0dh
    mov    dx, 3d4h
    out    dx, ax
  end;
end;
end.
