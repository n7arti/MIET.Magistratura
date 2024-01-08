x = 0:0.1:25;

A = trimf(x, [0, 4, 8]);
B = trimf(x, [6, 12, 18]);

Union_AB = max(A, B);
Intersection_AB = min(A, B);
Complement_A = 1 - A;

figure;

subplot(4, 1, 1);
plot(x, A, 'r', x, B, 'b');
title('Исходные множества A и B');
legend('A', 'B');

subplot(4, 1, 2);
plot(x, Union_AB, 'g');
title('Объединение A и B');
legend('A ? B');

subplot(4, 1, 3);
plot(x, Intersection_AB, 'm');
title('Пересечение A и B');
legend('A ? B');

subplot(4, 1, 4);
plot(x, Complement_A, 'b');
title('Дополнение А');
legend('A', '1 - A');