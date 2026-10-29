function merge_plots_weighted_all_samples(doePath, weightingType, showPlotsOption, saving, xAxisLimits, yAxisLimits, fontName, fontSize)
    % Apply merge_plots_weighted.m to all samples in a folder.
    % Author: Kento Takahashi - KU Leuven
    
    arguments
        doePath string {mustBeFolder}
        weightingType string = 'linear' % 'linear' or 'sensitivity'
        showPlotsOption (1,1) logical = 0
        saving (1,1) logical = 0
        xAxisLimits (1,2) double = [-inf inf] % [] or [µm]
        yAxisLimits (1,2) double = [-inf inf] % [MPa]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end
    
    addpath(fullfile('..', '..', 'additional_functions', 'merging'))

    samplesDirs = dir(fullfile(doePath, 't*'));
    samplesDirs = samplesDirs([samplesDirs.isdir]);

    for sample = 1:numel(samplesDirs)
        samplePath = fullfile(samplesDirs(sample).folder, samplesDirs(sample).name);
        savingPath = fullfile(samplePath, 'results');
        merge_plots_weighted(samplePath, weightingType, saving, savingPath, xAxisLimits, yAxisLimits, fontName, fontSize)
        if showPlotsOption == 0
            close all
        end
    end
end