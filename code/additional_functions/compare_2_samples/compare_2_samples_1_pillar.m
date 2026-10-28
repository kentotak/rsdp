function compare_2_samples_1_pillar(sample1Path, sample2Path, pillarDiameter, plot1Name, plot2Name, xAxisLimits, yAxisLimits, saving, savingPath, savingFilename, savingFileExt, fontName, fontSize)
    % Script to compare the residual stress for two pillar diameters for two samples.
    % This code is meant to be used with the DP app.
    % Author: Kento Takahashi
    % Last edit: 12/10/2026 (added arguments definition)
    
    arguments
        sample1Path string {mustBeFolder}
        sample2Path string {mustBeFolder}
        pillarDiameter (1,1) double = 10
        plot1Name string = 'Sample 1'
        plot2Name string = 'Sample 2'
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        saving (1,1) logical = 0
        savingPath string = mfilename("fullpath")
        savingFilename string = 'comparison-plot1-plot2.jpg'
        savingFileExt string = 'svg';
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    % Options
    plot1Color = '#489fb5';
    plot2Color = '#ff8c42';

    %% Compare 2 curves for 1 pillar diameter
    % Data import
    meanRSPath = fullfile(sprintf('%02dum_pillar', pillarDiameter), 'results', 'meanRS.mat');
    sample1Data = load(fullfile(sample1Path, meanRSPath)).data;
    sample2Data = load(fullfile(sample2Path, meanRSPath)).data;
    
    % Extract relevant data
    sample1Depth = sample1Data.depth;
    sample1RS = sample1Data.meanRS;
    sample2Depth = sample2Data.depth;
    sample2RS = sample2Data.meanRS;
    
    sample1StdDevsX = sample1Data.stdDevX*pillarDiameter;
    sample1StdDevsY = sample1Data.stdDevY;
    
    sample2StdDevsX = sample2Data.stdDevX*pillarDiameter;
    sample2StdDevsY = sample2Data.stdDevY;
    
    % Plotting
    figure
    hold on

    % Window parameters
    % set(gcf,'WindowState','maximized')
    % set(gcf,'Units','centimeters')
    % set(gcf,'InnerPosition',[10 10 17 8])
    % set(gcf,'Menu','none','ToolBar','none')
    % set(gca,'Position',[0.13 0.2 0.85 0.8])
    
    % Plot stresses
    plot(sample1Depth, sample1RS, 'Color', plot1Color, 'LineWidth', 3)
    plot(sample2Depth, sample2RS, 'Color', plot2Color, 'LineWidth', 3)

    % Plot standard deviations
    fill(sample1StdDevsX, sample1StdDevsY, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(sample2StdDevsX, sample2StdDevsY, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    hold off
    
    % Plot appearance
    xlim(xAxisLimits)
    ylim(yAxisLimits)
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')

    if strcmp(plot1Name, '')
        legendEntries{1} = 'Sample 1';
    else
        legendEntries{1} = plot1Name;
    end

    if strcmp(plot2Name, '')
        legendEntries{2} = 'Sample 2';
    else
        legendEntries{2} = plot2Name;
    end
    legend(legendEntries, 'Location','southeast')
    
    set(gca,'FontSize',fontSize)
    set(gca, 'FontName', fontName)
    
    %% Saving
    if saving
        if isempty(savingFilename)
            saveas(gcf,fullfile(savingPath, sprintf('comparison-%dum_pillar-%s-%s.jpeg', pillarDiameter, plot1Name, plot2Name)))
        else
            if strcmp(savingFileExt,'svg')
                exportgraphics(gcf, sprintf('%s.%s', savingFilename, savingFileExt),'ContentType','vector')
            else
                saveas(gcf, fullfile(savingPath, sprintf('%s.%s', savingFilename, savingFileExt)))
            end
        end
    end
end