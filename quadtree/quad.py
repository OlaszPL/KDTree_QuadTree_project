from enum import Enum

BUCKET_SIZE = 1 #ilość punktów przechowywanych w jednym liściu drzewa, domyślnie 1
def set_partition(points, x, y):
    p_ne = set()
    p_nw = set()
    p_sw = set()
    p_se = set()

    if points is not None:
        for p in points:
            if p[0] > x and p[1] > y:
                p_ne.add(p)
            elif p[0] <= x and p[1] > y:
                p_nw.add(p)
            elif p[0] <=x and p[1] <= y:
                p_sw.add(p)
            elif p[0] > x and p[1] <= y:
                p_se.add(p)

    return p_ne, p_nw, p_sw, p_se

class Quarter(Enum):
    NE = 1
    NW = 2
    SW = 3
    SE = 4

class Rectangle:
    def __init__(self, min_x, min_y, max_x, max_y):
        self.min_x = min_x
        self.min_y = min_y
        self.max_x = max_x
        self.max_y = max_y
    def __str__(self): return f'{self.min_x} {self.min_y} {self.max_x} {self.max_y}'
    def med_y(self): return (self.max_y + self.min_y) / 2.0
    def med_x(self): return (self.max_x + self.min_x) / 2.0
    #rectangle_partition zwraca 4 prostokąty odpowiadające ćwiartkom
    def rectangle_partition(self):
        med_y = self.med_y()
        med_x = self.med_x()
        s_ne = Rectangle(med_x, med_y, self.max_x, self.max_y)
        s_nw = Rectangle(self.min_x, med_y, med_x, self.max_y)
        s_sw = Rectangle(self.min_x, self.min_y, med_x, med_y)
        s_se = Rectangle(med_x, self.min_y, self.max_x, med_y)

        return s_ne, s_nw, s_sw, s_se
    #intersects sprawdza, czy dwa prostokąty się przecinają
    def intersects(self, other):
        return (self.min_x < other.max_x and self.max_x > other.min_x
                and self.min_y < other.max_y and self.max_y > other.min_y)
    #contains sprawdza, czy punkt należy do prostokąta
    def contains(self, point):
        x, y = point
        if self.min_x <= x <= self.max_x and self.min_y <= y <= self.max_y:
            return True
        return False
    #draw rysuje prostokąt w wizualizerze
    def draw(self, visualizer, color):
        return visualizer.add_line_segment((((self.min_x, self.min_y), (self.max_x, self.min_y)),
                                     ((self.min_x, self.min_y), (self.min_x, self.max_y)),
                                     ((self.min_x, self.max_y), (self.max_x, self.max_y)),
                                     ((self.max_x, self.min_y), (self.max_x, self.max_y))), color = color)

