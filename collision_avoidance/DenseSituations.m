function v_safe = DenseSituations(ORCA,n,v_max)

    disp('Dense');

    % Randomize array to get lower expected runtime
    for i = size(ORCA,1):-1:2    
        rnd = ceil(rand * i);
        temp_O = ORCA(i,:);
        temp_n = n(i,:);
        ORCA(i,:) = ORCA(rnd,:);
        n(i,:) = n(rnd,:);
        ORCA(rnd,:) = temp_O;
        n(rnd,:) = temp_n;
    end

    % Set a starting point.
    v_safe = dot(ORCA(1,:),n(1,:))*n(1,:);
    prev_minmax = 0;
    if (norm(v_safe) > v_max)
        v_safe = v_safe/norm(v_safe) * v_max;
        prev_minmax = dot(ORCA(1,:)-v_safe,n(1,:));
    end
        
    % Find optimal point
    ind = 2;
    while (ind <= size(ORCA,1))
        [v_safe,prev_minmax] = NewSafestVelocity(ind, ORCA, n, v_safe, v_max, prev_minmax);
        ind = ind+1;
    end
end