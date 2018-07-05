% non linear data fitting

x = [2.5 3.5 4.5 5.5 6.5]';
y = [-43.095 -45.735 -46.016 -56.393 -57.39]';

plot(x, y, 'ro');

[f, g] = fit(x, y, 'exp1');
