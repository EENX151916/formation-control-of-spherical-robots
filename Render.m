function Render(BotsData, GoalData, TimeStamps, Render_Settings, Bot_radius, dt, Leader_Exists, Export_Settings, Visual_Settings, View_Settings)

Leader_Color = [209, 118, 0]/255;
Goal_Color = [0.6 0.6 0.6];
Follower_Color = [0, 58, 94]/255;
Quiver_color = [255, 42, 0]/255;
Quiver_size = 0.2;
Quiver_thickness = 1.5;
Dir_Quiver_color = [0.6 0.6 0.6];
Dir_Quiver_size = 0.1;
Dir_Quiver_thickness = 3;
Trail_color = [0.4 0.4 0.4];
% Trail_color = Follower_Color;

Trail_ticks = Visual_Settings(3);    % Trail points per second
Trail_lifeTime = Visual_Settings(2);
Trail_points_alive = Trail_ticks * Trail_lifeTime;
Trail_frame_skips = floor(1/dt / Trail_ticks); % Number of frames to skip for each trail point
Trail_color_dropoff_exponent = 4;

Playback_modifier = 1;

if Export_Settings{1} == false
    figure('Position', [100 100 View_Settings{1}]);
%     figure;
    FTR = 1:Render_Settings(1):length(TimeStamps); % Frames To Render
    RenderTime = zeros(length(FTR),1);
    FrameTime = zeros(length(FTR),1);
else
    FrameSkip = floor(1/dt/Export_Settings{3});
    if FrameSkip == 0
        FrameSkip = 1;
    end
    FTR = 1 : FrameSkip : length(TimeStamps); % Frames To Render

    figure('Position', [10 10 900 700]);

    video = VideoWriter(Export_Settings{2}, 'MPEG-4');
    video.FrameRate = 1/(FrameSkip*dt);
    video.Quality = Export_Settings{4};
    open(video)
end


rerendered_first_frame = false;
for I = 1:length(FTR)
    if I == 2 && rerendered_first_frame == false
        rerendered_first_frame = true;
        I = 1;
    end
    
    tic
    cla
    hold on
    
    % Print trails if wanted
    if Visual_Settings(1) == true
        
        Number_of_Trail_FTR = floor(FTR(I) / Trail_frame_skips);
       
        % Calculate on which frames a trail point should be plotted for
        Trail_FTR = zeros(Number_of_Trail_FTR,1);
        for i = 1 : Number_of_Trail_FTR
            Trail_FTR(i) = Trail_frame_skips*(i)-1; % Frames to render trail points on
        end
        Trail_FTR = Trail_FTR(max([1,size(Trail_FTR,1)-Trail_points_alive]):end);
        
        % Plot trail points for the trial frames to render
        for i = 1:size(Trail_FTR,1)      
            plot(BotsData(:,1,Trail_FTR(i)), BotsData(:,2,Trail_FTR(i)),'.', 'Color', min(    Trail_color + ([1 1 1]-Trail_color)* ((Number_of_Trail_FTR-i)/Number_of_Trail_FTR)^Trail_color_dropoff_exponent   ,[1 1 1])); 
        end
    end
    
    
     
    
    
    % Print Bots and goals
    if Leader_Exists
        if Visual_Settings(7) == true
            for bot = 2:size(BotsData,1)
               % Print goal positions
               rectangle('Position', [GoalData(bot,1:2,FTR(I))-Bot_radius*1.5*[1 1] 1.5*Bot_radius*[2 2]], 'Curvature', [1 1], 'FaceColor', 'none', 'EdgeColor', Goal_Color, 'LineWidth', 1); 
            end
        end
        for bot = 2:size(BotsData,1)
           % Print follower bots
           rectangle('Position', [BotsData(bot,1:2,FTR(I))-Bot_radius*[1 1] Bot_radius*[2 2]], 'Curvature', [1 1], 'FaceColor', Follower_Color, 'EdgeColor', 'none'); 
        end
        %Print leader bot
        rectangle('Position', [BotsData(1,1:2,FTR(I))-Bot_radius*[1 1] Bot_radius*[2 2]], 'Curvature', [1 1], 'FaceColor', Leader_Color, 'EdgeColor', 'none'); 
    else
        if Visual_Settings(7) == true
            for bot = 1:size(BotsData,1)
               % Print goal positions
               rectangle('Position', [GoalData(bot,1:2,FTR(I))-Bot_radius*1.5*[1 1] 1.5*Bot_radius*[2 2]], 'Curvature', [1 1], 'FaceColor', 'none', 'EdgeColor', Goal_Color, 'LineWidth', 2); 
            end
        end
        for bot = 1:size(BotsData,1)
           % Print follower bots
           rectangle('Position', [BotsData(bot,1:2,FTR(I))-Bot_radius*[1 1] Bot_radius*[2 2]], 'Curvature', [1 1], 'FaceColor', Follower_Color, 'EdgeColor', 'none'); 
        end
    end
    
    
    % Print direction arrows
    if Visual_Settings(5) == true
        quiver(BotsData(:,1,FTR(I)), BotsData(:,2,FTR(I)), Dir_Quiver_size*cos(BotsData(:,4,FTR(I)))*Quiver_size, Dir_Quiver_size*sin(BotsData(:,4,FTR(I)))*Quiver_size, 0, 'color', Dir_Quiver_color, 'LineWidth', Dir_Quiver_thickness);
    end
    
    
    % Print velocity arrows if wanted
    if Visual_Settings(6) == true
        quiver(BotsData(:,1,FTR(I)), BotsData(:,2,FTR(I)), BotsData(:,3,FTR(I)).*cos(BotsData(:,4,FTR(I)))*Quiver_size, BotsData(:,3,FTR(I)).*sin(BotsData(:,4,FTR(I)))*Quiver_size, 0, 'color', Quiver_color, 'LineWidth', Quiver_thickness);
    end
    
    
    % Print Bot labels if wanted
    if Visual_Settings(4) == true
        if Leader_Exists
            % Print labels for followers first, then na L for leader
            for bot = 2:size(BotsData,1)
                text(BotsData(bot,1,FTR(I))-0.015, BotsData(bot,2,FTR(I))+0.006, num2str(bot-1),'FontSize',16, 'Color', [1 1 1]);
            end
            text(BotsData(1,1,FTR(I))-0.015, BotsData(1,2,FTR(I))+0.006, 'L','FontSize',16, 'Color', [0 0 0]);
            
        else
            % Print labels for every bot
            for bot = 1:size(BotsData,1)
                text(BotsData(bot,1,FTR(I))-0.015, BotsData(bot,2,FTR(I))+0.006, num2str(bot),'FontSize',16, 'Color', [1 1 1]);
            end
        end
    end
    
    
    hold off
    
    % Time title
