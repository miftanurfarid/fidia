function yout = mreverba(y, fs, delay, atten)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                                                               %%%%%
%%%%%  This function performs a multiple all-pass reverb filter on  %%%%%
%%%%%  input signal Y:    [b,a] = mreverba(y, fs, delay,atten)       %%%%%
%%%%%  where 'delay'  a vector of delays between signal and         %%%%%
%%%%%  echo in milliseconds and 'fs' is the sampling frequency in   %%%%%
%%%%%  in killohertz, and 'atten' is a vector that scales each      %%%%%
%%%%%  reverberation corresponding to a delay.                      %%%%%
%%%%%  Update by Kevin D. Donohue 3/19/2003 (donohue@engr.uky.edu)  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Find integer part of the delay - 

g = fix(delay*fs);

%  Sort delays into sequential order and adjust the corresponding scales

[d, n] = sort(g);
ad = atten(n);
len = length(d);

%   Check to make sure first reverberation does not occur on the first
%   sample, if it does, eliminate it:

while d(1) == 1 
   d = d(2:len);
   ad = ad(2:len);
   len = length(d);
end

%   Create denominator coefficients for reverberation filter
[b,a] = areverb(fs, d(1), ad(1)); %  first echo
yout = filter(b,a,y);
for k = 2:len
     [b,a] = areverb(fs, d(k), ad(k)); %  next echo    
      yout = yout + filter(b,a,y);
end
