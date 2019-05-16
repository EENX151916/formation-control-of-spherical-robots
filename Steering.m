function SteeringSignals = Steering(Goal, Bots, dt)

Distance_Kp = 0.5;
Distance_Kd = 0.4;
dc_Kp = 2;


% mod = 0.1;
% Distance_Kd = Distance_Kd * mod;
% Distance_Kp = Distance_Kp * mod;

% Omega controller
Theta_Kp = 4;
Theta_Ki = 0;
Theta_Kd = 0;
Theta_e_tot_max = 0;
Aim_time = 0.4;


%% === Calculating errors ===

ei = Goal(:,1:2) - Bots(:,1:2); % Position error

% --- Distance error ---
Distance = vecnorm(ei,2,2);

% --- Directional error ---
% Calculate the velocity of the wanted position
persistent Goal_old;
if isempty(Goal_old), Goal_old = 0; end
Goal_vel = (Goal-Goal_old) / dt;
Goal_old = Goal;

% Calculate aiming point
ei_aim = ei + Goal_vel * Aim_time;

% Calculate wanted angle
real_goal_angle = atan2(ei(:,2),ei(:,1));
aim_goal_angle = atan2(ei_aim(:,2),ei_aim(:,1));

% Convert to (0,2pi]
real_goal_angle(real_goal_angle<0) = 2*pi+real_goal_angle(real_goal_angle<0);
aim_goal_angle(aim_goal_angle<0) = 2*pi+aim_goal_angle(aim_goal_angle<0);

% Calculate directional error
Real_Theta_e = real_goal_angle - Bots(:,4);
Aim_Theta_e = aim_goal_angle - Bots(:,4);

% If error is greater than pi, rotate the other way around the unit circle
Real_Theta_e(abs(Real_Theta_e) > pi) = -sign(Real_Theta_e(abs(Real_Theta_e) > pi)) .* (2*pi - abs(Real_Theta_e(abs(Real_Theta_e) > pi)));
Aim_Theta_e(abs(Aim_Theta_e) > pi) = -sign(Aim_Theta_e(abs(Aim_Theta_e) > pi)) .* (2*pi - abs(Aim_Theta_e(abs(Aim_Theta_e) > pi)));

% If error is greater than pi/2
% Theta_e(abs(Theta_e)>pi/2) = pi + Theta_e(abs(Theta_e)>pi/2) .* sign(Theta_e(abs(Theta_e)>pi/2));


%% Controller of distance changes
% Distance to wanted position is changed. Therefore the derivative of the
% distance to the wanted position must be regulated so that it always 
% decrease proportional to how great the distance is. This means that the
% greater the distance, the faster the error decrease will be.

% ---------- Distance ----------
% Variables that has to be saved
persistent Distance_old;
if isempty(Distance_old), Distance_old = Distance; end

real_dc = (Distance - Distance_old) / dt;
goal_dc = Distance_Kp * Distance + Distance_Kd * real_dc;

% New variables that has to be saved
Distance_old = Distance;

% ---------- Speed ----------
dc_e = goal_dc + real_dc;

% Calculation of steering signal for controlling changes in distance
dc_u = dc_e * dc_Kp .* cos(Real_Theta_e);



%% Omega controller

persistent Aim_Theta_e_old;
persistent Theta_e_tot;   
if isempty(Aim_Theta_e_old), Aim_Theta_e_old = 0; end
if isempty(Theta_e_tot), Theta_e_tot = 0; end

Theta_e_tot = Aim_Theta_e*dt + Theta_e_tot;

% Limiting e_tot
Theta_e_tot(Theta_e_tot > Theta_e_tot_max) = Theta_e_tot_max;

% Calculating steering signal for the distance controller
Theta_u = Aim_Theta_e*Theta_Kp + Theta_e_tot*Theta_Ki + (Aim_Theta_e - Aim_Theta_e_old)/dt * Theta_Kd;

% Update the old error
Aim_Theta_e_old = Aim_Theta_e;



%% Steering

SteeringSignals = [dc_u Theta_u];

end















