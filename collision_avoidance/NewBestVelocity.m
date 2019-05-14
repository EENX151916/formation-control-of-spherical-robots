function [v_ans,exists_Allowed] = NewBestVelocity(indNew, ORCA, n, v_best, v_want, v_max)

    exists_Allowed = true;

    % If old v_best allowed, choose the same best velocity.
    if dot((v_best - ORCA(indNew,:)),n(indNew,:)) >= 0 - 10^(-10)
            v_ans = v_best;
            return;
    end

    % Plot ORCA
    if false
        figure(1)
        PlotORCAlines(ORCA,n);
        hold on
        plot(v_best(1),v_best(2),'x');
        hold off
        figure(2)
        PlotORCA(ORCA,n);
        hold on
        plot(v_best(1),v_best(2),'x');
        hold off
    end

    % Find coordinates of closest point on new line
    v_nb = v_want + dot((ORCA(indNew,:)-v_want),n(indNew,:))*n(indNew,:);

    % Check if v_nb is allowed
    newAllowed = true;
    for i = 1:indNew-1
        if (dot((v_nb - ORCA(i,:)),n(i,:)) < 0)
            newAllowed = false;
            break;
        end
    end

    % If new best is allowed, return values.
    if (newAllowed)
        v_ans = v_nb;
        if norm(v_nb) < v_max
            return;
        end  
    end


    % Find intersection of new line and old lines
    paraORCA = @(t,i) ORCA(i,:) + t.*n(i,:)*[0 1;-1,0];
    intersection = @(t,i1,i2) paraORCA(t(1),i1) - paraORCA(t(2),i2);

    ORCAind = 1;
    secind = 1;
    coordintsec = zeros(0,0);
    while (ORCAind < indNew)
        intsec = @(t) intersection(t,ORCAind,indNew);

        options = optimset('Display','off');
        [T,FVAL,EXITFLAG] = fsolve(intsec,[0,0],options);

        if (EXITFLAG > 0)
            coordintsec(secind,:) = paraORCA(T(2),indNew);
            nintsec(secind,:) = n(ORCAind,:);
            secind = secind + 1;
        end
        ORCAind = ORCAind + 1;
    end

    % Decide which is allowed and closest
    maxSet = false;
    minSet = false;
    min_v = [0,0];
    max_v = [0,0];
    for j = 1:size(coordintsec,1)
        dir = dot(n(indNew,:)*[0 1;-1,0],nintsec(j,:));
        if (dir >= 0)
            if (~maxSet)
                max_v = coordintsec(j,:);
                maxSet = true;
            else
                if dot((max_v-coordintsec(j,:)),(n(indNew,:)*[0 1;-1,0])) < 0
                    max_v = coordintsec(j,:);
                end
            end
        else
            if (~minSet)
                min_v = coordintsec(j,:);
                minSet = true;
            else
                if dot((min_v-coordintsec(j,:)),(n(indNew,:)*[0 1;-1,0])) > 0
                    min_v = coordintsec(j,:);
                end
            end
        end
    end    

    % Choose the best allowed point
    % If nothing is allowed
    if ~minSet
        if maxSet
            v_ans = max_v;
        end
    elseif ~maxSet
        v_ans = min_v;
    else
        if dot((min_v-max_v),n(indNew,:)*[0 1;-1,0]) < 0
            exists_Allowed = false;
            v_ans = v_best; % Should be set to something as safe as possible
        else
            if norm(min_v-v_want) < norm(max_v-v_want)
                v_ans = min_v;
            else
                v_ans = max_v;
            end
        end
    end

    % If the new best velocity has greater speed than maximal speed
    if norm(v_ans) > v_max
        % Lowest speed of the velocities on new ORCA-line.
        x_d = dot((ORCA(indNew,:)),n(indNew,:));

        % Velocity on ORCA-line with the lowest speed
        x = x_d * n(indNew,:);

        % If the lowest speed is still greater than maximal speed, choose
        % safest possible velocity.
        if abs(x_d) > v_max
            v_ans = v_max * v_ans/norm(v_ans);
            exists_Allowed = false;
        else % Choose best velocity with v_max as speed.
            v_ans = x + (v_ans-x)/norm(v_ans-x) * sqrt(v_max^2 - (x_d)^2);
        end
    end
end
