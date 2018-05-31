clearvars; close all; clc;

% load data
% (x1)-(x2)-(x3)-(x4)

[x(:,4), ~]  = audioread('../data/sumber_bunyi_bergerak/Track 1_030.wav'); % right
[x(:,3), ~]  = audioread('../data/sumber_bunyi_bergerak/Track 2_030.wav');
[x(:,2), ~]  = audioread('../data/sumber_bunyi_bergerak/Track 3_030.wav');
[x(:,1), fs] = audioread('../data/sumber_bunyi_bergerak/Track 4_030.wav'); % left

%
wl = 0.02 * fs;
step = wl / 2;
nframes = floor((length(x) - wl + step) / step);
lenx = nframes * step - step + wl;
x = x(1:lenx,:);
d = 0.3;
c = 1492.1;
r = zeros(1,nframes);
dx = zeros(1,nframes);
dy = zeros(1,nframes);

start = 1;
for idx = 1:nframes
    fprintf('frames #%i\n',idx);
    [delta(1), ~] = tde(x(start:start+wl-1,1), x(start:start+wl-1,2), fs);  % left
    [delta(2), ~] = tde(x(start:start+wl-1,2), x(start:start+wl-1,3), fs);  % mid
    [delta(3), ~] = tde(x(start:start+wl-1,3), x(start:start+wl-1,4), fs);  % right
    
    if mean(delta) > 0
        phi(1) = estTheta(delta(3),c,d);
        phi(2) = estTheta(delta(2),c,d);

        
    end
    
    % m = estM(phi,d);

    % r(idx) = (1.5 * d + m ) / cos(mean(phi));
    % r = d*sin(phi(1)) / sin(phi(1) - phi(2));
    % Y = sin(phi(1)) * r;
    % X = cos(phi(1)) * r;


    % if r(idx) == inf || r(idx) == -inf
    %     r(idx) = r(idx-1);
    % end

    % dx(idx) = r(idx) * cos(mean(phi));
    % dy(idx) = r(idx) * sin(mean(phi));

    plot(phi(1),'bo');
    hold on;
    plot(phi(2),'ro');
    plot(phi(3),'ko');
    pause(0.01);

    start = start + step;
end

% subplot(211);
% hold on; plot(cc(:,1));% plot(cc(:,2)); plot(cc(:,3));
% subplot(212);
% hold on; plot(phat(:,1));% plot(phat(:,2)); plot(phat(:,3));

% doa = estTheta(cc(:,1),1492.1,0.3);