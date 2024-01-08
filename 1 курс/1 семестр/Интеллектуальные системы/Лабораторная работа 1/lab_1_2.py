import numpy as np
import pandas as pd
from matplotlib import pyplot as plt
from lab_1_1 import computeCost
import warnings

warnings.filterwarnings('ignore')


def featureNormalize(X_norm):
    '''
    Инструкция:   Сначала, для каждого признака из набора данных вычислите
                  его среднее значение и произведите его вычитание из набора данных,
                  при этом среднее значение сохраните как mu. Далее, рассчитайте
                  стандартное (среднеквадратическое) отклонение sigma
                  для каждого признака и разделите X-mu на sigma.
                  Заметим, что X представляет собой матрицу, в которой каждый
                  столбец характеризует признак, а каждая строка - обучающий пример.
                  Нормализацию данных следует производить отдельно для каждого
                  признака
    '''
    mu = np.mean(X, axis=0)
    sigma = np.std(X, axis=0)
    X_norm = (X - mu) / sigma

    return X_norm, mu, sigma


def computeCostMulti(X, y, theta):
    m = y.shape[0]
    J = (1 / (2 * m)) * np.sum((np.dot(X, theta) - y) ** 2)

    return J


def gradientDescentMulti(X, y, theta, alpha, num_iters):
    m = y.shape[0]
    J_history = []

    for i in range(num_iters):
        # Вычисляем градиент
        gradient = (1 / m) * np.dot(X.T, (np.dot(X, theta) - y))

        # Обновляем параметры theta
        theta = theta - alpha * gradient
        # Сохраняйте функцию стоимости на каждой итерации
        J_history.append(computeCostMulti(X, y, theta))

    return theta, J_history


def normalEqn(X, y):
    theta = np.linalg.inv(X.T.dot(X)).dot(X.T).dot(y)

    return theta


data = pd.read_csv("cost_apartments.csv")
data.head()

# Задание 1
X = np.array(data[['squera', 'number_rooms']], dtype=float)
y = np.array(data['price'], dtype=float)
m = y.shape[0]

# Вывод на экран массива данных
print('Первые 10 элементов массива данных:');
print(X[:10])

X_norm, mu, sigma, = featureNormalize(X)
X = np.hstack((np.ones((m, 1)), X_norm))

# Задание 2
alpha = 0.01
num_iters = 1000
theta = np.zeros(3)
# Инициализация theta и нахождение локального экстремума (минимума)
# функции с помощью движения вдоль градиента (градиентный спуск)
theta, J_history = gradientDescentMulti(X, y, theta, alpha, num_iters)
print('theta:\n {} \n {} \n {} \n'.format(theta[0], theta[1], theta[2]))
print('J_history первое и последнее значение функции\n {} \n {}'.format(J_history[0], J_history[-1]))

print("%0.5f" % (computeCost(X, y, theta)))

# Вывод на экран графика сходимости процесса
plt.figure(figsize=(9, 7))
plt.plot(range(num_iters), J_history, label="learning rate {:.2f}".format(alpha))
plt.xlabel('Число итераций')
plt.ylabel('Функция стоимости J')
plt.grid(alpha=0.2)
plt.legend()
plt.show()

num_iters_test = 150
theta_test = np.zeros(2)
_, J_history_1 = gradientDescentMulti(X_norm, y, theta_test, 0.01, num_iters_test)
_, J_history_2 = gradientDescentMulti(X_norm, y, theta_test, 0.1, num_iters_test)
_, J_history_3 = gradientDescentMulti(X_norm, y, theta_test, 0.03, num_iters_test)
_, J_history_4 = gradientDescentMulti(X_norm, y, theta_test, 0.3, num_iters_test)

# Вывод на экран графика сходимости процесса
fig = plt.figure(figsize=(9, 7))
ax = fig.add_subplot(1, 1, 1)
ax.set_xlabel('Число итераций')
ax.set_ylabel('Функция стоимости J')
plt.title(' Сходимость метода градиентного спуска с соответствующим диапазоном скоростей обучения\n')
ax.plot(np.arange(len(J_history_1)), J_history_1, lw=2, c='r', label="learning rate {:.2f}".format(0.01))
ax.plot(np.arange(len(J_history_2)), J_history_2, lw=2, c='g', label="learning rate {:.2f}".format(0.1))
ax.plot(np.arange(len(J_history_3)), J_history_3, lw=2, c='b', label="learning rate {:.2f}".format(0.03))
ax.plot(np.arange(len(J_history_4)), J_history_4, lw=2, c='y', label="learning rate {:.2f}".format(0.3))
plt.grid(alpha=0.2)
plt.legend()
plt.show()

# Практическое задание
in_x = np.array([1, 60, 3])
norm_mu = np.concatenate([[0], mu], axis=0)
norm_sigma = np.concatenate([[1], sigma], axis=0)
norm_in_x = ((in_x - norm_mu) / norm_sigma).T
price = np.dot((theta.T), norm_in_x);

print('Стоимость трехкомнатной квартиры площадью 60 м2 оцененная методом')
print(f'градиентного спуска составляет: {price} рублей\n')

# Задание 3
X = np.array(data[['squera', 'number_rooms']], dtype=float)
y = np.array(data['price'], dtype=float)
m = y.shape[0]
X = np.concatenate([np.ones((m, 1)), X], axis=1)
print(X[0:5])

theta_sisteam = normalEqn(X, y)
print("Значение theta, полученное с помощью системы нормальных уравнений: ")
print(*theta_sisteam, sep='\n')

in_x_new = np.array([1, 60, 3])
price_sistem = in_x_new.dot(theta_sisteam)
print(
    'Стоимость трехкомнатной квартиры площадью 60 м2, оцененная методом наименьших квадратов составляет: {:.2f} рублей'.format(
        price_sistem))
