function averaging_all_pillars_1_sample(samplePath, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, individualPlotsOption, normalizedDepthLimits, fontName, fontSize)
    % Apply averaging_1_pillar.m to the 5 and 10 µm pillar diameter folders for one sample.
    % Author: Kento Takahashi - KU Leuven

    arguments
        samplePath string {mustBeFolder}
        saving (1,1) logical = 0
        scanDirection (1,1) double = 0
        xAxisData string = "normalizedDepth" % "normalizedDepth" or "depth"
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        individualPlotsOption (1,1) logical = 0
        normalizedDepthLimits (1,2) double = [.05 .2]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    addpath(fullfile('..', '..', 'additional_functions'))
    
    pillarDiameters = [5, 10];
    pillarDirs = dir(fullfile(samplePath, '*um_pillar'));    

    for pillar = 1:numel(pillarDiameters)
        pillarPath = fullfile(pillarDirs(pillar).folder,pillarDirs(pillar).name);
        averaging_1_pillar(pillarPath, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, individualPlotsOption, normalizedDepthLimits, fontName, fontSize)
    end
end