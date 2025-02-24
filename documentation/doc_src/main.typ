#let today = datetime.today().display("[day].[month].[year]")


#set page(
  paper: "a4",
  margin: (x: 1.8cm, y: 2cm),
)
#set text(lang: "pl", font: "New Computer Modern", size: 11pt)

#align(center)[
  #image("csm_agh_znak_nazwa_asym_2w_pl_d1b882bad0 (1).png", width: 130%)

  #text(size: 18pt, [Algorytmy geometryczne - projekt])

  #text(size: 21pt, [*Wyszukiwanie geometryczne\ przeszukiwanie obszarów ortogonalnych
  QuadTree oraz KD-drzewa*])
  
  #v(2em)
    Dokumentacja

    #today
  #v(2em)
  Aleksander Jóźwik
  
  Szymon Hołysz
]

#pagebreak()

#set page(numbering: "1")

#set par(justify: true)
#set page(
  header: [
    #set text(10pt)
    #grid(
      columns: (1fr, 1fr),
      align: (left, right),
      [#image("header.png")],
      align(horizon)[QuadTree oraz KD-drzewa],
      line(length: 200%, stroke: 0.3pt)
    )
  ],
)

#show raw.where(block: true): block.with(
  fill: luma(240),
  inset: 10pt,
  radius: 4pt,
)

#v(1em)
#set heading(numbering: "1.")

#show outline.entry.where(
  level: 1
): it => {
  v(12pt, weak: true)
  strong(it)
}

#outline(indent: auto)
#pagebreak()

= Wprowadzenie
#v(1em)
Niniejsza dokumentacja opisuje implementacje dwóch struktur danych: _KD-drzewa_ i _QuadTree_ w języku Python. Struktury te są fundamentalne w realizacji wydajnych zapytań przestrzennych, znajdujących zastosowanie w systemach geolokalizacyjnych, bazach danych przestrzennych i aplikacjach GIS.

_KD-drzewa_ umożliwiają efektywne wykonywanie zapytań zakresowych w przestrzeni wielowymiarowej, co jest kluczowe np. w systemach nawigacyjnych przy wyszukiwaniu punktów zainteresowania w określonym obszarze czy w bazach danych geoprzestrzennych przy analizie rozkładu obiektów. _QuadTree_ z kolei specjalizuje się w operacjach na danych dwuwymiarowych, co znajduje zastosowanie w mapach cyfrowych przy dynamicznym ładowaniu szczegółów terenu czy w systemach monitoringu przy śledzeniu obiektów w określonych sektorach przestrzeni.

= Część techniczna
== Wymagania techniczne

Kod programu był uruchamiany w interpreterze języka _Python_ w wersji 3.13.1. Wymagane zależności zostały zapisane w pliku _requirements.txt_. Są to między innymi:

```py
numpy >= 1.25.2
pandas >= 2.0.3
matplotlib >= 3.7.2
notebook >= 6.5.4
```

W celu instalacji należy wywołać następujące polecenie:

```py
pip install -r requirements.txt
```

W projekcie umieszczono oraz wykorzystano narzędzie wizualizacji stworzone przez koło naukowe BIT. Kod źródłowy wraz z dokumentacją dostępny jest pod poniższym adresem:\
#text(fill: blue)[#link("https://github.com/aghbit/Algorytmy-Geometryczne")].

Do poprawnego funkcjonowania nie są wymagane dodatkowe zależności.

== Schemat pakietów

```py
KDTree_QuadTree_project/
│
├── kdtree/
│   ├── kdtree.py
│   ├── kdtree_test.py
│   └── kdtree_visualizer.py
│
├── quadtree/
│   └── quad.py
│
├── visualizer/
│
├── automatic_tests.py
├── generators.py
├── gui_creator.py
├── main.ipynb
└── requirements.txt
```

#pagebreak()

== Pakiet kdtree
=== Moduł kdtree
==== Klasa _Node_
Reprezentuje węzeł w strukturze KD-drzewa. Zawiera odniesienia do lewego i prawego dziecka.

===== Atrybuty
- self.line - wartość jednej ze współrzędnych, przez którą poprowadzono linię podziału,
- self.left - odniesienie do lewego dziecka węzła,
- self.right - odniesienie do prawego dziecka węzła,
- self.point - współrzędne punktu zawartego w węźle będącym liściem (krotka).

===== Metody
#v(1em)
```py
def __init__(
    self: Self@Node,
    line: Any | None = None,
    left: Any | None = None,
    right: Any | None = None,
    point: Any | None = None
) -> None
```
Konstruktor węzła w KD-drzewie.

*Parametry:*

- line - wartość jednej ze współrzędnych, przez którą poprowadzono linię podziału,
- left - odniesienie do lewego dziecka węzła,
- right - odniesienie do prawego dziecka węzła,
- point - współrzędne punktu zawartego w węźle będącym liściem (krotka).

#v(1em)
```py
def report_subtree(self: Self@Node) -> (Any | list)
```
Zwraca wszystkie punkty poddrzewa zakorzenionego w danym węźle.

*Zwraca: * listę punktów reprezentowanych jako krotki.

==== Klasa _KDtree_
Klasa KDtree jest implementacją drzewa k-wymiarowego, wykonaną na podstawie @wyklad oraz @ksiazka.\ Pozwala ona na wydajne zapytania o punkty z obszaru k-wymiarowej przestrzeni. Złożoność pamięciowa $O(n)$, gdzie $n$ to liczba punktów.

===== Atrybuty
- self.k - liczba wymiarów,
- self.eps - tolerancja dla zera,
- self.root - węzeł będący korzeniem KD-drzewa.

#pagebreak()
===== Metody
#v(1em)
```py
def __build_kdtree(
    self: Self@KDtree,
    P: Any,
    depth: Any
) -> (Node | None)
```
Buduje rekurencyjnie KD-drzewo.

*Parametry:*

- P - k-wymiarowa lista list punktów posortowanych ze względu na k-tą współrzędną,
- depth - aktualna głębokość w drzewie.

*Zwraca: * obiekt klasy _Node_ będący korzeniem drzewa (poddrzewa).

#v(1em)
```py
def __init__(
    self: Self@KDtree,
    P: Any,
    k: int = 2,
    eps: float = 0
) -> None
```
Konstruktor inicjalizujący instancję KD-drzewa. Złożoność: $O(k dot n log n)$, gdzie $k$ jest liczbą wymiarów, a $n$ to liczba punktów. W większości przypadków $k << n$, a więc za złożoność budowania drzewa można przyjąć $O(n log n)$.

*Parametry:*
- P - lista punktów,
- k - liczba wymiarów,
- eps - tolerancja dla zera.

*Wyjątki: *
- ValueError - jeżeli przekazana lista punktów P jest pusta,
- TypeError - jeżeli punkty nie spełniają zadeklarowanego wymiaru k.

#v(1em)
```py
def __contains(
    self: Self@KDtree,
    lower_bound: Any,
    upper_bound: Any,
    lower_left: Any,
    upper_right: Any
) -> bool
```
Sprawdza czy dany region całkowicie zawiera się w regionie, z którego wyszukujemy punkty.