class Node:
    def __init__(self, tree, quarter, square, parent = None, children = (None, None, None, None)):
        self.tree = tree
        self.quarter = quarter
        self.parent = parent
        self.square = square
        self.ne, self.nw, self.sw, self.se = children
        self.points = None
    def __str__(self): return f'{self.square} {self.points}'
    def is_leaf(self): return self.points is not None and self != self.tree.root
    #construct_subtree rekurencyjnie tworzy drzewo ćwiartek w dół od danego liścia,
    # aż w każdym liściu będzie co najwyżej BUCKET_SIZE punków
    def construct_subtree(self, points, forced = False):
        if len(points) <= BUCKET_SIZE and not forced:
            self.points = points
            self.tree.leaves.append(self)
        else:
            x = self.square.med_x()
            y = self.square.med_y()
            p_ne, p_nw, p_sw, p_se = set_partition(points, x, y)
            s_ne, s_nw, s_sw, s_se = self.square.rectangle_partition()

            self.ne = Node(self.tree, Quarter.NE, s_ne, self)
            self.nw = Node(self.tree, Quarter.NW, s_nw, self)
            self.sw = Node(self.tree, Quarter.SW, s_sw, self)
            self.se = Node(self.tree, Quarter.SE, s_se, self)

            self.ne.construct_subtree(p_ne)
            self.nw.construct_subtree(p_nw)
            self.sw.construct_subtree(p_sw)
            self.se.construct_subtree(p_se)
    #rekurencyjne wstawianie punktu do gotowego drzewa
    def insert_subtree(self, point):
        if not self.square.contains(point): return False
        if self.is_leaf():
            if len(self.points) < BUCKET_SIZE:
                self.points.add(point)
                return True
            else:
                points_to_add = self.points.copy()
                points_to_add.add(point)
                self.construct_subtree(points_to_add)
                return True
        if self.ne.insert_subtree(point): return True
        if self.nw.insert_subtree(point): return True
        if self.se.insert_subtree(point): return True
        if self.sw.insert_subtree(point): return True
    #rekurencyjne wyszukiwanie punktów
    def query_range_subtree(self, range_rect):
        result = set()
        if self.square.intersects(range_rect):
            if self.points is not None:
                for point in self.points:
                    if range_rect.contains(point):
                        result.add(point)
            if self.ne is not None:
                r_ne = self.ne.query_range_subtree(range_rect)
                if r_ne is not None: result.update(r_ne)
            if self.nw is not None:
                r_nw = self.nw.query_range_subtree(range_rect)
                if r_nw is not None: result.update(r_nw)
            if self.sw is not None:
                r_sw = self.sw.query_range_subtree(range_rect)
                if r_sw is not None: result.update(r_sw)
            if self.se is not None:
                r_se = self.se.query_range_subtree(range_rect)
                if r_se is not None: result.update(r_se)
        return result
    #wersja wyszukiwania z wizualizacją
    def graphic_query_range_subtree(self, range_rect, visualizer, color):
        result = set()
        temp_square = self.square.draw(visualizer, color)
        stay = False
        if self.square.intersects(range_rect):
            if self.points is not None:
                stay = True
                for point in self.points:
                    if range_rect.contains(point):
                        visualizer.add_point(point, color = color)
                        result.add(point)
            if self.ne is not None:
                r_ne = self.ne.graphic_query_range_subtree(range_rect, visualizer, color)
                if r_ne is not None: result.update(r_ne)
            if self.nw is not None:
                r_nw = self.nw.graphic_query_range_subtree(range_rect, visualizer, color)
                if r_nw is not None: result.update(r_nw)
            if self.sw is not None:
                r_sw = self.sw.graphic_query_range_subtree(range_rect, visualizer, color)
                if r_sw is not None: result.update(r_sw)
            if self.se is not None:
                r_se = self.se.graphic_query_range_subtree(range_rect, visualizer, color)
                if r_se is not None: result.update(r_se)
        if not stay:
           visualizer.remove_figure(temp_square)
        return result
    def draw(self, visualizer, color):
        self.square.draw(visualizer, color)
        if self.ne is not None: self.ne.draw(visualizer, color)
        if self.nw is not None: self.nw.draw(visualizer, color)
        if self.sw is not None: self.sw.draw(visualizer, color)
        if self.se is not None: self.se.draw(visualizer, color)
class Quad:
    def __init__(self, points):
        self.points = points
        self.leaves = []
        self.root = Node(self, None, min_square(points))
        self.root.construct_subtree(points)
    def __str__(self): return self.leaves
    #poniższe funkcje wywołują swoje rekurencyjne odpowiedniki
    def insert(self, point): return self.root.insert_subtree(point)
    def query_range(self, range_rect): return self.root.query_range_subtree(range_rect)
    def graphic_query_range(self, range_rect, visualizer, color):
        range_rect.draw(visualizer, 'brown')
        return self.root.graphic_query_range_subtree(range_rect, visualizer, color)
    def draw(self, visualizer, color):
        self.root.draw(visualizer, color)

def min_square(points):
    min_x = min(p[0] for p in points)
    max_x = max(p[0] for p in points)
    min_y = min(p[1] for p in points)
    max_y = max(p[1] for p in points)
    return Rectangle(min_x, min_y, max_x, max_y)