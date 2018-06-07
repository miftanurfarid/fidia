function loud=loudness(freq, lF)
% Compute loudness level in Phons on the basis of equal-loudness functions.
% It accounts a middle ear effect and is used for frequency-dependent gain adjustments.
% This function uses linear interpolation of a lookup table to compute the loudness level, 
% in phons, of a pure tone of frequency freq using the reference curve for sound 
% pressure level dB. The equation is taken from section 4 of BS3383.
% 
% Input lF should be inputed by calling the function initMiddleEar,
% otherwise, calling initMiddleEar in this programme.
%
if nargin < 2,
   lF = initMiddleEar;
end

dB = 60;
if (freq<20 || freq>12500)
    return;
end
i=1;
while(lF.ff(i)<freq)
    i=i+1;
end

afy=lF.af(i-1)+(freq-lF.ff(i-1))*(lF.af(i)-lF.af(i-1))/(lF.ff(i)-lF.ff(i-1));
bfy=lF.bf(i-1)+(freq-lF.ff(i-1))*(lF.bf(i)-lF.bf(i-1))/(lF.ff(i)-lF.ff(i-1));
cfy=lF.cf(i-1)+(freq-lF.ff(i-1))*(lF.cf(i)-lF.cf(i-1))/(lF.ff(i)-lF.ff(i-1));
loud=4.2+afy*(dB-cfy)/(1+bfy*(dB-cfy));

end