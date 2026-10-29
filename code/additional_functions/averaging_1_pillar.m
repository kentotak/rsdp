function averaging_1_pillar(pillarPath, saving, scanDirection, xAxisData, xAxisLimits, yAxisLimits, individualPlotsOption, normalizedDepthLimits, fontName, fontSize)
    % This function averages the residual stress for multiple series of the same pillar diameter.
    % The standard deviation is also computed.
    % This code is meant to be used with rsdp.
    % Author: Kento Takahashi -  KU Leuven

    arguments
        pillarPath string {mustBeFolder}
        saving (1,1) logical = 0
        scanDirection (1,1) double = 0
        xAxisData string = "normalizedDepth" % "normalizedDepth" or "depth"
        xAxisLimits (1,2) double = [-inf inf] % [] or [µm]
        yAxisLimits (1,2) double = [-inf inf] % [MPa]
        individualPlotsOption (1,1) logical = 0
        normalizedDepthLimits (1,2) double = [.05 .2] % []
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    % Paths
    allSeries = dir(pillarPath);
    filepath = fullfile('results', 'depth_profiling', num2str(scanDirection), sprintf('residualStress-%d.mat', scanDirection));
    seriesDirectories = allSeries([allSeries.isdir] & ~ismember({allSeries.name}, {'.', '..', 'results'}));
    
    % Creating the directory for saving the plots
    if saving
        resultsDir = fullfile(pillarPath, 'results');
    
        if ~exist(resultsDir, 'dir')
            mkdir(resultsDir)
        end
    end

    %% Import data
    data.normalizedDepth = load(fullfile(pillarPath, seriesDirectories(1).name, filepath)).data.normalizedDepth(:);
    data.depth = load(fullfile(pillarPath, seriesDirectories(1).name, filepath)).data.depth(:);
    data.nbSeries = numel(seriesDirectories);
    for series = 1:data.nbSeries
        data.residualStress(:, series) = load(fullfile(pillarPath, seriesDirectories(series).name, filepath)).data.residualStress(:);
    end

    %% Compute averaged stress and standard deviation
    data.meanRS = mean(data.residualStress, 2);
    data.stdDev = std(data.residualStress, 0, 2);

    % Keep values in normalized depth interval specified by normalizedDepthLimits
    mask = ~isnan(data.meanRS+data.stdDev) & data.normalizedDepth >= normalizedDepthLimits(1) & data.normalizedDepth <= normalizedDepthLimits(2);

    data.normalizedDepth = data.normalizedDepth(mask);
    data.depth = data.depth(mask);
    data.meanRS = data.meanRS(mask);
    data.stdDev = data.stdDev(mask);

    data.stdDevX = [data.(xAxisData);flipud(data.(xAxisData))];
    data.stdDevY = [data.meanRS+data.stdDev;flipud(data.meanRS-data.stdDev)];

    %% Plot
    figure
    hold on

    plot(data.(xAxisData), data.meanRS, 'LineWidth', 3) % Residual stress
    fill(data.stdDevX, data.stdDevY, 'b', 'FaceAlpha', 0.2, 'EdgeColor', 'none') % Standard deviation

    if individualPlotsOption % Individual plots
        for series = 1:data.nbSeries
            plot(data.(xAxisData), data.residualStress(:, series))
        end
    end
    
    hold off
    
    % Plot appearance
    switch xAxisData
        case 'normalizedDepth'
            xlabel('Normalized depth (h/D)')
        case 'depth'
            xlabel('Depth [µm]')
    end

    ylabel('Residual Stress [MPa]')
    xlim(xAxisLimits)
    ylim(yAxisLimits)

    set(gca, 'FontName', fontName)
    set(gca, 'FontSize', fontSize)
    set(gca, 'Color', 'none')
    box off

    %% Saving
    if saving
        % Graphs
        if individualPlotsOption
            saveas(gcf, fullfile(resultsDir, 'mean_RS-with_individual_plots.jpg'))
        else
            saveas(gcf, fullfile(resultsDir, 'mean_RS.jpg'))
        end

        % Data
        filename = 'meanRS.mat';
        save(fullfile(resultsDir, filename), 'data')
    end
end