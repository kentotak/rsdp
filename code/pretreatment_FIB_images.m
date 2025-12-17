% This script pre-treats a stack of raw images and averages them
% Author: Kento Takahashi
% Date of last change: 04/12/2025

function pretreatment_FIB_images(fijiPath,seriesPath,imagesDirection,saving,width,height,rotation,filter1,filter2,nbImagesStep)
    try
        run(fullfile(fijiPath,'scripts','Miji.m'))
    catch
        return
    end

    %% Parameters
    xCrop = 0;
	yCrop = 0;

    %% Files
    rawDir = fullfile(seriesPath,"raw",imagesDirection);
    fileList = dir(rawDir);
    numImages = length(fileList);

    % 
    if rotation == 0
        processedDir = fullfile(seriesPath,"processed","x");
    elseif rotation == 90
        processedDir = fullfile(seriesPath,"processed","y");
    else
        processedDir = fullfile(seriesPath,"processed","45");
    end

    if ~exist(processedDir, 'dir')
            mkdir(processedDir)
    end

    %% Image processing
    MIJ.run("Image Sequence...",sprintf("dir=[%s] filter=[tif]",rawDir))

    % Crop
    MIJ.run('Specify...',sprintf('x=%d y=%d width=%d height=%d',xCrop,yCrop,width,height))
    MIJ.run('Crop')

    % Correlations processing shows the evolution of markers only if the images are in 8 bits
    MIJ.run('8-bit')
    
    % Rotation
    if rotation == 45
        MIJ.run('Rotate...', 'angle=45');
    elseif rotation == 90
        MIJ.run('Rotate 90 Degrees Left')
    end

    % Applying selected filters    
    if strcmp(filter1,'Image registration (alignment)')
        MIJ.run('StackReg ','transformation=[Rigid Body]')
    elseif strcmp(filter1,'Intensity averaging')
        MIJ.run("Grouped Z Project...", sprintf("projection=[Average Intensity] group=%d",nbImagesStep))
    end

    if strcmp(filter2,'Image registration (alignment)')
        MIJ.run('StackReg ','transformation=[Rigid Body]')
    elseif strcmp(filter2,'Intensity averaging')
        MIJ.run("Grouped Z Project...", sprintf("projection=[Average Intensity] group=%d",nbImagesStep))
    end
    
    %% Saving images
    baseName = regexprep(fileList(numImages).name,'[0-9]{3}\.[^\.]*$','');
    
    if saving == true
        MIJ.run('Image Sequence... ',sprintf('dir=[%s] format=TIFF name=%s digits=3',processedDir,baseName))
    end

    %% Close
    MIJ.run('Close All')

    MIJ.exit