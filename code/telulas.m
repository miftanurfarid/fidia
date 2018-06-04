clearvars; close all; clc;

% load data
% (x4)-(x3)-(x2)-(x1)
folder = '../data/sumber_bunyi_bergerak/';
[x(:,1), ~]  = audioread([folder 'Track 1_030.wav']); % right
[x(:,2), ~]  = audioread([folder 'Track 2_030.wav']);
[x(:,3), ~]  = audioread([folder 'Track 3_030.wav']);
[x(:,4), fs] = audioread([folder 'Track 4_030.wav']); % left

%
wl = 0.02* fs;
step = wl / 2;
nframes = floor((length(x) - wl + step) / step);
lenx = nframes * step - step + wl;
x = x(1:lenx,:);
d = 0.3;
c = 1554.1;
r = zeros(1,nframes);
theta = zeros(1,nframes);
dx = zeros(1,nframes);
dy = zeros(1,nframes);
phi = zeros(1,nframes);

start = 1;
for idx = 1:nframes
    fprintf('frame # %i : %i\n', idx, nframes)
    % [delta,~] = tde(x(start:start+wl-1,1), x(start:start+wl-1,2), fs);
    [delta21,~] = tde(x(start:start+wl-1,2), x(start:start+wl-1,1), fs);
    [delta32,~] = tde(x(start:start+wl-1,3), x(start:start+wl-1,2), fs);
    [delta43,~] = tde(x(start:start+wl-1,4), x(start:start+wl-1,3), fs);
            
    if mean(delta21 + delta32 + delta43) >= 0
        phi1 = estTheta(delta21,c,d);
        phi2 = estTheta(delta32,c,d);
        m = d * (2*tan(phi1) - tan(phi2)) / (tan(phi2) - tan(phi1));
        theta(idx) = - atan(tan(deg2rad(180) - phi2) / 0.5);

        if rad2deg(theta(idx)) < -85 && rad2deg(theta(idx)) > -95
            theta(idx) = -(theta(idx));
        end

        r(idx) = (m - 1.5 * d) / cos(theta(idx));

        if r(idx) == inf || r(idx) == -inf
            r(idx) = r(idx-1);
        end
        
        dx(idx) = r(idx) * cos(theta(idx));
        dy(idx) = r(idx) * sin(theta(idx));
        % plot(idx,r(idx),'rx'); hold on; ylim([-10 10]);
        % plot(idx,rad2deg(phi1),'rx'); hold on;
        % plot(idx,rad2deg(phi2),'bx'); hold on;
        % plot(idx,m,'rx'); hold on;
        plot(idx,(1.5*d - m), 'rx'); hold on;
    elseif mean(delta21 + delta32 + delta43) < 0
        phi3 = estTheta(delta43,c,d);
        phi4 = estTheta(delta32,c,d);
        m = d * (2*tan(deg2rad(180) - phi4) - tan(deg2rad(180) - phi3)) / (tan(deg2rad(180) - phi3) - tan(deg2rad(180) - phi4));
        theta(idx) = atan(tan(deg2rad(180) - phi3) / 0.5);

        if rad2deg(theta(idx)) < -85 && rad2deg(theta(idx)) > -95
            theta(idx) = -(theta(idx));
        end

        r(idx) = (m - 1.5 * d) / cos(theta(idx));

        if r(idx) == inf || r(idx) == -inf
            r(idx) = r(idx-1);
        end

        dx(idx) = - r(idx) * cos(theta(idx));
        dy(idx) = r(idx) * sin(theta(idx));
        % plot(idx,r(idx),'bx'); hold on; ylim([-10 10]);
        % plot(idx,rad2deg(phi3),'gx'); hold on;
        % plot(idx,rad2deg(phi4),'kx'); hold on;
        % plot(idx,m,'bx'); hold on;
        plot(idx,(1.5*d - m), 'bx'); hold on;
    end
    
    % figure(1);
    % plot(idx, r(idx), 'rx'); hold on; ylim([-10 10]);
    % plot(dx(idx), dy(idx), 'rx'); hold on; ylim([-10 10]); xlim([-10 10]);
    % plot(idx,rad2deg(theta(idx)),'rx'); hold on;
    
    pause(0.001);
    % theta(idx)          
    start = start + step;
end

% ylim([-10 10]);
% plot(r);