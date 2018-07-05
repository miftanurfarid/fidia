% spl sumber bunyi
splSource = 130;

% baca file bunyi dari sensor
[h1, fs1] = audioread('../data/gerak1/Track 4_030.wav');
[h2, fs2] = audioread('../data/gerak1/Track 3_030.wav');
[h3, fs3] = audioread('../data/gerak1/Track 2_030.wav');
[h4, fs4] = audioread('../data/gerak1/Track 1_030.wav');

spl1 = spl(h1,'water',0.01,fs1);
spl2 = spl(h2,'water',0.01,fs2);
spl3 = spl(h3,'water',0.01,fs3);
spl4 = spl(h4,'water',0.01,fs4);

spl1 = max(spl1);
spl2 = max(spl2);
spl3 = max(spl3);
spl4 = max(spl4);

splMax = max(spl1 spl2 spl3 spl4);

n = 0.3;
r = splMax / n;