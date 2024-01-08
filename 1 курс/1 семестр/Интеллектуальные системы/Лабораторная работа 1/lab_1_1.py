import numpy as np
import pandas as pd
import scipy
from scipy.optimize import minimize
from matplotlib import pyplot as plt
import warnings

warnings.filterwarnings('ignore')


def plotData(x, y):
    '''
  Инструкция: Отобразите на графике исходные обучающие данные, используя
              команды "figure", "plot" или "scatter". Создайте подписи осей графиков,
              применяя команды "xlabel" и "ylabel". Определите, что данные
              о количестве населения и соответствующем доходе от продаж
              передаются в функцию plotData(x, y) в виде ее
              аргументов x and y
  '''
    plt.figure(1)
    plt.scatter(x, y, c='purple', marker='o', alpha=0.5)
    plt.title('Точечный график обучающих данных')
    plt.xlabel('Число жителей города (десятки тысяч)')
    plt.ylabel('Прибыль (10 тыс. руб)')
    plt.show()


def computeCost(X, y, theta):
    """
    Инструкция: Вычисляйте стоимость J как результат выбора параметра theta.
                В результате стоимость будет определяться величиной J.
    """
    m = len(X)
    J = 0
    hypothesis = np.dot(X, theta)
    squared_errors = (hypothesis - y) ** 2
    J = (1 / (2 * m)) * np.sum(squared_errors)

    return J


def gradientDescent(X, y, theta, alpha, num_iters):
    m = len(y)  # number of training examples
    J_history = np.zeros((num_iters, 1))

    for i in range(num_iters):
        # Вычисляем градиент
        gradient = (1 / m) * np.dot(X.T, (np.dot(X, theta) - y))

        # Обновляем параметры theta
        theta = theta - alpha * gradient

        # Сохраняйте функцию стоимости на каждой итерации
        J_history[i] = computeCost(X, y, theta)

        print(f'Итерация {i + 1}/{num_iters}: Стоимость = {J_history[i]}')

    return theta, J_history


def f_cost(x, df):
    theta_0, theta_1 = x
    return (np.sum((1 / (2 * len(df['profit']))) * ((theta_0 + df['population'] * theta_1 - df['profit']) ** 2)))


