with Ada.Real_Time; use Ada.Real_Time;

with SDL;
with SDL.Events.Events;
with SDL.Events.Keyboards;
with SDL.Log;
with SDL.Video.Pixel_Formats;
with SDL.Video.Rectangles;
with SDL.Video.Surfaces;
with SDL.Video.Windows.Makers;

procedure Surface with
  SPARK_Mode => Off
is
   W : SDL.Video.Windows.Window;
begin
   SDL.Log.Set (Category => SDL.Log.Application, Priority => SDL.Log.Debug);

   if SDL.Initialise (Flags => SDL.Enable_Screen) = True then
      SDL.Video.Windows.Makers.Create (Win      => W,
                                       Title    => "Surface (Esc to exit)",
                                       Position => SDL.Natural_Coordinates'(X => 100, Y => 100),
                                       Size     => SDL.Positive_Sizes'(800, 640),
                                       Flags    => SDL.Video.Windows.Resizable);

      --  Main loop.
      declare
         Event            : SDL.Events.Events.Events;
         Window_Surface   : SDL.Video.Surfaces.Surface;
         Area             : constant SDL.Video.Rectangles.Rectangle :=
           (X => 10, Y => 10, Width => 50, Height => 50);
         Areas            : constant SDL.Video.Rectangles.Rectangle_Arrays :=
           ((X => 100, Y => 10, Width => 50, Height => 50),
            (X => 120, Y => 20, Width => 50, Height => 50),
            (X => 160, Y => 40, Width => 50, Height => 50));
         Green_Area       : constant SDL.Video.Rectangles.Rectangle :=
           (X => 15, Y => 15, Width => 10, Height => 10);
         Blue_Areas       : constant SDL.Video.Rectangles.Rectangle_Arrays :=
           ((X => 150, Y => 15, Width => 10, Height => 10),
            (X => 125, Y => 25, Width => 10, Height => 10),
            (X => 165, Y => 45, Width => 10, Height => 10));
         Blit_Copy_Area   : constant SDL.Video.Rectangles.Rectangle :=
           (X => 10, Y => 10, Width => 150, Height => 70);
         Blit_Dest_Area   : SDL.Video.Rectangles.Rectangle :=
           (X => 10, Y => 130, Width => 100, Height => 100);
         Finished         : Boolean := False;

         Loop_Start_Time_Goal : Ada.Real_Time.Time;
         Loop_Start_Time_Real : Ada.Real_Time.Time;
         Loop_Delay_Overhead_Time : Ada.Real_Time.Time_Span;
         Loop_Delay_Overhead_Average : Ada.Real_Time.Time_Span :=
           Ada.Real_Time.Time_Span_Zero;

         Frame_Duration : constant Ada.Real_Time.Time_Span :=
           Ada.Real_Time.Microseconds (16_667);
         --  60 Hz refresh rate

         Loop_Debug_Iterator : Natural := 0;

         use type SDL.Events.Keyboards.Key_Codes;
      begin
         Window_Surface := W.Get_Surface;

         Window_Surface.Fill (Area, SDL.Video.Pixel_Formats.To_Pixel
                              (Format => Window_Surface.Pixel_Format,
                               Red    => 200,
                               Green  => 100,
                               Blue   => 150));

         Window_Surface.Fill (Areas, SDL.Video.Pixel_Formats.To_Pixel
                              (Format => Window_Surface.Pixel_Format,
                               Red    => 100,
                               Green  => 100,
                               Blue   => 150));

         W.Update_Surface;  --  Shows the above two calls.

         Window_Surface.Fill (Green_Area, SDL.Video.Pixel_Formats.To_Pixel
                              (Format => Window_Surface.Pixel_Format,
                               Red    => 100,
                               Green  => 200,
                               Blue   => 100));

         W.Update_Surface_Rectangle (Rectangle => Green_Area);

         Window_Surface.Fill (Blue_Areas, SDL.Video.Pixel_Formats.To_Pixel
                              (Format => Window_Surface.Pixel_Format,
                               Red    => 150,
                               Green  => 150,
                               Blue   => 250));

         W.Update_Surface_Rectangles (Rectangles => Blue_Areas);

         Window_Surface.Blit_Scaled (Self_Area   => Blit_Dest_Area,
                                     Source      => Window_Surface,
                                     Source_Area => Blit_Copy_Area);

         W.Update_Surface_Rectangle (Blit_Dest_Area);

         Loop_Start_Time_Goal := Ada.Real_Time.Clock;

         SDL.Log.Put_Debug ("Frame duration: " &
                              To_Duration (Frame_Duration)'Img);

         loop
            Loop_Start_Time_Goal := Loop_Start_Time_Goal + Frame_Duration;
            delay until Loop_Start_Time_Goal;

            Loop_Start_Time_Real := Ada.Real_Time.Clock;

            Loop_Delay_Overhead_Time := Loop_Start_Time_Real -
              Loop_Start_Time_Goal;

            Loop_Delay_Overhead_Average := (Loop_Delay_Overhead_Average +
                                              Loop_Delay_Overhead_Time) / 2;

            Loop_Debug_Iterator := Loop_Debug_Iterator + 1;
            if Loop_Debug_Iterator mod 256 = 0 then
               SDL.Log.Put_Debug ("Loop_Delay_Overhead_Time: " &
                                    To_Duration (Loop_Delay_Overhead_Time)'Img);
               SDL.Log.Put_Debug ("Loop_Delay_Overhead_Average: " &
                                    To_Duration (Loop_Delay_Overhead_Average)'Img);
            end if;

            while SDL.Events.Events.Poll (Event) loop
               case Event.Common.Event_Type is
                  when SDL.Events.Quit =>
                     Finished := True;

                  when SDL.Events.Keyboards.Key_Down =>
                     if Event.Keyboard.Key_Sym.Key_Code = SDL.Events.Keyboards.Code_Escape then
                        Finished := True;
                     end if;

                  when others =>
                     null;
               end case;
            end loop;

            exit when Finished;
         end loop;
      end;

      SDL.Log.Put_Debug ("");

      W.Finalize;
      SDL.Finalise;
   end if;
end Surface;
