# импортируем все необходимые билиотеки
import numpy as np
import pandas as pd
import math
from matplotlib import pyplot as plt
import warnings
from scipy.optimize import fmin
from scipy.optimize import fmin_bfgs
warnings.filterwarnings('ignore')

import seaborn as sns
sns.set(style='ticks')

def plotData(X, y, size, marker, color, label):
  '''
  Инструкция: Отобразите на графике исходные обучающие данные, используя
              команды "figure", "scatter". Создайте подписи осей графиков,
              применяя команды "xlabel" и "ylabel".
  '''
  plt.scatter(X, y, s=size, marker=marker, color=color, label=label)

  plt.xlabel('Шум')  # Название оси X
  plt.ylabel('Неравномерность вращения')  # Название оси Y
  plt.title('Точечный график обучающих данных')  # Название графика
  plt.legend()  # Добавление легенды

def sigmoid(z):
  """
  Указание:    z может быть матрицей вектором или скаляром.
  """
  g = 1 / (1 + np.exp(-z))
  return g

def costFunction(theta, X, y, return_grad=False):
  """
  Указание: Градиент должен иметь ту же размерность, что и theta
  """
  m = len(y)
  J = 0
  grad = np.zeros((theta.shape[0] , 1))

  h_theta = []
  first_part = []
  second_part = []
  for i in range(m):
    h_theta.append(sigmoid(np.matmul(np.transpose(theta), X[i])))
    first_part.append(-(y[i] * math.log(h_theta[i])))
    second_part.append((1 - y[i]) * math.log(1 - h_theta[i]))
    J += first_part[i] - second_part[i]
  J = J / m
  for j in range(X.shape[1]):
    summary = 0
    for i in range(m):
      summary += (h_theta[i] - y[i]) * X[i][j]
    grad[j] = summary / m

  if return_grad:
    return J, grad
  else:
    return J

def plotDecisionBoundary(X, theta, df):
  """
  Указание: Ваша задача разобраться, как строиться граница классов
  """
  x_values = [np.min(X[:, 1]), np.max(X[:, 2])]
  y_values = - (theta[0] + np.dot(theta[1], x_values)) / theta[2]

  plt.figure(figsize=(13,10))
  plt.plot(x_values, y_values, linewidth = 3, color = 'black', label='Граница классов')
  plotData(df['noise'][df['class'] == 0], df['rotation'][df['class'] == 0], 250, '>', 'green', 'Исправен' )
  plotData(df['noise'][df['class'] == 1], df['rotation'][df['class'] == 1], 250, '<', 'red', 'Поломка')

  plt.show()

def predict(x, y, threshold=0.5):
  """
  PREDICT Отнесение образца к классам 0 или 1 ("исправен" или "не исправен")
  в процессе линейной регрессии на основании оценки theta
  PREDICT обеспечивает классификацию X с пороговым
  значением 0.5 (т.е., если значение сигмоидной функции
  sigmoid(theta'*x) >= 0.5, то присвоение 1)
  """
  accuracy = 0
  for row, yi in zip(x, y):
    y_p = int(sigmoid(np.dot(theta.T, row)) >= threshold)
    if y_p == yi:
      accuracy += 1

  return accuracy / len(y)

def mapFeature(X1, X2):
    degree = 6
    out = np.ones((X1.shape[0], sum(range(degree + 2))))
    curr_column = 1
    for i in range(1, degree + 1):
      for j in range(i + 1):
        out[:, curr_column] = np.power(X1, i - j) * np.power(X2, j)
        curr_column += 1
    return out

def costFunctionReg(theta, X, y, lambda_reg):
  """
  Вычисление функции стоимости и значения градиента(ов)для
  задачи логистической регрессии с регуляризацией
  costFunctionReg(theta, X, y, lambda_reg) вычисляет функцию стоимости, используя
  theta в качестве параметра логистической регрессии, а также значение(я)
  градиентов
  """
  m = len(y)
  J = 0
  h = sigmoid(np.dot(X, theta))

  reg_term = (lambda_reg / (2 * m)) * np.sum(np.square(theta[1:]))
  J = -1 / m * (np.dot(y.T, np.log(h)) + np.dot((1 - y).T, np.log(1 - h))) + reg_term

  return J

def gradFunctionReg(theta, X, y, lambda_reg):
    grad = np.zeros(theta.shape)
    grad = (1. / m) * np.dot(sigmoid(np.dot(X, theta)).T - y, X).T + (float(lambda_reg) / m) * theta

    return grad.flatten()


