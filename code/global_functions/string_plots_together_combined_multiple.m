% Apply string_plots_together_combined_5_10.m to all samples in
% samplesPath.
% Author: Kento Takahashi
% Date of last edit: 17/04/2026

saving = false;

xAxisLowLimit = .2;
xAxisHighLimit = 2.1;

yAxisLowLimit = -inf;
yAxisHighLimit = inf;

% Change the following path if needed
samplesPath = uigetdir;

samples = dir(samplesPath);
samples = samples([samples.isdir]);
samples(strcmp({samples.name},'results')) = [];
for k = 1:length(samples)
    samplePath = fullfile(samples(k).folder,samples(k).name);
    string_plots_together_combined_5_10(saving,samplePath,xAxisLowLimit,xAxisHighLimit,yAxisLowLimit,yAxisHighLimit)
end

