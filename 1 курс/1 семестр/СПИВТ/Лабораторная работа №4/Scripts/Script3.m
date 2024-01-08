clear; close all;
A=[rand(1,10) + 0.5; rand(1,10); rand(1,10)];
B=[rand(1,10); rand(1,10) + 0.5; rand(1,10)];
C=[rand(1,10); rand(1,10); rand(1,10) + 0.5];
figure;
hold on; grid on;
plot3(A(1,:), A(2, :), A(3, :), 'bo');
plot3(B(1,:), B(2, :), B(3, :), 'rx');
plot3(C(1,:), C(2, :), C(3, :), 'y+');
view(3);

MN=[min(A) max(A); min(B) max(B); min(C) max(C)];
net = newc(MN, 3);
net = train(net,[A, B, C]);
w = net.IW{1};
plot3(w(:, 1),w(:,2), w(:,3), 'kp');