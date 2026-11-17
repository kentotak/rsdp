# Case 1: Equibiaxial stress state
Only one set of images is needed in this case.

- During image acquisition, save your images to `sample/pillar/series/raw/0`.
- Set the saving button to `On` if you want your results to be saved.
- Go to the *Data selection* tab.
  - Select your series with the `Browse` button.
  - Set the scan direction to 0°.
- Go to the *Image processing* tab.
  - In the options:
    - Indicate the format of your images.
    - Crop to the dimensions of your images if you need to remove the bottom label.
    - Set the rotation of the images to *None*.
    - Apply relevant filters if needed.
  - Press `Process stack`.
- Go to the *Digital Image Correlation* tab.
  - Generate a file list.
    - In the file list options, indicate whether you want it to be created automatically or manually. If you set this option to manual, indicate the set of images you want to analyze by filling the fields accordingly.
    - Press `Generate file list`.
    - You should see a confirmation that the file list has been created in the message box below the work folder.
  - Create markers and process correlations.
    - Change parameters if needed.
    - Press `Process correlations`.
  - Press `Displacement analysis`.
    - Filter out markers that seem like outliers, using the functions in `Markers -> Clean`.
    - Create a strain file using the functions in `Strain analysis`.
- Go to the *Depth profiling* tab.
  - In the parameters:
    - Set the stress state to `Equibiaxial`.
    - Import the strain file you obtained through the DIC analysis earlier.
    - Indicate the different parameters related to the milling geometry and the properties of your material. If the properties of your sample vary in depth, you can also import a csv file.
    - You can vary the smoothing parameters (used during depth profiling) and the DIC parameters (depends on how you defined your markers during the DIC analysis).
  - Press `Depth profiling`.
- Additional functions:
  - Average multiple profiles if needed.
  - You can also compare your profile to other profiles using the comparison function.
# Case 2: Biaxial stress state with principal directions at 0° and 90°, only one set of images
If the user only has one set of images in the 0° direction, then they can either create new images by rotating the set and performing the full analysis on the new rotated set, or by rotating the markers in the DIC application and performing the strain analysis on those markers.

|      Previous section       |                       |     |
| :-------------------------: | --------------------- | --- |
| [Comparison](Comparison.md) | [Outline](Outline.md) |     |
