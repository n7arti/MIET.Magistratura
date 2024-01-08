[center, U, obj_fcn] = fcm(fcmdata, 2);% определение центра кластеризации(два кластера)
maxU = max(U);% определение максимальной степени принадлежности отдельного элемента данных кластеру
index1 = find (U(1, :) == maxU);% распределение строк матрицы данных между соответствующими кластерами
index2 = find(U(2, :) == maxU);
figure;
hold on; grid on;
plot3(fcmdata (index1, 1), fcmdata (index1, 2), fcmdata (index1, 3),' bo', 'markersize', 5,'LineWidth' ,1); 
plot3(fcmdata (index2, 1), fcmdata (index2, 2), fcmdata (index2, 3), 'rx', 'markersize', 5,'LineWidth', 1);
plot3(center (1, 1), center (1, 2), center (1, 3), 'ko', 'markersize', 15, 'LineWidth', 2);
plot3(center (2, 1), center (2, 2), center (2, 3), 'kx', 'markersize', 15, 'LineWidth', 2);
view(3);
figure;
plot(obj_fcn)