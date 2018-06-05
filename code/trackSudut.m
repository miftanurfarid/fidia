clearvars; close all; clc;

% load data

for idx = 0:5:180
    filename = sprintf('../data/tone/white_%03i.wav',idx);
    [x, fs]  = audioread(filename);
    wl = 0.02 * fs;
    step = wl / 2;
    nframes = floor((length(x) - wl + step) / step);
    lenx = nframes * step - step + wl;
    x = x(1:lenx,:);
    d = 0.18;
    c = 343;

    [delta,~] = tde(x(:,1), x(:,2), fs);
    phi = rad2deg(estTheta(delta,c,d));
    plot(idx,phi,'rx',idx,idx,'k'); hold on;
end
plot(linspace(0,180,length(0:5:180)),linspace(0,180,length(0:5:180)));