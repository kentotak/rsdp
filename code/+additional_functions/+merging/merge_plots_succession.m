function merge_plots_succession(samplePath,saving,xAxisLimits,yAxisLimits,fontName,fontSize)
    % This function strings results for multiple pillar sizes together.
    % This code is meant to be used with the DP app.
    % Author: Kento Takahashi

    arguments
        samplePath string {mustBeFolder}
        saving (1,1) logical = 0
        xAxisLimits (1,2) double = [-inf inf] % [] or [µm]
        yAxisLimits (1,2) double = [-inf inf] % [MPa]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    %% Paths
    filepath = fullfile('results', 'meanRS.mat');
    [~, sampleName] = fileparts(samplePath);
    
    % Creating the directory for saving the plots
    resultsDir = fullfile(samplePath, 'results');
    
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end
    
    % Results structure array
    mergedData = struct('depth',cell(1),'meanRS',cell(1));

    % Initialize max values
    maxDepth = 0;
    maxStdDevX = 0;

    % Select data
    pillarsDirs = selectMultipleFolders();

    % Plot appearance
    legendEntries = cell(1,numel(pillarsDirs)*2);
    colors = abyss(length(pillarsDirs));

    % Initialize figure
    figure
    % set(gcf,'WindowState','maximized')
    hold on
    
    for pillar = 1:length(pillarsDirs)
        % Extract pillar diameter from first 2 characters of folder name
        [~,pillarDiameter] = fileparts(pillarsDirs{pillar});
        pillarDiameter = str2double(pillarDiameter(1:2));
        
        %% Import data
        fileData = load(fullfile(pillarsDirs{pillar},filepath));
        depth = fileData.depth;
        meanRS = fileData.meanRS;
        stdDevX = fileData.stdDevX*pillarDiameter;
        stdDevY = fileData.stdDevY;
    
        %% Plot
        scatter(depth(depth>=maxDepth), meanRS(depth>=maxDepth), 'Color', colors(pillar,:), 'LineWidth', 3)
        fill(stdDevX(stdDevX >= maxStdDevX), stdDevY(stdDevX >= maxStdDevX), colors(pillar,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
        % Plot legend
        legendEntries{pillar*2-1} = sprintf('Pillar diameter: %d µm', pillarDiameter);
        legendEntries{pillar*2} = '';
    
        %% Save data
        mask1 = depth>=maxDepth & ~isnan(meanRS);
        mergedData(1).depth = [mergedData(1).depth;depth(mask1)];
        mergedData(1).meanRS = [mergedData(1).meanRS;meanRS(mask1)];

        mask2 = stdDevX>maxStdDevX;
        mergedData(1).stdDevX = stdDevX(mask2);
        mergedData(1).stdDevY = stdDevY(mask2);
    
        % Conditions to plot the curves one after the other
        maxDepth = max(depth(~isnan(meanRS)));
        maxStdDevX = max(stdDevX);
    end
    
    hold off
    
    % Plot appearance
    set(gca, 'FontName', fontName)
    set(gca, 'FontSize', fontSize)

    xlim(xAxisLimits)
    ylim(yAxisLimits)
    
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    title(sprintf('Curves strung together for sample %s', sampleName))
    legend(legendEntries,'Location','best')
    hold(gca,'off')
    set(gca,'Color','none');
    
    %% Saving
    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('%s-merged_plots-succession.jpg',sampleName)))
        filename = 'merged_data-succession.mat';
        save(fullfile(resultsDir,filename),'mergedData')
    end
end