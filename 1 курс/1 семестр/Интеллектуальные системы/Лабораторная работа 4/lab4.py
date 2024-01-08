import numpy as np
import imageio
from sklearn.cluster import KMeans
import sys
from matplotlib import pyplot as plt
import warnings
warnings.filterwarnings('ignore')

import scipy.io

def plotData(x):
    plt.figure(figsize=(17,13))
    plt.scatter(x[:,0], x[:,1], s = 200, color = 'green',  marker = 'o',  alpha=0.5)
    plt.yticks(size = 15)
    plt.xticks(size = 15)
    plt.title('Визуализация данных', fontsize=20)
    plt.show()

def findClosestCentroids(X, centroids):
  '''
   Осуществите полный перебор набора данных, для каждого элемента
   набора данных найдите соответствующий ему ближайший центр,
   сохраните индекс в одномерном массиве idx.
   А именно, idx(i) должен содержать индекс
   ближайшего центра для произвольного примера i. Таким образом,
   диапазон значений в заполняемом массиве должен быть от 1 до K.
  '''
  K = centroids.shape[0]
  idx = np.zeros((X.shape[0], 1), dtype=int)
  m = X.shape[0]

  for i in range(m):
      min_distance = float('inf')
      for k in range(K):
          distance = np.linalg.norm(X[i] - centroids[k])
          if distance < min_distance:
              min_distance = distance
              idx[i] = k

  return idx

def computeCentroids(X, idx, K):
  '''
  computeCentroids возвращает новые значения центров, формируемые в процессе
  итерационного уточнения положения среднего.
  Уточнение сводится к перегруппировке примеров (точек) к ближайшим центрам
  и последующему перерасчету местоположения центров.
  centroids = computeCentroids(X, idx, K) возвращает новые центры.
  В качестве входных данных выступает набор (матрица) X,
  каждая строка которого (которой) представляет собой отдельный пример, a
  вектор idx = m x 1 определяет индексы центров i-го примера
  (К - количество центров). Возвращаемой переменной является матрица
  центров, в которой каждая строка представляет собой конечное среднее центров.

  Указание:     Обрабатывайте каждый центр и вычисляйте среднее значение
                всех точек (примеров), которые ему соответствуют.
                Конкретнее, вектор-строка центров centroids(i, :)
                должен содержать среднее значение всех примеров,
                соответствующих центроиду i.
  '''
  m, n = X.shape
  centroids = np.zeros((K, n))
  for k in range(0, K):
      # Находим все точки, принадлежащие к центроиду k
      points = X[idx.flatten() == k, :]

      # Если есть точки, принадлежащие к центроиду, вычисляем среднее
      if points.shape[0] > 0:
          centroids[k, :] = np.mean(points, axis=0)

  return centroids

def drawLine(p1, p2):
    plt.plot([p1[0], p2[0]], [p1[1], p2[1]], linewidth = 2, color='black')

def hsv(n=63):
    from matplotlib import colors
    return colors.hsv_to_rgb(np.column_stack([np.linspace(0, 1, n+1), np.ones(((n+1), 2))]))

def plotDataPoints(X, idx, K):

    palette = hsv( K )
    colors = np.array([palette[int(i)] for i in idx])

    # Plot the data
    plt.scatter(X[:,0], X[:,1], s=200, facecolors='none', edgecolors=colors)

    return

def plotProgresskMeans(X, centroids, previous, idx, K, i):
    plotDataPoints(X, idx, K)
    plt.scatter(centroids[:,0], centroids[:,1], marker='x', s=500, c='k', linewidth=5)
    for j in range(centroids.shape[0]):
        drawLine(centroids[j, :], previous[j, :])

    plt.title('Iteration number {:d} \n'.format(i+1), fontsize=20)
    return

def runkMeans(X, initial_centroids, max_iters):

    m, n = X.shape
    K = initial_centroids.shape[0]
    centroids = initial_centroids
    previous_centroids = centroids
    idx = np.zeros((m, 1))

    plt.figure(figsize=(17,13))
    for i in range(max_iters):


        sys.stdout.write('\rK-Means iteration {:d}/{:d}...'.format(i+1, max_iters))
        sys.stdout.flush()

        idx = findClosestCentroids(X, centroids)

        plotProgresskMeans(X, centroids, previous_centroids, idx, K, i)
        previous_centroids = centroids

        centroids = computeCentroids(X, idx, K)

    plt.show()

    return centroids, idx

def kMeansInitCentroids(X, K):
  '''
  Указание: Установите центры случайным образом из набора Х.
  '''
  m, n = X.shape
  centroids = np.zeros((K, n))

  # Выбираем K случайных индексов из набора данных
  random_indices = np.random.choice(m, K, replace=False)

  # Используем выбранные индексы для установки центроидов
  centroids = X[random_indices, :]

  return centroids

