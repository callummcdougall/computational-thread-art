# computational-thread-art

This project contains code that renders an image as a series of lines connecting pins around a circular frame. For more detail in the physical implementation of these pieces, see my Medium page. The file **alg_bare** is a Python script containing all the functions required to run the algorithm and generate your own pieces of art. For instructions on exactly how to run the algorithm, see the section *How to run alg_bare*.

# Algorithm description

(high level)

(low-level: function by function)


# How to run alg_bare

I would recommend running this algorithm in Jupyter notebooks, or something similar. I appreciate that most code on GitHub is designed to be downloaded and run from command line, but this is not. The reason I have chosen this is because there are 3 main stages of the algorithm: (1) the formatting of the image, (2) the generation of the lines, and (3) the creation of a Eulerian path connecting them. Each stage is only performed if the previous stage is satisfactory, so it makes sense to be able to run the code in sequential blocks, depending on which stage you are at. At this point, I note that the instructions I have included do not extend

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

2i. Decide on your parameters. There are several parameters that need to be set, I will go through each one in detail below, explaining what it does, and how to set it optimally.
* **size** is the length of the image that the algorithm uses, in pixels. I recommend choosing the appropriate size to make your thread width be 1 pixel: for instance, the thread I use is 0.15mm, the bike wheels I use have a diameter of 58cm, so I usually default to a size of 580/0.15 = 3867 (to the nearest integer).
* **nlines** is the number of times that the alg draws a line. Note that, since the alg has the ability to remove lines as well, this should stop increasing at a certain point. If you are exprrimenting with a few different parameter settings, then after your first test you will have an idea of roughly how many lines are drawn overall. I suggest setting nlines to be 20% more than this, so that the alg has enough time to settle on a good solution. If it is your first try, then I would suggest the following: for a mostly mid-tone image of size 3867\*3867, set nlines to 6000. If size is not 3867, scale this number proportionally (important: scale by area of image, not length).
* **nrandom** is the number of random lines that the alg tests for each one it draws. A high value will mean greater accuracy as well as a much longer run time. When you are running the final design, I would suggest at least a value of 200 (I generally use 300, although this can take about 8 hours!). If you are experimenting, a value of 150 (or even 100) should be sufficient.
* **
* **darkness** determines what scalar value to subtract from the pixels that a line goes through (so it is always between 0 and 255). A higher value will mean less lines are drawn overall. This will impact light and dark areas reasonably equally. Although every image is different, I have found values in the range 140-160 to be reasonable.
* **lightness_penalty** determines the ratio (penalty for drawing too many lines)/(penalty for not drawing enough). To elaborate, I described in the *Algorithm description* section how my algorithm takes the sum of absolute values of pixels - in reality, this was a simplification. My algorithm takes the sum of the positive pixels, plus the absolute sum of the negative pixels *multiplied by lightness_penalty*. For instance, a lightness_penalty of 0 would mean that any line will be drawn as long as it goes over a pixel with a still-positive value, whereas 1 would mean a line is only drawn if it goes over more "still dark" areas than "still light" areas. For the average image, I would recommend starting with a value of 0.3-0.4, but this may vary - in particular, if your image is mostly an outline with a white background, then you will need a very low lightness penalty, maybe as low as 0.1.

General tips on tweaking parameters
* If you are deciding between 2 renderings, one with more threads and one with less, err on the side of less: I have found that many pyhsical implementations look much darker than their computer renderings. If you are using a bike wheel-sized frame (so ~60cm diameter), as a rule of thumb, 4500-5000 threads (pre-Eulerian path generation) should be plenty, and sometimes around 1500-2000 will suffice (of course this will vary based on the image).

2ii. Run the section of code titled *IMAGE PREPARATION & LINE GENERATION*, with all the parameters filled in. Note that I have used the placeholder text \[FILL\] anywhere that user input is required. The program should print out output as it runs, which will look something like this:

4176/5650, progress = 37.86%, time = 06:56:14, total time = 07:15:52

The first quantity is (number of lines drawn so far)/(number of lines calculated), so these 2 numbers should initially both be equal as they increase, and only diverge when new lines stop being drawn. Progress indicates the percentage amount that the penalty that has been reduced from its initial value (for more detail on how penalty is calculated, see the section *Algorithm description*). Time indicates how long the algorithm has been running for (hh:mm:ss), and total time is an estimation of how long the algorithm will take until it ends. When the code finishes running, it will save a copy of the image into the working directory, called *new_image*. You should inspect this, and if you are happy with it, then proceed to step 3.

3. EULERIAN PATH



