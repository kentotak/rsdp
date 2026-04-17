% Apply averaging_1_pillar.m to all 5 and 10 µm diameter pillars folders
% for all samples in samplesPath.
% Author: Kento Takahashi
% Date of last edit: 17/04/2026

addpath('..')

saving = false;

scanDirection = 0;
normalizedDepthLowLimit = 0.05;
normalizedDepthHighLimit = .2;

xAxisLowLimit = normalizedDepthLowLimit-.01;
xAxisHighLimit = normalizedDepthHighLimit+.01;

yAxisLowLimit = -inf;
yAxisHighLimit = inf;

indidualPlotsOption = false;

samplesPath = uigetdir;
samples = dir(samplesPath);
samples(strcmp({samples.name},'results')) = [];
samples = samples([samples.isdir]);
for k = 1:length(samples)
    pillarPath = fullfile(samples(k).folder,samples(k).name,'05um_pillar');
    pillarDiameter = 5;
    averaging_1_pillar(saving, pillarPath, pillarDiameter, xAxisLowLimit, xAxisHighLimit, yAxisLowLimit, yAxisHighLimit, indidualPlotsOption, ...
        scanDirection,normalizedDepthLowLimit,normalizedDepthHighLimit)

    pillarPath = fullfile(samples(k).folder,samples(k).name,'10um_pillar');
    pillarDiameter = 10;
    averaging_1_pillar(saving, pillarPath, pillarDiameter, xAxisLowLimit, xAxisHighLimit, yAxisLowLimit, yAxisHighLimit, indidualPlotsOption, ...
        scanDirection,normalizedDepthLowLimit,normalizedDepthHighLimit)
end

