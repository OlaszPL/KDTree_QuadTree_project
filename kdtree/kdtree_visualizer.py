from kdtree.kdtree import Node
from visualizer.main import Visualizer
import matplotlib.pyplot as plt

def visualize_queried_points(P, lower_left, upper_right, result):
    """Visualizes the queried points within a specified rectangular region.

    Parameters:
        P (list of tuple): A list of points (tuples) to be visualized. Each point should be a 2-tuple representing (x, y) coordinates.
        lower_left (tuple): The lower-left corner of the rectangular region as a 2-tuple (x, y).
        upper_right (tuple): The upper-right corner of the rectangular region as a 2-tuple (x, y).
        result (list of tuple): A list of points (tuples) that are the result of the query. Each point should be a 2-tuple representing (x, y) coordinates.

    Raises:
        TypeError: If the points in P are not 2-dimensional.
    """
    if len(P[0]) != 2: raise TypeError('Visualization only available for 2 dimensions!')
    vis = Visualizer()
    vis.add_point(P, color = 'blue')
    vis.add_polygon([lower_left, (upper_right[0], lower_left[1]), upper_right, (lower_left[0], upper_right[1])], color = 'grey', alpha = 0.4)
    vis.add_point(result, color = 'red')
    vis.show()


class KDtreeVisualizer:
    """KD-tree data structure with visualisations.
    """
    def __build_kdtree(self, P, depth, lower_bound, upper_bound):
        n = len(P[0])
        if n < 1: return None
        if n == 1: return Node(point = P[0][0])

        poly = self.vis_build.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'grey', alpha = 0.4)

        axis = depth % self.k
        median_point = P[axis][(n - 1) // 2]
        median = median_point[axis]

        if axis == 0:
            line = ((median_point[0], lower_bound[1]), (median_point[0], upper_bound[1]))
            self.vis_build.add_line_segment(line, color = 'orange', alpha = 0.8)
            self.lines.append(line)
            new_lower_bound = (median, lower_bound[1])
            new_upper_bound = (median, upper_bound[1])
        else:
            line = ((lower_bound[0], median_point[1]), (upper_bound[0], median_point[1]))
            self.vis_build.add_line_segment(line, color = 'green', alpha = 0.8)
            self.lines.append(line)
            new_lower_bound = (lower_bound[0], median)
            new_upper_bound = (upper_bound[0], median)

        prep_P_left, prep_P_right = [[] for _ in range(self.k)], [[] for _ in range(self.k)]

        for i in range(self.k):
            for p in P[i]:
                if p[axis] - median <= self.eps:
                    prep_P_left[i].append(p)
                else:
                    prep_P_right[i].append(p)

        self.vis_build.remove_figure(poly)

        return Node(
            line = median,
            left = self.__build_kdtree(prep_P_left, depth + 1, lower_bound, new_upper_bound),
            right = self.__build_kdtree(prep_P_right, depth + 1, new_lower_bound, upper_bound),
        )
    

    def __init__(self, P, eps = 0):
        if not P: raise ValueError('KDtree cannot be empty!')
        if len(P[0]) != 2: raise TypeError('Points does not match declared dimension - visualizer works only for 2 dimensions!')

        self.k = 2
        self.eps = eps
        # saved for correct visualization for multiple queries of points from the area
        self.points = P
        self.lines = []
        self.vis_build, self.vis_query = Visualizer(), Visualizer()
        self.vis_build.add_point(P, color = 'blue')

        preprocessed_P = [sorted(P, key = lambda x:x[i]) for i in range(self.k)]

        self.start_lower_bound = (preprocessed_P[0][0][0], preprocessed_P[1][0][1])
        self.start_upper_bound = (preprocessed_P[0][-1][0], preprocessed_P[1][-1][1])
        
        self.root = self.__build_kdtree(preprocessed_P, 0, self.start_lower_bound, self.start_upper_bound)


    def __contains(self, lower_bound, upper_bound, lower_left, upper_right):
        return all(lower_left[i] - lower_bound[i] <= self.eps for i in range(self.k)) and all(upper_right[i] - upper_bound[i] >= -self.eps for i in range(self.k))
    

    def __intersects(self, lower_bound, upper_bound, lower_left, upper_right):
        for i in range(self.k):
            if upper_bound[i] - lower_left[i] < -self.eps or lower_bound[i] - upper_right[i] > self.eps:
                return False
        return True
    
    
    def __search_kdtree(self, v : Node, lower_bound : list, upper_bound : list, lower_left, upper_right, depth):
        if v.left is None and v.right is None:
            if all(lower_left[i] - self.eps <= v.point[i] <= upper_right[i] + self.eps for i in range(self.k)):
                greenpoly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'green', alpha = 0.5)
                self.vis_query.add_point(v.point, color = 'green')
                self.vis_query.remove_figure(greenpoly)
                return [v.point]
            else:
                return []

        poly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'grey', alpha = 0.4)

        axis = depth % self.k
        if axis == 0:
            ls = self.vis_query.add_line_segment(((v.line, lower_bound[1]), (v.line, upper_bound[1])), color = 'orange')
        else:
            ls = self.vis_query.add_line_segment(((lower_bound[0], v.line), (upper_bound[0], v.line)), color = 'orange')

        points = []

        self.vis_query.remove_figure(poly)
        
        # left region
        if v.left is not None:
            old = upper_bound[axis]
            upper_bound[axis] = v.line
            if self.__contains(lower_bound, upper_bound, lower_left, upper_right):
                res = v.left.report_subtree()
                points += res
                greenpoly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'green', alpha = 0.5)
                self.vis_query.add_point(res, color = 'green')
                self.vis_query.remove_figure(greenpoly)
            elif self.__intersects(lower_bound, upper_bound, lower_left, upper_right):
                points += self.__search_kdtree(v.left, lower_bound, upper_bound, lower_left, upper_right, depth + 1)
            else:
                redpoly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'red', alpha = 0.5)
                self.vis_query.remove_figure(redpoly)
            # backtracking
            upper_bound[axis] = old

        # right region
        if v.right is not None:
            old = lower_bound[axis]
            lower_bound[axis] = v.line
            if self.__contains(lower_bound, upper_bound, lower_left, upper_right):
                res = v.right.report_subtree()
                points += res
                greenpoly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'green', alpha = 0.5)
                self.vis_query.add_point(res, color = 'green')
                self.vis_query.remove_figure(greenpoly)
            elif self.__intersects(lower_bound, upper_bound, lower_left, upper_right):
                points += self.__search_kdtree(v.right, lower_bound, upper_bound, lower_left, upper_right, depth + 1)
            else:
                redpoly = self.vis_query.add_polygon([lower_bound, (upper_bound[0], lower_bound[1]), upper_bound, (lower_bound[0], upper_bound[1])], color = 'red', alpha = 0.5)
                self.vis_query.remove_figure(redpoly)
            # backtracking
            lower_bound[axis] = old

        self.vis_query.remove_figure(ls)

        return points
    

    def query(self, lower_left, upper_right):
        if len(lower_left) != len(upper_right) != self.k:
            raise TypeError('Points does not match declared dimension!')
        
        self.vis_query.clear()
        self.vis_query.add_point(self.points, color = 'blue')
        self.vis_query.add_line_segment(self.lines, color = 'pink', alpha = 0.8)
        self.vis_query.add_polygon([lower_left, (upper_right[0], lower_left[1]), upper_right, (lower_left[0], upper_right[1])], color = 'darkblue', alpha = 0.4)
        
        # region represented as two k-dimensional boundary points
        return self.__search_kdtree(self.root, list(self.start_lower_bound), list(self.start_upper_bound), lower_left, upper_right, 0)
    
    def show_build_visualization(self, interval = 400):
        """Displays a visualization of the KD-tree building process.

        Parameters:
            interval (int): The time interval in milliseconds between frames in the visualization. Default is 400 ms.
        """
        return self.vis_build.show_gif(interval = interval)

    def show_query_visualization(self, interval = 600):
        """Displays a visualization of the query process.

        Parameters:
            interval (int): The time interval between frames in the visualization, in milliseconds. Default is 600 ms.
        """
        return self.vis_query.show_gif(interval = interval)


if __name__ == '__main__':
    points_set = [(3, 7), (1, 9), (2, 8), (6, 4), (4, 6), (5, 5), (9, 1), (7, 3), (8, 2)]
    kdtree = KDtreeVisualizer(points_set, eps=1e-12)
    lower_left = (5, 0)
    upper_right = (10, 6)

    print(kdtree.query(lower_left, upper_right))

    # kdtree.vis_build.save_gif(interval=400)
    kdtree.vis_query.save_gif(interval=600)