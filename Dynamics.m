function v_theta_goal_saturated = Dynamics(Bots, a_omega_goal, Bot_max_v, Bot_max_a, Bot_vald_max_a, Bot_max_omega, Bot_max_omega_acc, dt)
    
    % Get wanted linear acceleration and rotational velocity
    acc_goal = a_omega_goal(:,1);
    omega_goal = a_omega_goal(:,2);  
 
    % Saturate the acceleration
    acc_goal(abs(acc_goal) > Bot_vald_max_a) = Bot_vald_max_a * sign(acc_goal(abs(acc_goal) > Bot_vald_max_a));
    
    % Calculate new velocity and saturate it
    vel_goal = Bots(:,3) + acc_goal*dt;
    vel_goal(abs(vel_goal) > Bot_max_v) = Bot_max_v * sign(vel_goal(abs(vel_goal) > Bot_max_v));
    vel_goal(vel_goal <= 0) = 1E-5;
    
    % Calculate the new acceleration given that v > 0
    acc_goal = (vel_goal - Bots(:,3)) / dt;
 
    
    % Saturate omegas acceleration
    omega_acc_goal = (omega_goal - Bots(:,5))/dt;
    omega_acc_goal(abs(omega_acc_goal) > Bot_max_omega_acc) = Bot_max_omega_acc * sign(omega_acc_goal(abs(omega_acc_goal) > Bot_max_omega_acc));
    
    omega_goal = Bots(:,5) + omega_acc_goal * dt;
    
    % Calculate the new rotational velocity and saturate it    
    omega_max_adv = sqrt((Bot_max_a.^2 - acc_goal.^2) ./ vel_goal.^2);
    omega_max_adv(omega_max_adv > Bot_max_omega) = Bot_max_omega;
    
    omega_goal(abs(omega_goal) > omega_max_adv) = omega_max_adv(abs(omega_goal) > omega_max_adv) .* sign(omega_goal(abs(omega_goal) > omega_max_adv));
    
    
    
    v_theta_goal_saturated = [vel_goal omega_goal];
end
