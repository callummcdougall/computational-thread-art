import numpy as np
from itertools import product
from PIL import Image, ImageDraw
import matplotlib.pyplot as plt
import time
from IPython.display import clear_output


def generate_pins(npins, size, nail_pixel_size):

    r = (size / 2) - 1
    
    theta = np.arange(npins, dtype="float64") / npins * (2 * np.pi)
    
    epsilon = np.arcsin(nail_pixel_size / size)
    
    theta_acw = theta.copy() + epsilon
    theta_cw = theta.copy() - epsilon
    
    theta = np.stack((theta_cw, theta_acw)).ravel("F")
    
    x = r * (1 + np.cos(theta)) + 0.5
    y = r * (1 + np.sin(theta)) + 0.5
    
    return np.array((x,y)).T


def fitness(image, a, b, darkness, lightness_penalty, w, using_w, adding):
    
    pixels = through_pixels(a, b)
    old_pixel_values = np.array([image[p[0],p[1]] for p in pixels])
    
    if adding:
        new_pixel_values = old_pixel_values - darkness
    else:
        new_pixel_values = old_pixel_values + darkness
    
    if using_w:
        pixel_weightings = np.array([w[p[0],p[1]] for p in pixels])
        old_pixel_values = old_pixel_values * pixel_weightings
        new_pixel_values = new_pixel_values * pixel_weightings

    new_penalty = sum(new_pixel_values[new_pixel_values > 0]) - lightness_penalty * sum(new_pixel_values[new_pixel_values < 0])
    old_penalty = sum(old_pixel_values[old_pixel_values > 0]) - lightness_penalty * sum(old_pixel_values[old_pixel_values < 0])
    
    return new_penalty - old_penalty


def optimise_fitness(image, nrandom, darkness, lightness_penalty, npins, list_of_lines, w, using_w):
    
    n_pin_sides = npins * 2
    
    rand_numbers = np.random.choice(n_pin_sides**2, nrandom, replace=False)
        
    rand_lines = [sorted((int(i/n_pin_sides), i%n_pin_sides)) for i in rand_numbers]
        
    best_fitness = 0
    best_line = (0,1)
    
    for line in rand_lines:
                
        if int(line[0]/2) != int(line[1]/2) and line[1]-line[0] > 10:

            p0, p1 = pins[line[0]], pins[line[1]]
            
            new_fitness = fitness(image, p0, p1, darkness, lightness_penalty, w, using_w, adding = line not in list_of_lines)

            if new_fitness < best_fitness:
                
                best_fitness = new_fitness
                best_line = line
    
    p0, p1 = pins[best_line[0]], pins[best_line[1]]
    
    adding = best_line not in list_of_lines
    
    if adding:
        for p in through_pixels(p0, p1):
            image[p[0],p[1]] -= darkness
    else:
        for p in through_pixels(p0, p1):
            image[p[0],p[1]] += darkness      
        
    return (image, best_line, adding)


def find_lines(image, nlines, nrandom, darkness, lightness_penalty, npins, w, using_w):
    
    t0 = time.time()
    
    list_of_lines = []
    penalty_over_time = []
    
    initial_penalty = get_penalty(image, lightness_penalty, w, using_w)
        
    for i in range(nlines):

        if i%10 == 0:
            penalty = get_penalty(image, lightness_penalty, w, using_w)
            if i != 0:
                t = time.time() - t0
                T = t * nlines / i
                for j in range(3):
                    print("{}/{}, progress = {}%, time = {}, total time = {}"
                          .format(len(list_of_lines), i, np.round(100*(1 - penalty/initial_penalty), 2),
                                  hms_format(t), hms_format(T)), end="\r")
            else:
                print("{}/{}, progress = {}%"
                      .format(len(list_of_lines), i, np.round(100*(1 - penalty/initial_penalty), 2)), end="\r")
            penalty_over_time.append(penalty)
                
        image, line, adding = optimise_fitness(image, nrandom, darkness, lightness_penalty, npins, list_of_lines, w, using_w)
        
        if adding:
            list_of_lines.append(line)
        else:
            list_of_lines.remove(line)
    
    clear_output()
    penalty = get_penalty(image, lightness_penalty, w, using_w)
    print("{}/{}, progress = {}%"
          .format(len(list_of_lines), nlines, int(penalty), np.round(100*(1 - penalty/initial_penalty), 2)))
    penalty_over_time.append(penalty)
    
    t = time.time() - t0
    print("time = " + hms_format(t))
    
    return list_of_lines


def hms_format(t):
    t = [int(t/3600), int((t%3600)/60), int(t%60)]
    for i in range(3):
        t[i] = "0"*int(2-len(str(t[i]))) + str(t[i])
    return "{}:{}:{}".format(t[0],t[1],t[2])


def get_penalty(image, lightness_penalty, w, using_w):
    
    if using_w:
        image_2 = image * w
        return sum(image_2[image_2>0]) - sum(image_2[image_2<0])*lightness_penalty
    else:
        return sum(image[image>0]) - sum(image[image<0])*lightness_penalty
    
    
