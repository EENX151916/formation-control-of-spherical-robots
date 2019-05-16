function v_ans = CheckSpeed(v_ans, n, v_max)

if norm(v_ans) > v_max
    
    % Lowest speed of the velocities on the line.
    x_d = dot(v_ans,n);

    % Velocity on the line with the lowest speed
    x = x_d * n;

    % Choose safest velocity with v_max as speed.
    if x_d < v_max
        v_ans = x + (v_ans-x)/norm(v_ans-x) * sqrt(v_max^2 - (x_d)^2);
    else
        disp('CheckSpeed is not working');
    end
end