#pagebreak()
*Parametry:*
- lower_bound - punkt w postaci krotki lub listy, który reprezentuje dolny zakres aktualnie rozważanego zakresu,
- upper_bound - punkt w postaci krotki lub listy, który reprezentuje górny zakres aktualnie rozważanego zakresu,
- lower_left - punkt w postaci krotki lub listy, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki lub listy, który reprezentuje górny zakres regionu zapytania przestrzennego.

*Zwraca: * bool: True jeżeli region się całkowicie zawiera, False w przeciwnym przypadku.

#v(1em)
```py
def __intersects(
    self: Self@KDtree,
    lower_bound: Any,
    upper_bound: Any,
    lower_left: Any,
    upper_right: Any
) -> bool
```
Sprawdza czy dany region przecina się z regionem, o który stworzono zapytanie.

*Parametry:*
- lower_bound - punkt w postaci krotki lub listy, który reprezentuje dolny zakres aktualnie rozważanego zakresu,
- upper_bound - punkt w postaci krotki lub listy, który reprezentuje górny zakres aktualnie rozważanego zakresu,
- lower_left - punkt w postaci krotki lub listy, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki lub listy, który reprezentuje górny zakres regionu zapytania przestrzennego.

*Zwraca: * bool: True jeżeli regiony się przecinają, False w przeciwnym przypadku.

#v(1em)
```py
def __search_kdtree(
    self: Self@KDtree,
    v: Node,
    lower_bound: list,
    upper_bound: list,
    lower_left: Any,
    upper_right: Any,
    depth: Any
) -> (list[Any | None] | Any | list)
```
Rekurencyjnie przeszukuje KD-drzewo w celu znalezienia punktów z zadanego regionu.

*Parametry:*
- v - obecny węzeł w KD-drzewie,
- lower_bound - punkt w postaci listy, który reprezentuje dolny zakres aktualnie rozważanego zakresu,
- upper_bound - punkt w postaci listy, który reprezentuje górny zakres aktualnie rozważanego zakresu,
- lower_left - punkt w postaci krotki lub listy, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki lub listy, który reprezentuje górny zakres regionu zapytania przestrzennego,
- depth - aktualna głębokość w KD-drzewie.

*Zwraca: * listę punktów z danego obszaru.

#v(1em)
```py
def query(
    self: Self@KDtree,
    lower_left: Any,
    upper_right: Any
) -> (list[Any | None] | Any | list)
```
Tworzy zapytanie do KD-drzewa, aby znaleźć wszystkie punkty z zadanego obszaru.\ Złożoność (przy zbalansowanym drzewie) dla $k = 2$ wynosi: $O(sqrt(n) + d)$, gdzie $d$ jest liczbą znalezionych punktów. Dla dowolnej liczby wymiarów jest to: $O(n^(1 - 1/k) + d)$.

*Parametry:*
- lower_left - punkt w postaci krotki lub listy, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki lub listy, który reprezentuje górny zakres regionu zapytania przestrzennego.

*Zwraca: * listę wszystkich punktów, które znajdują się w zadanym obszarze.

*Wyjątki:*
- TypeError - jeżeli wymiary wprowadzonych punktów nie zgadzają się z zadeklarowanym wymiarem KD-drzewa.

=== Moduł kdtree_visualizer
Moduł wykorzystuje narzędzie wizualizacji stworzone przez koło naukowe BIT oraz bibliotekę _matplotlib_.
==== Klasa _KDtreeVisualizer_
Klasa _KDtreeVisualizer_ stanowi modyfikację klasy _KDtree_ z pakietu kdtree, która ma dodaną możliwość graficznej wizualizacji krok po kroku budowania drzewa oraz wykonywania zapytań o punkty z zadanego obszaru. Poniżej zostaną opisane różnice pomiędzy tymi modułami.

===== Atrybuty
Dodano następujące atrybuty:

- self.points - lista punktów, które znajdują się w KD-drzewie (potrzebna do poprawnej wizualizacji dla wielokrotnych zapytań),

- self.lines - lista odcinków (w postaci krotek dwóch punktów: początku i końca) stanowiących linie podziału (wykorzystywana przy wizualizacji dla zapytań),
- self.vis_build - obiekt klasy Visualizer, który umożliwia wizualizację budowania drzewa,
- self.vis_query - obiekt klasy Visualizer, który umożliwia wizualizację zapytania,
- self.start_lower_bound - punkt, który reprezentuje dolny zakres obszaru, w którym znajdują się wszystkie punkty (wykorzystywany przy wizualizacji),
- self.start_upper_bound - punkt, który reprezentuje górny zakres obszaru, w którym znajdują się wszystkie punkty (wykorzystywany przy wizualizacji).
#pagebreak()

===== Metody
#v(1em)
```py
def __init__(
    self: Self@KDtreeVisualizer,
    P: Any,
    eps: int = 0
) -> None
```
Konstruktor KD-drzewa pozbawiony możliwości określenia liczby wymiarów - wizualizacja możliwa tylko dla dwóch wymiarów.

*Wyjątki:*
- TypeError - jeżeli punkty nie są z dwuwymiarowej przestrzeni.

#v(1em)
```py
def show_build_visualization(
    self: Self@KDtreeVisualizer,
    interval: int = 400
) -> Image
```
Wyświetla wizualizację budowania KD-drzewa.

*Parametry:*
- interval - interwał w milisekundach pomiędzy klatkami animacji (domyślnie 400 ms).

*Zwraca: * obraz w formacie _gif_.

#v(1em)
```py
def show_query_visualization(
    self: Self@KDtreeVisualizer,
    interval: int = 600
) -> Image
```
Wyświetla wizualizację procesu zapytania.

*Parametry:*
- interval - interwał w milisekundach pomiędzy klatkami animacji (domyślnie 600 ms).

*Zwraca: * obraz w formacie _gif_.

==== Funkcja _visualize_queried_points_
#v(1em)
```py
def visualize_queried_points(
    P: Any,
    lower_left: Any,
    upper_right: Any,
    result: Any
) -> None
```
Funkcja służy do wizualizacji punktów, obszaru zapytania oraz znalezionych punktów.

#pagebreak()
*Parametry:*
- P - lista punktów,
- lower_left - punkt reprezentujący lewy dolny róg prostokątnego obszaru zapytania,
- upper_right - punkt reprezentujący prawy górny róg prostokątnego obszaru zapytania,
- result - lista punktów zwrócona w zapytaniu.

* Wyjątki: *
- TypeError - jeżeli punkty nie są z dwuwymiarowej przestrzeni.

=== Moduł kdtree_test
Moduł ten zawiera 10 wielowymiarowych testów jednostkowych służących do przetestowania poprawności implementacji KD-drzewa.

==== Funkcja _runtests_
#v(1em)
```py
def runtests() -> None
```
Uruchamia testy. Wypisuje odpowiednio informacje na ekranie:
- w przypadku zaliczonego i-tego testu: "Test i: zaliczony!",
- w przypadku niezaliczonego i-tego testu: "Test i: niezaliczony!!!".

#v(1em)
== Pakiet quadtree
=== Klasa _Quarter_
Typ wyliczeniowy (enum) reprezentujący cztery typy wezłów w podziale na ćwiartki:
 - NE (prawa górna)
 - NW (lewa górna)
 - SW (lewa dolna)
 - SE (prawa dolna)
