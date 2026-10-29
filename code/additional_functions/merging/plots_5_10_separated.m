function plots_5_10_separated(samplePath, saving, savingPath, xAxisLimits, yAxisLimits, fontName, fontSize)
    % Plot averaged data for 5 and 10 µm diameter pillars on same graph.
    % Author: Kento Takahashi - KU Leuven

    arguments
        samplePath string {mustBeFolder}
        saving (1,1) logical = 0
        savingPath string {mustBeFolder} = ''
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    % Options
    plotColor = '#489fb5';
    axesColor = 'black';

    % Importing other functions
    [functionPath, ~] = fileparts(mfilename("fullpath"));
    addpath(functionPath)

    % Sample name
    filepath = fullfile('results', 'meanRS.mat');
    [~, sampleName] = fileparts(samplePath);

    if ~exist(savingPath, 'dir')
        mkdir(savingPath)
    end

    %% Import data
    mergedData = struct;
    pillarsDirs = {fullfile(samplePath, '05um_pillar'), fullfile(samplePath, '10um_pillar')};

    for pillar = 1:length(pillarsDirs)
        fileData = load(fullfile(pillarsDirs{pillar}, filepath)).data;
        meanRS = fileData.meanRS;
        stdDev = fileData.stdDev;

        % Filter out nan values
        validPoints = ~isnan(meanRS + stdDev);
        depth = fileData.depth(validPoints);
        meanRS = meanRS(validPoints);
        stdDev = stdDev(validPoints);
        stdDevX = [vertcat(depth);flipud(vertcat(depth))];
        stdDevY = [meanRS + stdDev; flipud(meanRS - stdDev)];

        % Export data
        mergedData(pillar).depth = depth;
        mergedData(pillar).meanRS = meanRS;
        mergedData(pillar).stdDev = stdDev;
        mergedData(pillar).stdDevX = stdDevX;
        mergedData(pillar).stdDevY = stdDevY;
    end

    %% Plot
    f = figure;
    hold on

    % Plot RS and standard deviation
    scatter(vertcat(mergedData.depth), vertcat(mergedData.meanRS), 20, 'filled', 'MarkerFaceColor', plotColor)
    fill(mergedData(1).stdDevX, mergedData(1).stdDevY, '', 'FaceColor', plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    fill(mergedData(2).stdDevX, mergedData(2).stdDevY, '', 'FaceColor', plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')

    % Plot details
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    % title(sprintf('Sample %s - Weighted mean between 0.5 and 1 µm', mergedData.sampleName))
    legend({'Averaged stress', 'Standard deviation'}, 'Location', 'southeast')
    hold off
    ax = gca;
    set(ax, 'Color', 'none')
    set(ax, 'FontSize', fontSize)
    set(ax, 'FontName', fontName)
    set(ax, 'Box', 'off')
    set(ax, 'XColor', axesColor)
    set(ax, 'YColor', axesColor)
    xlim(xAxisLimits)
    ylim(yAxisLimits)

    %% Saving
    if saving
        figName = sprintf('5_10_um_profiles_separated-%s.svg', sampleName);
        % saveas(gcf, fullfile(savingPath, figName))
        exportgraphics(f, fullfile(savingPath, figName))
        filename = sprintf('5_10_um_separated.mat');
        save(fullfile(savingPath, filename), 'mergedData')
    end
end
