% This script takes into input the measurements of milling steps from imageJ and converts them to values of h/D.
function calculation_uncertainty_normalized_depth(saving,path,pillarDiameter,theoreticalStepSize)
    inputFilename = 'uncertainty-normalized_depth.csv';
    data = readtable(fullfile(path, inputFilename));
    
    numSteps = length(dir(fullfile(path,'*.tif')))-1;
    
    theoreticalDepths = (0:theoreticalStepSize:theoreticalStepSize*numSteps)';
    
    x = data.X/cos(38*pi/180);
    y = data.Y/cos(38*pi/180);
    
    %% Calculate the distances between the ellipses
    numEllipses = length(x);
    measuredDepths = zeros(numEllipses,1);
    for i = 2:numEllipses
            measuredDepths(i) = sqrt((x(i-1)-x(i))^2+(y(i-1)-y(i))^2);
    end
    
    differenceDepths = zeros(size(measuredDepths));
    
    for i = 2:numEllipses
        differenceDepths(i) = abs(measuredDepths(i)-theoreticalDepths(i));
    end
    squaredDifference = differenceDepths.^2;
    uncertaintyNormalizedDepth = squaredDifference./pillarDiameter;
    p = polyfit(theoreticalDepths(1:length(uncertaintyNormalizedDepth)),uncertaintyNormalizedDepth,2);
    polyfitUncertaintyNormalizedDepth = polyval(p,theoreticalDepths);
    
    figure
    plot(theoreticalDepths,polyfitUncertaintyNormalizedDepth)
    hold on
    scatter(theoreticalDepths(1:length(uncertaintyNormalizedDepth)),uncertaintyNormalizedDepth)
    
    legend('Polynomial fitting of degree 2','Uncertainty on the normalized depth','Location','best')
    xlabel('Depth [µm]')
    ylabel('Uncertainty on normalized depth')
    
    %% Calculate the mean value and the standard deviation
    meanDepth = mean(measuredDepths);
    stddevDepth = std(measuredDepths);
    
    %% Saving the graphs and data
    if saving == true
        outputFilename = 'uncertainty-normalized_depth.mat';
        save(fullfile(path, outputFilename),"measuredDepths","meanDepth","stddevDepth","polyfitUncertaintyNormalizedDepth")
    end
end
