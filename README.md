# computational-thread-art

This project contains code that renders an image as a series of lines connecting pins around a circular frame. For more detail in the physical implementation of these pieces, see my Medium page. This repository contains 2 Python scripts:

* **alg_bare** only contains the bare essentials to run the algorithm and generate your own computational pieces. For instructions on exactly how to run the algorithm, see below.
* **alg_full** contains all the same elements as alg_bare, but includes a detailed description of how each part of the code works (so you can make your own modifications if desired).

# Basic description of algorithm

# How to run alg_bare

1i. Have an image (either jpeg or pdf) stored in your current working directory. It must be square in size (if it isn't, it will be squashed into shape). Here are a few tips on choosing and preparing the image:
* Generally, images with high contrast work better, but only up to a point: if there are lots of very dark and very light areas, 
* If your image has a background, make sure that it is noticably different in brightness from the foreground. For instance, when preparing portrait images, I sometimes find it helpful to appy a radial gradient to the background, so that it is lighter at the edges of the face, but mid-tone further out. This leads to another point - make sure there is a change in brightness wherever your image has a significant border.
* Convert it to black and white first. This isn't strictly necessary because the algorithm does this anyway, but it is useful to get a good idea of what the final output will look like.
* Keep in mind that a circular portion of the image will be rendered, not the whole image.
* Having a very high resolution image isn't actually as important as you might think. 500px\*500px will usually suffice (although the higher the better).

1ii. Prepare an importance weighting (optional). This is recommended if your picture has a foreground that you want to emphasise. The importance weighting should be an edited version of the original (same size and format, no cropping!). The areas you want most detail on should be painted black, and the other areas should be given a greyscale value representative of the level of detail you require. Here are a few tips on creating the importance weighting:
* A vignette can improve the image, by allowing the algorithm to put more detail in the centre of the image. Be sure this happens the right way around (i.e. brighter as you get further out), because most vignettes will automatically be darker at the borders instead!
* Be wary of making the background completely white, because this can have unforseen side effects, such as a number of lines bunching in certain areas. In previous designs of mine based on portrait photos, this has resulted in the appearance of devil horns, due to the accumulation of vertical lines on the edges of faces!

2. Decide on your parameters. There are several important parameters that can be tweaked, I will go through each one in detail below, explaining what it does, and how to set it optimally.
* **size** is the length of the image that the algorithm uses, in pixels. I recommend choosing the appropriate size to make your thread width be 1 pixel: for instance, the thread I use is 0.15mm, the bike wheels I use have a diameter of 58cm, so I usually default to a size of 580/0.15 = 3867 (to the nearest integer).
* **
* **darkness** determines what scalar value to subtract from the pixels that a line goes through (so it is always between 0 and 255). A higher value will mean less lines are drawn overall. This will impact light and dark areas reasonably equally. Although every image is different, I have found values in the range 140-160 to be reasonable.
* **lightness_penalty** determines the ratio (penalty for drawing too many lines)/(penalty for not drawing enough). To elaborate, I described in the *basic description* section how my algorithm takes the sum of absolute values of pixels - in reality, this was a simplification. My algorithm takes the sum of the positive pixels, plus the absolute sum of the negative pixels *multiplied by lightness_penalty*. For instance, a lightness_penalty of 0 would mean that any line will be drawn as long as it goes over a pixel with a still-positive value, whereas 1 would mean a line is only drawn if it goes over more "still dark" areas than "still light" areas. For the average image, I would recommend starting with a value of 0.3-0.4, but this may vary - in particular, if your image is mostly an outline with a white background, then you will need a very low lightness penalty, maybe as low as 0.1.

3. Run the algorithm. The code for this (which is highlighted in **alg_bare** is as follows:




Tips on tweaking parameters
* If you are deciding between 2 renderings, one with more threads and one with less, err on the side of less: I have found that many pyhsical implementations look much darker than their computer renderings. If you are using a bike wheel-sized frame (so ~60cm diameter), as a rule of thumb, 4500-5000 threads (pre-Eulerian path generation) should be plenty, and sometimes around 1500-2000 will suffice (of course this will vary based on the image).
