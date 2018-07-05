function [b,a] = areverb(fs, delay, atten)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                                                               %%%%%
%%%%%  This function creates the filter coeficients for an allpass   %%%%%
%%%%%  reverb filter:    [b,a] = areverb(fs, delay,atten)           %%%%%
%%%%%  where 'delay'  is the delay in ms between signal and         %%%%%
%%%%%  echo in milliseconds and 'fs' is the sampling frequency in   %%%%%
%%%%%  in killohertz, and 'atten' scales the reverberation          %%%%%
%%%%%  Update by Kevin D. Donohue 3/19/2003 (donohue@engr.uky.edu)  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Find integer part of the delay - 
g = round(delay*fs);

%   Create denominator and numerator coefficients for reverberation filter
a = [1, zeros(1,g-2), -atten];   %  Comb-like denomenator structure
b = [-atten, zeros(1, g-2), 1];  %  zero out infinite gain at combs, however phase remains intact
