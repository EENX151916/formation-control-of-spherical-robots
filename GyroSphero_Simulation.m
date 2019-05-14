close all, clear all, clc, format long
addpath('CA');


%% ========================== Input ==========================

% ______________ Simulation settings ______________
EndTime =                   40;
dt =                        0.01;

% ________________ Data export settings ________________
Export_data =               false;

% ________________ Render settings ________________
View_Settings = {           [600 400]          % [x y] Window size (0 for default)
                            3                   % Free(1)/Fixed(2)/tracking(3) camera
                            
                            % Free camera
                            0.5                 % Minimum view margin

                            % Fixed camera
                            [-2 2]              % x limits
                            [-0.5 0.5]          % y limits
                            
                            % Tracking camera
                            1                   % Bot to track
                            0.4                   % Minimum view margin
                            [-0.2 0]               % x- and y-offset
                };

Render_Settings = [         10                  % Render-frame-skips
                  ];
                       
Visual_Settings = [         true                % Trails
                            5                   % Trails lifetime
                            15                   % Trail points per second
                            true               % Bot number labels
                            false               % Bot direction arrows
                            true                % Bot velocity arrows
                            true                % Print Goals
                  ];             

Export_Settings = {         false               % Export video
                            'Simulation.mp4'    % File name
                            30                  % Framerate
                            100                 % Quality
                  };               


% ________________ Bot properities ________________
Bot_max_v =                 1.5;
Bot_max_a =                 0.7;
Bot_vald_max_a =            0.35;
Bot_max_omega =             10;                 % Rad/s
Bot_max_omega_acc =         90;                 % Rad / s^2
Bot_radius =                0.0365;

Collision_Avoidance =       true;
% _____________ Formation properties ______________

Leader_Exists =             true;
leader_speed = 25;
Leader_v_theta =            @(t) Bot_max_v*leader_speed/100 * [1 0];

Type_of_formation =         2;                  % Standard(1)/Manual(2)/Random(3)
MANUAL_goal_switching =     false;

if Type_of_formation == 1                       % Formation from standard
    [Bots, Goal_fixed, Leader_Exists] = GetBotTest(8);
    
elseif Type_of_formation == 2                   % Manual input of bot formation
    Bots = [                0 0 0 0 0
                            -0.1 0 0 0 0
                            -0.2 0 0 0 0
                            -0.3 0 0 0 0
                            -0.4 0 0 0 0
           ];
    Goal_fixed = [          0 0
                            -0.15 0
                            0.15 0
                            0 0.15
                            0 -0.15
                 ];
else                                            % Random formation
    Number_of_bots =        5;
    Area_Limit =            [-1 1];
    Goal_switching =        false;
    Goal_switch_time =      15;
    Circular_start =        true;
    Circular_start_r =      3;
    
    if Circular_start == true
        for i = 1:Number_of_bots
           Bots(i,:) = [Circular_start_r*cos(2*pi*(i-1)/Number_of_bots) Circular_start_r*sin(2*pi*(i-1)/Number_of_bots) 0 0 0];
        end
    else
        Bots = [(rand(Number_of_bots,2)*2-1)*Area_Limit(2) zeros(Number_of_bots,2)];
    end
    Goal_fixed = (rand(Number_of_bots,2)*2-1)*Area_Limit(2);
end



%% ========================== Simulation ==========================
% Intitialization variables
if Leader_Exists First_follower_bot = 2; else First_follower_bot = 1; end
SimTime = 0;
sim_i = 1;
Goal_switch_ticker = 0;
Collision_Occured = false;

BotsData = zeros(size(Bots,1), size(Bots,2), floor(EndTime/dt));
GoalData = zeros(size(Goal_fixed,1), size(Goal_fixed,2), floor(EndTime/dt));
TimeStamps = zeros(floor(EndTime/dt),1);
Position_Error = zeros(length(TimeStamps), size(Bots,1)-First_follower_bot+1);
Goal_real = Goal_fixed;

