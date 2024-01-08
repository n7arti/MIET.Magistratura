
[center, U, obj_fcn] = fcm(fcmdata, 2);% определение центра кластеризации(два кластера)
maxU = max(U);% определение максимальной степени принадлежности отдельного элемента данных кластеру
index1 = find (U(1, :) == maxU);% распределение строк матрицы данных между соответствующими кластерами
index2 = find(U(2, :) == maxU);
plot (fcmdata (index1, 1), fcmdata (index1, 2),' ko', 'markersize', 5,'LineWidth' ,1); % построение данных, соответствующих первому кластеру
hold on
plot(fcmdata (index2, 1), fcmdata(index2, 2), 'kx', 'markersize', 5,'LineWidth', 1);% построение данных, соответствующих второму кластеру
plot(center(1, 1), center(1, 2), 'ko', 'markersize', 15, 'LineWidth', 2)
%построение кластерных центров
plot (center (2, 1), center (2, 2), 'kx', 'markersize', 15, 'LineWidth',2) %построение кластерных центров