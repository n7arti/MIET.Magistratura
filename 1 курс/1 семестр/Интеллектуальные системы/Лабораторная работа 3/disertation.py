import numpy as np
import matplotlib.pyplot as plt
from matplotlib.animation import FuncAnimation

# Параметры модели
X0 = 0.0  # Начальное положение бедра по оси X
Y0 = 0.0  # Начальное положение бедра по оси Y
Theta0 = 0.0  # Начальный угол бедра
Theta1 = 0.0  # Начальный угол колена
Theta2 = 0.0  # Начальный угол стопы
L1 = 1.0  # Длина бедра
L2 = 1.0  # Длина голени
L3 = 0.5  # Длина стопы

# Временные параметры
t_start = 0.0  # Начальное время
t_end = 2.0  # Конечное время
dt = 0.01  # Шаг времени

# Создание временного массива
t = np.arange(t_start, t_end, dt)

# Функция для вычисления положения суставов
def calculate_joint_positions():
    # Вычисление положения бедра
    X_b = X0 + L1 * np.sin(Theta0)
    Y_b = Y0 + L1 * np.cos(Theta0)

    # Вычисление положения колена
    X_k = X_b + L2 * np.sin(Theta0 + Theta1)
    Y_k = Y_b + L2 * np.cos(Theta0 + Theta1)

    # Вычисление положения стопы
    X_s = X_k + L3 * np.sin(Theta0 + Theta1 + Theta2)
    Y_s = Y_k + L3 * np.cos(Theta0 + Theta1 + Theta2)

    return X_b, Y_b, X_k, Y_k, X_s, Y_s

# Функция для обновления анимации
def update_frame(frame):
    plt.cla()  # Очистка текущего графика
    X_b, Y_b, X_k, Y_k, X_s, Y_s = calculate_joint_positions()

    # Отрисовка суставов и связей
    plt.plot([X0, X_b], [Y0, Y_b], color='b', linewidth=2)  # Бедро
    plt.plot([X_b, X_k], [Y_b, Y_k], color='g', linewidth=2)  # Голень
    plt.plot([X_k, X_s], [Y_k, Y_s], color='r', linewidth=2)  # Стопа
    plt.plot(X0, Y0, marker='o', markersize=6, color='b')  # Бедро - точка сустава
    plt.plot(X_b, Y_b, marker='o', markersize=6, color='g')  # Голень - точка сустава
    plt.plot(X_k, Y_k, marker='o', markersize=6, color='r')  # Стопа - точка сустава

    # Установка пределов осей
    plt.xlim(X0 - L1 - L2 - L3, X0 + L1 + L2 + L3)
    plt.ylim(Y0 - L1 - L2 - L3, Y0 + L1 + L2 + L3)

    plt.xlabel('Положение по оси X')
    plt.ylabel('Положение по оси Y')
    plt.title('Анимация движения ноги')

# Создание анимации
animation = FuncAnimation(plt.gcf(), update_frame, frames=len(t), interval=1000*dt)

# Отображение анимации
plt.show()