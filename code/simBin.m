folder = '/home/abudzar/Carbon/Documents/tesis/data/mit_kemar_measurement/elev0/';

f = 1000;
Fs = 16000;
dt = 0:1/Fs:(1.5*Fs - 1)/Fs;
x = 0.5*sin(2*pi*f*dt);

for idx = 90:-5:-90
    
    if idx < 0
        theta = 360 + idx;
    else
        theta = idx;
    end

    [hl, ~] = audioread([folder sprintf('L0e%03ia.wav', theta)]);
    [hr, fs] = audioread([folder sprintf('R0e%03ia.wav', theta)]);

    if fs ~= Fs
        hl = resample(hl,Fs,fs);
        hr = resample(hr,Fs,fs);
    end

    X = [];
    X(:,1) = conv(x,hl);
    X(:,2) = conv(x,hr);

    audiowrite(sprintf('../data/tone/tone%ihz_%03i.wav',f,idx),X,Fs);
end