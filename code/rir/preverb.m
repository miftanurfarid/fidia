function [b,a] = preverb(fs, delay, atten)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%                                                               %%%%%
%%%%%  This function creates the filter coeficients for a plain      %%%%%
%%%%%  reverb filter:    [b,a] = preverb(fs, delay,atten)           %%%%%
%%%%%  where 'delay' is the amount of delay between signal and      %%%%%
%%%%%  echo in milliseconds and 'fs' is the sampling frequency in   %%%%%
%%%%%  in killohertz, and 'atten' scales reverberations.            %%%%%
%%%%%  Update by Kevin D. Donohue 3/19/2003 (donohue@engr.uky.edu)  %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  Find integer part of the delay - 

g = round(delay*fs);

a = [1, zeros(1,g-2), -atten];   %  Comb-like pole structures
b = 1;                           %  Flat numerator response