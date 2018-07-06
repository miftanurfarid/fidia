function [t,E,fit] = calc_decay(z,y_fit,y_dec,fs)
% CALC_DECAY calculate decay time from decay curve
% Returns the time for a specified decay y_dec calculated
% from the fit over the range y_fit. The input is the
% integral of the impulse sample at fs Hz. The function also
% returns the energy decay curve in dB and the corresponding
% fit.

    E = 10 .* log10(z); % put into dB
    E = E - max(E); % normalise to max 0
    E = E(1:find(isinf(E),1,'first')-1); % remove trailing infinite values
    IX = find(E<=max(y_fit),1,'first'):find(E<=min(y_fit),1,'first'); % find yfit x-range
    if isempty(IX)
        error('Impulse response has insufficient dynamic range to evaluate to %i dB',min(y_fit))
    end

    % calculate fit over yfit
    xx = reshape(IX,1,length(IX));
    yy = reshape(E(IX),1,length(IX));
    pp = polyfit(xx,yy,1);
    fit = polyval(pp,1:2*length(E)); % actual fit
    fit2 = fit-max(fit); % fit anchored to 0dB

    diff_y = abs(diff(y_fit)); % dB range diff
    t = (y_dec/diff_y)*find(fit2<=-diff_y,1,'first')/fs; % estimate decay time

    fit = fit(1:length(E));

end