function pretreatment_FIB_images(fijiPath,seriesPath,scanDirection,saving,imgFormat,cropOption,width,height,rotation,filter1,filter2,nbImagesStep)
    % This function applies a series of filters on a stack of images.
    % Written for rsdp.
    % Author: Kento Takahashi -  KU Leuven
    % Date of last change: 23/10/2026 (minor changes)
    
    try
        run(fullfile(fijiPath,'scripts','Miji.m'))
    catch
        return
    end

    %% Parameters
    xCrop = 0;
	yCrop = 0;

    %% Files
    rawDir = fullfile(seriesPath,"raw",num2str(scanDirection));
    fileList = dir(rawDir);
    fileList = fileList(~strcmpi({fileList.name},'thumbs.db'));
    numImages = length(fileList);

    % Import stack depending on value of rotation
    processedDir = fullfile(seriesPath, 'processed', num2str(rotation));

    if ~exist(processedDir, 'dir')
        mkdir(processedDir)
    end

    %% Image processing
    MIJ.run("Image Sequence...",sprintf("dir=[%s] filter=[%s]",rawDir,imgFormat))

    % Crop
    if cropOption
        MIJ.run('Specify...',sprintf('x=%d y=%d width=%d height=%d',xCrop,yCrop,width,height))
        MIJ.run('Crop')
    end

    % Correlations processing only shows the evolution of markers if the images are in 8 bits
    MIJ.run('8-bit')
    
    % Rotation
    if rotation == 45
        MIJ.run("Rotate... ", "angle=-45 grid=1 interpolation=Bilinear stack");
    elseif rotation == 90
        MIJ.run('Rotate 90 Degrees Left')
    end

    % Applying selected filters
    switch filter1
        case 'Image registration (alignment)'
            MIJ.run('StackReg ','transformation=[Rigid Body]')
        case 'Intensity averaging'
            MIJ.run("Grouped Z Project...", sprintf("projection=[Average Intensity] group=%d",nbImagesStep))
    end

    switch filter2
        case 'Image registration (alignment)'
            MIJ.run('StackReg ','transformation=[Rigid Body]')
        case 'Intensity averaging'
            MIJ.run("Grouped Z Project...", sprintf("projection=[Average Intensity] group=%d",nbImagesStep))
    end

    %% Saving images
    baseName = regexprep(fileList(numImages).name,'[0-9]{3}\.[^\.]*$','');
    
    if saving
        switch imgFormat
            case {'tif','tiff'}
                imgFormatSaving = 'TIFF';
            case 'bmp'
                imgFormatSaving = 'BMP';
            case {'jpg','jpeg'}
                imgFormatSaving = 'JPEG';
            case 'png'
                imgFormatSaving = 'PNG';
        end
        MIJ.run('Image Sequence... ',sprintf('dir=[%s] format=%s name=%s digits=3',processedDir,imgFormatSaving,baseName))
    end

    %% Close & Exit
    MIJ.run('Close All')
    MIJ.exit
end