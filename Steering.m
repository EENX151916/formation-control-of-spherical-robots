function Styrsignaler = Steering(Goal, Bots, dt)

Distance_Kp = 0.5;
Distance_Kd = 0.4;
dc_Kp = 2;


% mod = 0.1;
% Distance_Kd = Distance_Kd * mod;
% Distance_Kp = Distance_Kp * mod;

% Omega regulator
Theta_Kp = 4;
Theta_Ki = 0;
Theta_Kd = 0;
Theta_e_tot_max = 0;
Aim_time = 0.4;


%% Ber�kning av fel
ei = Goal(:,1:2) - Bots(:,1:2); % Positionsfelet

% --- Avst�ndsfel ---
Distance = vecnorm(ei,2,2);

% --- Fel i Vinkel ---
% Ber�kna �nskad positionens hastighet
persistent Goal_old;
if isempty(Goal_old), Goal_old = 0; end
Goal_vel = (Goal-Goal_old) / dt;
Goal_old = Goal;

% Ber�kna siktpunkt
ei_aim = ei + Goal_vel * Aim_time;

% Ber�kna �nskad vinkel
real_goal_angle = atan2(ei(:,2),ei(:,1));
aim_goal_angle = atan2(ei_aim(:,2),ei_aim(:,1));

% Konvertera till (0,2pi]
real_goal_angle(real_goal_angle<0) = 2*pi+real_goal_angle(real_goal_angle<0);
aim_goal_angle(aim_goal_angle<0) = 2*pi+aim_goal_angle(aim_goal_angle<0);

% Ber�kna vinkelfelet
Real_Theta_e = real_goal_angle - Bots(:,4);
Aim_Theta_e = aim_goal_angle - Bots(:,4);

% Om felet �r st�rre �n pi, rotera �t andra h�llet runt enhetscirkeln
Real_Theta_e(abs(Real_Theta_e) > pi) = -sign(Real_Theta_e(abs(Real_Theta_e) > pi)) .* (2*pi - abs(Real_Theta_e(abs(Real_Theta_e) > pi)));
Aim_Theta_e(abs(Aim_Theta_e) > pi) = -sign(Aim_Theta_e(abs(Aim_Theta_e) > pi)) .* (2*pi - abs(Aim_Theta_e(abs(Aim_Theta_e) > pi)));

% % Om felet �r st�rre �n pi/2
% Theta_e(abs(Theta_e)>pi/2) = pi + Theta_e(abs(Theta_e)>pi/2) .* sign(Theta_e(abs(Theta_e)>pi/2));


%% Avst�nds-f�r�ndrings Regulator

% Avst�ndet till �nskad position �ndras. D�rf�r skall derivatan av
% avst�ndet till �nskad position regleras s� att den alltid minskar
% proprotionellt till hur stort avst�ndet �r. Det betyder att ju st�rre
% avst�nd, desto snabbare ska minskningen i avst�ndet vara.


% ---------- Avst�nd ----------
% Variabler som m�ste sparas
persistent Distance_old;
if isempty(Distance_old), Distance_old = Distance; end

real_dc = (Distance - Distance_old) / dt;
goal_dc = Distance_Kp * Distance + Distance_Kd * real_dc;

% Nya variabler som m�ste sparas
Distance_old = Distance;

% ---------- Fart ----------
dc_e = goal_dc + real_dc;

% Ber�kning av styrsignalen f�r avst�nds-f�r�ndrings-reglering.
dc_u = dc_e * dc_Kp .* cos(Real_Theta_e);



%% Omega Regulator
persistent Aim_Theta_e_old;
persistent Theta_e_tot;   
if isempty(Aim_Theta_e_old), Aim_Theta_e_old = 0; end
if isempty(Theta_e_tot), Theta_e_tot = 0; end

Theta_e_tot = Aim_Theta_e*dt + Theta_e_tot;

% Begr�nsa e_tot
Theta_e_tot(Theta_e_tot > Theta_e_tot_max) = Theta_e_tot_max;

% Ber�kning av styrsignalen f�r avst�ndsreglering.
Theta_u = Aim_Theta_e*Theta_Kp + Theta_e_tot*Theta_Ki + (Aim_Theta_e - Aim_Theta_e_old)/dt * Theta_Kd;

% Uppdaterar gamla felet.
Aim_Theta_e_old = Aim_Theta_e;



%% Steering

Styrsignaler = [dc_u Theta_u];

% % L�gg p� ett brus s� att inga symmetriska fall uppst�r
% Styrsignaler = Styrsignaler + rand(size(Styrsignaler))/50;



end















