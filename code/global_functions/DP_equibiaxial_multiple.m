function DP_equibiaxial_multiple(samplePath, stepSize, pillarRedFactor, elasticModulus, poissonRatio, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, pointsSpan, polynomialDegree, normalizedDepthLimits, fontName, fontSize)
    % Apply DP_equibiaxial.m to all series of pillar diameter 5 and 10 µm in samplePath.
    % Author: Kento Takahashi - KU Leuven

    arguments
        samplePath string {mustBeFolder}
        stepSize double
        pillarRedFactor (1,1) double
        elasticModulus (1,1) double
        poissonRatio (1,1) double
        saving (1,1) logical = 0
        scanDirection (1,1) double = 0
        xAxisData string = "normalizedDepth"
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        pointsSpan (1,1) double = 6
        polynomialDegree (1,1) double = 3
        normalizedDepthLimits (1,2) double = [.05 .2]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    addpath(fullfile('..', 'depth_profiling'))
    
    pillarDiameters = [5, 10];

    % Loop on samples
    pillarDirs = dir(fullfile(samplePath, '*um_pillar'));
    
    for pillar = 1:numel(pillarDiameters)
        pillarDiameter = pillarDiameters(pillar);
        pillarPath = fullfile(pillarDirs(pillar).folder, pillarDirs(pillar).name);
        seriesDirs = dir(fullfile(pillarPath, 'series*'));
        
        for series = 1:length(seriesDirs)
            seriesPath = fullfile(pillarPath, seriesDirs(series).name);
            strainPath = fullfile(seriesPath, 'processed', '0');
            strainFile = fullfile(strainPath, 'eulerianstraintruex.dat');
            [~, seriesName] = fileparts(seriesPath);

            DP_equibiaxial(seriesPath, strainFile, pillarDiameter, stepSize, pillarRedFactor, elasticModulus, poissonRatio, saving, seriesName, scanDirection, xAxisData, xAxisLimits, yAxisLimits, pointsSpan, polynomialDegree, normalizedDepthLimits, fontName, fontSize)
        end
    end
end