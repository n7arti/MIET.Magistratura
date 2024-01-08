x = 0:0.1:20;
y1 = gaussmf (x, [5 10]);
y2 = 1-y1;
plot (x, y1,':', 'LineWidth', 4);
hold on;
plot (x, y2, 'LineWidth', 4, 'Color', 'Red');