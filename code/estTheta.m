function doa = estTheta(etd,c,d)
    % doa = estimated doa
    % etd = estimated time delay
    % c   = speed of sound
    % d   = microphone - microphone

    % doa = real(rad2deg(acos(etd * c / d))); % in deg
    % doa = real(acos(etd * c / d)); % in rad
    doa = real(asin(etd * c / d));
end