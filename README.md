# computational-thread-art

This project contains code that renders an image as a series of lines connecting pins around a circular frame. For more detail in the physical implementation of these pieces, see my Medium page. The file **line_generation** is a Python script containing all the code required to generate your own pieces of art. The 3 sections in this document are: 
* **Algorithm description** (which includes **High level description**, giving the broad strokes of how the algorithm works, and **Function by function**, which looks at each function and its purpose in detail)
* **How to run**, which gives the instructions for running the **line_generation** file. 
* **Final thoughts**, in which I outline the future directions I might take this algorithm.
Note that I have not included, either in the algorithm description, run instructions or Python file, the process by which I generated multicoloured images - if anyone is interested in adding colour to their images, please send me a message and I can include this feature!

# Algorithm description

## High level description

This is a very broad description of the algorithm. It misses a lot of finer points, so if you read anything in this next paragraph that is contradicted elsewhere, it is likely incorrect here, but has been simplified for the purpose of explainability.

First, an image is converted into a square array of greyscale pixel values from 0 to 255, where 0 represents white, and 255 black. The coordinates for the pin positions are calculated. A number of lines are generated between randomly chosen pairs of pins, and each line is tested by calculating how much it reduces the overall penalty. The penalty is defined as the sum of all the absolute pixel values in the image; a line will change the penalty by reduding the value in all the pixels it goes through by a certain amount. For instance, a line through a mostly black area might change pixel values from 200 to 100, this reduces the penalty a lot. A line through a mostly white area (or an area over which many lines have already been drawn) might change pixel values from 50 to -50, this will not reduce the penalty. Once all these penalty changes have been calculated, the line which reduces the penalty the most will be chosen, the pixel values will be edited accordingly, and this process will repeat. If a randomly selected line happens to already have been drawn, the algorithm will compute the change in penalty brought about by removing it, that way lines can be removed as well as added, so the line-adding process will naturally reach a balance, where the total number of lines stops changing. Once a certain number of lines have been added/withdrawn, the algorithm terminates.

The second half of the code creates a Eulerian path, which is a path around the vertices that uses each edge exactly once. Of course, this might not exist. We require 2 conditions: the the number of lines connected to each side of the pin to be the same (since every line must enter the pin on one side, and leave on the other), and for the graph to be connected, so the first thing the code does is add lines so that these 2 conditions are satistfied. Then, a path is iteratively built up, with the lines added in the 2 previous steps labelled as "outside" (indicating that the thread should go around the outside of the frame, so as not to interfere with the image).

## Function-by-function description

#### Functions for image preparation & line generation

***generate_pins***
* Generates the position of pins, given a particular number of pins, image size, and nail pixel size.
* Creates 2 lists of positions (one for the anticlockwise side, one for the clockwise), and meshes them together so that the order they appear in the final output is the order of nodes anticlockwise around the frame.

***through_pixels***
* Finds which pixels a line between particular pins runs through.
* Adjusted so that the number of pixels (approximately) equals the distance between the pins.

***fitness***
* Measures how much line improves image. improvement is difference in penalty, i.e. new penalty - old penalty (where a smaller penalty is better).
* Penalty is the sum of absolute values of positive pixels, minus absolute values of negative pixels times a lightness penalty. If the lightness penalty is 1, going over light areas is as bad as not going over dark areas, so not enough lines get drawn. If the lightness penalty is 0, the algorithm won't care about going over light areas as long as it goes over dark areas as well, so too many lines will be drawn. It needs to be balanced between these 2 extremes (normally about 0.4-0.6).
* The adding parameter in fitness means that it can calculate the improvement either from adding a line, or from removing a line that is already in the image.

