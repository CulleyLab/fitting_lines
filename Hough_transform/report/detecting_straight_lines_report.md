---
output:
  html_document: default
  pdf_document: default
---
# Detecting and measuring straight lines

The aim of this stage of the summer project was to detect straight microtubules in microscopy images. Skeletonisation, linear regression, and the linear Hough transform offered distinct advantages and disadvantages. 

## Library preparation

I created a small library of 128x128 pixel images featuring single and multiple straight, curved, intersecting, and other lines which could be further subdivided. To automate sorting the manually curated ROIs, I wrote some ImageJ macros. 

Workflow: select ROIs $\rightarrow$ sort stacks $\rightarrow$ sort substacks

## Skeletonisation

Workflow: Gaussian blur $\sigma = 0.75$ $\rightarrow$ threshold (Autothreshold, triangles (originally used for chromatid segmentation)) $\rightarrow$ erode $\rightarrow$ skeletonise

Advantages: 
- can be performed easily automated in ImageJ 
- is relatively simple 
- for single, straight and curved lines, the line endponts and length can be obtained directly from the skeletonised images 

Disadvantages: 
- requires thresholding to binarise images
    - this works poorly for ROIs in the center and periphery of an image, as they are illuminated differently 
- the erosion step can sometimes break up lines
- the skeletonisation step performs poorly for parallel lines which are close together or for intersecting lines
- there is more than one way of obtaining satisfactory results; all rely on tuning one or more parameters
- labelling fails for intersecting lines

## Linear regression

Linear regression was considered briefly and in comparison to the linear Hough transform. Regression was only performed on single straight lines. 

Advantages: 
- in addition to the advantages above, linear regression can, in theory, detect intersecting lines in skeletonised images

Disadvantages: 
- requires binarised images as input
- cannot detect vertical lines
- could fail with greater number of lines

## Hough transform

The Hough transform was implemented to handle both raw and skeletonised data. 

Workflow: apply Hough transform on raw/skeletonised image $\rightarrow$ convert parameters from polar Hough space back to Cartesian coordinates for visualisation and measurements $\rightarrow$ obtain line intensity profiles for all detected lines $\rightarrow$ discard false positives $\rightarrow$ determine end-points of true lines 

Advantages: 
- can work with raw and skeletonised data alike
    - working with raw data ensures no information is lost to processing 
- requires little to no data preprossesing (save for normalisation)
- can detect intersecting and vertical lines

Disadvantages: 
- thresholding is required to detect the peaks of multiple lines in Hough space  
- in raw images, phantom lines and noise are detected by the local maximum detection algorithm 
    - therefore, the detected lines need to be curated further to obtain the correct number of lines in an image
- line endpoints (and therefore line lengths) are not immediately apparent and require additional data processing too


### Linear regression vs linear Hough transform for one straight line in a skeletonised image

![](../report/figs/ht_vs_lin_reg.png?raw=true "lin reg vs hough transf")


There is a slight (and practically negligible) difference in the deteceted lines. Whereas linear regression minimises the square of all residuals, the Hough transform gives more weight to points which lie on the same straight line (which result in more intersecting curves in Hough space and a more incremented accumulator). Linear regression would not be able to handle vertical lines.

### Detect multiple lines in skeletonised and raw data using local maxima detection algorithm

![](../report/figs/phantom_lines.png?raw=true "skeletonised")

![](../report/figs/phantom_lines_raw.png?raw=true "raw")

Deciding on a suitable max_dist parameter for `peak_local_max()` is challenging, as $\theta$ and $\rho$ are anisotropic and specify different distances. In addition to phantom lines (in brown), multiple lines lying on or close to a given line are detected. 

### Anisotropic characteristics of $\theta$ and $\rho$ in polar Hough space

Varying $\theta$ and $\rho$ has different effects on the detected lines in Cartesian space. 

![](../report/figs/var_rho_theta.png?raw=true "var rho theta")

There was a faint attempt to explore the behaviour of the `min_distance` parameter, but the results of varying `min_distance` were not straightworward to interpret and generalise to more line detection cases... 

![](../report/figs/min_dist.png?raw=true "var min")

### Obtaining line profiles to narrow the detected lines down to true lines

![](../report/figs/line_profs.png?raw=true "line profiles")

The intensity profiles of all detected lines showed that while the profiles of all lines were unique, they all shared at least one peak which was approximately Gaussian, corresponding to brighter pixels. 

This could be exploited along with the tendecy of the Hough transform to connect bright spots in images. Thereore, all line profiles with `n_peaks > 1` (from `peak_local_max()`) were discarded. 

Fitting a Gaussian curve to the intensity profiles allowed for the peaks to be further selected via `sigma < threshdold`. 

![](../report/figs/line_profs_individual.png?raw=true "line profiles and Gaussians")

### Final steps: curating lines along the same true line (and plotting them correctly)

While the results to far are encouraging, I am still struggling with multiple lines along the same true line. 

They can be identified via similar `sigma` values and because they will have one solution as a system of linear equations. The angle of the crossing lines could be used to select a better, final line (not necessarily originally detected by transform).  

I am also struggling to translate the indecies of the line lengths along the intensity profile back into Cartesian coordinates (but getting there!)

![fig5](../report/figs/sofarsobad.png?raw=true "sofarsobad")
