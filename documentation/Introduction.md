The goal of `rsdp` is to analyze images acquired in the frame of the Focused Ion Beam-Digital Image Correlation (FIB-DIC) technique ([Korsunsky et al., 2010](https://doi.org/10.1016/j.surfcoat.2010.09.033)). The analysis process consists in (optionally) filtering the images, defining markers, analyzing the displacements of the markers, estimating the strain and finally calculating residual stress.
**Note**: I first designed this application to streamline the entire FIB-DIC analysis process. This means that it is mainly suited for my needs. However, I worked on making the interface as user-friendly as possible for other potential users.

Some of the functionalities presented here are based on a [previous DIC application](https://mathworks.com/matlabcentral/fileexchange/) developed in the frame of the [iStress project](https://cordis.europa.eu/project/id/604646) by Melanie Senn and Christoph Eberl. This original application allowed to analyze DIC markers and to calculate a value of residual stress for the entire volume milled. However, the code written at that time is presently outdated given the evolution of `MATLAB` from [GUIDE to App Designer](https://mathworks.com/products/matlab/app-designer.html). Moreover, the large number of user prompts made the whole analysis process quite clumsy. The application presented here brings some changes to the original code and includes the possibility to follow the evolution of residual stress over depth, i.e., residual stress depth profiling, based on code written by Enrico Salvati.
## General analysis process
A typical FIB-DIC analysis goes as follows:
1. Milling & image acquisition
2. Image processing (optional)
3. Strain analysis
    1. Markers definition
    2. Calculation of the displacements
    3. Manual removal of markers
    4. Strain calculation
4. Stress calculation (either for entire milled volume, or in depth)
5. Advanced functions (optional)
    1. Averaging of multiple residual stress profiles
    2. Comparison between curves

|                       |                Next section                 |
| --------------------- | :-----------------------------------------: |
| [Outline](Outline.md) | [Image acquisition](Image%20acquisition.md) |
