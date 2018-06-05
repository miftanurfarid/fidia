folder = '/home/abudzar/Carbon/Documents/tesis/data/mit_kemar_measurement/elev0/';

% f = 1000;
Fs = 16000;
% dt = 0:1/Fs:(1.5*Fs - 1)/Fs;
x = rand(1,Fs*2);

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

    if idx <= 90 && idx >= 0
        sudut = abs(idx - 90);
        audiowrite(sprintf('../data/tone/white_%03i.wav',sudut),X,Fs);
    else
        sudut = 90 - idx;
        audiowrite(sprintf('../data/tone/white_%03i.wav',sudut),X,Fs);
    end

end