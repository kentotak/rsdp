% This function averages the residual stress for multiple series of the same pillar diameter.
% The standard deviation is also computed.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024


function averaging_1_pillar(saving, path, pillarDiameter, xAxisLowLimit, xAxisHighLimit, yAxisLowLimit, yAxisHighLimit, indidualPlotsOption, ...
    scanDirection,normalizedDepthLowLimit,normalizedDepthHighLimit)
    allSeries = dir(path);
    nbSeries = length(dir(path));
    data = zeros(500,(nbSeries-3)+1);
    filepath = fullfile('results', 'depth_profiling', num2str(scanDirection), sprintf('residualStress-%d.mat',scanDirection));
    
    % Creating the directory for saving the plots
    resultsDir = fullfile(path, 'results');
    
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end
    
    % Plotting
    figure
    set(gcf,'WindowState','maximized')
    hold on
    for series = 4:nbSeries
        if allSeries(series).isdir && ~ismember(allSeries(series).name, {'.', '..', 'results'})
            if series == 4
                data(:,1) = load(fullfile(path, allSeries(series).name, filepath)).normalizedDepth;
                data(:,2) = load(fullfile(path, allSeries(series).name, filepath)).stress;
            else
                data(:,(series-3)+1) = load(fullfile(path, allSeries(series).name, filepath)).stress;
            end
            if indidualPlotsOption
                plot(data(:,1),data(:,(series-3)+1))
            end
        end
    end

    normalizedDepth = data(:,1);
    meanRS = mean(data(:,2:end),2);
    stdDev = std(data(:, 2:end), 0, 2);  % Standard deviation of each row across columns 2:end

    % Plot in interval
    % mask = ~isnan(meanRS+stdDev) & normalizedDepth >= min(normalizedDepth) & normalizedDepth <= max(normalizedDepth);
    mask = ~isnan(meanRS+stdDev) & normalizedDepth >= normalizedDepthLowLimit & normalizedDepth <= normalizedDepthHighLimit;

    normalizedDepth = normalizedDepth(mask);
    meanRS = meanRS(mask);
    stdDev = stdDev(mask);

    plot(normalizedDepth,meanRS,'LineWidth',3)
    
    hold on
    
    % Plot the standard deviation as a shaded region around the mean
    % validPoints = ~isnan(meanRS + stdDev) & normalizedDepth >= .05 & normalizedDepth <= .2;
    
    % stdDevX = [normalizedDepth(validPoints); flipud(normalizedDepth(validPoints))];  % X values for the shaded region
    % stdDevY = [meanRS(validPoints) + stdDev(validPoints); flipud(meanRS(validPoints) - stdDev(validPoints))];  % Y values for the shaded region
    
    stdDevX = [normalizedDepth;flipud(normalizedDepth)];
    stdDevY = [meanRS+stdDev;flipud(meanRS-stdDev)];

    % Plot the shaded region (standard deviation)
    fill(stdDevX, stdDevY, 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
    hold off
    
    xlabel('Normalized depth (h/D)')
    ylabel('Residual Stress [MPa]')
    xlim([xAxisLowLimit xAxisHighLimit])
    ylim([yAxisLowLimit yAxisHighLimit])

    if saving == true
        if indidualPlotsOption
            saveas(gcf, fullfile(resultsDir, 'mean_RS-with_individual_plots.jpg'))
        else
            saveas(gcf, fullfile(resultsDir, 'mean_RS.jpg'))
        end
    end
    
    %% Saving the graphs and data
    depth = normalizedDepth*pillarDiameter;
    variance = stdDev.^2;
    if saving == true
        filename = 'meanRS.mat';
        save(fullfile(resultsDir,filename),'normalizedDepth', 'depth', 'meanRS', 'stdDevX', 'stdDevY', 'pillarDiameter','variance',"stdDev")
    end
end