% Plot all results, 5 and 10 µm pillar diameters separated.
% A weighted average can be computed between 0.5 and 1 µm, either linear or adjusted to the
% sensitivity function.
% Author: Kento Takahashi
% Last edit: 18/09/2026

%% Paths
rootPath = 'I:\PhD_IDrive\exp\FIB-DIC\dataFIB\DoE'; % Folder containing the results for all samples.
dirs = dir(fullfile(rootPath, 't2*'));

%% Options
saving = 1;
polyFitOption = 0;
polyDegree = 3;
weightedMeanOption = 0;
weightedMeanType = "linear"; % "linear" or "sensitivity"

% Axes limits
xAxisLimits = [.2 2.1];
yAxisLimits = [-750 150];

%% Plot
for directory = 1:length(dirs)
    samplePath = fullfile(dirs(directory).folder, dirs(directory).name);
    savingPath = fullfile(samplePath,'results');
    if weightedMeanOption
        plots_5_10_weighted(samplePath,weightedMeanType,saving,savingPath,xAxisLimits,yAxisLimits)
    else
        plots_5_10_separated(samplePath,saving,savingPath,polyFitOption,polyDegree,xAxisLimits,yAxisLimits);
    end
end
