function DP_equibiaxial_all_series_all_samples(doePath, stepSize, pillarRedFactor, elasticModulus, poissonRatio, showPlotsOption, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, pointsSpan, polynomialDegree, normalizedDepthLimits, fontName, fontSize)
    % Apply DP_equibiaxial.m to all series of pillar diameter 5 and 10 µm af all samples in doePath.
    % Author: Kento Takahashi - KU Leuven

    arguments
        doePath string {mustBeFolder}
        stepSize double % [µm]
        pillarRedFactor (1,1) double
        elasticModulus (1,1) double % [MPa]
        poissonRatio (1,1) double % []
        showPlotsOption (1,1) logical = 0
        saving (1,1) logical = 0
        scanDirection (1,1) double = 0 % 0, 45 or 90
        xAxisData string = "normalizedDepth" % 'normalizedDepth' or 'depth'
        xAxisLimits (1,2) double = [-inf inf] % [] or [µm]
        yAxisLimits (1,2) double = [-inf inf] % [MPa]
        pointsSpan (1,1) double = 6
        polynomialDegree (1,1) double = 3
        normalizedDepthLimits (1,2) double = [.05 .2] % []
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end
    
    addpath(fullfile('..', 'depth_profiling'))
    
    % Loop on samples
    samplesDirs = dir(fullfile(doePath, 't*'));
    samplesDirs = samplesDirs([samplesDirs.isdir]);
    
    for sample = 1:numel(samplesDirs)
        samplePath = fullfile(samplesDirs(sample).folder, samplesDirs(sample).name);
        DP_equibiaxial_all_series_1_sample(samplePath, stepSize, pillarRedFactor, elasticModulus, poissonRatio, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, pointsSpan, polynomialDegree, normalizedDepthLimits, fontName, fontSize)
        if showPlotsOption == 0
            close all
        end
    end
end