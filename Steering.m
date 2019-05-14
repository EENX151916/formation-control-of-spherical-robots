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


%% Beräkning av fel
ei = Goal(:,1:2) - Bots(:,1:2); % Positionsfelet

% --- Avståndsfel ---
Distance = vecnorm(ei,2,2);

% --- Fel i Vinkel ---
% Beräkna önskad positionens hastighet
persistent Goal_old;
if isempty(Goal_old), Goal_old = 0; end
Goal_vel = (Goal-Goal_old) / dt;
Goal_old = Goal;

% Beräkna siktpunkt
ei_aim = ei + Goal_vel * Aim_time;

% Beräkna önskad vinkel
real_goal_angle = atan2(ei(:,2),ei(:,1));
aim_goal_angle = atan2(ei_aim(:,2),ei_aim(:,1));

% Konvertera till (0,2pi]
real_goal_angle(real_goal_angle<0) = 2*pi+real_goal_angle(real_goal_angle<0);
aim_goal_angle(aim_goal_angle<0) = 2*pi+aim_goal_angle(aim_goal_angle<0);

% Beräkna vinkelfelet
Real_Theta_e = real_goal_angle - Bots(:,4);
Aim_Theta_e = aim_goal_angle - Bots(:,4);

% Om felet är större än pi, rotera åt andra hållet runt enhetscirkeln
Real_Theta_e(abs(Real_Theta_e) > pi) = -sign(Real_Theta_e(abs(Real_Theta_e) > pi)) .* (2*pi - abs(Real_Theta_e(abs(Real_Theta_e) > pi)));
Aim_Theta_e(abs(Aim_Theta_e) > pi) = -sign(Aim_Theta_e(abs(Aim_Theta_e) > pi)) .* (2*pi - abs(Aim_Theta_e(abs(Aim_Theta_e) > pi)));

% % Om felet är större än pi/2
% Theta_e(abs(Theta_e)>pi/2) = pi + Theta_e(abs(Theta_e)>pi/2) .* sign(Theta_e(abs(Theta_e)>pi/2));


%% Avstånds-förändrings Regulator

% Avståndet till önskad position ändras. Därför skall derivatan av
% avståndet till önskad position regleras så att den alltid minskar
% proprotionellt till hur stort avståndet är. Det betyder att ju större
% avstånd, desto snabbare ska minskningen i avståndet vara.


% ---------- Avstånd ----------
% Variabler som måste sparas
persistent Distance_old;
if isempty(Distance_old), Distance_old = Distance; end

real_dc = (Distance - Distance_old) / dt;
goal_dc = Distance_Kp * Distance + Distance_Kd * real_dc;

% Nya variabler som måste sparas
Distance_old = Distance;

% ---------- Fart ----------
dc_e = goal_dc + real_dc;

% Beräkning av styrsignalen för avstånds-förändrings-reglering.
dc_u = dc_e * dc_Kp .* cos(Real_Theta_e);



%% Omega Regulator
persistent Aim_Theta_e_old;
persistent Theta_e_tot;   
if isempty(Aim_Theta_e_old), Aim_Theta_e_old = 0; end
if isempty(Theta_e_tot), Theta_e_tot = 0; end

Theta_e_tot = Aim_Theta_e*dt + Theta_e_tot;

% Begränsa e_tot
Theta_e_tot(Theta_e_tot > Theta_e_tot_max) = Theta_e_tot_max;

% Beräkning av styrsignalen för avståndsreglering.
Theta_u = Aim_Theta_e*Theta_Kp + Theta_e_tot*Theta_Ki + (Aim_Theta_e - Aim_Theta_e_old)/dt * Theta_Kd;

% Uppdaterar gamla felet.
Aim_Theta_e_old = Aim_Theta_e;



%% Steering

Styrsignaler = [dc_u Theta_u];

% % Lägg på ett brus så att inga symmetriska fall uppstår
% Styrsignaler = Styrsignaler + rand(size(Styrsignaler))/50;



end















