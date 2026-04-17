% Apply DP_equibiaxial.m to all series of pillar diameter 5 and 10 µm for all samples in samplesPath.
% Author: Kento Takahashi
% Date of last edit: 17/04/2026

addpath('..')

% The following parameters are explained in DP_equibiaxial.m
saving = false;

scanDirection = 0;
stepSize = .125;
pillarRedFactor = .8;
xAxisData = 'Normalized depth';
normalizedDepthLowLimit = 0.05;
normalizedDepthHighLimit = .2;

xAxisLowLimit = normalizedDepthLowLimit-.01;
xAxisHighLimit = normalizedDepthHighLimit+.01;

yAxisLowLimit = -inf;
yAxisHighLimit = inf;

pointsSpan = 6;
polynomialDegree = 3;

elasticModulus = 120;
poissonRatio = .36;

% Change this
samplesPath = uigetdir;

% Loop on samples
samples = dir(samplesPath)
samples = samples([samples.isdir]);
samples(strcmp({samples.name},'results')) = [];
for k = 1:length(samples)
    pillarPath = fullfile(samples(k).folder,samples(k).name,'05um_pillar');
    pillarDiameter = 5;
    series = dir(pillarPath);
    for i = 1:length(series)
        if series(i).isdir && ~startsWith(series(i).name, '.') && ~strcmp(series(i).name,'results')
            seriesPath = fullfile(pillarPath, series(i).name);
            path = fullfile(seriesPath,'processed','0');
            strainFile = fullfile(path,'eulerianstraintruex.dat');
            [~,seriesName] = fileparts(seriesPath);
            DP_equibiaxial(saving,seriesName,seriesPath,strainFile,scanDirection,pillarDiameter,stepSize,pillarRedFactor,xAxisData,xAxisLowLimit,xAxisHighLimit, ...
                yAxisLowLimit,yAxisHighLimit,pointsSpan,polynomialDegree,elasticModulus,poissonRatio,normalizedDepthLowLimit,normalizedDepthHighLimit)
        end
        close all
    end

    pillarPath = fullfile(samples(k).folder,samples(k).name,'10um_pillar');
    pillarDiameter = 10;
    series = dir(pillarPath);
    for i = 1:length(series)
        if series(i).isdir && ~startsWith(series(i).name, '.') && ~strcmp(series(i).name,'results')
            seriesPath = fullfile(pillarPath, series(i).name);
            path = fullfile(seriesPath,'processed','0');
            strainFile = fullfile(path,'eulerianstraintruex.dat');
            [~,seriesName] = fileparts(seriesPath);
            DP_equibiaxial(saving,seriesName,seriesPath,strainFile,scanDirection,pillarDiameter,stepSize,pillarRedFactor,xAxisData,xAxisLowLimit,xAxisHighLimit, ...
                yAxisLowLimit,yAxisHighLimit,pointsSpan,polynomialDegree,elasticModulus,poissonRatio,normalizedDepthLowLimit,normalizedDepthHighLimit)
        end
        close all
    end
end