% Simulation Loop
tic
while SimTime <= EndTime
    
    % Set real goal position depending on if a leader is in the formation
    if Leader_Exists 
        Goal_real = Bots(1,1:2) + Goal_fixed *[cos(Bots(1,4)) sin(Bots(1,4)); -sin(Bots(1,4)) cos(Bots(1,4))];
    end
    
    % Save the time and bots data
    BotsData(:,:,sim_i) = Bots(:,:);
    GoalData(:,:,sim_i) = Goal_real(:,:);
    TimeStamps(sim_i) = SimTime;
    
    % -- Caluculate data on bots --
    % Positional error 
    Position_Error(sim_i,:) = vecnorm(Goal_real(First_follower_bot:end,:) - Bots(First_follower_bot:end,1:2),2,2);   

    % Detect collision, this loop does nothing other than change a variable
    for bot1 = 2: size(Bots,1)
        for bot2 = 1: bot1-1
          if norm(Bots(bot1,1:2)-Bots(bot2,1:2)) <= 2*Bot_radius
             Collision_Occured = true;
          end
        end
    end
    
    
    
    % Generate a new goal after a certain time
    if Type_of_formation == 3 && Goal_switching == true && floor(SimTime/Goal_switch_time) > Goal_switch_ticker
        Goal_fixed = (rand(Number_of_bots,2)*2-1)*Area_Limit(2)*0.5;
        Goal_switch_ticker = Goal_switch_ticker + 1;
    
    elseif MANUAL_goal_switching
        if 15 <= SimTime && SimTime < 22
            Goal_fixed = [0  0;
                         0  0.5;
                         0.5 0;
                         -0.5 0;
                         0 -0.5];
        elseif 22 <= SimTime && SimTime < 29
            Goal_fixed = [0  0;
                         -0.5  0.5;
                         0.5 0.5;
                         0.5 -0.5;
                         -0.5 -0.5];
        elseif 29 <= SimTime && SimTime < 40
            Goal_fixed = [0  0;
                         0  -0.5;
                         0  0.5;
                         -0.5 0;
                         -1 0];
        end
    end
    
    
    
    % ---------- Calculation of v_goal - Start  ----------
    % Get the bots control signals (wanted v and omega)
    Control_signals = Steering(Goal_real, Bots, dt);
    
    % Saturate wanted [v omega] to bot dynamics
    v_omega_goal = Dynamics(Bots, Control_signals, Bot_max_v, Bot_max_a, Bot_vald_max_a, Bot_max_omega, Bot_max_omega_acc, dt);
    v_omega_goal(:,2) = v_omega_goal(:,2) + (rand(size(v_omega_goal(:,2))))/50;  
    
    if Collision_Avoidance
        % Calculate new theta from omega and add it to goal [v theta]
        v_theta_goal = [v_omega_goal(:,1) Bots(:,4)+v_omega_goal(:,2)*dt];

        % --- CA ---
        % Convert [v theta] to [v_x v_y], implement Collision Avoidance
        v_goal = [v_theta_goal(:,1).*cos(v_theta_goal(:,2)) v_theta_goal(:,1).*sin(v_theta_goal(:,2))];
        v_current = [Bots(:,3).*cos(Bots(:,4)) Bots(:,3).*sin(Bots(:,4))];
        for bot = First_follower_bot:size(Bots,1)
            v_goal(bot,:) = CollisionAvoidance(v_current, Bots(:,1:2), Bot_max_v, Bot_max_a, Bot_radius, v_goal(bot,:), bot, Leader_Exists,dt, Bot_max_omega);
        end
        % Convert [v_x v_y] to [a theta]
        a_omega_goal = v_xy2a_omega(v_goal, Bots, dt);

        % Convert [v theta] to [v omega] and saturate to bot dynamics
        v_omega_goal = Dynamics(Bots, a_omega_goal, Bot_max_v, Bot_max_a, Bot_vald_max_a, Bot_max_omega, Bot_max_omega_acc, dt);
    end
    % ---------- Calculation of v_goal - End ----------
 
    
    
    
    % Update the bots speed and rotation
    Bots(First_follower_bot:end,3) = v_omega_goal(First_follower_bot:end,1);
    Bots(First_follower_bot:end,5) = v_omega_goal(First_follower_bot:end,2);
    Bots(First_follower_bot:end,4) = Bots(First_follower_bot:end,4) + v_omega_goal(First_follower_bot:end,2)*dt;
    
    % Saturate the bots theta to [0, 2pi)
    while sum(Bots(:,4)<0) > 0 || sum(Bots(:,4)>=2*pi) > 0
        Bots(Bots(:,4)<0, 4) = Bots(Bots(:,4)<0, 4) + 2*pi;
        Bots(Bots(:,4)>=2*pi, 4) = Bots(Bots(:,4)>=2*pi, 4) - 2*pi;
    end
    
    Leader_v = Leader_v_theta(SimTime);
    if Leader_Exists, Bots(1,3:4) = [norm(Leader_v) atan2(Leader_v(2),Leader_v(1))]; end
    
    % Update the bots positions
    Bots(:,1:2) = Bots(:,1:2) + [Bots(:,3).*cos(Bots(:,4)) Bots(:,3).*sin(Bots(:,4))] * dt;

    
    
    
    % Update the simulation time and iterator
    SimTime = SimTime + dt;
    sim_i = sim_i+1;
end




%% ========================== Simulation information ==========================
% Print Simulation information
fprintf("Simulation Calculation Complete\n")
fprintf("\tTime: " + toc + "s\n\n")

% Display the bots positional error over time
figure;
hold on
for follower_bot = 1:size(Position_Error,2)
    plot(TimeStamps,Position_Error(:,follower_bot), 'Color', [22 111 255]/255, 'Linewidth', 2);    
end
legend('Avstånd till målposition' )
ylim([-0.1 1.5]);
yline(0, 'k--', 'HandleVisibility','off', 'LineWidth', 2);

% plot(TimeStamps,squeeze(BotsData(1,1,:))); 
% yline(Bot_radius,'--');
% yline(-Bot_radius,'--');



%% ========================== Export Data ==========================


% Export specific data
fileID = fopen('simulation_data_fart.txt','w');
fprintf(fileID,'%f ', squeeze(BotsData(end,1,:)));
fprintf(fileID,'\n');
fclose(fileID);

% Export Data Movement data
if Export_data == true
    fileID = fopen('simulation_data.txt','w');

    fprintf(fileID, '%f\n', dt);
    for timeStep = 1 : size(BotsData,3)
        for bot = 1 : size(BotsData,1)
            fprintf(fileID,'%f %f', norm(BotsData(bot,3:4,timeStep)), VectorToAngle(BotsData(bot,3:4,timeStep),2));

            if bot ~= size(BotsData,1)
                fprintf(fileID,' ');
            end
        end
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end



%% ========================== Rendering ==========================

Render(BotsData, GoalData, TimeStamps, Render_Settings, Bot_radius, dt, Leader_Exists, Export_Settings, Visual_Settings, View_Settings);

