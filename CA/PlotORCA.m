function PlotORCA(ORCA,n)

    for ind = 1:size(ORCA,1)
    v = -10:0.01:10;
    [x, y] = meshgrid(v);
    cond = ones(length(v));
    for i = 1:length(v)
        for j = 1:length(v)
            if (dot(([x(i,j),y(i,j)] - ORCA(ind,:)),n(ind,:)) > 0)
                cond(i,j) = NaN;
            end        
        end
    end
    
    hold on
    surf(x, y, cond)
    hold off
end

