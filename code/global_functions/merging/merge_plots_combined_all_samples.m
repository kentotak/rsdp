function merge_plots_combined_all_samples(doePath, showPlotsOption, saving, xAxisLimits, yAxisLimits, fontName, fontSize)
    % Apply merge_plots_combined.m to all samples in a folder.
    % Author: Kento Takahashi - KU Leuven
    
    arguments
        doePath string {mustBeFolder}
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
        merge_plots_combined(samplePath, saving, xAxisLimits, yAxisLimits, fontName, fontSize)
        if showPlotsOption == 0
            close all
        end
    end
end