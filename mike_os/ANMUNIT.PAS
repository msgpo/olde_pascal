{     This procedure handles loading and primitive displaying of anm files.
  The load procedure handles the original anm format that had no header.
  There is no need to try to figure out how this format is structured because
  It is no longer in use.  I just included it because some of the example
  anm's are in this format.  Any file saved with Animator Pro will be in the
  new format.
}

UNIT anmunit;

INTERFACE

CONST
  VGA=$a000;                                  { Points to Video Memory       }
Type
  Graphics=array[0..15,0..15]of byte;         { Type of original .anm format }
Var
  A             : Array[1..1000] of Pointer;  { Pointers to frames           }
  Last_Frame    : integer;                    { Number of frames in anm      }
  Gridx         : byte;                       { Number of pixels wide        }
  Gridy         : byte;                       { Number of pixels high        }
  Anm_pal       : byte;                       { Weather a palette was
                                                included with the .anm       }
  Anm_Oren      : byte;                       { Weather the anm was saved
                                                in row major order or column
                                                major order                  }

PROCEDURE Load_Anm(Filename:String);          { Loads an .anm file           }
PROCEDURE Set_Palette(C,R,G,B:Byte);          { Sets a palette index to a
                                                certain color                }
PROCEDURE Put_Anm (x,y,n:integer);            { Places an anm on screen      }

IMPLEMENTATION

PROCEDURE Set_Palette(C,R,G,B:Byte);
  Begin
   Port[$3c8] := C;                           { Color index     }
   Port[$3c9] := R;                           { Red intensity   }
   Port[$3c9] := G;                           { Green intensity }
   Port[$3c9] := B;                           { Blue intensity  }
End;

Procedure Load_Anm(Filename:String);
    Var
        f   :File;
        f2  :File of graphics;         { File handle for pro anm's          }
        x,y :Byte;                     { File handle for old anm's          }
        xx  :Integer;
        Size:Word;                     { Holds the size of the file         }
        Flag:Boolean;                  { Weather the file is a pro file or
                                         an old anm file                    }
        Grid:Graphics;
        R,G,B:byte;
    Begin;
      Flag:=False;                     { Set flag to false                  }
      Assign(F,Filename);
      Reset(F,1);
      BlockRead(F,x,1);
      IF x<> ord('a') then Flag:=True; { If the first 8 bytes of the file   }
      BlockRead(F,x,1);
      IF x<> ord('n') then Flag:=True; { don't contain the word "animator"  }
      BlockRead(F,x,1);
      IF x<> ord('i') then Flag:=True; { then it must be an old anm file    }
      BlockRead(F,x,1);
      IF x<> ord('m') then Flag:=True;
      BlockRead(F,x,1);
      IF x<> ord('a') then Flag:=True;
      BlockRead(F,x,1);
      IF x<> ord('t') then Flag:=True;
      BlockRead(F,x,1);
      IF x<> ord('o') then Flag:=True;
      BlockRead(F,x,1);
      IF x<> ord('r') then Flag:=True;
      If Flag then                     { If it is an old anm file then start}
         Begin;
           Close(F);
           Assign(F2,Filename);
           Reset(F2);
           Size:=Filesize(F2);
           For xx:=1 to Last_Frame do
               Freemem(A[xx],Gridx*Gridy);
           Gridx:=16;
           Gridy:=16;
           For xx:=1 to Size do
           Begin;
             Getmem(A[xx],Gridx*Gridy);
             Read(F2,Grid);
             For y:=0 to 15 do
             For x:=0 to 15 do
                 Mem[Seg(A[xx]^):Ofs(A[xx]^)+y+x*16]:=Mem[Seg(Grid):Ofs(Grid)+x+Y*16];
           End;
           Last_Frame:=Size;
           Close(F2);
           Exit;
         End;
      Size:=Filesize(F)-13;           { If new format the do this           }
      BlockRead(F,x,1);               { Get version number of program the
                                        file was saved with                 }
      If x>20 then exit;              { If greater than 2.0 then exit       }
      BlockRead(F,Gridx,1);           { Get width of anm                    }
      BlockRead(F,Gridy,1);           { Get height of anm                   }
      BlockRead(F,Anm_pal,1);         { Get palette flag.                   }
      BlockRead(F,Anm_Oren,1);        { Get orentation flag                 }
      For xx:=1 to Last_Frame do
          Freemem(A[xx],Gridx*Gridy); { Free any memory previously set
                                        asside for the pointer array        }
      If Anm_Pal=1 then               { If palette flag=1 then load a palette}
         Begin;
           For x:=0 to 255 do         { The palette information is the first }
           Begin;                     { 768 bytes following the header       }
             BlockRead(F,R,1);
             BlockRead(F,G,1);
             BlockRead(F,B,1);
             Set_Palette(X,R,G,B);
           End;
           Dec(Size,768);             { Decrease size to reflect the number
                                        of bytes left in the file that have
                                        not been read yet                   }
         End;
      If Anm_Pal=2 then               { If palette flag=2 then load palette }
         Begin;                       { above the first 16 default colors   }
           For x:=0 to 255 do
           Begin;                     { Note: The palette size is still 768 }
             BlockRead(F,R,1);        { just as when the pal flag was 1.    }
             BlockRead(F,G,1);
             BlockRead(F,B,1);
             If x>15 then Set_Palette(X,R,G,B);
           End;
           Dec(Size,768);             { Decrease size to reflect the number
                                        of bytes left in the file that have
                                        not been read yet                   }

         End;                         { If orentation flag=1 then load in   }
      If Anm_Oren=1 then              { row major order                     }
         Begin;
           For xx:=1 to Size div (Gridx*Gridy) do
           Begin;
             Getmem(A[xx],Gridx*Gridy);           { Get memory for the frame }
                                                  { Read in the frame        }
             BlockRead(F,Mem[Seg(A[xx]^):Ofs(A[xx]^)],Gridx*Gridy);
           End;
           Last_Frame:=Size div (Gridx*Gridy);    { Set the number of frames }
         End;
      If Anm_Oren=2 then              { If orentation flag=2 then load in    }
         Begin;                       { Column major order                   }
           For xx:=1 to Size div (Gridx*Gridy) do
           Begin;
             Getmem(A[xx],Gridx*Gridy);
             For x:=0 to Gridx-1 do
             For y:=0 to Gridy-1 do
                 BlockRead(F,Mem[Seg(A[xx]^):Ofs(A[xx]^)+x+y*Gridx],1);
           End;
         End;
      Close(F);
    End;
PROCEDURE Put_Anm (x,y,n:integer);
  Var
    xx : Integer;      { Loop counter }
    yy : Integer;      { Loop counter }
    s  : Word;         { Segment of the frame to be displayed }
    O  : word;         { Offset of the frame to be displayed }
  Begin;
    S:=Seg(A[n]^);     { Get the segment of the frame }
    O:=Ofs(A[n]^);     { Get the offset of the frame  }
    For yy:=0 to gridy-1 do
    move(mem[s:o+yy*gridx],mem[vga:x+(y+yy)*320],gridx); { Move the frame to
                                                           the display a line
                                                           at a time         }

  End;
End.