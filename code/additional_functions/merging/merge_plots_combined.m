function merge_plots_combined(path,saving,xAxisLimits,yAxisLimits,fontName,fontSize)
    % Combines data of multiple pillar diameters.
    % Author: Kento Takahashi
    % Date: 13/10/2026 (removed eval functions and put data in structure arrays instead)
    
    arguments
        path string {mustBeFolder}
        saving (1,1) logical = 0
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    %% Options
    plotColor = '#489fb5';
    
    %% Paths
    [functionPath,~] = fileparts(mfilename("fullpath"));
    addpath(functionPath)

    filepath = fullfile('results', 'meanRS.mat');
    [~, sampleName] = fileparts(path);

    resultsDir = fullfile(path, 'results'); 

    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end

    cd(path)

    %% Import data
    pillarsDirs = selectMultipleFolders();

    data = struct;

    for pillar = 1:length(pillarsDirs)
        % Extract pillar diameter from first 2 characters of folder name
        [~,data(pillar).pillarDiameter] = fileparts(pillarsDirs{pillar});
        data(pillar).pillarDiameter = str2double(data(pillar).pillarDiameter(1:2));

        data(pillar).fileData = load(fullfile(pillarsDirs{pillar},filepath));
        data(pillar).depth = data(pillar).fileData.depth;
        data(pillar).stress = data(pillar).fileData.meanRS;
        data(pillar).variance = data(pillar).fileData.variance;
    end
    
    %% Interpolate stresses and standard deviations
    mergedData = struct;

    mergedData.depth = vertcat(data.depth);
    mergedData.uniqueDepths = unique(mergedData.depth);

    pillarData = struct;

    for pillar = 1:length(pillarsDirs)
        % Filter in depth interval
        maxDepth = max(data(pillar).depth);
        interpolatedDepth = mergedData.uniqueDepths(mergedData.uniqueDepths<=maxDepth);
        otherValues = nan(size(mergedData.uniqueDepths(mergedData.uniqueDepths>maxDepth)));

        interpolatedStress = interp1(data(pillar).depth,data(pillar).stress,interpolatedDepth);
        pillarData(pillar).stress = [interpolatedStress; otherValues];

        interpolatedVariance = interp1(data(pillar).depth,data(pillar).variance,interpolatedDepth);
        pillarData(pillar).variance = [interpolatedVariance; otherValues];
    end

    %% Calculate merged data
    mergedData.meanRS = mean(horzcat(pillarData.stress), 2, 'omitnan');
    mergedData.meanVariance = mean(horzcat(pillarData.variance), 2, 'omitnan');
    stdDev = sqrt(mergedData.meanVariance);

    validPoints = ~isnan(mergedData.meanRS+stdDev);
    mergedData.stdDevX = [mergedData.uniqueDepths(validPoints); flipud(mergedData.uniqueDepths(validPoints))];
    mergedData.stdDevY = [mergedData.meanRS(validPoints) + stdDev(validPoints); flipud(mergedData.meanRS(validPoints) - stdDev(validPoints))];

    %% Plot
    figure

    hold on
    scatter(mergedData.uniqueDepths, mergedData.meanRS, 20, 'filled', 'MarkerFaceColor', plotColor)
    fill(mergedData.stdDevX, mergedData.stdDevY, '', 'MarkerFaceColor', plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    yline(0,'k--') % vertical line at 0
    hold off
    
    % Plot appearance
    % set(gcf,'WindowState','maximized')
    % set(gcf,'InnerPosition',[0 0 1 1])
    % set(gcf,'Menu','none','ToolBar','none')

    set(gca, 'FontSize', fontSize)
    set(gca, 'FontName', fontName)
    set(gca, 'Color', 'none');

    xlim(xAxisLimits)
    ylim(yAxisLimits)
    
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    % title(sprintf('Curves strung together for sample %s', sampleName))
    legend({'Averaged stress','Standard deviation'},'Location','best')

    if saving
        saveas(gcf, fullfile(resultsDir, sprintf('%s-merged_plots-combined.jpg',sampleName)))
        filename = 'merged_data-combined.mat';
        save(fullfile(resultsDir,filename),'mergedData')
    end
end