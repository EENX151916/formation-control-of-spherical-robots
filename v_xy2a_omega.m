function a_omega_goal = v_xy2a_omega(v_goal, Bots, dt)
% This function converts the goal velocity [v_x, v_y] to polar coordinates
% [v, theta]. Then, calculates the change needed [a, theta].


% ------- Theta to Omega -------
% Convert [v_x, v_y] to [v, theta].
v_theta_goal = [vecnorm(v_goal,2,2) atan2(v_goal(:,2),v_goal(:,1))];
% Saturate theta to (0, 2pi]
v_theta_goal(v_theta_goal(:,2)<0, 2) = v_theta_goal(v_theta_goal(:,2)<0, 2) + 2*pi;


% Get difference between current and goal theta
Theta_e = v_theta_goal(:,2) - Bots(:,4);
% If Theta_e is larger than pi, rotate the other way
Theta_e(abs(Theta_e) > pi) = -sign(Theta_e(abs(Theta_e) > pi)) .* (2*pi - abs(Theta_e(abs(Theta_e) > pi)));

% Convert theta to omega
omega = Theta_e/dt;


% ------- v to a -------
a_goal = (v_theta_goal(:,1) - Bots(:,3))/dt;


a_omega_goal = [a_goal omega];

end