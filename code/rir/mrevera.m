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

%  Sort delays into sequential order and adjust the corresponding scales
[d, n] = sort(delay);
ad = atten(n);
len = length(d);

%   Check to make sure first reverberation does not occur on the first
%   sample, if it does, eliminate it:

while d(1) == 1 
   d = d(2:len);
   ad = ad(2:len);
   len = length(d);
end
y = [y; zeros(fix(50*max(ad))*fix(max(d)*fs),1)];
%   Create denominator coefficients for reverberation filter
%  UNCOMMENT FOR AN ALL-PASS REVERB (FLAT FREQUENCY RESPONSE)
[b,a] = areverb(fs, d(1), ad(1)); %  first echo
%  UNCOMMENT FOR A PLAIN REVERB (COMB-LIKE FREQUENCY RESPONSE)
%[b,a] = preverb(fs, d(1), ad(1)); %  first echo
yout = filter(b,a,y);

for k = 2:len
    %  UNCOMMENT FOR AN ALL-PASS REVERB (FLAT FREQUENCY RESPONSE)
    [b,a] = areverb(fs, d(k), ad(k)); %  next echo
      %  UNCOMMENT FOR A PLAIN REVERB (COMB-LIKE FREQUENCY RESPONSE)
      %[b,a] = preverb(fs, d(k), ad(k)); %  next echo
     yout = yout + filter(b,a,y);      
end
yout = y + yout;