=== Klasa _Rectangle_
Reprezentuje przedział ortogonalny. Zawiera współrzędne (x. y) minimalnego i maksymalnego punktu przedziału.

==== Atrybuty
 - self.min_x - współrzędna _x_ minimalnego punktu
 - self.min_y - współrzędna _y_ minimalnego punktu
 - self.max_x - współrzędna _x_ maksymalnego punktu
 - self.max_y - współrzędna _y_ maksymalnego punktu

==== Metody 
#v(1em)
```py
def med_y(self): return (self.max_y + self.min_y) / 2.0
def med_x(self): return (self.max_x + self.min_x) / 2.0
```
Zwracają średnią ze współrzędnych _x_ i _y_ punktu maksymalnego i minimalnego.
#pagebreak()
#v(1em)
```py
def rectangle_partition(self):
    med_y = self.med_y()
    med_x = self.med_x()
    s_ne = Rectangle(med_x, med_y, self.max_x, self.max_y)
    s_nw = Rectangle(self.min_x, med_y, med_x, self.max_y)
    s_sw = Rectangle(self.min_x, self.min_y, med_x, med_y)
    s_se = Rectangle(med_x, self.min_y, self.max_x, med_y)

    return s_ne, s_nw, s_sw, s_se

```
Zwraca cztery obiekty klasy `Rectangle()` odpowiadające podziałowi prostokąta na ćwiartki.
#v(1em)
```py
def intersects(self, other):
    return (self.min_x < other.max_x and self.max_x > other.min_x
            and self.min_y < other.max_y and self.max_y > other.min_y)
```
Przyjmuje wskazanie na inny obiekt `Rectangle()` i sprawdza, czy się przecinają. Zwraca wartość logiczną.
#v(1em)
```py
  def contains(self, point):
      x, y = point
          if self.min_x <= x <= self.max_x and self.min_y <= y <= self.max_y:
              return True
          return False
```
Przyjmuje krotkę dwóch współrzędnych punktu i sprawdza, czy należy do przedziału. Zwraca wartość logiczną.
#v(1em)
```py
def draw(self, visualizer, color):
    return visualizer.add_line_segment((
                      ((self.min_x, self.min_y), (self.max_x, self.min_y)),
                      ((self.min_x, self.min_y), (self.min_x, self.max_y)),
                      ((self.min_x, self.max_y), (self.max_x, self.max_y)),
                      ((self.max_x, self.min_y), (self.max_x, self.max_y))), color = color)
```
Przyjmuje wskazanie na obiekt `Visualizer()` i parametr `color`. Dodaje do wizualizatora prostokąt odpowiadający przedziałowi i zwraca wskazanie na ten prostokąt.
=== Klasa _Node_
Reprezentuje węzeł w strukturze drzewa ćwiartek. Zawiera odniesienia do rodzica i dzieci, drzewa, przedziału, któremu odpowiada i zbioru punktów, które przechowuje.
==== Atrybuty
 - self.tree - wskazanie na obiekt klasy `Quad()`
 - self.quarter - wartość `Quarter(Enum)`
 - self.parent - wskazanie na rodzica, obiekt klasy `Node()`
 - self.square - wskazanie na przedział, któremu odpowiada; obiekt klasy `Rectangle()`
 - self.ne, self.nw, self.se, self.sw - wskazania na dzieci obiekty klasy `Node()`
 - self.points = wskazanie na zbiór `set()` punktów, które przechowuje; jeżeli węzeł nie jest liściem, to `self.points = None`

 #pagebreak()
==== Metody
#v(1em)
```py
def is_leaf(self): return self.points is not None and self != self.tree.root
```
Sprawdza, czy węzeł jest liściem. Zwraca wartość logiczną.
#v(1em)
```py
def construct_subtree(self, points, forced = False):              
    if len(points) <= BUCKET_SIZE and not forced:                
        self.points = points                                     
        self.tree.leaves.append(self)                            
    else:                                                        
        x = self.square.med_x()                                  
        y = self.square.med_y()                                  
        p_ne, p_nw, p_sw, p_se = set_partition(points, x, y)     
        s_ne, s_nw, s_sw, s_se = self.square.rectangle_partition(
                                                                 
        self.ne = Node(self.tree, Quarter.NE, s_ne, self)        
        self.nw = Node(self.tree, Quarter.NW, s_nw, self)        
        self.sw = Node(self.tree, Quarter.SW, s_sw, self)        
        self.se = Node(self.tree, Quarter.SE, s_se, self)

        self.ne.construct_subtree(p_ne)                          
        self.nw.construct_subtree(p_nw)                          
        self.sw.construct_subtree(p_sw)                          
        self.se.construct_subtree(p_se)                          
```
Rekurencyjnie buduje drzewo ćwiartek. Przyjmuje zbiór punktów i w zależności od ich liczby tworzy liść (umieszcza punkty w self.points) albo dzieli punkty na ćwiartki i umieszcza je w poddrzewach.
#v(1em)
```py
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
```
Rekurencyjnie wstawia punkt do drzewa. Przyjmuje krotkę współrzędnych punktów i w zależności od tego, czy przedział bieżącego węzła może zawierać dany punkt, albo wstawia go do jednego z poddrzew, albo zwraca `False`.
#pagebreak()
```py
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
```
Rekurencyjnie wyszukuje punktów należących do przedziału ortogonalnego. Przyjmuje obiekt klasy `Rectangle()`, sprawdza czy przedział węzła przecina zadany przedział i jeżeli bieżący węzeł jest liściem, sprawdza, czy punkty w nim przechowywane należą do zadanego przedziału. W przeciwnym wypadku przeszukuje dzieci bieżącego węzła.
#v(1em)
```py
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
```


Wersja graficzna powyższej metody, która dodatkowo przyjmuje wskazanie na wizualizator `Visualizer()` i dodaje do niego kolejne etapy wyszukiwania używając koloru `color`.

#pagebreak()

#v(1em)
```py
def draw(self, visualizer, color):                          
    self.square.draw(visualizer, color)                    
    if self.ne is not None: self.ne.draw(visualizer, color)
    if self.nw is not None: self.nw.draw(visualizer, color)
    if self.sw is not None: self.sw.draw(visualizer, color)
    if self.se is not None: self.se.draw(visualizer, color)
```
Przyjmuje wskazanie na obiekt `Visualizer()` i parametr `color`. Dodaje do wizualizatora prostokąt odpowiadający bieżącemu węzłowi i rekurencyjnie wywołuje metodę dla swoich dzieci.

=== Klasa _Quad_
Reprezentuje drzewo ćwiartek. Zawiera odniesienie do korzenia drzewa, zbiór punktów należących do drzewa i listę liści. 
==== Atrybuty
 - self.points - zbiór punktów, na podstawie których skonstruowane zostało drzewo
 - self.leaves - lista liści
 - self.root wskazanie na obiekt `Node()` będący korzeniem
