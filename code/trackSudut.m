clearvars; close all; clc;

% load data
% (x4)-(x3)-(x2)-(x1)

[x(:,1), ~]  = audioread('Track 1_030.wav'); % right
[x(:,2), ~]  = audioread('Track 2_030.wav');
[x(:,3), ~]  = audioread('Track 3_030.wav');
[x(:,4), fs] = audioread('Track 4_030.wav'); % left

%
wl = 0.02 * fs;
step = wl / 2;
nframes = floor((length(x) - wl + step) / step);
lenx = nframes * step - step + wl;
x = x(1:lenx,:);
d = 0.3;
c = 1554.1;

start = 1;
for m = 1:nframes
    [delta12,~] = tde(x(start:start+wl-1,2), x(start:start+wl-1,1), fs);
    plot(dx(idx),dy(idx),'rx'); hold on;
    
end