%     t = title("Time: " + num2str(TimeStamps(FTR(I))) + ' s');
    % set(t, 'horizontalAlignment', 'left');
    


    % Apply View settings
    switch View_Settings{2}
        
        % Free Camera
        case 1 
            % Get the most extreme (outer) positions of the bots
            Extreme_pos = [min(BotsData(:,1,FTR(I))) max(BotsData(:,1,FTR(I))) min(BotsData(:,2,FTR(I))) max(BotsData(:,2,FTR(I)))];
            
            % Set axis limits
            xlim(Extreme_pos(1:2) + View_Settings{3}*[-1 1]);
            ylim(Extreme_pos(3:4) + View_Settings{3}*[-1 1]);
            axis equal;
            
            % Center the limits
            xl = xlim;
            yl = ylim;
            xlim(mean(Extreme_pos(1:2)) + (xl(2)-xl(1))/2 * [-1 1]);
            ylim(mean(Extreme_pos(3:4)) + (yl(2)-yl(1))/2 * [-1 1]);
            
        % Fixed Camera
        case 2 
             % Set axis limits
            xlim(View_Settings{4});
            axis equal
            ylim(View_Settings{5});
            
        % Tracking Camera
        case 3 
            % Set axis limits
            xlim(BotsData(View_Settings{6},1,FTR(I)) + View_Settings{7}*[-1 1] + View_Settings{8}(1));
            ylim(BotsData(View_Settings{6},2,FTR(I)) + View_Settings{7}*[-1 1] + View_Settings{8}(2));
            axis equal
            
            % Center axis limits
            xl = xlim;
            yl = ylim;
            xlim(BotsData(View_Settings{6},1,FTR(I)) + View_Settings{8}(1) + (xl(2)-xl(1))/2 * [-1 1]);
            ylim(BotsData(View_Settings{6},2,FTR(I)) + View_Settings{8}(2) + (yl(2)-yl(1))/2 * [-1 1]);
            
    end
    
    grid off
    set(gca, 'fontsize',20, 'XMinorTick', 'on', 'YMinorTick', 'on')
    drawnow
    Time = round(TimeStamps(FTR(I)),3)
    
    
    
    
    RenderTime(I) = toc;
    
    if Export_Settings{1} == false
        pause((dt*Render_Settings(1)-RenderTime(I))/Playback_modifier);
        FrameTime(I) = toc; % Used to make sure the render plays in real time.
    else
        frame = getframe(gcf);
        writeVideo(video,frame);
    end
end




if Export_Settings{1} == true
   close(video);
else
    % Export render times
    % Plot render time: time to render and time between frames.
    % figure;
    % plot(1:length(FTR), RenderTime);
    % hold on;
    % plot(1:length(FTR), FrameTime)
    % legend("Render Time", "Total Render Time")

    fprintf("Rendering Complete\n")
    fprintf("\tMedian time / frame: " + median(sort(RenderTime)) + "s\n")              % Time to render frame, not time between frames
    fprintf("\tMinimum frame skip = " + median(sort(RenderTime))/dt + "s\n")               % Recommended delta time so that simulation can be played in real time. Depends on the machine this is running on.
    fprintf("\tAverage true render time / frame: " + mean(FrameTime(10:end)) + "s\n")   % Average time between frames
    fprintf("\tOffset from dt: " + (mean(FrameTime(10:end))-dt) + "s\n")              % Time difference between "time between frames" and delta time
end
end