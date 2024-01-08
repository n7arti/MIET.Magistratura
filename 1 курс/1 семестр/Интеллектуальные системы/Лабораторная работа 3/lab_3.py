import numpy as np
import pandas as pd
import seaborn as sns
import math
from mpl_toolkits.mplot3d import axes3d
from matplotlib import cm
from matplotlib import pyplot as plt
import warnings
warnings.filterwarnings('ignore')
from sklearn import svm
import scipy.io

def plotData(X, y):
  # ====================== Ваш код здесь ======================
  # Указание: Реализуйте функцию, которая будет визуализировать набор данных


  plt.figure(figsize=(12, 8))
  y = y.ravel()

  plt.plot(X[:, 0][y == 1], X[:, 1][y == 1], "k+", label='Positive')
  plt.plot(X[:, 0][y == 0], X[:, 1][y == 0], "yo", label='Negative')
  plt.legend()

def svmTrain(X, y, C, kernelFunction, tol=1e-3, max_passes=-1, sigma=0.1):
    y = y.flatten()

    if kernelFunction == "gaussian_rbf":
        clf = svm.SVC(C = C, kernel="rbf", tol=tol, max_iter=max_passes, verbose=2)
        return clf.fit(gaussianKernelGramMatrix(X,X, sigma=sigma), y)

    else:
        clf = svm.SVC(C = C, kernel=kernelFunction, tol=tol, max_iter=max_passes, verbose=2)
        return clf.fit(X, y)

def visualizeBoundaryLinear(X, y, model, c):
    plotData(X, y)
    w = model.coef_[0]
    b = model.intercept_[0]
    xp = np.linspace(X[:,0].min(), X[:,0].max(), 100)
    yp = - (w[0] * xp + b) / w[1]

    plt.plot(xp, yp, linewidth = 3, color = 'blue', label='Граница классов')
    plt.legend(fontsize=15)
    plt.title('\n C = {:d} \n'.format(c), fontsize=20)

def visualizeBoundary(X, y, model, sigma = 0.1):
    x1plot = np.linspace(X[:,0].min(), X[:,0].max(), 100).T
    x2plot = np.linspace(X[:,1].min(), X[:,1].max(), 100).T
    X1, X2 = np.meshgrid(x1plot, x2plot)
    vals = np.zeros(X1.shape)
    for i in range(X1.shape[1]):
        this_X = np.column_stack((X1[:, i], X2[:, i]))
        vals[:, i] = model.predict(gaussianKernelGramMatrix(this_X, X, sigma=sigma))
    plotData(X, y)
    plt.contour(X1, X2, vals, colors="blue", levels=[0], linewidth=10, label='Граница классов')

def gaussianKernel(x1, x2, sigma=0.1):
  '''
  sim = gaussianKernel(x1, x2) Под ядром Гаусса подразумевается функция,
  определяющая сходство пары образцов на основании оценки расстояния между ними.
  Возвращаемой величиной является переменная sim

  Следует определить векторы x1 и x2 как векторы-столбцы
  '''
  # ====================== Ваш код здесь ======================
  # Указание: Запрограммируйте функцию, табулирующую близость векторов x1 и x2,
  # вычисляя значение ядра Гаусса, с параметром sigma
  sim = np.exp(-np.sum(np.square(x1 - x2)) / (2 * (sigma**2)))

  return sim

def gaussianKernelGramMatrix(X1, X2, K_function=gaussianKernel, sigma=0.1):
  gram_matrix = np.zeros((X1.shape[0], X2.shape[0]))
  for i, x1 in enumerate(X1):
    for j, x2 in enumerate(X2):
      gram_matrix[i, j] = K_function(x1, x2, sigma)
  return gram_matrix

def dataset3Params(X, y, Xval, yval):
  '''
  DATASET3PARAMS возвращает искомые параметры C и sigma для третьей части
  упражнения, в котором требуется определить оптимальные значения (C, sigma)
  для эффективного использования SVM с некоторой радиальной базисной функцией
  (например, c гауссовским ядром)

  Следует запрограммировать функцию, используя метод перекрестной проверки (кросс-валидация).

  Указание: Необходимо также рассчитать ошибку для набора данных, выбранных для проверки.
            Ошибка определяет долю примеров для перекрестной проверки, классифицированных
            неправильно.
  '''
  values = [0.01, 0.03, 0.1, 0.3, 1, 3, 10, 30]
  best_score = 0

  for C in values:
      for sigma in values:
          model = svm.SVC(C = C, kernel="rbf", gamma=1 / (2 * sigma ** 2))
          model.fit(X, y)
          score = model.score(Xval, yval)

          if score > best_score:
              best_score = score
              best_C = C
              best_sigma = sigma

  return best_C, best_sigma

#Часть 1: Загрузка и визуализация данных
mat = scipy.io.loadmat('ex3data1.mat')
X = mat["X"]
y = mat["y"]
plotData(X, y)
plt.show()

#Часть 2: Обучение линейного классификатора SVM
# Ваша задача в этой ячейке проанализировать как влияет параметр С на качество классификаци.
# Получить графики как на рисунках 2,3 и написать вывод.
C = [1, 100, 1000]
for c in C:
    model = svmTrain(X, y, c, "linear", 1e-3, 20)
    visualizeBoundaryLinear(X, y, model, c)
    plt.show()

#Часть 3: Применение радиальной базисной функции (ядра) Гаусса
x1 = np.array([1, 2, 1])
x2 = np.array([0, 4, -1])
sigma = 2
sim = gaussianKernel(x1, x2, sigma)

print("Gaussian Kernel between x1 =", x1, ", x2 =", x2, ", sigma =", sigma, ":\n{:f}".format(sim))

#Часть 4: Визуализация обучающего набора 2
mat = scipy.io.loadmat('ex3data2.mat')
X = mat["X"]
y = mat["y"]

plotData(X, y)
plt.show()

#Часть 5: Обучение SVM с радиальной базисной функцией Гаусса (Набор данных 2)
C = 1
sigma = 0.1

model = svmTrain(X, y, C, "gaussian_rbf", sigma=sigma)
visualizeBoundary(X, y, model)
plt.show()

#Часть 6: Визуализация обучающего набора 3
mat = scipy.io.loadmat('ex3data3.mat')
X = mat["X"]
y = mat["y"]

plotData(X, y)
plt.show()

#Часть 7: Обучение SVM с радиальной базисной функцией Гаусса (Набор данных 3)
Xval = mat["Xval"]
yval = mat["yval"]

# Задание: Определить оптимальные параметры С и σ, используя метод перекрестной проверки с помощью множества Хval, yval.
C, sigma = dataset3Params(X, y, Xval, yval)
print("Best parameters are C={:.2f}, sigma={:.2f}".format(C, sigma))

model = svmTrain(X, y, C, "gaussian_rbf", sigma=sigma)
visualizeBoundary(X, y, model, sigma)
plt.show()