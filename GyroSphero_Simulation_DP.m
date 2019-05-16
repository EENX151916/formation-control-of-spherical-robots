close all, clear all, clc, 

addpath('CA')

%% Input
% Simulation settings
EndTime = 20;
dt = 0.1;

% Render settings
AxisLimit = [-20 20];
RendererSettings = [ true; % Trails
                     8; % Render frame skips (1 = no skipping frames)
                     ];


% Bot properities [vel_max, acc_max]
Bot_v_max = 20;
Bot_a_max = 5;

Bot_radius=1;


%% Start properties
% Bot = [p_x, p_y, v_x, v_y]
NBalls = questdlg('How many bots do you want to use?','Number of balls','3','4','5','3');
switch NBalls %Sätter ett case för varje möjlighet från questdlg rutan.
    
    case '3'
        
        Bots = zeros(1,4);
        
        for i=2:3
            X=sprintf('Enter X%d :',i);
            Y=sprintf('Enter Y%d :',i);
            prompt={X,Y};
            name='Input for Ball 1';
            numlines=1;
            defaultanswer={num2str(randi([-20,20])),num2str(randi([-20,20]))};
            
            answer(:,i) = inputdlg(prompt,name,numlines,defaultanswer);
            Bots(i,1:2) = [str2num(answer{1,i}),str2num(answer{2,i})];
        end
        
        Nform = questdlg('What formation?','What formation?','LineX','Triangle','LineY','LineX');
        for i=1
            switch Nform
                
                case 'LineX'
                    
                    Goal = zeros(3,4);
                    Goal(:,1) = 0;
                    Goal(2,2) = 4*Bot_radius;
                    Goal(3,2) = 8*Bot_radius;
                    
                    
                case 'Triangle'
                    
                    Goal = zeros(3,4);
                    Goal(2,1:2) = [-4*Bot_radius,sqrt(3)*4*Bot_radius];
                    Goal(3,1:2) = [4*Bot_radius ,sqrt(3)*Bot_radius*4];
                    
                    
                    
                case 'LineY'
                    
                    Goal = zeros(3,4);
                    Goal(:,2) = 0;
                    Goal(2,1) = 8*Bot_radius;
                    Goal(3,1) = 4*Bot_radius;
            end
        end
        
        
    case '4'
        
        Bots = zeros(4,4);
        
        for i=2:4
            X=sprintf('Enter X%d :',i);
            Y=sprintf('Enter Y%d :',i);
            prompt={X,Y};
            name='Input for Ball 1';
            numlines=1;
            defaultanswer={num2str(randi([-20,20])),num2str(randi([-20,20]))};
            
            answer(:,i)=inputdlg(prompt,name,numlines,defaultanswer);
            Bots(i,1:2) = [str2num(answer{1,i}),str2num(answer{2,i})];
        end
        
        Nform = questdlg('What formation?','What formation?','LineX','Square','LineY','LineX');
        for i=1
            switch Nform
                
                case 'LineX'
                    
                    Goal = zeros(4,4);
                    Goal(:,1) = 0;
                    Goal(4,2) = 12*Bot_radius;
                    Goal(2,2) = 8*Bot_radius;
                    Goal(3,2) = 4*Bot_radius;
                    
                    
                    
                    
                case 'Square'
                    
                    Goal = zeros(4,4);
                    Goal(2,1:2) = [0 ,4*Bot_radius];
                    Goal(3,1:2) = [4*Bot_radius ,0];
                    Goal(4,1:2) = [4*Bot_radius ,4*Bot_radius];
                    
                    
                case 'LineY'
                    
                    Goal = zeros(4,4);
                    Goal(:,2) = 0;
                    Goal(2,1) = 12*Bot_radius;
                    Goal(3,1) = 8*Bot_radius;
                    Goal(4,1) = 4*Bot_radius;
                    
            end
        end
        
    case '5' %Det maximala antalet städer som kan åkas till är 8, då google har begränsat mängden städer i waypoint till 8 för "free users".
        
        Bots = zeros(5,4);
        
        for i=2:5
            X=sprintf('Enter X%d :',i);
            Y=sprintf('Enter Y%d :',i);
            prompt={X,Y};
            name='Input for Ball 1';
            numlines=1;
            defaultanswer={num2str(randi([-20,20])),num2str(randi([-20,20]))};
            
            answer(:,i)=inputdlg(prompt,name,numlines,defaultanswer);
            Bots(i,1:2) = [str2num(answer{1,i}),str2num(answer{2,i})];
        end
        
        Nform = questdlg('What formation?','What formation?','LineX','Dice-five','LineY','LineX');
        for i=1
            switch Nform
                
                case 'LineX'
                    
                    Goal = zeros(5,4);
                    Goal(:,1) = 0;
                    Goal(2,2) = 12*Bot_radius;
                    Goal(3,2) = 8*Bot_radius;
                    Goal(4,2) = 4*Bot_radius;
                    Goal(5,2) =-4*Bot_radius;
                    
                    
                    
                case 'Dice-five'
                    
                    Goal = zeros(5,4);
                    Goal(2,1:2) = [-Bot_radius*4 , Bot_radius*4];
                    Goal(3,1:2) = [-Bot_radius*4 ,-Bot_radius*4];
                    Goal(4,1:2) = [ Bot_radius*4 ,-Bot_radius*4];
                    Goal(5,1:2) = [ Bot_radius*4 , Bot_radius*4];
                    
                    
                case 'LineY'
                    
                    Goal = zeros(5,4);
                    Goal(:,2) = 0;
                    Goal(2,1) = 3*Bot_radius*4;
                    Goal(3,1) = 2*Bot_radius*4;
                    Goal(4,1) = Bot_radius*4;
                    Goal(5,1) =-Bot_radius*4;
                    
            end
        end
