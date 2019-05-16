function v_new = CollisionAvoidance(v_now,p_now,v_max,a_max,r,v_want,ind,Leader_Exists,dt, Bot_max_omega)

    % v_now is the velocity of each robot in x and y direction right now
    % p_now is the position of each robot right now
    % v_max is the maximal velocity of the robot
    % a_max is the maximal acceleration of the robot
    % r is the radius of the robot
    % v_want is the wanted velocity in x and y for this robot
    % ind is the index of this robot
    % Leader_Exists is true if a leader is included
    % dt is the time between calculations
    % Bot_max_omega is the maximal angle velocity

    tau = v_max/a_max + dt + pi/Bot_max_omega;

    % Create the ORCA half planes, saved in ORCA as points and vectors. 
    % n is the direction of the norm so that any velocity on that side of ORCA 
    % is allowed.
    [ORCA, n] = CreateORCA(v_now, p_now, v_max, tau, r, ind, Leader_Exists);

    % Choose best velocity from ORCA
    v_new = FindBestVelocityFromORCA(ORCA,n,v_want,v_max);

end