def prepare_image(file_name, size, weighting=False):
    
    image = Image.open(file_name).resize((size,size))
    
    if weighting:    
        image = 1 - np.array(image.convert(mode="L").getdata()).reshape((size,size)) / 255
    else:
        image = 255 - np.array(image.convert(mode="L").getdata()).reshape((size,size))

    for (i,j) in product(range(size), range(size)):
        if ((i - (size-1)*0.5)**2 + (j - (size-1)*0.5)**2)**0.5 > size*0.5:
            image[i,j] = 0                                
            
    return image.T[:,::-1]


def save_plot(lines, npins, size, nail_pixel_size, file_name):
        
    pins = generate_pins(npins, size, nail_pixel_size)
    
    for i in range(len(pins)):
        pins[i] = [pins[i][0],size-pins[i][1]]
    
    thread_image = Image.new('L', (size,size), 255)
    draw = ImageDraw.Draw(thread_image)
        
    lines = [(pins[n[0]], pins[n[1]]) for n in lines]
    for j in lines:
        draw.line((tuple(j[0]), tuple(j[1])), fill=0)
        
    thread_image.save(file_name, format="JPEG")
    
    
    
    
    
real_size = 0.58
npins = 20
size = 1000
nail_size = 75
nlines = 200
nrandom = 50
darkness = 150
lightness_penalty = .5

pins = generate_pins(npins, size, nail_size)

image = prepare_image("churchill_9.jpg", size)
image_w = prepare_image("churchill_w4.jpg", size, weighting=True)

lines = find_lines(image, nlines, nrandom, darkness, lightness_penalty, npins, w=image_w, using_w=True)

save_plot(lines, npins, size, nail_size, "new_file")





class edge():
    
    def __init__(self, A, B):
        self.A = A
        self.B = B
        self.A_vertex = int(A/2)
        self.B_vertex = int(B/2)
        self.A_direction = A%2
        self.B_direction = B%2
        
    def __repr__(self):
        return ("({}, {})".format(self.A, self.B))
    
    def __eq__(self, other):
        return str(self) == str(other)
    
    def backwards(self):
        return edge(self.B, self.A)
    
    def connected(self, e):
        return self.B_vertex == e.A_vertex and self.B_direction != e.A_direction
        
    def next_edges(self, edge_list):
        
        forwards_edge_list = [e for e in edge_list if self.connected(e)]
        backwards_edge_list = [e.backwards() for e in edge_list if self.connected(e.backwards())]
        
        edge_list = forwards_edge_list + backwards_edge_list
        
        return edge_list
    
    
def extra_edges_parity_correct(edge_list, n_vertices):
        
    d = {n : 0 for n in range(n_vertices)}
    
    for e in edge_list:
        
        if e.A_direction == 0:
            d[e.A_vertex] -= 1
        elif e.A_direction == 1:
            d[e.A_vertex] += 1
    
        if e.B_direction == 0:
            d[e.B_vertex] -= 1
        elif e.B_direction == 1:
            d[e.B_vertex] += 1
    
    extra_edges = []
    
    while True:
        s0 = sum([max(i,0) for i in d.values()])
        s1 = sum([-min(i,0) for i in d.values()])
        if s0 == s1:
            break
        elif s0 > s1:
            need_a_zero = [i for i in d.keys() if d[i] > 0]
            a, b, distance = get_closest_pair(need_a_zero, need_a_zero, n_vertices)
            d[a] -= 1
            d[b] -=1
            A = 2*a
            B = 2*b
            extra_edges.append(edge(A,B))
        elif s1 > s0:           
            need_a_one = [i for i in d.keys() if d[i] < 0]
            a, b, distance = get_closest_pair(need_a_one, need_a_one, n_vertices)
            d[a] += 1
            d[b] +=1
            A = 2*a+1
            B = 2*b+1
            extra_edges.append(edge(A,B))  
        
    while sum([abs(i) for i in d.values()]) > 0:      
        need_a_zero = [n for n in d.keys() if d[n] > 0]
        need_a_one = [n for n in d.keys() if d[n] < 0]
        a, b, distance = get_closest_pair(need_a_zero, need_a_one, n_vertices) #see cell below
        d[a] -= 1
        d[b] += 1
        A = 2*a
        B = 2*b + 1
        extra_edges.append(edge(A,B))

    return extra_edges


def get_closest_pair(need_a_zero, need_a_one, n_vertices):
    
    best_distance = n_vertices
    
    for a in need_a_zero:
        for b in need_a_one:
            new_distance = (a-b)%n_vertices
            if new_distance < best_distance and new_distance != 0:
                best_distance = new_distance
                best_a = a
                best_b = b

    return (best_a, best_b, best_distance)


