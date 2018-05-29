clearvars; close all; clc;

f = 1000;   % 1000 Hz
fs = 16000;
sdt = 30:-0.5:-30;
c = 340;    % 340 m/s
d = 1;  % jarak antar mic
dt = 0:1/fs:length(sdt)*0.02;
x = 0.5*sin(2*pi*f*dt);

for idx = 1:length(sdt)
    delt = (d/2*sdt(idx) + d/2*sin(sdt(idx))) / c;
    dt2 = round(delt * fs);

    if sdt > 0
        xl = [zeros(1,dt2) xt];
        xr = [xt zeros(1,dt2) ];
    elseif sdt == 0
        xl = xt;
        xr = xt;
    else
        xr = [zeros(1,dt2) xt];
        xl = [xt zeros(1,dt2) ];
    end


end
