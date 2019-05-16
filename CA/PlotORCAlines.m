function PlotORCAlines(ORCA,n)

t = -10:10;
for i = 1:size(ORCA,1)
    this_ORCA = zeros(length(t),2);
    th_ORCA = @(s) ORCA(i,:) + s.*n(i,:)*[0 1;-1 0];
    
    for i = 1:length(t)
        this_ORCA(i,:) = th_ORCA(t(i));
    end
    hold on
    plot(this_ORCA(:,1),this_ORCA(:,2))
    hold off
end