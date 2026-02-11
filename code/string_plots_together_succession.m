% This function strings results for multiple pillar sizes together.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024

function string_plots_together_succession(saving,path,xAxisLowLimit, xAxisHighLimit, yAxisLowLimit,yAxisHighLimit)
    filepath = fullfile('results', 'meanRS.mat');
    [~, sampleName] = fileparts(path);
    
    % Creating the directory for saving the plots
    resultsDir = fullfile(path, 'results');
    
    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end
    
    % Results structure array
    strungData = struct();

    % Plotting
    figure
    set(gcf,'WindowState','maximized')
    hold on
    
    maxDepth = 0;
    maxStdDevX = 0;
    cd(path)
    pillarsDirs = selectMultipleFolders();
    legendEntries = cell(1,length(pillarsDirs)*2);
    colors = abyss(length(pillarsDirs));
    
    % Save data
    for exportedData = {'depth','meanRS'}
        eval(sprintf('strungData.full%s = [];',capitalize_first_letter(exportedData{1})));
    end
    
    for pillar = 1:length(pillarsDirs)
        [~,pillarDiameter] = fileparts(pillarsDirs{pillar});
        pillarDiameter = str2double(pillarDiameter(1:2));
        
        % Import data
        disp(pillarsDirs(pillar))
        disp(filepath)
        fileData = load(fullfile(path,pillarsDirs(pillar),filepath));
        depth = fileData.depth;
        meanRS = fileData.meanRS;
        stdDevX = fileData.stdDevX*pillarDiameter;
        stdDevY = fileData.stdDevY;
    
        % Mean RS
        plot(depth(depth>=maxDepth),meanRS(depth>=maxDepth), 'Color', colors(pillar,:), 'LineWidth', 3)
    
        % Standard deviation as zones around the mean
        fill(stdDevX(stdDevX>=maxStdDevX), stdDevY(stdDevX>=maxStdDevX), colors(pillar,:), 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
        % Legend
        legendEntries{pillar*2-1} = sprintf('Pillar diameter: %d µm', pillarDiameter);
        legendEntries{pillar*2} = '';
    
        % Save data
        for exportedData = {'depth','meanRS'}
            eval(sprintf('strungData.full%s = [strungData.full%s;%s(depth>=maxDepth & ~isnan(meanRS))];',capitalize_first_letter(exportedData{1}),capitalize_first_letter(exportedData{1}),exportedData{1}))
        end
        for exportedData = {'stdDevX','stdDevY'}
            eval(sprintf('strungData.%s%d = %s(stdDevX>maxStdDevX);',exportedData{1},pillar,exportedData{1}));
        end
    
        % Conditions to string the curves one after the other
        maxDepth = max(depth(~isnan(meanRS)));
        maxStdDevX = max(stdDevX);
    end
    
    hold off
    
    xlim([xAxisLowLimit xAxisHighLimit])
    ylim([yAxisLowLimit yAxisHighLimit])
    
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    title(sprintf('Curves strung together for sample %s', sampleName))
    legend(legendEntries,'Location','best')
    hold(gca,'off')
    set(gca,'Color','none');
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('%s-strung_plots.jpg',sampleName)))
        filename = 'strung_data-succession.mat';
        save(fullfile(resultsDir,filename),'strungData')
    end
end