x = 0:0.1:15;
y = trimf(x, [4 8 12]);
plot (x, y, 'LineWidth', 4);
xlabel ('trimf (x, P), P = [4 8 12]');
figure
y = trapmf(x, [2 4 6 8]);
plot (x, y, 'LineWidth', 4);
xlabel ('trapmf (x, P), P = [2 4 6 8]');