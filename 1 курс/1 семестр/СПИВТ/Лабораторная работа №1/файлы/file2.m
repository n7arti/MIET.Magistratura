x = -30:1:50;
y = gaussmf (x, [10 11]);
plot (x, y, 'LineWidth', 4);
clear x;
x = [-20:50]';
y1 = gauss2mf (x, [5 6 10 12]);
y2 = gauss2mf (x, [5 10 11 10]);
y3 = gauss2mf (x, [10 12 5 6]);
figure
plot (x, y1, 'LineWidth', 4, 'Color', 'Red');
hold on;
plot (x, y2, 'LineWidth', 4, 'Color', 'Green');
hold on;
plot (x, y3, 'LineWidth', 4, 'Color', 'Blue');