end

SaveBots = Bots;

%% ----- Simulation -----
% Intitialization variables
%   BotsData and TimeStamps are use to save the data that is later used for
%   rendering. Like individual frames in a movie.
BotsData = zeros(size(Bots,1), size(Bots,2), floor(EndTime/dt));
TimeStamps = zeros(floor(EndTime/dt),1);
SimTime = 0;
iteration = 1;

tic
while SimTime <= EndTime
    
    % Save the time and bots data
    BotsData(:,:,iteration) = Bots(:,:);
    TimeStamps(iteration) = SimTime;
    for i = 1 : size(Bots,1)
        Error(iteration,i) = norm(Goal(i,1:2) - Bots(i,1:2));
    end
    
    
    % --------------------  Calc - Start  --------------------
    % Get the bots goal velocity direction
    v_goal = Steering(Goal, Bots);
    
        % TODO add CA to v_goal
    for ind=2:size(Bots,1)
        
        v_goal(ind,:) = collisionAvoidance(Bots(:,3:4),Bots(:,1:2),Bot_v_max,Bot_radius,v_goal(ind,:),ind);
        
    end

    % Apply bot limitations to calculate the real new velocities
    v_new = Dynamics(Bots, v_goal, Bot_v_max, Bot_a_max, dt);
    
    % Update speed and position
    Bots(:,3:4) = v_new;
    Bots(:,1:2) = Bots(:,1:2) + Bots(:,3:4)*dt;
    % -------------------- Calc - End --------------------
     
    
    % Update the simulation time and iterator
    SimTime = SimTime + dt;
    iteration = iteration+1;
    
    
end
fprintf("Simulation Calculation Complete\n")
fprintf("\tTime: " + toc + "s\n\n")


figure;
hold on
for i = 1 :size(Bots,1)
    plot(TimeStamps,Error(:,i));    
end

%% Export Data
fileID = fopen('simulation_data.txt','w');

fprintf(fileID, '%f\n', dt);
for i = 1 : size(BotsData,3)
    for j = 1 : size(BotsData,1)
        fprintf(fileID,'%f %f ', norm(BotsData(j,3:4,i)), VectorToAngle(BotsData(j,3:4,i),2));
    end
    fprintf(fileID,'\n');
end
fclose(fileID);


%% Rendering
Render(BotsData, TimeStamps, RendererSettings, AxisLimit, Bot_radius, dt);
  