def convert():
    image_path = 'flower.png'
    image = imageio.imread(image_path)

    # Преобразуйте изображение в массив NumPy
    image_array = np.array(image)

    # Создайте словарь, содержащий данные, которые вы хотите сохранить в MAT-файле
    mat_data = {"A": image_array}

    # Укажите путь к файлу MAT
    mat_file_path = 'flower.mat'

    # Сохраните данные в MAT-файле
    scipy.io.savemat(mat_file_path, mat_data)

#Часть 1: Нахождение ближайших центроидов
mat = scipy.io.loadmat('ex4data.mat')
x = mat['X']
plotData(x)
K = 3;
# 3 центроида
initial_centroids = np.array( [[3, 3], [6, 2], [8, 5]] )

# Нахождение ближайших центроидов для выбранных элементов
idx = findClosestCentroids(x, initial_centroids)
print('Ближайшие центры для 3-х первых примеров:\n')
print(*idx[:3])

#Часть 2: Вычисление средних
#  Вычислите средние значения центров, основываясь на центроидах, найденных
#  в предыдущей части.
centroids = computeCentroids(x, idx, K);
print('Перерасчет местоположения центров после нахождения ближайших центров: \n')
print('  ',centroids[0])
print('  ',centroids[1])
print('  ',centroids[2])
print('\nУказание: Ожидаемые значения центров\n')
print('   [ 2.428301 3.157924 ]')
print('   [ 5.813503 2.633656 ]')
print('   [ 7.119387 3.616684 ]')

#Часть 3: Кластеризация на основе метода k-средних
K = 3
max_iters = 10
initial_centroids = np.array([[3, 3], [6, 2], [8, 5]])

centroids, idx = runkMeans(x, initial_centroids, max_iters)
print('\nK-Means Done.\n')

model = KMeans(n_clusters = 3, random_state = 42)
model.fit(x)
print(model.labels_)
print(model.cluster_centers_)

plt.figure(figsize=(17,13))
plt.scatter(x[:,0],x[:,1], s = 200,  marker = 'o',  alpha=0.7, c=model.labels_)
plt.scatter(model.cluster_centers_[:,0] ,model.cluster_centers_[:,1], s = 200, color='red',  marker = 'o')
plt.show()

for i in range(5):
    print(kMeansInitCentroids(x,3), '\n')
    centroids, idx = runkMeans(x, kMeansInitCentroids(x,3), max_iters)

#Часть 4: "K-means" кластеризация элементов изображения
print('\nRunning K-Means clustering on pixels from an image.\n\n')
convert()

# Загрузка изображения птицы
mat = scipy.io.loadmat('flower.mat')
A = mat["A"]

A = A / 255.0 # Осуществляется деление на 255 с целью нормировки всех данных в диапазоне от 0 до 1

# Размер изображения
img_size = A.shape
expected_size = img_size[0] * img_size[1] * 3
if A.size != expected_size:
    raise ValueError(f"Cannot reshape array of size {A.size} into shape {img_size[0] * img_size[1], 3}")


# Переопределение RGB изображения в матрицу Nx3, где N = количество элизов.
# Таким образом, каждая строка содержит сейчас значения компонент красного, зеленого и синего цветов
# В результате таких трансформаций, образована матрица X, которая будет использована в k-means.
X = A.reshape(img_size[0] * img_size[1], 3, order='F').copy()

# При  моделировании следует производить случайную начальную инициализацию центроидов.
# Необходимо запрограммировать kMeansInitCentroids.m перед обработкой
K = 5
max_iters = 50
initial_centroids = kMeansInitCentroids(X, K)

# Моделирование алгоритма
centroids, idx = runkMeans(X, initial_centroids, max_iters)

#Часть 5: Сжатие изображения
print('\nApplying K-Means to compress an image.\n')

# Нахождение ближайших значений в кластере
idx = findClosestCentroids(X, centroids)

# Представление изображения X в терминах индексов в idx.

# Восстановление изображения производится посредством отображения каждой точки изображения
# (заданной посредством индексов в idx) на значения центроидов
X_recovered = centroids[idx,:]

# Преобразование формата изображения
X_recovered = X_recovered.reshape(img_size[0], img_size[1], 3, order='F')

# Отображение исходного изображения

plt.figure(figsize=(15,15))
plt.subplot(1, 2, 1)
plt.imshow(A)
plt.title('Original \n', fontsize=20)

# Отображение сжатого изображения
plt.subplot(1, 2, 2)
plt.imshow(X_recovered)
plt.title( 'Compressed, with {:d} colors. \n'.format(K), fontsize=20)
plt.show()