==== Metody
#v(1em)
```py
def __init__(self, points):                          
    self.points = points                            
    self.leaves = []                                
    self.root = Node(self, None, min_square(points))
    self.root.construct_subtree(points)             
```
Konstruktor inicjalizujący instancję drzewa ćwiartek. Złożoność budowy drzewa zależy od głębokości drzewa $d$ i liczby punktów $n$. Średni czas budowy drzewa wynosi $O(n log n)$, natomiast w pesymistycznym przypadku (głębokość drzewa w przybliżeniu równa liczbie punktów) może wynieść $O(n^2)$.
#v(1em)
```py
def insert(self, point): return self.root.insert_subtree(point)
```
Przyjmuje krotkę współrzędnych punktu i wywołuje rekurencyjną metodę `insert_subtree()` dla korzenia drzewa.
#v(1em)
```py
def query_range(self, min_point, max_point):                                        
    range_rect = Rectangle(min_point[0], min_point[1], max_point[0], max_point[1]) 
    return self.root.query_range_subtree(range_rect)                               
```
Przyjmuje minimalny i maksymalny punkt przedziału ortogonalnego i wywołuje rekurencyjną metodę przeszukiwania `query_range_subtree` dla korzenia drzewa. Pesymistyczna złożoność  takiego wyszukiwania to $O(n)$.
#pagebreak()
```py
def graphic_query_range(self, min_point, max_point, visualizer, color):             
    range_rect = Rectangle(min_point[0], min_point[1], max_point[0], max_point[1]) 
    range_rect.draw(visualizer, 'brown')                                           
    return self.root.graphic_query_range_subtree(range_rect, visualizer, color)    
```
Wersja graficzna powyższej metody. Wywołuje graficzną wersję metody rekurencyjnej.
#v(1em)
```py
def draw(self, visualizer, color):     
    self.root.draw(visualizer, color) 
```
Przyjmuje wskazanie na wizualizator i wywołuje rekurencyjną metodę rysowania poddrzewa  dla korzenia drzewa.

== Moduł _generators_
Zawiera funkcje generujące zbiory punktów o różnych charakterystykach. Wykorzystano biblioteki _numpy_ oraz _random_.

=== Funkcja _generate_uniform_points_
#v(1em)
```py
def generate_uniform_points(
    left: Any,
    right: Any,
    n: int = 10 ** 5
) -> list[tuple[Any, ...]]
```
Funkcja generuje równomiernie n punktów na kwadratowym obszarze od left do right (jednakowo na osi y) o współrzędnych rzeczywistych.

*Parametry:*
- left - lewy kraniec przedziału,
- right - prawy kraniec przedziału,
- n - liczba generowanych punktów.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych np. $[(x_1, y_1), (x_2, y_2), ... (x_n, y_n)]$.

=== Funkcja _generate_normal_points_
#v(1em)
```py
def generate_normal_points(
    mean: Any,
    std: Any,
    n: int = 10 ** 5
) -> list[tuple[Any, ...]]
```
Funkcja generuje n punktów o rozkładzie normalnym na płaszczyźnie o współrzędnych rzeczywistych.

*Parametry:*
- mean - średnia wartość rozkładu,
- std - odchylenie standardowe rozkładu,
- n - liczba generowanych punktów.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych np. $[(x_1, y_1), (x_2, y_2), ... (x_n, y_n)]$.

#pagebreak()

=== Funkcja _generate_collinear_points_
#v(1em)
```py
def generate_collinear_points(
    a: Any,
    b: Any,
    n: int = 100,
    x_range: int = 1000
) -> list[tuple]
```
Funkcja generuje równomiernie n współliniowych punktów leżących na prostej ab pomiędzy punktami a i b.

*Parametry: *
- a - krotka współrzędnych oznaczająca początek wektora tworzącego prostą,
- b - krotka współrzędnych oznaczająca koniec wektora tworzącego prostą,
- n - liczba generowanych punktów.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych.

=== Funkcja _generate_rectangle_points_
#v(1em)
```py
def generate_rectangle_points(
    a: Any = (-10, -10),
    b: Any = (10, -10),
    c: Any = (10, 10),
    d: Any = (-10, 10),
    n: int = 100
) -> list[tuple]
```
Funkcja generuje n punktów na obwodzie prostokąta o wierzchołkach w punktach a, b, c i d.

*Parametry: *
- a - lewy-dolny wierzchołek prostokąta,
- b - prawy-dolny wierzchołek prostokąta,
- c - prawy-górny wierzchołek prostokąta,
- d - lewy-górny wierzchołek prostokąta,
- n - liczba generowanych punktów.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych.

=== Funkcja _generate_square_points_
#v(1em)
```py
def generate_square_points(
    a: Any = (0, 0),
    b: Any = (10, 0),
    c: Any = (10, 10),
    d: Any = (0, 10),
    axis_n: int = 25,
    diag_n: int = 20
) -> list[tuple]
```
Funkcja generuje axis_n punktów na dwóch bokach kwadratu leżących na osiach x i y oraz diag_n punktów na przekątnych kwadratu, którego wyznaczają punkty a, b, c i d.

#pagebreak()
*Parametry:*
- a - lewy-dolny wierzchołek kwadratu,
- b - prawy-dolny wierzchołek kwadratu,
- c - prawy-górny wierzchołek kwadratu,
- d - lewy-górny wierzchołek kwadratu,
- axis_n - liczba generowanych punktów na każdym z dwóch boków kwadratu równoległych\ do osi x i y,
- diag_n - liczba generowanych punktów na każdej przekątnej kwadratu.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych.


=== Funkcja _generate_grid_points_
#v(1em)
```py
def generate_grid_points(n: int = 100) -> list[tuple[int, int]]
```
Funkcja generuje punkty na siatce $n " " crossmark " " n$.

*Parametry: *
- n - liczba punktów wzdłuż jednej osi.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych.

=== Funkcja _generate_clustered_points_
#v(1em)
```py
def generate_clustered_points(
    cluster_centers: Any,
    cluster_std: Any,
    points_per_cluster: Any
) -> list[tuple]
```
Funkcja generuje punkty w klastrach wokół podanych centrów.

*Parametry:*
- cluster_centers - lista krotek współrzędnych centrów klastrów,
- cluster_std - odchylenie standardowe dla każdego klastra,
- points_per_cluster - liczba punktów w każdym klastrze.

*Zwraca: * tablicę punktów w postaci krotek współrzędnych.

== Moduł _automatic_tests_
Służy do automatycznego testowania dwóch struktur danych: KD-drzewa i QuadTree. Testy mają na celu sprawdzenie, czy obie struktury danych zwracają zgodne wyniki dla różnych zestawów punktów\ i zapytań zakresowych.

=== Funkcja _runtests_all_
#v(1em)
```py
def runtests_all() -> None
```
Funkcja generuje zbiory testowe oraz porównuje wyniki zapytań dla obu struktur danych.

Jeśli wyniki są różne, wypisuje komunikat o błędzie i kończy działanie.

Jeśli wszystkie testy przejdą pomyślnie, wypisuje komunikat o zaliczeniu testów.

#pagebreak()

== Moduł _gui_creator_
Zapewnia GUI do zadawania punktów i definiowania prostokątnego obszaru na płaszczyźnie 2D. Wykorzystuje biblioteki _matplotlib_ oraz _tkinter_.

=== Funkcja create_gui
#v(1em)
```py
def create_gui() -> (tuple[list, Any, Any] | None)
```
Tworzy GUI do zbierania punktów i definiowania prostokątnego obszaru na płaszczyźnie 2D.


