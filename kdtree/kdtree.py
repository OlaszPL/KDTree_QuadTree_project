class Node:
    """A node in the KD-tree data structure.
    """
    def __init__(self, line = None, left = None, right = None, point = None):
        """Initialize a Node in the KD-tree.

        Parameters:
            line: The splitting line for the node.
            left (Node): The left child node.
            right (Node): The right child node.
            point: The point stored in the node.
        """
        self.line = line
        self.left = left
        self.right = right
        self.point = point

    def report_subtree(self):
        """Report all points in the subtree rooted at this node.

        Returns:
            list: A list of points in the subtree.
        """
        points = []
        if self.left is None and self.right is None:
            points.append(self.point)
        else:
            if self.left is not None:
                points += self.left.report_subtree()
            if self.right is not None:
                points += self.right.report_subtree()

        return points

class KDtree:
    """KD-tree data structure
    """
    inf = float('inf') # static variable

    def __build_kdtree(self, P, depth):
        """Build the KD-tree recursively.

        Parameters:
            P (list): The k-dimensional list of lists of points sorted by k-dimension to build the tree from.
            depth (int): The current depth in the tree.

        Returns:
            Node: The root node of the KD-tree.
        """
        n = len(P[0])
        if n < 1: return None
        if n == 1: return Node(point = P[0][0])

        axis = depth % self.k
        median = P[axis][(n - 1) // 2][axis]

        prep_P_left, prep_P_right = [[] for _ in range(self.k)], [[] for _ in range(self.k)]

        for i in range(self.k):
            for p in P[i]:
                if p[axis] - median <= self.eps:
                    prep_P_left[i].append(p)
                else:
                    prep_P_right[i].append(p)

        return Node(
            line = median,
            left = self.__build_kdtree(prep_P_left, depth + 1),
            right = self.__build_kdtree(prep_P_right, depth + 1),
        )
    

    def __init__(self, P, k = 2, eps = 0):
        """Initialize a KDTree object.

        Parameters:
            P (list): List of points.
            k (int, optional): Number of dimensions. Default is 2.
            eps (float, optional): Tolerance for zero. Default is 0.

        Raises:
            ValueError: If the list of points P is empty.
            TypeError: If the points do not match the declared dimension k.
        """
        if not P: raise ValueError('KDtree cannot be empty!')
        if len(P[0]) != k: raise TypeError('Points does not match declared dimension!')

        self.k = k
        self.eps = eps

        preprocessed_P = [sorted(P, key = lambda x:x[i]) for i in range(k)]
        
        self.root = self.__build_kdtree(preprocessed_P, 0)


    def __contains(self, lower_bound, upper_bound, lower_left, upper_right):
        """Check if the current region is within the given bounds.

        Parameters:
            lower_bound (list or tuple): The lower bound coordinates.
            upper_bound (list or tuple): The upper bound coordinates.
            lower_left (list or tuple): The lower-left coordinates of the node.
            upper_right (list or tuple): The upper-right coordinates of the node.

        Returns:
            bool: True if the region is within the bounds, False otherwise.
        """
        return all(lower_left[i] - lower_bound[i] <= self.eps for i in range(self.k)) and all(upper_right[i] - upper_bound[i] >= -self.eps for i in range(self.k))
    

    def __intersects(self, lower_bound, upper_bound, lower_left, upper_right):
        """Check if two regions intersect.

        Parameters:
            lower_bound (list or tuple): The lower bounds of the first region in each dimension.
            upper_bound (list or tuple): The upper bounds of the first region in each dimension.
            lower_left (list or tuple): The lower bounds of the second region in each dimension.
            upper_right (list or tuple): The upper bounds of the second region in each dimension.

        Returns:
            bool: True if the regions intersect, False otherwise.
        """
        for i in range(self.k):
            if upper_bound[i] - lower_left[i] < -self.eps or lower_bound[i] - upper_right[i] > self.eps:
                return False
        return True
    
    
    def __search_kdtree(self, v : Node, lower_bound : list, upper_bound : list, lower_left, upper_right, depth):
        """Recursively searches the KD-tree for points within a specified range.

        Parameters:
            v (Node): The current node in the KD-tree.
            lower_bound (list): The lower bounds of the current region.
            upper_bound (list): The upper bounds of the current region.
            lower_left (list or tuple): The lower bounds of the search range.
            upper_right (list or tuple): The upper bounds of the search range.
            depth (int): The current depth in the KD-tree.

        Returns:
            list: A list of points within the specified range.
        """
        if v.left is None and v.right is None:
            return [v.point] if all(lower_left[i] - self.eps <= v.point[i] <= upper_right[i] + self.eps for i in range(self.k)) else []

        axis = depth % self.k
        points = []
        
        # left region
        if v.left is not None:
            old = upper_bound[axis]
            upper_bound[axis] = v.line
            if self.__contains(lower_bound, upper_bound, lower_left, upper_right):
                points += v.left.report_subtree()
            elif self.__intersects(lower_bound, upper_bound, lower_left, upper_right):
                points += self.__search_kdtree(v.left, lower_bound, upper_bound, lower_left, upper_right, depth + 1)
            # backtracking
            upper_bound[axis] = old

        # right region
        if v.right is not None:
            old = lower_bound[axis]
            lower_bound[axis] = v.line
            if self.__contains(lower_bound, upper_bound, lower_left, upper_right):
                points += v.right.report_subtree()
            elif self.__intersects(lower_bound, upper_bound, lower_left, upper_right):
                points += self.__search_kdtree(v.right, lower_bound, upper_bound, lower_left, upper_right, depth + 1)
            # backtracking
            lower_bound[axis] = old

        return points
    

    def query(self, lower_left, upper_right):
        """Query the KD-tree to find all points within the specified rectangular region.

        Parameters:
            lower_left (list or tuple): The lower-left corner of the query region. 
                                        It should be a k-dimensional point.
            upper_right (list or tuple): The upper-right corner of the query region. 
                                        It should be a k-dimensional point.

        Returns:
            list: A list of points that lie within the specified region.

        Raises:
            TypeError: If the dimensions of the provided points do not match the 
                    dimension of the KD-tree.
        """
        if len(lower_left) != len(upper_right) != self.k:
            raise TypeError('Points does not match declared dimension!')
        
        # region represented as two k-dimensional boundary points
        lower_bound, upper_bound = [-KDtree.inf] * self.k, [KDtree.inf] * self.k

        return self.__search_kdtree(self.root, lower_bound, upper_bound, lower_left, upper_right, 0)
    


if __name__ == '__main__':
    points_set = [(0, 0), (20, 10), (20, 70), (60, 10), (60, 40), (70, 80), (75, 90), (80, 85), (80, 80), (80, 83)]
    kdtree = KDtree(points_set, eps=1e-12)
    lower_left = (20, 10)
    upper_right = (90, 80)

    print(kdtree.query(lower_left, upper_right))