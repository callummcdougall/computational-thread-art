# Computational Thread Art

![Thread-art David Bowie: computer output](https://miro.medium.com/max/612/1*qQECZMJGxPEqIZ64jAI33Q.jpeg)

This project contains code that renders an image as a series of lines connecting pins around a circular frame. For more detail in the physical implementation of these pieces, see my [article on Medium](https://medium.com/@cal.s.mcdougall/thread-portrait-art-a9e46ecf34de). The file **line_generation** is a Python script containing all the code required to generate your own pieces of art. The 4 sections in this document are: 
* **Algorithm description**, which gives a broad picture of how the algorithm works. For more detail, see the Jupyter Notebook file (where each function is explained).
* **How to run**, which give instructions for generating your own output, as well as tips on what images work best.
* **Algorithm Examples**, where I describe how I've provided example pieces of code that you can try out. 
* **Final thoughts**, in which I outline the future directions I might take this algorithm.

# Algorithm description

This is a very broad description of the algorithm. It misses a lot of finer points, so if you read anything in this next paragraph that is contradicted when you read the Jupyter Notebook file, it is likely incorrect here, but has been simplified for the purpose of explainability.

First, an image is converted into a square array of greyscale pixel values from 0 to 255, where 0 represents white, and 255 black. The coordinates for the pin positions are calculated. A number of lines are chosen between random pairs of pins, and each line is tested by calculating how much it reduces the overall penalty (which is defined as the sum of all the absolute pixel values in the image). A line will change the penalty by reducing the value of all the pixels it goes through by some fixed amount. For instance, a line through a mostly black area might change pixel values from 255 to 155 (reducing penalty a lot), whereas a line through a mostly white area (or an area which already has a lot of lines) might change pixel values from 20 to -80, which actually makes the penalty worse. Once all these penalty changes have been calculated, the line which reduces the penalty the most will be chosen, the pixel values will be edited accordingly, and this process will repeat. If a randomly selected line happens to already have been drawn, the algorithm will compute the change in penalty from removing it rather than adding it. Once the random line selection has run a certain number of times, the algorithm terminates. For the images that use colour, I usually just run the algorithm for each colour separately, using very specific images designed made with photo editing software (see the David Bowie lightning project for a perfect example of this).

The second half of the code creates a Eulerian path, which is a path around the vertices that uses each edge exactly once. For this to exist, we require 2 conditions: parity (the number of lines connected to each side of the pin must be the same, since every line must enter the pin on one side and leave on the other side), and connectedness (every pin must be reachable from every other). The first thing the code does is add lines so that these 2 conditions are satistfied (these added lines go around the outside of the wheel when I make my art in real life, so they don't interfere with the image). Once this is done, then a path is iteratively built up using Hierholzer's algorithm. Essentially, this works by drawing a loop, and if there are any edges left un-drawn, it goes through the loop and finds a place where it can "stick on" another loop. If the conditions of parity and connectedness are satisfied, then we can iterate this process until all edges are connected in the same loop.

# How to run

I would recommend running this algorithm in Jupyter Notebooks, or something similar (this shouldn't come as a surprise given this is how the documents are saved in this repository). Jupyter Notebooks lend themselves well to running this code; once I have selected an image I usually like to run lots of trials (tweaking the parameters, or editing the image), so the flexibility of notebooks is very useful. If you haven't downloaded Jupyter Notebooks, you can always use it in your browser (which requires a lot less effort!).

1. **IMAGE PREPARATION**

   1i. Have an image (either jpg or png) stored in your current working directory. It must be square in size (if it isn't, it will be squashed into shape). Here are a few tips on choosing and preparing the image:
      * The algorithm is very selective; lots of photos just aren't suitable. If you can't get a decent-looking output in the first 5 prototypes, it's probably best to try a different image.
      * Convert the image to black and white first; this helps evaluate suitability.
      * Having a high-res image isn't actually very important, usually 500px\*500px will suffice.
      * If your image has a background, make sure that it is noticably different in brightness from the foreground. For instance, lots of my images have a radial gradient for the background (this is most visible in the butterfly).
      * Characteristics of good images: 
          * good tonal range (i.e. lots of highlights, shadows and midtones)
          * lots of long straight lines across the image (e.g. angular features if you're doing a portrait)
      * Characteristics of bad images: 
          * low contrast
          * large white (or close-to-white) patches
          * one side of the image is in shadow (big problem with portraits)
   1ii. Prepare an importance weighting (optional). This is recommended if your picture has a foreground that you want to emphasise. The importance weighting should be an edited version of the original (same size and format, no cropping!). The areas you want most detail on should be painted black, and the other areas should be given a greyscale value representative of the level of detail you require. Here are a few tips on creating the importance weighting:
      * A vignette can improve the image, by allowing the algorithm to put more detail in the centre of the image. Be sure this happens the right way around (i.e. brighter as you get further out), because most vignettes will automatically be darker at the borders instead!
      * Be wary of making the background completely white, because this can have unforseen side effects, such as a number of lines bunching in certain areas. In previous designs of mine based on portrait photos, this has resulted in the appearance of devil horns, due to the accumulation of vertical lines on the edges of faces!
      * I've included options for the positive and negative importance weightings to be different, but I don't recommend trying this unless you are very confident in how the algorithm will work, since there can be unexpected side-effects.

2. **LINE GENERATION**

   2i. Decide on your parameters. There are several parameters that need to be set, I will go through each one in detail below, explaining what it does, and how to set it optimally. Note that **real_size** is only used in section 3, but I have included it here for completeness.
      * **wheel_real_size** and **nail_real_size** are in meters, they are the diameter of the bike wheel and the width of the picture hangers respectively.
      * **wheel_pixel_size** is the number of pixels in the array that is generated. A higher number means a higher-resolution image, but it can also take much longer for the algorithm to run. When doing a final image I recommend using around size 3000, but when prototyping, 1500-2000 might be better.
      * **npins** is the number of pins that are being placed on the frame. Note that increasing this should not significantly increase the run time. If you are using something with thickness like picture hangers (which I cannot reccommend enough!) then something like 150-200 will be enough (of course it depends on how many you can actually fit on your frame). If you are using nails, or something else only a couple of mm thick, then you may want to choose a larger number, say 250.
      * **nlines** is the number of times that the alg draws a line. Note that the alg will arrive at an equilibrium given enough time (since it can remove lines as well as add them). If you are experimenting with a few different parameter settings, then after your first test you will have an idea of roughly how many lines are drawn overall. I suggest setting nlines to be 20% more than this, so that the alg has enough time to settle on a good solution. If it is your first try, then I would suggest the following: for a mostly mid-tone image, set nlines to about 50% more than the size of your image (e.g. if image size is 3000, try 4500 lines).
      * **nrandom** is the number of random lines that the alg tests for each one it draws. A high value will mean greater accuracy as well as a much longer run time. When you are running the final design, I would suggest at least a value of 200 (I generally use 300, although this can take a pretty long time!). If you are experimenting, a value of 150 (or even 100) should be sufficient.
      * **darkness** determines what scalar value to subtract from the pixels that a line goes through (so it is always between 0 and 255). A higher value will mean less lines are drawn overall. This will impact light and dark areas reasonably equally. Although every image is different, I have found values in the range 140-160 to be reasonable.
      * **lightness_penalty** determines the ratio (penalty for drawing too many lines)/(penalty for not drawing enough). To elaborate, I described in the *Algorithm description* section how my algorithm takes the sum of absolute values of pixels - in reality, this was a simplification. My algorithm takes the sum of the positive pixels, plus the absolute sum of the negative pixels *multiplied by lightness_penalty*. For instance, a lightness_penalty of 0 would mean that any line will be drawn as long as it goes over a pixel with a still-positive value, whereas 1 would mean a line is only drawn if it goes over more "still dark" areas than "still light" areas. For the average image, I would recommend starting with a value of 0.3-0.4, but this may vary - in particular, if your image is mostly an outline with a white background, then you will need a very low lightness penalty, maybe as low as 0.1.

      General tips on tweaking parameters
      * If you are deciding between 2 different sets of parameters, one which gives you more threads and one which gives less, it's probably safer to choose the one that gives less. I have found that many pyhsical implementations look much darker than their digital representations. If you are using a bike wheel-sized frame (so ~60cm diameter), as a rule of thumb, 3000-3500 total lines should be plenty, and sometimes around 1500-2000 will suffice (of course this will vary based on the image).

   2ii. Run the section of code titled *IMAGE PREPARATION & LINE GENERATION*, with all the parameters and image file names filled in. If you are not using an image weighting, you should delete the line defining image_w, and change the final 2 parameters of the *find_lines* function to w=image, using_w = False. I have used the placeholder text \[FILL\] anywhere that user input is required. The alg should print out output as it runs, which will look something like this:

   10/10, avg penalty = 51.83, progress = 0.31%, time = 00:00:07, time left = 00:46:31
   
   The first quantity is number of lines drawn so far / number of lines calculated, so these 2 numbers should initially both be equal as they increase, and only diverge when the algorithm settles down (and lines start being removed as well as added). Avg penalty is the average penalty in all the cells in the array, as calculated by the penalty function. Progress indicates the percentage amount that the penalty that has been reduced from its initial value (for more detail on how penalty is calculated, see the section *Algorithm description*). Time indicates how long the algorithm has been running for (hh:mm:ss), and time left is an estimation of how long the algorithm will take until it ends (this is calculated by extrapolating from the time taken to draw the last 50 lines). When the code finishes running, it will save a copy of the image into the working directory, called *new_image*. You should inspect this, and if you are happy with it, then proceed to step 3 (unless all you want is the computater-generated image, in which case, congratulations, you are finished!).

3. **EULERIAN PATH**

    There are 3 important functions in the code block you need to run: *edges_to_output* converts the lines from step 2 into a readable output, *display* prints out this output in a readable form, and annotates every 100 lines so you can keep track of your progress (see below for an explanation of how to use this output), and *info* prints out the total number of lines (increased from step 2, because lines need to be added to create a Eulerian path), as well as the total length of the thread in meters.

    To explain the output of the *edges_to_output* function, I will use a sample from my David Bowie project, as well as an image of the actual physical implementation:

    54-1

    141-0

    143-0 outside

    0-0

    123-1
    
![Thread-art David Bowie: real life](https://cdn-images-1.medium.com/max/400/1*dp_OT23-ZQATQz37lEmkcA.jpeg)

As the image shows, I have stuck numbers around the outside of the wheel, and identified blocks of 5 and 10 pins with coloured pieces of tape (the red corresponds to pin numbers 0, 10, 20, etc). The tens digit (so 5, 14, 14, 0, 12 respectively) tells me which number from 0-16 to go to, and the units digit specifies the exact pin. The number after the dash, either 0 or 1, specifies which side of the pin: 0 means the clockwise side, 1 means anticlockwise. The word "outside" indicates that the edge in question should go around the outside of the wheel, because it was only added to create a Eulerian path. Note that, as in the above example, these "outside" threads are usually very short - they have been purposefully designed this way - but usually there will be some very long ones as well, which is unavoidable.

# Algorithm Examples

In previous sections, I've described how to choose your own parameters and run your own program. However, there are lots of things to consider and it might feel a bit daunting, which is why I've included some files of example pieces I've made. Each file includes the functions that I ran, the images that I used, and the computer output that it generated. Hopefully you'll be able to try running these, and get an idea for how the algorithm works. Hopefully these should all work out of the box, if any of them don't then please let me know.

I'm going to assume most people reading this are only interested in generating the computer output rather than the actual physical pieces, which is why I haven't included this part of the code in the examples. If anyone reading this is interested in getting the actual threading instructions, please send me a message and I can include this too.

# Final thoughts

This project has been a wonderful experience for me - I loved seeing the way in which mathematics and art intersected. I was inspired by Petros Vrellis' artwork; please see his [website](http://artof01.com/vrellis/works/knit.html) for a much more professional job than mine! There are several directions I am considering taking this project in. One is to properly introduce colour, not just a single colour as a background like I've done so far (these have all been pretty simple). I might experiment with trying to minimise Eulerian distance between pixels in an RGB/CMYK colour space. I would also be very interested in extending the number of dimensions from 2 to 3; maybe by constructing pieces that you need to look at in exactly the right way for them to come into focus. For now though, I hope you enjoyed reading about my algorithm, and if you have any questions about it, please message me!

p.s. - This project has taken a huge amount of effort, and I've had to learn many new things, that each felt insurmountable at the time. I understand that many people struggle with technology just as much as I do, so if you really want to try this art in real life but haven't been able to get the algorithm working, please send me a message explaining your situation and I would be happy to help out, e.g. by giving advice on how to get it working.

Happy coding!
