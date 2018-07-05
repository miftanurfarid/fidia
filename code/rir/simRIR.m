clear all; close all; clc;
fs = 48000;
mic = [19 18 1.6];
n = 12;
r = 0.3;
rm = [20 19 21];
src = [5 2 1];
h=rir(fs, mic, n, r, rm, src);