function [v_ans,next_minmax] = CurrentSafestVelocity(secindNew, mapSecToORCA, ORCA, n, coordintsec, nintsec, dirintsec, valintsec, v_safest, prev_minmax, v_max)

    tol = 10^(-10);    % Tolerance when checking equality
    
    % Get maximal distance if using previous v_safest
    next_minmax = dot(ORCA(mapSecToORCA(secindNew),:) - v_safest, n(mapSecToORCA(secindNew),:));
    
    % If old v_safest still as low, choose the same safe velocity.
    if next_minmax <= prev_minmax + tol
            v_ans = v_safest;
            next_minmax = prev_minmax;
            return;
    end

    %% === Find intersection of new line and old lines ===
    
    paraIntersec = @(t,i) coordintsec(i,:) + t.*dirintsec(i,:);
    intersection = @(t,i1,i2) paraIntersec(t(1),i1) - paraIntersec(t(2),i2);

    secind = 1;
    lineind = 1;
    coordpoints = zeros(0,0);
    npoints = zeros(0,0);
    dirpoints = zeros(0,0);
    mapLineToSec = zeros(0,0);
    while (secind < secindNew)
        intsec = @(t) intersection(t,secind,secindNew);

        options = optimset('Display','off');
        [T,FVAL,EXITFLAG] = fsolve(intsec,coordintsec(secindNew,:),options);

        if (EXITFLAG > 0)
            coordpoints(lineind,:) = paraIntersec(T(2),secindNew);
            npoints(lineind,:) = nintsec(secind,:);
            dirpoints(lineind,:) = dirintsec(secind,:);
            mapLineToSec(lineind) = secind;
            lineind = lineind + 1;
        end

        secind = secind + 1;
    end
    
    
    %% === Decide which is allowed and closest ===
    
    maxSet = false;
    minSet = false;
    min_v = [0,0];
    max_v = [0,0];
    for j = 1:size(coordpoints,1)
        dir = dot(dirintsec(secindNew,:),npoints(j,:));
        
        if (dir > 0)
            if (~maxSet)
                max_v = coordpoints(j,:);
                maxind = j;
                maxSet = true;
            else
                if dot((max_v-coordpoints(j,:)),dirintsec(secindNew,:)) < 0
                    max_v = coordpoints(j,:);
                    maxind = j;
                end
            end
        else
            if (~minSet)
                min_v = coordpoints(j,:);
                minind = j;
                minSet = true;
            else
                if dot((min_v-coordpoints(j,:)),dirintsec(secindNew,:)) > 0
                    min_v = coordpoints(j,:);
                    minind = j;
                end
            end
        end
    end
    
    %% === Choose the best allowed point ===
    ind_ans = 0;
    if ~minSet
        v_ans = ORCA(mapSecToORCA(secindNew),:);
    else
        if maxSet && (dot((min_v-max_v),dirintsec(secindNew,:)) < 0)
            disp('This should not ever happen!');
        else
            v_ans = min_v;
        end
    end
    
    %% === Constraint to maximal speed ===
    
    if norm(v_ans) > v_max
        v_ans = CheckSpeed(v_ans, nintsec(secindNew,:), v_max);
    end
    
end