def extra_edges_connect_graph(edge_list):
    
    full_edge_list = []
    for i in edge_list:
        if i.A_vertex not in full_edge_list:
            full_edge_list.append(i.A_vertex)
        if i.A_vertex not in full_edge_list:
            full_edge_list.append(i.A_vertex)
    
    s = set([edge_list[0].A_vertex, edge_list[0].B_vertex])
    
    extra_edges = []
    
    while len(s) < len(full_edge_list):
        
        s, found_new_vertex = add_connected_vertex(s, edge_list)
                
        if not found_new_vertex:
            
            v0, v1 = get_adjacant_vertices(s, set(range(n_vertices)) - s)
            
            extra_edges += [edge(2*v0, 2*v1), edge(2*v0+1, 2*v1+1)]
            
            s.add(v0)
            s.add(v1)
            
    return extra_edges


def add_connected_vertex(s, edge_list):

    for i in edge_list:
        
        if (i.A_vertex in s and i.B_vertex not in s) or (i.B_vertex in s and i.A_vertex not in s):
                
            s.add(i.A_vertex)
            s.add(i.B_vertex)
            return (s, True)
    
    return (s, False)


def get_adjacant_vertices(s, t):

    for i in s:
        for j in t:
            if abs(i-j) == 1:
                return (i, j) 
            
            
def create_cycle(edge_list, first_edge):
    
    cycle = [first_edge]
    
    while True:
        
        try:
            next_edge = cycle[-1].next_edges(edge_list)[0]
            
            cycle.append(next_edge)
                        
            if next_edge in edge_list:
                edge_list.remove(next_edge)
            else:
                next_edge = next_edge.backwards()
                edge_list.remove(next_edge)
                
        except:
            
            return cycle, edge_list
        
        
        
def add_cycle(cycle, edge_list):
    
    for i in range(len(cycle)):
        
        cycle = [cycle[-1]] + cycle[:-1]
        
        edge_list_copy = edge_list.copy()
        new_cycle, edge_list_copy = create_cycle(edge_list_copy, cycle[-1])
        if len(new_cycle) > 1:
            return cycle + new_cycle[1:], edge_list_copy

        
        
def create_full_cycle(edge_list):
    
    cycle, edge_list = create_cycle(edge_list[1:], edge_list[0])
    
    while len(edge_list) > 0:
        
        cycle, edge_list = add_cycle(cycle, edge_list)
    
    return cycle


def edges_to_output(line_list, n_vertices):
    
    edge_list = [edge(i[0],i[1]) for i in line_list if type(i) == list]
        
    correction_edges = extra_edges_parity_correct(edge_list, n_vertices)
            
    correction_edges += extra_edges_connect_graph(edge_list + correction_edges)
    
    full_cycle = create_full_cycle(edge_list + correction_edges)
    
    l = [0] * len(full_cycle)
    
    for i in correction_edges:
        for j in range(len(full_cycle)):
            if (i == full_cycle[j] or i.backwards() == full_cycle[j]) and l[j] == 0:
                l[j] = 1
                break
                        
    full_cycle, l = cut_down(full_cycle, l)
        
    l = [0] + l[:-1]

    output = []
    
    first_pin = True
        
    for i in zip(full_cycle, l):
        
        n1 = i[0].A_vertex   
        
        if first_pin:
            n2 = i[0].A_direction
            first_pin = False
        else:
            n2 = (i[0].A_direction + 1) % 2
        
        if i[1] == 1:
            n3 = " outside"
        else:
            n3 = ""
            
        output.append("{}-{}{}".format(n1, n2, n3))
    
    return full_cycle, output


def cut_down(full_cycle, l):
    
    for i in range(len(l)-1):
                
        if l[i] == 1 and l[i+1] == 1:
            new_full_cycle = full_cycle[:i] + [edge(full_cycle[i].A, full_cycle[i+1].B)] + full_cycle[i+2:]
            new_l = l[:i] + [1] + l[i+2:]
            return cut_down(new_full_cycle, new_l)
        
    if l[-1] == 1 and l[-2] == 1:
        return cut_down(full_cycle[:-1], l[:-1])
    
    return full_cycle, l


def display(output):
    
    count = 0

    for i in output:
        print(i)
        count += 1
        if count % 100 == 0:
            print("\n{}\n".format(count))
            
            
def info(lines, npins, size, nail_size, real_size):
    
    lines = [[i.A, i.B] for i in lines]
    
    pins = generate_pins(npins, size, nail_size)
    lines = [(pins[n[0]], pins[n[1]]) for n in lines]
    
    d = 0
    for i in lines:
        d += ((i[0][0]-i[1][0])**2 + (i[0][1]-i[1][1])**2) ** 0.5
    
    d = d * (real_size / size)
    
    print("distance = {} meters\n# lines = {}\n".format(int(d), len(lines)))   
    
    
    
    
    
    
output = edges_to_output(lines, npins)
info(output[0], npins, size, nail_size, real_size)
display(output[1])
