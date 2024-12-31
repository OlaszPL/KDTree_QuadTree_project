from kdtree.kdtree import KDtree
from quadtree.quad import Quad
import generators
import numpy as np

ns = [100, 300, 500, 1000, 10**4, 10**5]
left, right = -1000, 1000

tests = []

def runtests_all():
    for i in ns:
        tests.append(generators.generate_uniform_points(left, right, i))
        tests.append(generators.generate_normal_points(45, 7, i))
        tests.append(generators.generate_grid_points(int(i**0.5)))
        tests.append(generators.generate_clustered_points(generators.generate_uniform_points(left, right, 4), 100, i // 4))
        tests.append(generators.generate_collinear_points((left, left), (right, right), i))
        tests.append(generators.generate_rectangle_points())
        tests.append(generators.generate_square_points(axis_n = i // 2, diag_n = i // 2))

    for test in tests:
        p1 = np.random.uniform(left, right, size=2)
        p2 = np.random.uniform(left, right, size=2)
        lower_left, upper_right = (min(p1[0], p2[0]), min(p1[1], p2[1])), (max(p1[0], p2[0]), max(p1[1], p2[1]))
        Q = Quad(test)
        res1 = Q.query_range(lower_left, upper_right)
        KD = KDtree(test)
        res2 = set(KD.query(lower_left, upper_right))

        if res1 != res2:
            print('Błąd - niezgodne wyniki między algorytmami!')
            return

    print('Testy zaliczone!')

if __name__ == '__main__':
    runtests_all()