def main():
    # Задание 1
    df = pd.read_csv('service_center.csv')
    df.head()

    # строим набор наших данных
    plotData(df['population'], df['profit'])

    # Задание 2
    m = len(df)
    X = np.stack([np.ones(m), df['population']], axis=1)  # Добавляем единичный столбец к Х
    y = np.array(df['profit'])
    y = y.reshape((m, 1))
    print(X[0:5])
    theta = np.zeros((2, 1))  # Инициализируем начальные значения
    print(theta)
    iterations = 2000  # Количество итераций
    alpha = 0.01  # Скорость обучения

    print("Стоимость:", computeCost(X, y, theta))

    theta, J_history = gradientDescent(X, y, theta, alpha, iterations)  # Выполнение градиентного спуска

    plt.figure(figsize=(9, 7))
    plt.plot(range(iterations), J_history, label="cost function")
    plt.title('График изменения значения функции стоимости')
    plt.xlabel('Количество итераций')
    plt.ylabel('Функция стоимости')
    plt.grid(alpha=0.2)
    plt.legend()
    plt.show()

    x0 = np.array([1, 1])
    result = scipy.optimize.minimize(f_cost, x0, df, method='BFGS')
    result

    min_theta_0 = result.x[0]
    min_theta_1 = result.x[1]
    min_J = result.fun
    print(min_theta_0, min_theta_1, min_J, sep='\n')

    min_theta_0 = theta[0]
    min_theta_1 = theta[1]
    min_J = J_history.min()
    print(*min_theta_0, *min_theta_1, min_J, sep='\n')

    plt.figure(figsize=(9, 7))
    plt.scatter(df['population'], df['profit'], label="training data", s=150, c='purple', marker='o', alpha=0.55)
    plt.plot(X[:, 1], X.dot(theta), label="linear regression")
    plt.xlabel('Число жителей города (десятки тысяч)')
    plt.ylabel('Прибыль (10 тыс руб)')
    plt.grid(alpha=0.2)
    plt.legend()
    plt.show()

    predict1 = np.array([1, 3.5]).dot(theta)
    predict2 = np.array([1, 7]).dot(theta)

    print('Для количества изделий = 35,000, предсказываем прибыль: {:.2f} \n'.format(*predict1 * 10000))
    print('Для количества изделий = 70,000, предсказываем прибыль: {:.2f} \n'.format(*predict2 * 10000))

    # Задание 3
    # Сетка, на которой рассчитывается J
    theta0_vals = np.linspace(-10, 10, 100);
    theta1_vals = np.linspace(-1, 4, 100);

    theta0_ww, theta1_ww = np.meshgrid(theta0_vals, theta1_vals)

    # Инициализация J_vals to a matrix of 0's
    J_vals = np.zeros((len(theta0_vals), len(theta1_vals)))

    # Заполнение J_vals
    for i in range(len(theta0_vals)):
        for j in range(len(theta1_vals)):
            t = [theta0_vals[i], theta1_vals[j]]
            J_vals[i, j] = computeCost(X, y, t)

    w0 = np.linspace(-10, 10, 100)
    w1 = np.linspace(-1, 4, 100)

    ww0, ww1 = np.meshgrid(w0, w1)

    sse = []  # Sum of Squared Errors
    for j in range(len(w1)):
        sse.append([])
        for i in range(len(w0)):
            sse[j].append(
                (1 / (2 * len(df['profit']))) * ((ww0[j][i] + df['population'] * ww1[j][i] - df['profit']) ** 2).sum())
    sse = np.array(sse)

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')
    ax.view_init(20, 335)

    # ax.plot_surface(ww0, ww1, sse, cmap=plt.cm.Spectral, rstride=3, cstride=3)
    ax.plot_wireframe(ww0, ww1, sse, color='purple', rstride=3, cstride=3, antialiased=True, label='function cost')

    # точка - минимум
    ax.scatter(min_theta_0, min_theta_1, np.log(min_J),
               color='blue', marker='o', s=300,
               label='min: $θ_0$=%0.2f, $θ_1$=%0.2f, $J$=%0.2f' % (min_theta_0, min_theta_1, min_J))

    ax.set_xlabel('$θ_0$', fontsize=12)
    ax.set_ylabel('$θ_1$', fontsize=12)
    ax.set_zlabel('$J$', fontsize=12)
    plt.title('Визуализация функции стоимости', fontsize=15)
    plt.yticks(size=10)
    plt.xticks(size=10)
    plt.legend(fontsize=15)
    plt.show()

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection='3d')
    ax.view_init(5, 335)

    # ax.plot_surface(ww0, ww1, np.log(sse), cmap=plt.cm.Spectral, rstride=3, cstride=3)
    ax.plot_wireframe(ww0, ww1, np.log(sse), color='purple', rstride=3, cstride=3, antialiased=True,
                      label='function cost')

    # точка - минимум
    ax.scatter(min_theta_0, min_theta_1, np.log(min_J),
               color='blue', marker='o', s=300,
               label='min: $θ_0$=%0.2f, $θ_1$=%0.2f, $log(J)$=%0.2f' % (min_theta_0, min_theta_1, np.log(min_J)))

    ax.set_xlabel('$θ_0$', fontsize=12)
    ax.set_ylabel('$θ_1$', fontsize=12)
    ax.set_zlabel('$log(J)$', fontsize=12)
    plt.title('Визуализация функции стоимости', fontsize=15)
    plt.yticks(size=10)
    plt.xticks(size=10)
    plt.legend(fontsize=15)
    plt.show()

    # Контурное представление
    plt.figure(figsize=(9, 7))
    plt.contourf(ww0, ww1, np.log(sse))
    # plt.contour(ww0, ww1, np.log(sse))
    plt.scatter(min_theta_0, min_theta_1, s=100, c='red', marker='o',
                label='min: $θ_0$=%0.2f, $θ_1$=%0.2f' % (min_theta_0, min_theta_1))
    plt.xlabel('$θ_0$', fontsize=15)
    plt.ylabel('$θ_1$', fontsize=15)
    plt.yticks(size=13)
    plt.xticks(size=13)
    plt.legend(fontsize=20)
    plt.show()


if __name__ == "__main__":
    main()
