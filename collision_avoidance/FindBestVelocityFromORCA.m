function v_best = FindBestVelocityFromORCA(ORCA,n,v_want,v_max)

    plotIt = false;

    % Make sure the wanted velocity is less than v_max.
    if norm(v_want) > v_max + 10^(-10)
        v_best = v_want/norm(v_want) * v_max;
%        plotIt = true;
    else
        v_best = v_want;
    end

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

    i = 1;
    allowed = true;
    while (i <= size(ORCA,1))
        [v_best,allowed] = NewBestVelocity(i, ORCA, n, v_best, v_want, v_max);

        if plotIt
            figure(1)
            plotORCAlines(ORCA,n);
            plot(v_best(1),v_best(2),'x');
            figure(2)
            plotORCA(ORCA,n);
            plot(v_best(1),v_best(2),'x');
        end

        if ~allowed
            disp("no allowed velocities");
            break;
        end
        i = i+1;
    end
    
    if ~allowed
        v_best = DenseSituations(ORCA,n,v_max);
    end
end