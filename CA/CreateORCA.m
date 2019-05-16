function [ORCA,n] = CreateORCA(v_now, p_now, v_max, tau, r, ind, Leader_Exists)

    rel_v = v_now(ind,:) - v_now;    % Relative velocity
    M = p_now - p_now(ind,:);        % Centre of collision disc
    R = 2*r;                         % Radius of collision disc

    % No ORCA for itself
    rel_v(ind,:) = [];
    M(ind,:) = [];

    % Only check for robots nearby
    Leader_Far_Away = false;
    k = 1;
    while k <= size(M,1)
        if norm(M(k,:)) > 2*v_max*tau+R
            M(k,:) = [];
            rel_v(k,:) = [];
            if k == 1 && ~Leader_Far_Away
                Leader_Far_Away = true;
            end
        else
            k = k+1;
        end
    end

    % If no robots nearby
    if size(M,1) == 0
        ORCA = zeros(0);
        n = zeros(0);
        return;
    end

    M_tau = M(:,:)/tau;
    R_tau = R/tau;

    %% === Calculate tangent lines of disc ===
    
    for i = 1:size(rel_v,1)
        M_tau_v = M_tau(i,:) - [0,0];
        M_tau_norm = norm(M_tau_v);
        Q_tau_0 = M_tau_v - (R_tau^2 * M_tau_v)/(M_tau_norm)^2;
        Q_tau_v = ((R_tau*sqrt(M_tau_norm^2 - R_tau^2))/M_tau_norm) * ((M_tau_v*[0,1;-1,0])/M_tau_norm);
        Q_tau_1(i,:) = Q_tau_0 + Q_tau_v; % Tangentpoint for the first line
        Q_tau_2(i,:) = Q_tau_0 - Q_tau_v; % Tangentpoint for the second line
    end

    %% === Find u and n ===
    
    for i = 1:size(M_tau,1)

        % Instantiate vectors
        normtang = zeros(2,2);
        disttang = zeros(2,1);
        pointtang = zeros(2,2);

        Q_tau(1,:) = Q_tau_1(i,:);
        Q_tau(2,:) = Q_tau_2(i,:);
        
        % First and second tangentline and point
        for index = 1:2
            normtang(index,:) = (Q_tau(index,:)-M_tau(i,:))/norm(Q_tau(index,:)-M_tau(i,:));
            disttang(index) = dot((Q_tau(index,:)-rel_v(i,:)),normtang(index,:));
            pointtang(index,:) = rel_v(i,:) + disttang(index)*normtang(index,:);
        end

        % Check which point is closer
        if abs(disttang(1)) < abs(disttang(2))
            ind_close = 1;
            ind_far = 2;
        else
            ind_close = 2;
            ind_far = 1;
        end

        % Check if closest line is on tangent line or on arc
        if dot(pointtang(ind_close,:)-Q_tau(ind_close,:),Q_tau(ind_close,:)/norm(Q_tau(ind_close,:))) < 0
            if dot(pointtang(ind_far,:)-Q_tau(ind_far,:),Q_tau(ind_far,:)/norm(Q_tau(ind_far,:))) < 0
                % closest is in radial direction
                n(i,:) = (rel_v(i,:)-M_tau(i,:))/norm(rel_v(i,:)-M_tau(i,:));
                u(i,:) = M_tau(i,:) + R_tau * n(i,:) - rel_v(i,:);
            else
                % Closest is on the tangentline ind_far
                u(i,:) = pointtang(ind_far,:) - rel_v(i,:);
                n(i,:) = normtang(ind_far,:);
            end
        else
            % Closest is on tangent line ind_close
            u(i,:) = pointtang(ind_close,:) - rel_v(i,:);
            n(i,:) = normtang(ind_close,:);
        end
    end

    % Set ORCA
    ORCA = v_now(ind,:) + 1/2*u;

    % Take whole responsibility for not colliding with the leader
    if Leader_Exists && ~Leader_Far_Away
        ORCA(1,:) = ORCA(1,:) + 1/2*u(1,:);
    end

end

