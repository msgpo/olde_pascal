uses crt,vgraph,inos;

begin
     Setup;
     InitOS;
     LoadPalette(Pal1,'game.pal');
     RestorePalette(Pal1);

     MakeButton(1,0,0,0,'Exit',3,11);
     MakeWindow(1,50,50,50,'A Lonely Window',5);
     MakeButton(2,1,60,60,'Button 1',7,0);
     MakeTextBox(1,1,60,75,15);
     MakeWindow(2,65,65,50,'Another Window',3);
     MakeWindow(3,100,20,30,'Yet Another Window',4);

     while not(ButtonA[1]^.pressed) do
     begin
          cls(vaddr,0);
          UpdateOS;
          flip(vaddr,vga);
     end;

     ShutDown;
end.