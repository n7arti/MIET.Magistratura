
[center, U, obj_fcn] = fcm(fcmdata, 2);% ����������� ������ �������������(��� ��������)
maxU = max(U);% ����������� ������������ ������� �������������� ���������� �������� ������ ��������
index1 = find (U(1, :) == maxU);% ������������� ����� ������� ������ ����� ���������������� ����������
index2 = find(U(2, :) == maxU);
plot (fcmdata (index1, 1), fcmdata (index1, 2),' ko', 'markersize', 5,'LineWidth' ,1); % ���������� ������, ��������������� ������� ��������
hold on
plot(fcmdata (index2, 1), fcmdata(index2, 2), 'kx', 'markersize', 5,'LineWidth', 1);% ���������� ������, ��������������� ������� ��������
plot(center(1, 1), center(1, 2), 'ko', 'markersize', 15, 'LineWidth', 2)
%���������� ���������� �������
plot (center (2, 1), center (2, 2), 'kx', 'markersize', 15, 'LineWidth',2) %���������� ���������� �������