*Zwraca: * Krotkę zawierającą:
- points (lista krotek) - lista współrzędnych $(x, y)$ punktów,
- lower_left (krotka) - współrzędne $(x, y)$ dolnego lewego rogu prostokąta,
- upper_right (krotka) - współrzędne $(x, y)$ górnego prawego rogu prostokąta.

== Plik _main.ipynb_
Plik Jupyter Notebook stworzony, aby zapewnić wygodny interfejs do prezentacji oraz wizualizacji funkcjonowania KD-tree i QuadTree. Jest to także narzędzie do przetestowania poprawności implementacji powyższych struktur oraz porównania ich efektywności dla poszczególnych zbiorów danych.

= Część użytkownika
W tej części pokazane zostaną przykłady uruchamiania programu oraz korzystania z jego poszczególnych modułów.

== Pakiet _kdtree_
=== Moduł _kdtree_
Stanowi implementację KD-drzewa.
==== Inicjalizacja struktury danych
#v(1em)
```py
from kdtree.kdtree import KDtree

points_set = [(0, 0), (20, 10), (20, 70), (60, 10), (60, 40), (70, 80), (75, 90), (80, 85), (80, 80), (80, 83)]

kdtree = KDtree(points_set, k = 2, eps = 1e-12)
```
W powyższym przykładzie dokonano importu struktury _KDtree_ z odpowiedniego pakietu.\ Następnie zainicjalizowano drzewo z wykorzystaniem konstruktora. Zostały przekazane do niego:
- points_set - lista punktów,
- k - liczba wymiarów (domyślnie 2),
- eps - tolerancja dla zera (opcjonalne).

#pagebreak()
==== Zapytanie o punkty z zadanego obszaru
#v(1em)
```py
lower_left = (20, 10)
upper_right = (90, 80)

result = kdtree.query(lower_left, upper_right)

print(result)
```
Wyjście:
```
[(20, 10), (60, 10), (20, 70), (60, 40), (70, 80), (80, 80)]
```
Do metody _query_ zostały przekazane:
- lower_left - punkt w postaci krotki, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki, który reprezentuje górny zakres regionu zapytania przestrzennego.


Program wypisał listę wszystkich punktów, które zostały znalezione w zdefiniowanym obszarze.

=== Moduł _kdtree_visualizer_
Stanowi implementację KD-drzewa, wzbogaconą o możliwość wizualizacji poszczególnych kroków

==== Inicjalizacja struktury danych
#v(1em)
```py
from kdtree.kdtree_visualizer import KDtreeVisualizer

points_set = [(0, 0), (20, 10), (20, 70), (60, 10), (60, 40), (70, 80), (75, 90), (80, 85), (80, 80), (80, 83)]
kdtree = KDtreeVisualizer(points_set, eps = 1e-12)
```
W powyższym przykładzie dokonano importu struktury _KDtreeVisualizer_ z odpowiedniego pakietu.\ Następnie zainicjalizowano drzewo z wykorzystaniem konstruktora. Zostały przekazane do niego:
- points_set - lista punktów,
- eps - tolerancja dla zera (opcjonalne).
Brak możliwości zdefiniowania liczby wymiarów (wizualizacja możliwa tylko dla dwuwymiarowej przestrzeni).

==== Wizualizacja procesu budowania KD-drzewa
#v(1em)
```py
kdtree.show_build_visualization(interval = 400)
```
Funkcja zwraca plik _gif_ będący animacją procesu budowania KD-drzewa. Parametr _interval_ odpowiada za czas interwału pomiędzy kolejnymi klatkami animacji (domyślnie 400 ms).

Oznaczenia kolorystyczne na wizualizacji:
- kolorem #text(fill: blue)[niebieskim] oznaczono punkty z przestrzeni,
- kolorem #text(fill: rgb(127, 127, 127))[szarym] oznaczany jest aktualnie rozpatrywany obszar (do podziału),
- odcinkami #text(fill: orange)[pomarańczowymi] oznaczono pionowe linie podziału,
- odcinkami #text(fill: green)[zielonymi] oznaczono poziome linie podziału.

#pagebreak()

==== Zapytanie o punkty z zadanego obszaru
#v(1em)
```py
lower_left = (20, 10)
upper_right = (90, 80)

result = kdtree.query(lower_left, upper_right)

print(result)
```
Wyjście:
```
[(20, 10), (60, 10), (20, 70), (60, 40), (70, 80), (80, 80)]
```
Do metody _query_ zostały przekazane:
- lower_left - punkt w postaci krotki, który reprezentuje dolny zakres regionu zapytania przestrzennego,
- upper_right - punkt w postaci krotki, który reprezentuje górny zakres regionu zapytania przestrzennego.


==== Wizualizacja procesu zapytania
#v(1em)
```py
kdtree.show_query_visualization(interval = 600)
```
Funkcja zwraca plik _gif_ będący animacją procesu zapytania do KD-drzewa. Parametr _interval_ odpowiada za czas interwału pomiędzy kolejnymi klatkami animacji (domyślnie 600 ms).

Oznaczenia kolorystyczne:
- kolorem #text(fill: blue)[niebieskim] oznaczono punkty,
- kolorem #text(fill: rgb(0,0,139))[ciemnym niebieskim] (półprzezroczystym) zaznaczono obszar, z którego punkty chcemy znaleźć,
- na #text(fill: purple)[różowo] zaznaczono odcinki, które dzielą płaszczyznę
- na #text(fill: rgb(127, 127, 127))[szaro] zaznaczany jest obszar, który zostanie zawężony w celu dalszego wyszukiwania,
- kolorem #text(fill: green)[zielonym] oznaczane są punkty wyszukane w trakcie zapytania oraz obszary, w których te punkty się znajdowały (w przypadku gdy obszar w całości znajduje się w obszarze, z którego chcemy znaleźć punkty, to wszystkie punkty z niego są kolorowane na zielono),
- kolorem #text(fill: orange)[pomarańczowym] oznaczane są odcinki, które pokazaują w jaki sposób w trakcie wyszukiwania rozpatrywane są i dzielone poszczególne obszary (czy algorytm rozpatruje stronę "lewą" czy "prawą").

== Pakiet _quadtree_
Pakiet quadtree zawiera implementację drzewa ćwiartek.
=== Inicjalizacja struktury danych
#v(1em)
```py
from quadtree.quad import Quad
points_set = [(0, 0), (20, 10), (20, 70), (60, 10), (60, 40), (70, 80), (75, 90), (80, 85),
(80, 80), (80, 83)]
quad_tree = Quad(points_set)
```
Powyższy kod importuje pakiet `Quad` i  inicjalizuje strukturę danych przekazując do niej listę punktów `points_set`.

#pagebreak()
=== Wizualizacja budowy struktury danych
#v(1em)
```py
from visualizer.main import Visualizer
vis = Visualizer()
quad_tree.draw(vis, 'blue')
vis.show_gif()
```
Powyższy kod uruchamia animację budowy drzewa ćwiartek. Importowany jest pakiet `visualizer`, a następnie generowana jest animacja.W animacji użyto następujących oznaczeń:
 - kolorem #text(fill: green)[zielonym] oznaczono zadane punkty,
 - kolorem #text(fill: blue)[niebieskim] oznaczono prostokąty reprezentujące węzły drzewa.
