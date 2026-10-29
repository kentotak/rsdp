function averaging_all_pillars_all_samples(doePath, showPlotsOption, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, individualPlotsOption, normalizedDepthLimits, fontName, fontSize)
    % Apply averaging_1_pillar.m to the 5 and 10 µm pillar diameter folders for one sample.
    % Author: Kento Takahashi - KU Leuven
    
    arguments
        doePath string {mustBeFolder}
        showPlotsOption (1,1) logical = 0
        saving (1,1) logical = 0
        scanDirection (1,1) double = 0 % 0, 45 or 90
        xAxisData string = "normalizedDepth" % "normalizedDepth" or "depth"
        xAxisLimits (1,2) double = [-inf inf] % [] or [µm]
        yAxisLimits (1,2) double = [-inf inf] % [MPa]
        individualPlotsOption (1,1) logical = 0
        normalizedDepthLimits (1,2) double = [.05 .2] % []
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end
    
    addpath(fullfile('..', '..', 'additional_functions'))
    
    samplesDirs = dir(fullfile(doePath, 't*'));
    samplesDirs = samplesDirs([samplesDirs.isdir]);
    
    for sample = 1:numel(samplesDirs)
        samplePath = fullfile(samplesDirs(sample).folder, samplesDirs(sample).name);
        averaging_all_pillars_1_sample(samplePath, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, individualPlotsOption, normalizedDepthLimits, fontName, fontSize)
        if showPlotsOption == 0
            close all
        end
    end
end