def plotDecisionBoundary1(theta, lambda_reg):
  plt.figure(figsize=(10, 10))

  plotData(data['test_1'][data['class'] == 0], data['test_2'][data['class'] == 0], 200, 'o', 'blue', 'Class 1')
  plotData(data['test_1'][data['class'] == 1], data['test_2'][data['class'] == 1], 200, 's', 'orange', 'Class 2')

  u = np.linspace(-1, 1.5, 50)
  v = np.linspace(-1, 1.5, 50)
  uu, vv = np.meshgrid(u, v)
  z = np.zeros((len(u), len(v)))

  for i in range(len(u)):
    for j in range(len(v)):
      z[i, j] = np.dot(mapFeature(np.array([u[i]]), np.array([v[j]])), theta)
  z = np.transpose(z)

  plt.contour(u, v, z, levels=[0], colors='black', linewidths=3)
  plt.title('\n lambda = {:d}, Точность обучения: {:.2%} \n'.format(lambda_reg, predict(X, y)), fontsize=20)

  plt.xlabel('Test 1', fontsize=20)
  plt.ylabel('Test 2', fontsize=20)
  plt.yticks(size=15)
  plt.xticks(size=15)
  plt.yticks(size=15)
  plt.xticks(size=15)
  plt.legend(fontsize=15)
  plt.show()

df = pd.read_csv('engine.csv')
df.head()
df.describe()
# Формируем вектор признаков
m = len(df)
x = np.array(df['noise'])
temp = np.array(df['rotation'])
y = np.array(df['class'])

x = x.reshape((m, 1))
temp = temp.reshape((m, 1))
y = y.reshape((m, 1))
X = np.hstack((temp,x))
print(X[0:5])
# Добавляем к вектору признаков столбец единиц для theta_0
t = np.ones((m,1))
X = np.hstack((t,X))
print(X[0:5])

#Задание 1. Отображение
#строим набор наших данных
plt.figure(figsize=(13,10))
plotData (df['noise'][df['class'] == 0], df['rotation'][df['class'] == 0], 250, '>', 'green', 'Исправен' )
plotData (df['noise'][df['class'] == 1], df['rotation'][df['class'] == 1], 250, '<', 'red', 'Поломка')
plt.show()

#Задание 2: Вычисление функции стоимости и градиентов
[m, n] = X.shape
initial_theta = np.zeros((n , 1))

cost, grad = costFunction(initial_theta, X, y, True)
print('Значение функции стоимости при начальных (нулевых) значениях вектора thetа:', cost, '\n');
print('Значение градиента при начальных (нулевых) значениях вектора thetа:',grad, ' \n');

#Задание 3: Оптимизация
myargs=(X, y)
theta = fmin(costFunction, x0=initial_theta, args=myargs)
cost1 = costFunction(theta, X, y)
print('Стоимость',cost1)
print('Значение theta:',theta)
plotDecisionBoundary(X, theta, df)

#Задание 4: Предсказание и оценка точности
prob = sigmoid(np.array([1, 45, 85]).dot(theta[:, np.newaxis]))
print('Для двигателя с уровнем шума 45 и вибрацией 85, предсказывается поломка с вероятностью:  {:.2%} \n'.format(prob[0]))
print('Точность обучения: {:.0%} \n'.format(predict(X, y)))

#Задание 5: Регуляризованная логистическая регрессия
data = pd.read_csv('test.csv')
data.head()
data.describe()
m = len(data)
x = np.array(data['test_1'])
temp = np.array(data['test_2'])
y = np.array(data['class'])

x = x.reshape((m, 1))
temp = temp.reshape((m, 1))
y = y.reshape((m, 1))
X = np.hstack((temp,x))
print(X[0:5])
plt.figure(figsize=(13,10))
plotData(data['test_1'][data['class'] == 0], data['test_2'][data['class'] == 0], 200, 'o', 'blue', 'Class 1' )
plotData(data['test_1'][data['class'] == 1], data['test_2'][data['class'] == 1], 200, 's', 'orange', 'Class 2')
plt.xlabel('Test 1')
plt.ylabel('Test 2')
plt.show()

X = mapFeature(X[:,0], X[:,1])
X.shape
initial_theta = np.zeros((X.shape[1], 1))
print(initial_theta)

cost = costFunctionReg(initial_theta, X, y, 1)
print('Значение функции стоимости при начальном значении theta (zeros):', cost)

gradFunctionReg(initial_theta, X, y, 1)

#Задание 6: Регуляризация и точность
lambda_reg = [0, 1, 10, 100, 150]

for lambda_i in lambda_reg:
    myargs=(X, y, lambda_i)
    theta = fmin_bfgs(costFunctionReg, x0 = initial_theta, args = myargs)
    plotDecisionBoundary1(theta, lambda_i)
lambda_reg = 0
myargs=(X, y, lambda_reg)
theta = fmin_bfgs(costFunctionReg, x0 = initial_theta, args = myargs)
print('Максимальная точность обучения: {:.2%} \n'.format(predict(X, y)))