=== Zapytanie o punkty z obszaru ortogonalnego
#v(1em)
```py
lower_left = (20, 10)
upper_right = (90, 80)
print(quad_tree.query_range(lower_left, upper_right))
```
Wyjście:
```py
{(60, 40), (80, 80), (60, 10), (20, 70), (70, 80), (20, 10)}

```
Do metody _query_range_ zostały przekazane dwa punkty w postaci krotek współrzędznych; lower_left - punkt minimalny i upper_right - punkt maksymalny.

Program wypisał zbiór wszystkich znalezionych punktów.

=== Wizualizacja zapytania
```py
vis.clear()
quad_tree.graphic_query_range(lower_left, upper_right)
vis.show_gif)
```
Powyższy kod uruchamia animację wyszukiwania obszaru ortogonalnego w drzewie. W animacji użyto następujących oznaczeń:
 - kolorem #text(fill: green)[zielonym] oznaczone są punkty przechowywane w drzewie,
 - kolorem #text(fill: red)[czerwonym] oznaczony jest zadany prostokąt,
 - kolorem #text(fill: blue)[niebieskim] oznaczone są prostokąty, które przecinają zadany prostokąt oraz wykryte punkty, które należą do zadanego prostokąta.

 #v(3em)
== Plik _main.ipynb_
Plik Jupyter Notebook został stworzony, aby zapewnić wygodny interfejs do prezentacji oraz wizualizacji funkcjonowania KD-drzewa i QuadTree. Jest to także narzędzie do przetestowania poprawności implementacji powyższych struktur oraz porównania ich efektywności dla poszczególnych zbiorów danych.

Wykonywane są w nim kolejno:

+ Importowanie bibliotek i modułów.
  - Importowanie niezbędnych bibliotek oraz modułów do obsługi KD-tree i QuadTree, testów, wizualizacji oraz generowania danych.

+ Testy poprawności implementacji:
  + Uruchomienie testów jednostkowych dla KD-tree.
  + Uruchomienie testów integralnościowych dla KD-tree i QuadTree.

+ Graficzne zadawanie punktów oraz obszaru wyszukiwania.
  - Interaktywne narzędzie do zadawania punktów na płaszczyźnie oraz obszaru wyszukiwania.

+ Wizualizacja punktów i obszaru wyszukiwania.
  - Wizualizacja zadanych punktów oraz obszaru wyszukiwania.

+ Wizualizacja budowania KD-tree i QuadTree.

+ Zapytania o punkty w zadanym obszarze.
  - Wykonanie zapytania o punkty w zadanym obszarze i porównanie wyników.

+ Wizualizacja wyszukiwania punktów:
 - Wizualizacja procesu wyszukiwania punktów w KD-tree.
 - Wizualizacja procesu wyszukiwania punktów w QuadTree.

+ Ostateczny wynik zapytania:
  - Wizualizacja ostatecznego wyniku zapytania.

+ Generowanie zbiorów punktów o różnych charakterystykach i ich wizualizacja.

+ Testy wydajnościowe.
  - Porównanie wydajności między implementacjami KD-tree oraz QuadTree.

#v(1em)

= Sprawozdanie
#v(1em)
== Dane techniczne
#v(1em)
- System operacyjny: Windows 10 22H2 (x86-64)
- Procesor: AMD Ryzen 5 1600AF (3.20 - 3.60 GHz)
- Pamięć RAM: 16GB (3400 MHz CL14)
- Środowisko: Jupyter Notebook
- Język: Python 3.13.1
Użyta precyzja przechowywania zmiennych i obliczeń w testach to _float64_.

#v(1em)
== Opis problemu
#v(1em)
Efektywne przeszukiwanie przestrzenne stanowi istotne zagadnienie w wielu dziedzinach informatyki, od systemów GIS po grafikę komputerową. W niniejszym sprawozdaniu analizujemy wydajność dwóch struktur danych służących do partycjonowania przestrzeni: KD-drzewa oraz drzewa czwórkowego (QuadTree). Ograniczamy się do przestrzeni dwuwymiarowej.

Struktury te umożliwiają szybkie wyszukiwanie punktów w zadanym obszarze poprzez rekurencyjny podział przestrzeni. KD-drzewo dzieli przestrzeń naprzemiennie wzdłuż kolejnych wymiarów, podczas gdy QuadTree dzieli obszar na cztery równe części. W przypadku zrównoważonego KD-drzewa, złożoność czasowa budowania wynosi $O(n log n)$, a wyszukiwanie punktów w zadanym obszarze zajmuje\ $O(sqrt(n) + d$), gdzie $d$ to liczba znalezionych punktów. Dla drzewa czwórkowego, złożoność budowania również wynosi $O(n log n)$, jednak w najgorszym przypadku może zdegenerować się do $O(n^2)$. Wyszukiwanie w QuadTree ma złożoność $O(log n + d)$ dla równomiernie rozłożonych danych.

Badanie porównawcze koncentruje się na analizie czasu konstrukcji struktury oraz wydajności zapytań przestrzennych dla różnych rozkładów danych wejściowych.

#v(1em)
== Realizacja
#v(1em)
W celu porównania obu struktur danych wygenerowano punkty z dwuwymiarowej przestrzeni o różnych charakterystykach. Dla każdego zbioru zostanie zaprezentowana wizualizacja (o niewielkiej liczności zbioru punktów), graficzna reprezentacja wyniku zapytania oraz porównanie czasowe. Animacje pokazujące krok po kroku funkcjonowanie algorytmów zostały zamieszczone w pliku _Jupyter_.

#v(1em)
== Wyniki
#v(1em)
Dla każdego ze zbiorów testowych, wyniki zapytania zwrócone przez obie struktury danych były tożsame, co stanowi dowód poprawności implementacji.

=== Zbiór punktów z rozkładu jednostajnego
#v(1em)
#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("jednostajny.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ z rozkładu jednostajnego
    ],
  )<zbior_jednostajny>
  ],
  align(top + right)[
    #figure(
    image("jednostajny_wynik.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru jednostajnego
    ],
  )<wynik_jednostajny>
    ],
)
#v(1em)
#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("jednostajny.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów z rozkładu jednostajnego]
)<czas_jednost>
#pagebreak()
#v(1em)

#figure(
  image("jednost_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ dla zbioru o rozkładzie jednostajnym]
)<jednost_budow_wykr>

#figure(
  image("jednost_zpay.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ dla zbioru o rozkładzie jednostajnym]
)<jednost_zap_wykr>

#v(1em)
Każdy z wygenerowanych zbiorów testowych wygląda podobnie do tego przedstawionego na #ref(<zbior_jednostajny>, supplement: "Rysunku"), różnicą jest liczność. Testy przeprowadzono dla obszaru zaznaczonego kolorem szarym na #ref(<wynik_jednostajny>, supplement: "Rysunku"). Jak można zauważyć w #ref(<czas_jednost>, supplement: "Tabeli"), czas budowy KD-drzewa jest w większości przypadków mniejszy, niż dla QuadTree (co potwierdza #ref(<jednost_budow_wykr>)). Dla niewielkiej liczności zbiorów, zapytania były wykonywane szybciej przez QuadTree, KD-drzewo okazało się szybsze dla większej liczności. Zależność czasu wykonania zapytania została przedstawiona na #ref(<jednost_zap_wykr>, supplement: "Rysunku").

