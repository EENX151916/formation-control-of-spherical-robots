function theta = VectorToAngle(v, type)

    % This function gets the angle from the x-axis to the given 2D-vector.
    %
    %   Type == 1: radians
    %   Type == 2: degrees

    theta = cart2pol(v(1),v(2));
    theta = mod(theta,2*pi);

    if type == 2
        theta = theta * 360 / (2*pi);
    end
end