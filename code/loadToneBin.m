theta = 90;
f = 1000;
filename = sprintf('../data/tone/tone%ihz_%03i.wav',f,theta);
[X,~] = audioread(filename);