#pagebreak()

=== Zbiór punktów z rozkładu normalnego
#v(1em)
#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("normalny.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ z rozkładu normalnego
    ],
  )<zbior_normalny>
  ],
  align(top + right)[
    #figure(
    image("normalny_wynik.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru normalnego
    ],
  )<wynik_normalny>
    ],
)
#v(1em)
#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("normalny.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów z rozkładu normalnego]
)<czas_normalny>

#v(1em)

#figure(
  image("normalny_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ dla zbioru o rozkładzie normalnym]
)<norm_budow_wykr>

#pagebreak()

#figure(
  image("normalny_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ dla zbioru o rozkładzie normalnym]
)<norm_zap_wykr>

#v(1em)
Dla zbioru widocznego na #ref(<zbior_normalny>, supplement: "Rysunku"), wyniki dla zapytania przedstawionego na #ref(<wynik_normalny>, supplement: "Rysunku") (dla różnych liczności) zostały umieszczone w #ref(<czas_normalny>, supplement: "Tabeli"). Dla zbioru o liczbie punktów wynoszącej 50, czas budowy QuadTree jest znacząco mniejszy od czasu dla KD-drzewa. Druga struktura natomiast realizuje zapytanie niemal 2 razy szybciej. Dla liczby punktów od 100 do 1000 czasy budowy są podobne, by dla zbiorów o większej liczności KD-drzewo okazało się w szybsze (zależność widoczna na #ref(<norm_budow_wykr>, supplement: "Rysunku")). Dla przypadków od 100 do 1000 punktów, QuadTree wykonuje zapytania szybciej. Dla zbioru 50 punktów oraz powyżej 100000, KD-drzewo jest kolejno dwukrotnie i trzykrotnie szybsze (co można zauważyć na #ref(<norm_zap_wykr>, supplement: "Rysunku")).
#v(1em)
=== Zbiór punktów na siatce
#v(1em)
#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("siatka.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ na siatce
    ],
  )<zbior_siatka>
  ],
  align(top + right)[
    #figure(
    image("siatka_wynik.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru punktów na siatce
    ],
  )<wynik_siatka>
    ],
)

#pagebreak()

#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("siatka.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów z siatki]
)<czas_siatka>

#v(1em)

#figure(
  image("siatka_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ dla zbioru punktów z siatki]
)<siat_budow_wykr>

#figure(
  image("siatka_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ dla zbioru punktów z siatki]
)<siat_zap_wykr>

#v(1em)
Na #ref(<zbior_siatka>, supplement: "Rysunku") zaprezentowano przykładowy zbiór 100 punktów równomiernie rozłożonych na siatce, a #ref(<wynik_siatka>) pokazuje wynik przykładowego zapytania. Szczegółowe porównanie czasów wykonania operacji dla różnych rozmiarów zbiorów przedstawiono w #ref(<czas_siatka>, supplement: "Tabeli"). Dane te zobrazowano również na dwóch wykresach porównawczych (#ref(<siat_budow_wykr>) i#ref(<siat_zap_wykr>, supplement: "")). Na podstawie tych wyników można zaobserwować, że proces budowy obu struktur charakteryzuje się bardzo podobną wydajnością - czasy budowy KD-drzewa i QuadTree są niemal identyczne. Dla największego testowanego zbioru, zawierającego milion punktów, czas budowy wynosi około 10.6 sekundy dla KD-drzewa i 10.4 sekundy dla QuadTree. Znaczące różnice ujawniają się jednak w czasie wykonywania zapytań przestrzennych. QuadTree wykazuje gorszą wydajność przy rosnącej liczbie punktów - dla zbioru miliona punktów czas zapytania wynosi 0.102 sekundy, podczas gdy KD-drzewo wykonuje tę samą operację w 0.042 sekundy. Warto zauważyć, że dla mniejszych zbiorów (do 1000 punktów) różnice w wydajności są minimalne - obie struktury osiągają czasy rzędu tysięcznych części sekundy. Jednak wraz ze wzrostem rozmiaru zbioru różnica w wydajności staje się coraz bardziej wyraźna, na korzyść KD-drzewa.
#v(1em)

=== Zbiór punktów zgrupowanych w klastry
#v(1em)

#v(1em)
#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("klastry.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ zgrupowanych w klastry
    ],
  )<zbior_klastry>
  ],
  align(top + right)[
    #figure(
    image("klastry_wynikl.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru punktów zgrupowanych w klastry
    ],
  )<wynik_klastry>
    ],
)

#v(1em)
#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("klastry.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów zgrupowanych w klastry]
)<czas_klastry>

#pagebreak()

#figure(
  image("klastry_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ dla zbioru punktów zgrupowanych w klastry]
)<klastry_budow_wykr>

#figure(
  image("klastry_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ dla zbioru punktów zgrupowanych w klastry]
)<klastry_zap_wykr>

#v(1em)

Na #ref(<zbior_klastry>, supplement: "Rysunku") zaprezentowano przykładowy zbiór 100 punktów pogrupowanych w 4 klastry. #ref(<wynik_klastry>) pokazuje wynik przykładowego zapytania. Szczegółowe porównanie czasów wykonania operacji dla różnych rozmiarów zbiorów przedstawiono w #ref(<czas_klastry>, supplement: "Tabeli"). Dane te zobrazowano również na dwóch wykresach porównawczych (#ref(<klastry_budow_wykr>) i#ref(<klastry_zap_wykr>, supplement: "")).  W tym przypadku czas budowy struktury dla obu algorytmów jest bardzo podobny. Znacząco różnią się czasy przeszukiwania drzewa, gdzie KD-drzewo jest znacznie wydajniejsze. Wynika to z rozłożenia punktów, które sprawia, że drzewo ćwiartek ma dużą głębokość i jest silnie niezrównoważone. Gdyby klastry były umieszczone w oddzielnych ćwiartkach, wtedy algorytm dla drzewa ćwiartek osiągnąłby lepsze wyniki.

#pagebreak()

=== Zbiór punktów wygenerowanych na prostej
#v(1em)

#v(1em)
#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("prosta.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ współliniowych
    ],
  )<zbior_prosta>
  ],
  align(top + right)[
    #figure(
    image("prosta_wynik.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru punktów współliniowych
    ],
  )<wynik_prosta>
    ],
)

#v(1em)
#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("prosta.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów współliniowych]
)<czas_prosta>

#v(1em)

#figure(
  image("prosta_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ dla zbioru punktów współliniowych]
)<prosta_budow_wykr>

#pagebreak()

#figure(
  image("prosta_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ dla zbioru punktów współliniowych]
)<prosta_zap_wykr>

#v(1em)
Na #ref(<zbior_prosta>, supplement: "Rysunku") zaprezentowano przykładowy zbiór 100 współliniowych punktów. #ref(<wynik_prosta>) pokazuje wynik przykładowego zapytania. Szczegółowe porównanie czasów wykonania operacji dla różnych rozmiarów zbiorów przedstawiono w #ref(<czas_prosta>, supplement: "Tabeli"). Dane te zobrazowano również na dwóch wykresach porównawczych (#ref(<prosta_budow_wykr>) i#ref(<prosta_zap_wykr>, supplement: "")). Dla punktów współliniowych budowa i wyszukiwanie punktów\ KD-drzewa są znacznie krótsze, ponieważ KD-drzewo jest w tym przypadku znacznie płytsze i bardziej zrównoważone.

