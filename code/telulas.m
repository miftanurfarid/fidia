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
r = zeros(1,nframes);
theta = zeros(1,nframes);
dx = zeros(1,nframes);
dy = zeros(1,nframes);

start = 1;
for idx = 1:nframes
    fprintf('frames #%i\n',idx);
  % [delta,~] = tde(x(start:start+wl-1,1), x(start:start+wl-1,2), fs);
    [delta12,~] = tde(x(start:start+wl-1,2), x(start:start+wl-1,1), fs);
    [delta23,~] = tde(x(start:start+wl-1,3), x(start:start+wl-1,2), fs);
    [delta43,~] = tde(x(start:start+wl-1,4), x(start:start+wl-1,3), fs);
   % [delta32,~] = tde(x(start:start+wl-1,2), x(start:start+wl-1,3), fs);
            
    if mean(delta12+delta23+delta43) > 0
        phi1 = estThetaCos(delta12,c,d);
        phi2 = estThetaCos(delta23,c,d);
        m = d * (2*tan(phi2) - tan(phi1)) / (tan(phi1) - tan(phi2));
        theta(idx) = atan(tan(phi2) / 0.5);
        r(idx) = (1.5 * d + m) / cos(theta(idx));
        dx(idx) = r(idx) * cos(theta(idx));
        dy(idx) = r(idx) * sin(theta(idx));
    elseif mean(delta12+delta23+delta43) < 0
        phi3 = estTheta(delta43,c,d);
        phi4 = estTheta(delta23,c,d);
        m = d * (2*tan(phi3) - tan(phi4)) / (tan(phi4) - tan(phi3));
        theta(idx) = atan(tan(phi3) / 0.5);
        r(idx) = (1.5 * d + m) / cos(theta(idx));
        dx(idx) = r(idx) * cos(theta(idx));
        dy(idx) = r(idx) * sin(theta(idx));
    end
    
    %m = estM(phi1,d);

%     r(idx) = (1.5 * d + m ) / cos(mean(phi));
%     r = d*sin(phi(1)) / sin(phi(1) - phi(2));
%          Y = sin(theta) * r;
%          X = cos(theta) * r;


%     if r(idx) == inf || r(idx) == -inf
%         r(idx) = r(idx-1);
%     end

%     dx(idx) = r(idx) * cos(mean(phi));
%     dy(idx) = r(idx) * sin(mean(phi));
% 
%     figure(1)
%     plot(r(idx),'bx');
%     hold on;
%     figure(2)
        plot(dx(idx),dy(idx),'rx'); hold on;
        pause(0.01);
%                           
    start = start + step;
end
% 
%  subplot(211);
%  hold on; plot(cc(:,1));% plot(cc(:,2)); plot(cc(:,3));
%  subplot(212);
%  hold on; plot(phat(:,1));% plot(phat(:,2)); plot(phat(:,3));

% doa = estTheta(cc(:,1),1492.1,0.3);