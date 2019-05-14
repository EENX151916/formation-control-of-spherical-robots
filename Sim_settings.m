% XXXXXXXXXXXXX NOT DONE XXXXXXXXXXXXX

% ______________ Simulation settings ______________
EndTime                 = 30;
dt                      = 0.01;


% ________________ Render settings ________________
AxisLimit               = [-10 10];

Render_frame_skip       = 12;

Preview                 = true;
Export_Video            = false;

Trails                  = true;
Trail_lifetime          = 5;

Video_FileName          = 'simulation_video1.avi';
Export_VideoSettings    = [30 80]; % (framerate, quality)


% ________________ Bot properities ________________
Bot_max_v               = 0.8;
Bot_max_a               = 0.4;
Bot_radius              = 0.1;


% _____________ Formation properties ______________
Leader_Exists           = false;
Leader_v                = @(t) Bot_max_v/4 * [abs(cos(t/10)) sin(t/10)];

% Only 1 can be true
Standard_Formation      = false;
        Formation_index = 2;
    
Manual_Formation        = false;
        Bots_manual = [   3  0  0  0;
                          0  3  0  0;
                         -3  0  0  0;
                          0 -3  0  0;];
        Goal_manual = [  -3  0;
                          0 -3;
                          3  0;
                          0  3];
                
Random_Formation        = true;
        Number_of_bots = 10;
        Goal_switching = true;
        Goal_switching_time = 7;








% Standard formation
Formation_index         = 2;
[nr_bots, Bots, Goal_fixed, Leader_Exists] = GetBotTest(2);

% Manual formation
Bots = [3 0 0 0;
        0 3 0 0;
       -3 0 0 0;
        0 -3 0 0;];
Goal_fixed = [-3 0;
         0 -3;
         3 0;
         0 3];

% Random input of bot formations
Number_of_bots = 40;
Goal_switching = false;
Goal_switch_time = 7;
Bots = [(rand(Number_of_bots,2)*2-1)*AxisLimit(2)*0.6 zeros(Number_of_bots,2)];
Goal_fixed = (rand(Number_of_bots,2)*2-1)*AxisLimit(2)*0.5;