***optimise_fitness***
* Process of adding a new line is as follows:
    1. Generates random lines (ensuring they aren't the same line, or the same but reversed, or connecting the same pin), then finds the line with the best fitness.
    2. Subtracts this line from the image.
    3. Returns the new image, the best line (i.e. the vertices it is connecting), and a boolean that says whether a line is being added or removed.
    
***find_lines***
* Calls optimise_fitness multiple times to draw a set of lines.
* Updates the image and the list of lines with each line drawn.
* Every 10 lines drawn, prints output that describes the progress of the algorithm.
* Prints total run time of algorithm at the end.

***hms_format***
* Takes a time, and converts it into hh:mm:ss. Used in find_lines function, to report progress.

***get_penalty***
* Calculates the total penalty of the image.
* Like other functions, it can do this for an image weighting, or a simplified version if no image weighting is used

***prepare_image***
* Takes a jpeg or png image file, and converts it into an array of bytes.
* The input needs to be square, otherwise it will be squashed.
* Colour input (boolean) determines whether image is monochrome (so pixel values = darkness of image) or coloured (so pixel values = saturation of image; note in this case the image must be pre-processed so only the appropriate colour is left).
* Weighting input (boolean) determines whether image is meant to be an importance weighting (so the byte array returned has values between 0 and 1, where 1 means black, so high importance, and 0 means white, so low importance).

***save_plot***
* Saves the plot of lines under a specified title - can then be opened with GIMP.
* Colours are added in the order they appear in the list.
* Uses RGB format.

#### Functions (and classes) for Eulerian path

***edge***
* Creates a class for edges that makes the path-finding process easier. Among the things this class allows me to do efficiently are:
   * Find the pin number, the node number (these two are different, as each pin has 2 nodes, corresponding to its 2 sides) and the orientation (i.e. which pin side is being referred to) of the two vertices which are connected by the edge.
   * Flip the direction of an edge (i.e. from node B to A, rather than A to B)
   * Look for edges that are connected to this edge (connected in the sense that the pair of edges share the same pin number, but not the same node number, so they can be traced by thread sequentially).

***extra_edges_parity_correct***
* Takes in edge_list and returns the extra edges needed so that every pin has the same number of edges on either side.
* This algorithm is quite complicated, since I have put a lot of thought into how to make sure the extra edges added are the easiest to physically implement, so I will not go into detail - if people are interested, please send a message!

***get_closest_pair***
* Used in the extra_edges_parity_correct algorithm, to find the closest pair of vertices to match up.

***extra_edges_connect_graph***
* Adds extra edges so that the graph is connected.
* This is an inefficient way to add edges, but since most graphs will already be connected (or very nearly), I think there's no point improving this.

***add_connected_vertex***
* Takes a set of vertices and an edge list, and adds a vertex not currently in s that can be connected (by an edge in the edge_list) to the rest of s.
* The boolean at the end says whether a new vertex was successfully added, if not then it is necessary to add a new edge.

***get_adjacant_vertices***
* Takes a set of vertices and its compliment, and returns a pair of vertices (in set and compliment respectively) that are a distance of 1 apart from each other.

***create_cycle***
* Creates a path from edges in edge_list, starting from first_edge. 
* Returns path, and new reduced edge_list.
* Note that the path returned will only (definitely) be a cycle if the edge_list is parity-corrected.

***add_cycle***
* Takes a cycle and edge_list, and goes through the cycle trying to find a place to insert a new cycle, using edges from edge_list.
* Once it finds a place, it inserts a cycle, and returns the new extended cycle, and the new reduced edge_list.

***create_full_cycle***
* Takes a (connected + parity-corrected) edge_list, and keeps adding cycles to it using add_cycle, until all edges have been added.

***edges_to_output***
* Takes in non-parity-corrected edges, and uses all the functions above to return a formatted output.
* Also uses cut_down function (see below).
* The format of the output is explained in the **How to run** section.

***cut_down***
* Removes sequences of multiple "outside" strings, replacing them with one direct string.

***display***
* Prints all the lines, in groups of 100.

***info***
* Prints out the total distance (in meters) of the thread, and the number of lines.

# How to run

I would recommend running this algorithm in Jupyter notebooks, or something similar. I appreciate that most code on GitHub is designed to be downloaded and run from command line, but this is not. The reason I have chosen this is because there are 3 main stages of the algorithm: (1) the formatting of the image, (2) the generation of the lines, and (3) the creation of a Eulerian path connecting them. Each stage is only performed if the previous stage is satisfactory, so it makes sense to be able to run the code in sequential blocks, depending on which stage you are at. You should only need 4 cells: one to define all the functions used in steps 1 and 2, one to run the code for steps 1 and 2, one to define the functions used in step 3, and one to run the code for step 3. This suggested partition is clearly indicated in the Python file.

1. IMAGE PREPARATION

   1i. Have an image (either jpeg or pdf) stored in your current working directory. It must be square in size (if it isn't, it will be squashed into shape). Here are a few tips on choosing and preparing the image:
      * Generally, images with high contrast work better, but only up to a point: if there are lots of very dark and very light areas, 
      * If your image has a background, make sure that it is noticably different in brightness from the foreground. For instance, when preparing portrait images, I sometimes find it helpful to appy a radial gradient to the background, so that it is lighter at the edges of the face, but mid-tone further out. This leads to another point - make sure there is a change in brightness wherever your image has a significant border.
      * Convert it to black and white first. This isn't strictly necessary because the algorithm does this anyway, but it is useful to get a good idea of what the final output will look like.
      * Keep in mind that a circular portion of the image will be rendered, not the whole image.
      * Having a very high resolution image isn't actually as important as you might think. 500px\*500px will usually suffice (although the higher the better).

   1ii. Prepare an importance weighting (optional). This is recommended if your picture has a foreground that you want to emphasise. The importance weighting should be an edited version of the original (same size and format, no cropping!). The areas you want most detail on should be painted black, and the other areas should be given a greyscale value representative of the level of detail you require. Here are a few tips on creating the importance weighting:
      * A vignette can improve the image, by allowing the algorithm to put more detail in the centre of the image. Be sure this happens the right way around (i.e. brighter as you get further out), because most vignettes will automatically be darker at the borders instead!
      * Be wary of making the background completely white, because this can have unforseen side effects, such as a number of lines bunching in certain areas. In previous designs of mine based on portrait photos, this has resulted in the appearance of devil horns, due to the accumulation of vertical lines on the edges of faces!

2. LINE GENERATION

   2i. Decide on your parameters. There are several parameters that need to be set, I will go through each one in detail below, explaining what it does, and how to set it optimally. Note that **real_size** is only used in section 3, but I have included it here for completeness.
      * **real_size** is the diameter, in meters, of your circular frame. For reference, the average bike wheel is ~0.58m.
      * **npins** is the number of pins that are being placed on the frame. Note that increasing this should not significantly increase the run time. If you are using something with thickness like picture hangers (which I cannot reccommend enough!) then something like 150-200 will be enough (of course it depends on how many you can actually fit on your frame). If you are using nails, or something else only a couple of mm thick, then you may want to choose a larger number, say 250.
      * **size** is the length of the image that the algorithm uses, in pixels. I recommend choosing the appropriate size to make your thread width be 1 pixel: for instance, the thread I use is 0.15mm, the bike wheels I use have a diameter of 0.58m, so I usually default to a size of 580/0.15 = 3867 (to the nearest integer). If you are unsure of how thick your thread is, I would approximate it as 0.15mm - this tends to be accurate for reasonably high-quality sewing thread.
      * **nail_size** is the pixel thickness of the nails. I described how you can calculate *size* above; *nail_size* should be calculated in a similar way. For instance, the clothes hangers I use have a thickness of 7mm, so the value that I use is 7/0.15 (note that, unlike size, this doesn't need to be an integer).
      * **nlines** is the number of times that the alg draws a line. Note that, since the alg has the ability to remove lines as well, this should stop increasing at a certain point. If you are exprrimenting with a few different parameter settings, then after your first test you will have an idea of roughly how many lines are drawn overall. I suggest setting nlines to be 20% more than this, so that the alg has enough time to settle on a good solution. If it is your first try, then I would suggest the following: for a mostly mid-tone image of size 3867\*3867, set nlines to 6000. If size is not 3867, scale this number proportionally (important: scale by area of image, not length).
      * **nrandom** is the number of random lines that the alg tests for each one it draws. A high value will mean greater accuracy as well as a much longer run time. When you are running the final design, I would suggest at least a value of 200 (I generally use 300, although this can take about 8 hours!). If you are experimenting, a value of 150 (or even 100) should be sufficient.
      * **darkness** determines what scalar value to subtract from the pixels that a line goes through (so it is always between 0 and 255). A higher value will mean less lines are drawn overall. This will impact light and dark areas reasonably equally. Although every image is different, I have found values in the range 140-160 to be reasonable.
      * **lightness_penalty** determines the ratio (penalty for drawing too many lines)/(penalty for not drawing enough). To elaborate, I described in the *Algorithm description* section how my algorithm takes the sum of absolute values of pixels - in reality, this was a simplification. My algorithm takes the sum of the positive pixels, plus the absolute sum of the negative pixels *multiplied by lightness_penalty*. For instance, a lightness_penalty of 0 would mean that any line will be drawn as long as it goes over a pixel with a still-positive value, whereas 1 would mean a line is only drawn if it goes over more "still dark" areas than "still light" areas. For the average image, I would recommend starting with a value of 0.3-0.4, but this may vary - in particular, if your image is mostly an outline with a white background, then you will need a very low lightness penalty, maybe as low as 0.1.

      General tips on tweaking parameters
      * If you are deciding between 2 renderings, one with more threads and one with less, err on the side of less: I have found that many pyhsical implementations look much darker than their computer renderings. If you are using a bike wheel-sized frame (so ~60cm diameter), as a rule of thumb, 4500-5000 threads (pre-Eulerian path generation) should be plenty, and sometimes around 1500-2000 will suffice (of course this will vary based on the image).

   2ii. Run the section of code titled *IMAGE PREPARATION & LINE GENERATION*, with all the parameters and image file names filled in. If you are not using an image weighting, you should delete the line defining image_w, and change the final 2 parameters of the *find_lines* function to w=image, using_w = False. I have used the placeholder text \[FILL\] anywhere that user input is required. The alg should print out output as it runs, which will look something like this:

   4176/5650, progress = 37.86%, time = 06:56:14, total time = 07:15:52

   The first quantity is (number of lines drawn so far)/(number of lines calculated), so these 2 numbers should initially both be equal as they increase, and only diverge when new lines stop being drawn. Progress indicates the percentage amount that the penalty that has been reduced from its initial value (for more detail on how penalty is calculated, see the section *Algorithm description*). Time indicates how long the algorithm has been running for (hh:mm:ss), and total time is an estimation of how long the algorithm will take until it ends. When the code finishes running, it will save a copy of the image into the working directory, called *new_image*. You should inspect this, and if you are happy with it, then proceed to step 3 (unless all you want is the computater-generated image, in which case, congratulations, you are finished!).

3. EULERIAN PATH

I have included a lot of detail about how the alg generates a path in my **Algorithm description**, under the subheading **Function by function**, so I will not recreate that here. What I will do is outline the 3 important functions in the code block you need to run: *edges_to_output* converts the lines from step 2 into a readable output, *display* prints out this output in a readable form, and annotates every 100 lines so you can keep track of your progress (see below for an explanation of how to use this output), and *info* prints out the total number of lines (increased from step 2, because lines need to be added to create a Eulerian path), as well as the total length of the thread in meters.

To explain the output, I will reference the image of the tiger that is at the top of my Medium post: https://medium.com/@cal.s.mcdougall/thread-portrait-art-a9e46ecf34de. You can see I have added coloured tape every 5 pins, starting at 0 and going around anticlockwise all the way to 167 (I used 168 pins in total for this image). Here is a sample of the output that I use to put the threads in place:

54-1
141-0
143-0 outside
0-0
123-1

The tens digit (so 5, 14, 14, 0, 12 respectively) tells me which number from 0-16 to go to - the red tape corresponds to the pins that are a multiple of 10. The units digit specifies the exact pin. The number after the dash, either 0 or 1, specifies which side of the pin: 0 means the clockwise side, 1 means anticlockwise. To further illustrate, the order of the nodes (going anticlockwise from the very first) is 0-0, 0-1, 1-0, 1-1, ... 167-0, 167-1. For instance, whatever position the thread was when I got to this point, I would then connect the strand I was holding to the left side of the pin that is 4 places to the left of the red tape between the numbers 4 and 5. The word "outside" indicates that the edge in question should go outside the frame, because it was only added to create a Eulerian path. Note that, as in the above example, these "outside" threads will tend to be very short distances - they have been purposefully designed this way - but inevitably there will be occasions where you have to circle around large sections of the frame.

# Final thoughts

This project has been a wonderful experience for me - I loved seeing how maths and art intersected. I was inspired by Petros Vrellis' artwork; please see his website http://artof01.com/vrellis/works/knit.html for a much more professional job than mine! There are several directions I am considering taking this project in. One is to properly introduce colour, not just a single colour as a background like I did in the tiger featured on my Medium page (this was actually a very simple feature to design - I generated the orange and black threads separately, with the orange based on pixel saturation just like the black was based on pixel darkness), but full colour images that use RGB-coloured threads (or maybe CMYK?). I would also be very interested in extending the number of dimensions from 2 to 3; maybe by constructing pieces that you need to look at in exactly the right way for them to come into focus. For now though, I hope you enjoyed reading about my algorithm, and if you have any questions about it, please message me!

p.s. - I am not a very tech-savvy person, and this project has taken a huge amount of effort. I understand that many people struggle with these things just as much as I do, so if you would really love to try this art in real life but lack the tech skills to use the algorithm, please send me a message explaining your situation and I would be happy to help out, either by giving advice on how to use my code, or if necessary, running it on my own computer and sending you the output - for a fee of a star on this repo, of course!