#v(2em)
=== Zbiór punktów na obwodzie prostokąta
#v(1em)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("obwod.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ na obwodzie prostokąta
    ],
  )<zbior_obwod>
  ],
  align(top + right)[
    #figure(
    image("obwod_wynik.png", width: 83%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru punktów na obwodzie prostokąta
    ],
  )<wynik_obwod>
    ],
)
#pagebreak()

#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("obwod.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów na obwodzie prostokąta]
)<czas_obwod>

#v(1em)

#figure(
  image("obwod_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ na obwodzie prostokąta]
)<obwod_budow_wykr>

#figure(
  image("obwod_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ na obwodzie prostokąta]
)<obwod_zap_wykr>

#pagebreak()
Na #ref(<zbior_obwod>, supplement: "Rysunku") zaprezentowano przykładowy zbiór 100 punktów na obwodzie. #ref(<wynik_obwod>) pokazuje wynik przykładowego zapytania. Szczegółowe porównanie czasów wykonania operacji dla różnych rozmiarów zbiorów przedstawiono w #ref(<czas_obwod>, supplement: "Tabeli"). Dane te zobrazowano również na dwóch wykresach porównawczych (#ref(<obwod_budow_wykr>) i#ref(<obwod_zap_wykr>, supplement: "")). Czas budowania struktur jest podobny, natomiast operacja przeszukiwania jest znacznie wolniejsza dla QuadTree (nawet sześciokrotnie). 

#v(1em)
=== Zbiór punktów na dwóch bokach kwadratu oraz dwóch jego przekątnych
#v(1em)

#grid(
  columns: (1fr, 1fr),
  align(top + left)[
    #figure(
    image("kwadrat.png", width: 79%),
    caption: [
      Przykładowy zbiór 100 punktów\ na dwóch bokach kwadratu oraz\ dwóch jego przekątnych
    ],
  )<zbior_kwadrat>
  ],
  align(top + right)[
    #figure(
    image("kwadrat_wynik.png", width: 81%),
    caption: [
      Wynik przykładowego zapytania\ dla zbioru punktów na dwóch bokach kwadratu oraz dwóch jego przekątnych
    ],
  )<wynik_kwadrat>
    ],
)

#v(1em)
#figure(
  table(
    align: center + horizon,
    columns: (auto, auto, auto, auto, auto, auto),
    rows: (auto, auto, auto, auto, auto, auto, auto, auto),
    table.cell(colspan: 2)[*Liczba punktów*], table.cell(colspan: 4)[*Czas [s]*],[*Zbioru*], [*Znalezionych*], [*Budowy\ KD-drzewa*], [*Budowy\ QuadTree*], [*Zapytania do\ KD-drzewa*], [*Zapytania do\ QuadTree*],
    ..csv("kwadrat.csv").flatten()
  ),
  caption: [Porównanie czasowe dla różnych liczności punktów\ na dwóch bokach kwadratu oraz dwóch jego przekątnych]
)<czas_kwadrat>

#v(1em)

#figure(
  image("kwadrat_budowa.png", width: 65%),
  caption: [Wykres porównawczy czasu budowania struktur od liczby punktów\ na dwóch bokach kwadratu oraz dwóch jego przekątnych]
)<kwadrat_budow_wykr>

#figure(
  image("kwadrat_zapytanie.png", width: 65%),
  caption: [Wykres porównawczy czasu zapytania do struktur od liczby punktów\ na dwóch bokach kwadratu oraz dwóch jego przekątnych]
)<kwadrat_zap_wykr>

#v(1em)

Na #ref(<zbior_kwadrat>, supplement: "Rysunku") zaprezentowano przykładowy zbiór 100 punktów na dwóch bokach kwadratu i dwóch przekątnych. #ref(<wynik_kwadrat>) pokazuje wynik przykładowego zapytania. Szczegółowe porównanie czasów wykonania operacji dla różnych rozmiarów zbiorów przedstawiono w #ref(<czas_kwadrat>, supplement: "Tabeli"). Dane te zobrazowano również na dwóch wykresach porównawczych (#ref(<kwadrat_budow_wykr>) i#ref(<kwadrat_zap_wykr>, supplement: "")). Stosunek czasu budowy struktur jest podobny do powyższych problemów, ale z racji na mniejszą liczbę punktów w zbiorze wynikowym czas przeszukiwania jest odpowiednio niższy. Dowodzi to, że oba algorytmy mają złożoność zależną od liczby punktów wyniku.

#pagebreak()
== Wnioski
#v(1em)
+ Zarówno KD-drzewo, jak i QuadTree poprawnie realizują wyszukiwanie punktów w zadanym obszarze, niezależnie od charakterystyki danych wejściowych.

+ KD-drzewo wykazuje przewagę w czasie budowy i przeszukiwania dla dużych zbiorów punktów, szczególnie gdy dane są równomiernie rozłożone lub współliniowe. Jest to efektem bardziej zrównoważonej struktury, co minimalizuje głębokość drzewa.

+ QuadTree jest bardziej wydajne w przypadku małych zbiorów punktów oraz w sytuacjach, gdy punkty są równomiernie rozłożone w przestrzeni. Wydajność tej struktury może być lepsza także dla mniej zagęszczonych zbiorów, gdzie rekurencyjny podział przestrzeni w QuadTree skutecznie ogranicza liczbę operacji w porównaniu z bardziej złożonymi układami.

+ Rozkład danych ma kluczowy wpływ na wydajność obu struktur. KD-drzewo radzi sobie lepiej w przypadku danych z rozkładów jednostajnego, normalnego i współliniowego, podczas gdy QuadTree wykazuje większy potencjał dla danych o mniejszej gęstości lub bardziej jednorodnym rozmieszczeniu w przestrzeni.

+ KD-drzewo jest bardziej uniwersalne i sprawdza się w aplikacjach wymagających obsługi dużych zbiorów punktów lub specyficznych rozkładów, podczas gdy QuadTree może być preferowane w przypadku mniejszych zbiorów, danych mniej zagęszczonych lub gdy prostota implementacji ma znaczenie.

+ Chociaż teoretyczna złożoność obu struktur jest podobna dla budowy i przeszukiwania, w praktyce KD-drzewo okazuje się bardziej stabilne wydajnościowo przy wzroście liczby punktów, podczas gdy QuadTree wykazuje większe zróżnicowanie w czasie operacji zależnie od rozmieszczenia danych i ich zagęszczenia.

Podsumowując, oba podejścia mają swoje mocne i słabe strony, a wybór odpowiedniej struktury danych powinien być dostosowany do charakterystyki danych i specyfiki zastosowania. KD-drzewo oferuje większą stabilność i przewagę w aplikacjach wymagających przetwarzania dużych i gęsto rozmieszczonych zbiorów punktów, natomiast QuadTree może być bardziej efektywne w przypadku mniejszych zbiorów, mniej zagęszczonych danych oraz tam, gdzie kluczowa jest prostota implementacji.


#align(bottom)[
#bibliography("bib.yml", style: "ieee")
]