function [v_ans,next_minmax] = NewSafestVelocity(indNew, ORCA, n, v_safe, v_max, prev_minmax)

    % Get maximal distance if using previous v_safe
    next_minmax = dot(ORCA(indNew,:) - v_safe(1,:), n(indNew,:));
    
    % If old v_safe still as low, choose the same safe velocity.
    if next_minmax < prev_minmax - 10^(-10)
            v_ans = v_safe;
            next_minmax = prev_minmax;
            return;
    end

    %% ==== Find intersection of new plane and old planes ====
    paraORCA = @(t,i) ORCA(i,:) + t.*n(i,:)*[0 1;-1,0];
    intersection = @(t,i1,i2) paraORCA(t(1),i1) - paraORCA(t(2),i2); 

    ORCAind = 1;
    secind = 1;
    coordintsec = zeros(0,0);
    dirintsec = zeros(0,0);
    valintsec = zeros(0,0);
    nintsec = zeros(0,0);
    mapSecToORCA = zeros(0,0);
    while (ORCAind < indNew)
        intsec = @(t) intersection(t,ORCAind,indNew);

        options = optimset('Display','off');
        [T,FVAL,EXITFLAG] = fsolve(intsec,ORCA(indNew,:),options);

        if (EXITFLAG > 0)
            coordintsec(secind,:) = paraORCA(T(2),indNew);
            valintsec(secind,:) = 0;
            dirintsec(secind,:) = (n(ORCAind,:) + n(indNew,:))/norm(n(ORCAind,:) + n(indNew,:));
            
            % Direction towards old safest point, perpendicular to line
            nintsec(secind,:) = dot((v_safe - coordintsec(secind,:)),(dirintsec(secind,:)*[0 1; -1 0]))*dirintsec(secind,:)*[0 1; -1 0];
            nintsec(secind,:) = nintsec(secind,:)/norm(nintsec(secind,:));
            
            mapSecToORCA(secind) = ORCAind;
            secind = secind + 1;
        
        elseif dot(n(ORCAind,:),n(indNew,:)) < 0 %if parallell and different direction
            % Half distance between the lines
            d = dot(ORCA(ORCAind,:) - ORCA(indNew,:),n(indNew,:))/2;
            
            coordintsec(secind,:) = ORCA(indNew,:) + d*n(indNew,:);
            coordintsec(secind,:) = dot(coordintsec(secind,:),n(indNew))*n(indNew); %Lowest speed
            valintsec(secind,:) = d;
            dirintsec(secind,:) = n(indNew,:)*[0,1;-1,0];
            
            % Direction towards old safest point, perpendicular to line
            nintsec(secind,:) = dot((v_safe - coordintsec(secind,:)),n(indNew,:))*n(indNew,:);
            nintsec(secind,:) = nintsec(secind,:)/norm(nintsec(secind,:));
            
            mapSecToORCA(secind) = ORCAind;
            secind = secind + 1;
        end
        
        ORCAind = ORCAind + 1;
    end
    
    %% ==== Handle cases with two planes ====
    if indNew == 2
        if ~isempty(coordintsec)
            v_ans = CheckSpeed(coordintsec(1,:), nintsec(1,:), v_max);
            next_minmax = dot(v_ans-ORCA(indNew,:),n(indNew,:));
          
        else
            d1 = dot(ORCA(1,:) - ORCA(2,:),n(2,:)); % value of plane 1 at line 2
            
            % Choose lowest speed on safest line
            if d1 < 0
                v_ans = dot(ORCA(2,:),n(2,:));
            else
                v_ans = dot(ORCA(1,:),n(1,:));
            end
            
            next_minmax = 0;
        end
        return;
    end
    
    %% ==== Handle cases with more than two planes ====
    
    % Find optimal
    v_safest = v_max*n(indNew,:);
    next_minmax = 0;
    i = 1;
    while (i <= size(coordintsec,1))
        [v_safest,next_minmax] = CurrentSafestVelocity(i, mapSecToORCA, ORCA, n, coordintsec, nintsec, dirintsec, valintsec, v_safest, next_minmax, v_max);
        i = i+1;
    end
    
    v_ans = v_safest;
end
