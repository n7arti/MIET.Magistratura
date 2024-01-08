x = -20:1:50;
y = gbellmf (x, [10 11 12]);
plot (x, y, 'LineWidth', 4);
xlabel ('gbellmf (x, P), P = [10 11 12]');