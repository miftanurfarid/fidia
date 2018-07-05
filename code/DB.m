clear; clc; close all;
%listfile=dir('cbrkwav3.wav');
%for i=1:length(listfile);
    [y,Fs]=audioread('Track 1_006.wav');
    S = 1;                                % (V/mPa) microphone sensitivity.
    p_Pa = y(:,1)/S;                      % (Pa) recorded signal in pascals, assuming y is in mV.
    spl_dB = spl(p_Pa,20*1e-6,0.01,Fs);    % this calculation specifies 1/4 second windowSize.
    db=max(spl_dB);
%   xlswrite('10-9500.xls' , 'coba500wav.wav');
%   xlswrite('10-9500.xls' , db,'sheet1',['L' num2str(i)]);

