% clearvars; close all; clc;
addpath(genpath(pwd));
addpath(genpath('../data'));

% load data
% (x4)-(x3)-(x2)-(x1)
% 18 22 24 25 = kapal
% 31 32 = puretone

[x1,  ~]  = audioread('Track 1_018.wav'); % right
[x2,  ~]  = audioread('Track 2_018.wav');
[x3,  ~]  = audioread('Track 3_018.wav');
[x4, fs]  = audioread('Track 4_018.wav'); % left

% filterbank
wave = mwavecreate(x2,x1,fs,0);
cc = mcorrelogram(80,5000,2.4,-1000,1000, 'hw', 'cp', wave, 0);
delay = mccgramplot2dsqrt(cc);
