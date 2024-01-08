rows = 1;
watched = randi([1,5],rows, 5);
predict = randi([1,5],rows, 1);

% Создание матрицы данных
checking = [watched, predict];
