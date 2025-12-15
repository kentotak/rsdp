# Depth profiling application Guidebook
## Functions overview
The here presented application is the continuation of an [application developed](https://mathworks.com/matlabcentral/fileexchange/) in the frame of the [iStress project](https://cordis.europa.eu/project/id/604646) by Melanie Senn and Christoph Eberl. On top of containing the same functions as the original application, it extends the residual stress analysis to include its complete depth profiling, i.e., the evolution of residual stress as a function of depth.

The application is largely based off the work of Enrico Salvati, who provided the native Matlab codes. The end goal was to streamline the depth profiling process for multiple pillars.

## Files structure
The general structure of files is shown in the following tree:
```
sample
└───pillar
    └───series1
        ├───raw
        │   └───x
        │   └───y*
        │   └───45*
        ├───processed**
        │   └───x
        │   └───y*
        │   └───45*
        └───results**
            └───depth_profiling**
```
\* Optional directories.  
\** These directories will be created automatically after relevant functions have been executed or if they already exist.

The 'workfolder' shown below is the directory where all modified files are located, such as the analyzed images and the DIC files. It is generally located in `/sample/pillar/series/processed/x` (or `/y` or `/45`, see [Data selection](#data-selection)).

<table>
    <tr>
        <td style="width:45%"><img src="./images/workfolder.png"></td>
        <td></td>
    </tr>
</table>


## Tab by tab description
### Data selection
The data selection tab allows the user to choose the directory where the raw images for one pillar are located. If a *Series directory* is selected, then the parent directory and its (grand-)parent directory are selected as well, which are named *Pillar directory* and *Sample directory* respectively.

The direction of the images can also be chosen, depending on if the user made SEM images of the pillar in the $x$, $y$, and/or 45° direction(s).

<table>
    <tr>
    <td style="width:45%"><img src="./images/tab-data_selection.png"></td>
    <td><img src="./images/parameters-data_selection.png"></td>
    </tr>
</table>

Selecting the data will also change the [workfolder](#files-structure) accordingly.

### Image processing
Image processing functions are disabled by default. They take a Fiji path and a series in input (see [Data selection](#data-selection)). The former can be selected in `File -> Fiji path`. This path is then automatically selected every time the user opens the application. The user is prompted to select a Fiji path if they have not selected a path to Fiji (this includes the first use of the application).

The original DIC application provided a certain amount of filters to apply on the SEM images. Here, the images are cropped to remove the bottom label from SEM images according to the image dimensions input by the user. Then, two image processing options are included:
- Image registration using StackReg: This aligns all the images according to the procedure described by [Thévenaz et al.](https://bigwww.epfl.ch/publications/thevenaz9801.html)
- Intensity averaging: This averages the grayscale level of each pixel over a number of images given by the user. This type of processing is recommended in the [FIB-DIC Good practice guide](https://eprintspublications.npl.co.uk/7807/).

<table>
    <tr>
        <td style="width:45%"><img src="./images/tab-image_processing.png"></td>
        <td><img src="./images/parameters-image_processing.png"></td>
    </tr>
</table>

### Digital Image Correlation
This part of the analysis comprised three steps as in the original DIC application, namely:

1. File list creation
2. Correlation processing
3. Displacement analysis

Those steps were kept the same here, with less prompts to the user. For example, the file list parameters window shown below makes it easier to create a file list for multiple series in a row by reducing the number of prompts to the user. The same principle applies to the process correlations parameters.

<table>
    <tr>
        <td style="width:45%"><img src="./images/tab-dic.png"></td>
        <td>
    </tr>
    <tr>
        <td><img src="./images/parameters-file_list.png"></td>
        <td><img src="./images/parameters-process_correlations.png"></td>
    </tr>
</table>

The displacement analysis application was slightly changed as it was noted that the markers selection controls did not appear before.

<table>
    <tr>
        <td style="width:100%"><img src="./images/app-displacement_analysis.png"></td>
        <td></td>
    </tr>
</table>

### Depth profiling
Three types of depth profiling are possible, depending on the type of stress expected in the material:
- Equibiaxial: Implies that all stresses are random. Therefore, they should all be equal no matter where pillars were milled in the sample. This type of depth profiling only requires one strain file, that can be browsed in *Strain in $x$ direction*.
- Non-equibiaxial: Implies that a difference is expected between the $x$ and $y$ directions. Two strain files are required in this case. They can be obtained by the analysis of one set of images in $x$, then rotated and analyzed in $y$, or by analyzing two sets of images.
- Full field: Allows to obtain the evolution of residual stress as a function of depth, in any direction (see [Salvati et al., 2019](https://doi.org/10.1016/j.jmps.2019.01.007)). Three strain files are required. It is possible to rotate the images to 45° using the image processing functions (see [Image processing](#image-processing)).

The user can also adjust parameters for depth profiling:
- Milling parameters (mandatory)
- Material properties (mandatory)
- Plot options:
    - $x$ axis data: choose whether to plot the residual stress as a function of depth (in µm) or of normalized depth (i.e., depth divided by pillar diameter).
    - Limits of the $x$ axis (depth or normalized depth) and of the $y$ axis (stress, in MPa)
- Strain curve smoothing parameters: A smoothing of strain is carried out before stress calculations (see [Korsunsky et al., 2018](https://doi.org/10.1016/j.matdes.2018.02.044)). The method used is a moving fitting of a number of points by a polynomial function. Both the points span and polynomial degree are changeable by the user. The depth profiling generates a strain curve and its associated smoothed curve so that the user can test those parameters.
- DIC parameters: It is possible to change the pillar reduction factor, which is set during the DIC analysis. 

<table>
    <tr>
        <td style="width:45%"><img src="./images/tab-dp.png"></td>
        <td><img src="./images/parameters-dp.png"></td>
    </tr>
</table>

### Averaging
The functions described here were specifically developed for the analysis of multiple series of pillar milling.

Averaging takes multiple series in input from the *Pillar directory* path (see [Data selection](#data-selection)) and averages the values of residual stress. Standard deviation is also plotted from this averaging.

Stringing allows to plot multiple averaged curves one after the other. The *Succession* option plots all data for one pillar diameter, stops at the last numerical value and plots the next pillar diameter. The *Combination* option will average the plots of two pillar diameters.

<table>
    <tr>
        <td style="width:45%"><img src="./images/tab-averaging.png"></td>
        <td>
            <figure>
                <img src="./images/parameters-averaging.png">
                <figcaption> Averaging parameters </figcaption>
            </figure>
        </td>
        <td>
            <figure>
                <img src="./images/parameters-stringing.png">
                <figcaption> Stringing parameters </figcaption>
            </figure>
        </td>
    </tr>
</table>

### Comparison
The user can compare two samples for one pillar diameter, or entirely.
<table>
    <tr>
        <td style="width:45%"><img src="./images/tab-compare.png"></td>
        <td><img src="./images/parameters-comparison.png"></td>
    </tr>
</table>
