import numpy as np
import random

def generate_uniform_points(left, right, n = 10 ** 5):
    """
    Funkcja generuje równomiernie n punktów na kwadwratowym obszarze od left do right (jednakowo na osi y) o współrzędnych rzeczywistych
    :param left: lewy kraniec przedziału
    :param right: prawy kraniec przedziału
    :param n: ilość generowanych punktów
    :return: tablica punktów w postaci krotek współrzędnych np. [(x1, y1), (x2, y2), ... (xn, yn)]
    """ 
    points =  np.random.uniform(left, right, size = (n, 2))
    return [tuple(point) for point in points]

def generate_normal_points(mean, std, n = 10 ** 5):
    """
    Funkcja generuje n punktów o rozkładzie normalnym na płaszczyźnie o współrzędnych rzeczywistych
    :param mean: średnia wartość rozkładu
    :param std: odchylenie standardowe rozkładu
    :param n: ilość generowanych punktów
    :return: tablica punktów w postaci krotek współrzędnych np. [(x1, y1), (x2, y2), ... (xn, yn)]
    """ 
    points = np.random.normal(mean, std, size=(n, 2))
    return [tuple(point) for point in points]

def generate_collinear_points(a, b, n = 100, x_range = 1000):
    """
    Funkcja generuje równomiernie n współliniowych punktów leżących na prostej ab pomiędzy punktami a i b
    :param a: krotka współrzędnych oznaczająca początek wektora tworzącego prostą
    :param b: krotka współrzędnych oznaczająca koniec wektora tworzącego prostą
    :param n: ilość generowanych punktów
    :return: tablica punktów w postaci krotek współrzędnych
    """
    points = []
    vect = (b[0] - a[0], b[1] - a[1])
    t_start = (-x_range - a[0]) / vect[0]
    t_end = (x_range - a[0]) / vect[0]

    t_factor = np.random.uniform(t_start, t_end, n)

    for t in t_factor:
        x = a[0] + vect[0] * t
        y = a[1] + vect[1] * t
        points.append((x, y))

    return [tuple(point) for point in points]

def generate_rectangle_points(a=(-10, -10), b=(10, -10), c=(10, 10), d=(-10, 10), n=100):
    '''
    Funkcja generuje n punktów na obwodzie prostokąta
    o wierzchołkach w punktach a, b, c i d
    :param a: lewy-dolny wierzchołek prostokąta
    :param b: prawy-dolny wierzchołek prostokąta
    :param c: prawy-górny wierzchołek prostokąta
    :param d: lewy-górny wierzchołek prostokąta
    :param n: ilość generowanych punktów
    :return: tablica punktów w postaci krotek współrzędnych
    korzystam z generowania punktów na prostej (będę losowo wybierał prostą, na której wygenerowany zostanie punkt)
    '''
    # (a, b)
    vect1 = (b[0] - a[0], b[1] - a[1])
    t1_start = 0
    t1_end = (b[0] - a[0]) / vect1[0]

    # (b, c)
    vect2 = (c[0] - b[0], c[1] - b[1])
    t2_start = 0
    t2_end = (c[1] - b[1]) / vect2[1]

    # (d, c)
    vect3 = (c[0] - d[0], c[1] - d[1])
    t3_start = 0
    t3_end = (c[0] - d[0]) / vect1[0]

    # (a, d)
    vect4 = (d[0] - a[0], d[1] - a[1])
    t4_start = 0
    t4_end = (d[1] - a[1]) / vect2[1]


    linears = [(a, vect1, t1_start, t1_end), (b, vect2, t2_start, t2_end), (d, vect3, t3_start, t3_end), (a, vect4, t4_start, t4_end)]
    points = []

    for _ in range(n):
        point, vect, t_start, t_end = random.choice(linears)
        t = np.random.uniform(t_start, t_end)
        x = point[0] + vect[0] * t
        y = point[1] + vect[1] * t
        points.append((x, y))

    return [tuple(point) for point in points]

def generate_square_points(a=(0, 0), b=(10, 0), c=(10, 10), d=(0, 10),
                           axis_n=25, diag_n=20):
    '''
    Funkcja generuje axis_n punktów na dwóch bokach kwadratu
    leżących na osiach x i y oraz diag_n punktów na
    przektąnych kwadratu, którego wyznaczają punkty
    a, b, c i d.
    :param a: lewy-dolny wierzchołek kwadratu
    :param b: prawy-dolny wierzchołek kwadratu
    :param c: prawy-górny wierzchołek kwadratu
    :param d: lewy-górny wierzchołek kwadratu
    :param axis_n: ilość generowanych punktów na każdym
                   z dwóch boków kwadratu równoległych do osi x i y
    :param diag_n: ilość generowanych punktów na każdej
                   przekątnej kwadratu
    :return: tablica punktów w postaci krotek współrzędnych
    '''
    points = [a, b, c, d]

    # (a, b)
    vect1 = (b[0] - a[0], b[1] - a[1])
    t1_start = 0
    t1_end = (b[0] - a[0]) / vect1[0]

    # (a, d)
    vect2 = (d[0] - a[0], d[1] - a[1])
    t2_start = 0
    t2_end = (d[1] - a[1]) / vect2[1]

    # (a, c)
    vect3 = (c[0] - a[0], c[1] - a[1])
    t3_start = 0
    t3_end = (c[0] - a[0]) / vect3[0]

    # (d, b)
    vect4 = (b[0] - d[0], b[1] - d[1])
    t4_start = 0
    t4_end = (b[0] - d[0]) / vect4[0]

    axis = [(a, vect1, t1_start, t1_end), (a, vect2, t2_start, t2_end)]
    diagonals = [(a, vect3, t3_start, t3_end), (d, vect4, t4_start, t4_end)]

    for point, vect, t_start, t_end in axis:
        for _ in range(axis_n):
            t = np.random.uniform(t_start, t_end)
            x = point[0] + vect[0] * t
            y = point[1] + vect[1] * t
            points.append((x, y))

    for point, vect, t_start, t_end in diagonals:
        for _ in range(diag_n):
            t = np.random.uniform(t_start, t_end)
            x = point[0] + vect[0] * t
            y = point[1] + vect[1] * t
            points.append((x, y))

    return [tuple(point) for point in points]

def generate_grid_points(n = 100):
    """
    Funkcja generuje punkty na siatce n x n
    :param n: ilość punktów wzdłuż jednej osi
    :return: tablica punktów w postaci krotek współrzędnych
    """
    return [(i, j) for i in range(n) for j in range(n)]

def generate_clustered_points(cluster_centers, cluster_std, points_per_cluster):
    """
    Funkcja generuje punkty w klastrach wokół podanych centrów klastrów
    :param cluster_centers: lista krotek współrzędnych centrów klastrów
    :param cluster_std: odchylenie standardowe dla każdego klastra
    :param points_per_cluster: ilość punktów w każdym klastrze
    :return: tablica punktów w postaci krotek współrzędnych
    """
    points = []
    for center in cluster_centers:
        cluster_points = np.random.normal(center, cluster_std, size=(points_per_cluster, 2))
        points += cluster_points
    return [tuple(point) for point in points]