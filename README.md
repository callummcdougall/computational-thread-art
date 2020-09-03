# Computational Thread Art

![Thread-art David Bowie: computer output](https://miro.medium.com/max/612/1*qQECZMJGxPEqIZ64jAI33Q.jpeg)

This project contains code that renders an image as a series of lines connecting picture hooks around a circular frame. For more detail in the physical implementation of these pieces, see my [article on Medium](https://medium.com/@cal.s.mcdougall/thread-portrait-art-a9e46ecf34de). The 4 sections in this document are: 
* **Algorithm description**, which gives a broad picture of how the algorithm works. For more detail, see the Jupyter Notebook file (where each function is explained).
* **How to run**, which give instructions for generating your own output, as well as tips on what images work best.
* **Algorithm Examples**, where I describe how I've provided example pieces of code that you can try out. 
* **Final thoughts**, in which I outline the future directions I might take this algorithm.

A quick note here for anyone who wants to run the algorithm - it takes me quite a while to generate the examples (getting all the files in the right place, etc), so I usually only update these files when I've made a big change to the algorithm. However, when I've made small changes (e.g. speed improvements), I will add the Jupyter Notebook to the main directory (it is called line_generation.ipynb). If you want to generate your own art, please run the line_generation notebook, but with the image-specific parts of the code customised (see HOW TO RUN, Section 2: line generation, for more details on this).

# Algorithm description

The original algorithm for rendering the actual image went as follows: first, an image is converted into a square array of greyscale pixel values from 0 to 255, where 0 represents white, and 255 black. The coordinates for the hook positions are calculated. A number of lines are chosen between random pairs of hooks, and each line is tested by calculating how much it reduces the penalty (which is defined as the average of all the absolute pixel values in the image). A line will change the penalty by reducing the value of all the pixels it goes through by some fixed amount. For instance, a line through a mostly black area might change pixel values from 255 to 155 (reducing penalty a lot), whereas a line through a mostly white area (or an area which already has a lot of lines) might change pixel values from 20 to -80, which actually makes the penalty worse. Once all these penalty changes have been calculated, the line which reduces the penalty the most will be chosen, the pixel values will be edited accordingly, and this process will repeat. If a randomly selected line happens to already have been drawn, the algorithm will compute the change in penalty from removing it rather than adding it. Once the random line selection has run a certain number of times, the algorithm terminates. For the images that use colour, I usually just run the algorithm for each colour separately, using very specific images designed with photo editing software (I use GIMP). See the David Bowie lightning project for a perfect example of this.

This original algorithm has been improved significantly, primarily by making the penalty more complicated than just the absolute sum of pixel values. The actual formula for penalty is:

![Formula](https://miro.medium.com/max/512/1*VHRwQybGtGxkdJWGvYq8Ag.png)

where p<sub>i</sub> is the pixel value, w<sup>+</sup> and w<sup>-</sup> are the positive and negative importance weightings, L is the lightness penalty, N is the line norm, and the sum is taken over all pixels the line goes through. 
 * The lightness penalty is a value (usually between 0 and 1) which reduces the penalty for negative pixels (or to put it in terms of the actual artwork, it makes the algorithm more willing to draw too many lines than too few)
 * The importance weighting is an image of the same dimensions of the original image, but when it is read by the algorithm, every pixel value is scaled to between 0 and 1, so the darker pixels indicate areas you want to give more weight to in the penalty calculation. The algorithm will prioritize accuracy in these areas at the expense of the rest of the image.
 * The line norm can have 3 different values: 1 (so penalty is just total sum), number of pixels (so penalty is average per pixel), or sum of all the weightings of the pixels (so penalty is average per weighted pixel). If w<sup>+</sup> and w<sup>-</sup> are different, the latter mode defaults to using w<sup>+</sup>.

The second half of the code creates a Eulerian path, which is a path around the vertices that uses each edge exactly once. For this to exist, we require 2 conditions: parity (the number of lines connected to each side of the hook must be the same, since every line must enter the hook on one side and leave on the other side), and connectedness (every hook must be reachable from every other). The first thing the code does is add lines so that these 2 conditions are satistfied (these added lines go around the outside of the wheel when I make my art in real life, so they don't interfere with the image). Once this is done, then a path is iteratively built up using Hierholzer's algorithm. Essentially, this works by drawing a loop, and if there are any edges left un-drawn, it goes through the loop and finds a place where it can "stick on" another loop. If the conditions of parity and connectedness are satisfied, then we can iterate this process until all edges are connected in the same loop.

# How to run

I would recommend running this algorithm in Jupyter Notebooks, or something similar (this shouldn't come as a surprise given this is how the documents are saved in this repository). Jupyter Notebooks lend themselves well to running this code; once I have selected an image I usually like to run lots of trials (tweaking the parameters, or editing the image), so the flexibility of notebooks is very useful. If you haven't downloaded Jupyter Notebooks, you can always use it in your browser (which requires a lot less effort!). To run the algorithm using your own image, you can take any of my example algorithms (see section Algorithm Examples), and replace the appropriate bits of code.

1. **IMAGE PREPARATION**

   1i. Have an image (either jpg or png) stored in your current working directory. It must be square in size (if it isn't, it will be squashed into shape). Here are a few tips on choosing and preparing the image:
      * The algorithm is very selective; lots of photos just aren't suitable. If you can't get a decent-looking output in the first 5 prototypes, it's probably best to try a different image.
      * Convert the image to black and white first; this helps evaluate suitability.
      * Having a high-res image isn't actually very important, usually 400px\*400px will suffice.
      * If your image has a background, make sure that it is noticably different in brightness from the foreground. For instance, lots of my images have a radial gradient for the background (best example of this is the butterfly).
      * Characteristics of good images: 
          * good tonal range (i.e. lots of highlights, shadows and midtones)
          * lots of long straight lines across the image (e.g. angular features if you're doing a face)
      * Characteristics of bad images: 
          * low contrast
          * large white / very bright patches
          * one side of the image is in shadow (this is an especially big problem with faces)
   1ii. Prepare an importance weighting (optional). This is recommended if your picture has a foreground or particular features that you want to emphasise. The importance weighting should be an edited version of the original (same size and format, no cropping). It should be greyscale, with black areas indicating the highest importance and white indicating the least importance. Here are a few tips on creating the importance weighting:
      * Beware of sharp lines in importance weightings, they can look a bit jarring. Unless your actual image has sharp lines in the same place, try to blur the edges of different sections of colour in importance weightings.
      * There is an option for having a different positive and negative importance weighting. I would recommend not using this feature unless strictly necessary, because it can lead to unforseen consequences with image quality. Generally, the only time I use different positive and negative weightings are when I want to make sure that a bright area (e.g. whites of eyes) is preserved, then I might make the positive weighting light on the eyes and the negative weighting dark (so the algorithm is fine with not drawing enough lines, but it is very reluctant from drawing too many). Even in these situations, I try to keep the positive and negative weightings very similar. 
      * Even if you care less about accuracy in the background, you should assign a small weighting too it. When I was rendering Churchill for the first time, I put 0 importance weighting on the background, and the bunching of vertical lines on either side of his face made it look like he had devil horns!

2. **LINE GENERATION**

   In this section, I have included an image of an example Jupyter Notebook, which was used to generate my image of Churchill. I will go through this example now, explaining each of the parameters involved.
   
   ![churchill_example_alg_1](https://user-images.githubusercontent.com/45238458/91828466-156cd880-ec38-11ea-9ff8-a959ce292afc.png)

   * The first cell has the size parameters: the real diameter of the wheels and width of the hooks you are using (in meters), the wheel pixel size (which is the side-length of the digital image you want to create), and the number of hooks you are using. If you're just creating digital art, I would recommend leaving these settings the same as the image above (this has the added advantage that all thread vertices are evenly spaced). If you are making it in real life, then you will need to change these settings so they are appropriate for the image you're creating. A few things to note:
       * You only need to run this cell once, and then you can run the cells below multiple times (with different images / parameters).
       * I chose wheel_pixel_size around 3500 for most of my images because this meant the thread was one pixel thick (based on the wheel_real_size of 0.58m and the thickness of the thread I was using). Therefore, if you are using a smaller frame than a bike wheel, I would recommend reducing wheel_pixel_size.
   * The second cell reads the images from your directories. Note that the second one has the argument weighting=True, which indicates it is an importance weighting (so all values should be scaled to between 0 and 1). You can also use the argument color=True, which means the saturation of the image is taken rather than the darkness, this is useful for some images (see the tiger for an example), but is not the way I ususally create colour images (see Joker or David Bowie lightning for an example of how I usually add colour).
   * The third cell displays the images. Note that I've included image_m twice, this is just because I prefer showing at least 3 images (the size is more manageable).
   * The fourth cell shows the actual algorithm being run. These are where all the most important parameters are, so I will describe each of them.
       * The first parameter is the image you are trying to reproduce.
       * **n_lines** is the total number of lines you want to draw. If you are doing this physically, I would recommend having this number no more than 3500 (because often the real-life thread looks a lot denser than the program output does). If you are just doing it digitally, then you should probably set this number higher. Note that the algorithm will eventually reach an equilibrium where it removes lines as fast as adding them, so in the case of digital art, don't worry about setting this much higher.
       * **n_random** is the number of random lines that are chosen at each step. Image quality is pretty poor if this goes below 50, but it doesn't improve much past 200, so I'd recommend somewhere in the middle. If you're experimenting then you can use lower numbers, but if you're producing a final piece then use higher numbers.
       * **darkness** is the quantity that is subtracted from the pixels when a line is drawn through them. Intuitively this should be 255, however in practice I've found smaller numbers work better, i.e. 150-200. The higher the number, the less lines are drawn.
       * **lightness_penalty** has already been discussed above. This has the same effect as darkness (if it is increased, less lines are drawn), but increasing this parameter will primarily reduce lines in already light areas, rather than reducing lines everywhere.
       * **w** is the image used as an importance weighting (discussed earlier). If using no importance weighting, leave out this argument. If your importance weighting is different for positive and negative penalties, replace this argument with w_pos=image_wpos, w_neg=image_wneg (where image_wpos and image_wneg are the importance weightings).
       * **line_norm_mode** has also already been discussed. There are 3 settings (N = 1, number of pixels, weighted sum), and you can choose these using the following keyword arguments: line_norm_mode = "none", "length", or "weighted length". For most images, length should suffice, but occasionally I've found that an unusual image works terribly with length and incredibly well with weighted length (the best example of this is Jack Nicholson from The Shining; try running this in "length" mode and see how terrible it is!).
   * The fifth cell allows you to save your plot as a jpg. The 1st argument is a list of lines (if you are using an image with colour, this list will have more than one element), the 2nd argument is a list of corresponding colours (using RGB colourspace), the 3rd is the file name, and the 4th is the plot size (in most cases, it makes sense for this to be the same size as wheel_pixel_size). 
   * The sixth cell allows you to save your plot at distinct points (which looks pretty cool!). It has the same arguments as the save_plot function, except for one more at the end: a list of proportions. For each number in this list, a jpg will be saved with that proportion of lines drawn (so in the example above, I'm saving at 20%, 40%, etc). The jpg file names are made by taking the file name you've given, and adding a corresponding percentage on the end of the name.
   The projects which use multiple colours have some added features, but I hope they should be pretty intuitive. If any of them aren't, please add this as an issue and I can put some extra detail into this section.
   If you are just creating digital art then you can finish here, if not then please read the next section for instructions on how to make the art physically.
   

3. **EULERIAN PATH**

    Below is an image of the cells you need to run to generate output. These cells are found at the end of each Jupyter Notebook. 
    
    ![churchill_example_alg_2](https://user-images.githubusercontent.com/45238458/91839842-a26b5e00-ec47-11ea-8c98-11403c187cbd.png)
    
    * The first cell finds a thread path through all the edges (this can take about a minute to run for the larger pieces), and prints out the total distance of the image (both in meters of thread, and number of lines). Note, the number of lines will be larger than the number in the program above, because more lines have to be added that go outside the wheel, to allow for a single unbroken path. 
    * The second cell displays the final instructions in the form I use for my threading (this is explained below).
    * The third cell performs a sanity-check by re-deriving the position of the edges from the output, reconstructing the original image, and saving it as a jpg (which by default is called reconstructed.jpg).

    To explain the output of the *edges_to_output* function, I will use a sample from my David Bowie project, as well as an image of the actual physical implementation:

    54-1

    141-0

    143-0 outside

    0-0

    123-1
    
![Thread-art David Bowie: real life](https://cdn-images-1.medium.com/max/400/1*dp_OT23-ZQATQz37lEmkcA.jpeg)

As the image shows, I have stuck numbers around the outside of the wheel, and marked blocks of 5 and 10 hooks with coloured pieces of tape (the red corresponds to hook numbers 0, 10, 20, etc). The tens digit (so 5, 14, 14, 0, 12 respectively in this example) tells me which number from 0-16 to go to, and the units digit specifies the exact hook. The number after the dash, either 0 or 1, specifies which side of the hook: 0 means the side clockwise from the centre of the hook, 1 means anticlockwise. The word "outside" indicates that the edge in question should go around the outside of the wheel, because it was only added to create a Eulerian path. Note that, as in the above example, these "outside" threads are usually very short - they have been purposefully designed this way - but usually there will be some very long ones as well, which is unavoidable.

# Algorithm Examples

In previous sections, I've described how to choose your own parameters and run your own program. However, there are lots of things to consider and it might feel a bit daunting, which is why I've included files of all the pieces I've made (at time of writing). Each file includes the Jupyter Notebook that I ran, the images that I used, and the Python output that was generated. You can try running these, tweaking some of the parameters, and so get an idea for how the algorithm works.

# Final thoughts

This project has been a wonderful experience for me - I loved seeing the way in which mathematics and art intersected. I was inspired by Petros Vrellis' artwork; please see his [website](http://artof01.com/vrellis/works/knit.html) for a much more professional job than mine! There are several directions I am considering taking this project in. One is to properly introduce colour, not just a single colour as a background like I've done so far (these have all been pretty simple conceptually, even the more creative ones like David Bowie). I might experiment with trying to minimise Eulerian distance between pixels in an RGB/CMYK colour space. I would also be very interested in moving from 2D to 3D; maybe by constructing pieces that you need to look at in exactly the right way for them to come into focus. For now though, I hope you enjoyed reading about my algorithm, and if you have any questions about it, please message me!

p.s. - This project has taken a huge amount of effort, and I've had to learn many new things, that each felt insurmountable at the time. I understand that many people struggle with technology just as much as I do, so if you really want to try this art in real life but haven't been able to get the algorithm working, please send me a message explaining your situation and I would be happy to help out, e.g. by giving advice on how to get it working.

Happy coding!
