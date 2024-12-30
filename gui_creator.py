import matplotlib.pyplot as plt
from matplotlib.widgets import Button
import tkinter as tk
from tkinter import simpledialog

def create_gui():
    """Creates a GUI for collecting points and defining a rectangular region on a 2D plane.

    Returns:
        tuple: A tuple containing:
            - points (list of tuples): List of (x, y) coordinates of the points.
            - lower_left (tuple): (x, y) coordinates of the lower-left corner of the rectangle.
            - upper_right (tuple): (x, y) coordinates of the upper-right corner of the rectangle.
    """
    root = tk.Tk()
    root.withdraw()

    input_str = simpledialog.askstring(
        "Zakres osi",
        "Podaj wartości min_x, max_x, min_y, max_y (rozdzielone przecinkami):"
    )
    if input_str:
        vals = input_str.split(',')
        if len(vals) == 4:
            try:
                min_x = float(vals[0])
                max_x = float(vals[1])
                min_y = float(vals[2])
                max_y = float(vals[3])
            except ValueError:
                min_x, max_x, min_y, max_y = 0, 10, 0, 10
        else:
            min_x, max_x, min_y, max_y = 0, 10, 0, 10
    else:
        min_x, max_x, min_y, max_y = 0, 10, 0, 10

    points = []
    rect_points = []
    collecting_rect = False

    def onclick(event):
        if event.inaxes == ax:
            x, y = event.xdata, event.ydata
            if collecting_rect and len(rect_points) < 2:
                rect_points.append((x, y))
                ax.scatter(x, y, c='g')
                fig.canvas.draw()
                if len(rect_points) == 2:
                    x1, y1 = rect_points[0]
                    x2, y2 = rect_points[1]
                    lower_left = (min(x1, x2), min(y1, y2))
                    upper_right = (max(x1, x2), max(y1, y2))
                    rect = plt.Rectangle(lower_left, upper_right[0] - lower_left[0], upper_right[1] - lower_left[1], 
                                        linewidth=1, edgecolor='b', facecolor='none')
                    ax.add_patch(rect)
                    fig.canvas.draw()
            elif not collecting_rect:
                points.append((x, y))
                ax.scatter(x, y, c='r')
                fig.canvas.draw()

    def on_next(_):
        nonlocal collecting_rect
        if len(points) < 1:
            ax.set_title("Musisz najpierw dodać co najmniej jeden punkt, aby użyć 'next'.", pad=20)
            fig.canvas.draw()
            return
        collecting_rect = True
        btn_next.disconnect_events()
        btn_next.color = 'lightgray'
        btn_next.hovercolor = 'lightgray'
        ax.set_title("Zdefiniuj dwa punkty (lower_left, upper_right), a następnie naciśnij \"save\"", pad=20)
        fig.canvas.draw()


    done = False

    def on_save(_):
        nonlocal done
        if len(points) < 1:
            ax.set_title("Musisz najpierw dodać co najmniej jeden punkt, aby użyć 'next'.", pad=20)
            fig.canvas.draw()
            return
        if len(rect_points) < 2:
            ax.set_title("Musisz zdefiniować dwa punkty (lower_left, upper_right), aby zapisać.", pad=20)
            fig.canvas.draw()
            return
        plt.close()
        root.after(100, root.quit)
            
    fig, ax = plt.subplots()

    fig.canvas.manager.set_window_title("Kreator punktów")
    ax.set_title("Zadaj dowolne punkty na płaszczyźnie, a następnie naciśnij \"next\"", pad=20)

    ax.set_autoscale_on(False)
    ax.set_xlim([min_x, max_x])
    ax.set_ylim([min_y, max_y])
    plt.subplots_adjust(bottom=0.2)

    plt.subplots_adjust(bottom=0.2)
    fig.canvas.mpl_connect('button_press_event', onclick)

    ax_next = plt.axes([0.7, 0.05, 0.1, 0.075])
    ax_save = plt.axes([0.81, 0.05, 0.1, 0.075])
    btn_next = Button(ax_next, 'next')
    btn_save = Button(ax_save, 'save')
    btn_next.on_clicked(on_next)
    btn_save.on_clicked(on_save)

    plt.show(block = False)
    root.mainloop()

    if len(rect_points) == 2:
        lower_left, upper_right = rect_points
    else:
        return None

    return (points, lower_left, upper_right)


if __name__ == '__main__':
    P, lower_left, upper_right = create_gui()
    from kdtree.kdtree_visualizer import KDtreeVisualizer
    kd = KDtreeVisualizer(P, 1e-12)
    kd.query(lower_left, upper_right)
    kd.vis_query.save_gif(interval=600)