function compare_2_samples(sample1Path,sample2Path,fullComparisonOption,pillarDiameter,mergeMode,weighting,plot1Name,plot2Name,xAxisLimits,yAxisLimits,saving,savingPath,savingFilename,savingFileExt,fontName,fontSize)
    % Script to compare two samples.
    % This code is meant to be used with the DP app.
    % Author: Kento Takahashi
    % Last edit: 12/10/2026 (added arguments definition)
    
    arguments
        sample1Path string {mustBeFolder}
        sample2Path string {mustBeFolder}
        fullComparisonOption (1,1) logical = 1
        pillarDiameter (1,1) double = 10
        mergeMode string = 'combined' % 'combined', 'succession' or 'none'
        weighting logical = 1
        plot1Name string = 'Plot 1'
        plot2Name string = 'Plot 2'
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

    if fullComparisonOption
        %% Data import
        switch mergeMode
            case 'combined'
                if weighting
                    dataFilename = 'merged_data-weighted-linear.mat';
                else
                    dataFilename = 'merged_data-combined.mat';
                end
            case 'succession'
                dataFilename = 'merged_data-succession.mat';
            case 'none'
                dataFilename = '5_10_um_separated.mat';
        end

        mergedDataPath = fullfile('results', dataFilename);

        sample1Data = load(fullfile(sample1Path,mergedDataPath)).mergedData;
        sample2Data = load(fullfile(sample2Path,mergedDataPath)).mergedData;
    
        %% Plot
        figure
        hold on
        % Window options
        % set(gcf,'WindowState','maximized')
        % set(gcf,'Units','centimeters')
        % set(gcf,'InnerPosition',[10 10 17 8])
        % set(gcf,'Menu','none','ToolBar','none')
    
        switch mergeMode
            case 'none'
                scatter(vertcat(sample1Data.depth), vertcat(sample1Data.meanRS), 20, 'filled', 'MarkerFaceColor', plot1Color)
    
                scatter(vertcat(sample2Data.depth), vertcat(sample2Data.meanRS), 20, 'filled', 'MarkerFaceColor', plot2Color)
    
                fill(sample1Data(1).stdDevX, sample1Data(1).stdDevY, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                fill(sample1Data(2).stdDevX, sample1Data(2).stdDevY, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    
                fill(sample2Data(1).stdDevX, sample2Data(1).stdDevY, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                fill(sample2Data(2).stdDevX, sample2Data(2).stdDevY, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
            case {'combined', 'succession'}
                scatter(sample1Data.depth,sample1Data.meanRS, 20, 'filled', 'MarkerFaceColor', plot1Color)
                scatter(sample2Data.depth,sample2Data.meanRS, 20, 'filled', 'MarkerFaceColor', plot2Color)
    
                fill(sample1Data.stdDevX, sample1Data.stdDevY, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
                fill(sample2Data.stdDevX, sample2Data.stdDevY, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
        end
        
        hold off

        % Plot appearance
        legendEntries{1} = plot1Name;
        legendEntries{2} = plot2Name;

        xlim(xAxisLimits)
        ylim(yAxisLimits)
        
        ax = gca;
        ax.FontSize = fontSize;
        ax.FontName = fontName;
        ax.Color = 'none';
        ax.Box = 'off';

        legend(legendEntries, 'Location','southeast')
        xlabel('Depth [µm]')
        ylabel('Residual Stress [MPa]')
    
        %% Saving
        if saving
            if isempty(savingFilename)
                saveas(gcf,fullfile(savingPath, sprintf('comparison-full-%s_%s-%s.png',plot1Name,plot2Name,mergeMode)))
            else
                if strcmp(savingFileExt, 'svg')
                    exportgraphics(gcf, sprintf('%s.%s', savingFilename, savingFileExt), 'ContentType', 'vector')
                else
                    saveas(gcf, fullfile(savingPath, sprintf('%s.%s', savingFilename, savingFileExt)))
                end
            end
        end
    else
        %% Compare 2 curves for 1 pillar diameter
        % Data import
        fullPath1 = fullfile(sample1Path,sprintf('%02dum_pillar-smoothed_10_3',pillarDiameter),'results','meanRS.mat');
        fullPath2 = fullfile(sample2Path,sprintf('%02dum_pillar-smoothed_10_3',pillarDiameter),'results','meanRS.mat');
        
        sample1Data = load(fullPath1);
        sample2Data = load(fullPath2);
        
        % Extract relevant data
        sample1Depths = sample1Data.depth;
        sample1Stresses = sample1Data.meanRS;
        sample2Depths = sample2Data.depth;
        sample2Stresses = sample2Data.meanRS;
        
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

        set(gca,'FontSize',fontSize)
        set(gca, 'FontName', fontName)
        % set(gca,'Position',[0.13 0.2 0.85 0.8])
        
        % Plot stresses
        plot(sample1Depths,sample1Stresses, 'Color', '#0072BD', 'LineWidth', 3)
        
        plot(sample2Depths,sample2Stresses, 'Color', '#D95319', 'LineWidth', 3)
        
        if curve1Name == 0
            legendEntries{1} = sprintf('Sample %s',plot1Name);
        else
            legendEntries{1} = curve1Name;
        end

        if curve2Name == 0
            legendEntries{2} = sprintf('Sample %s',plot2Name);
        else
            legendEntries{2} = curve2Name;
        end
        
        xlim(xAxisLimits)
        ylim(yAxisLimits)
        
        % Plot standard deviations
        fill(sample1StdDevsX, sample1StdDevsY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        fill(sample2StdDevsX, sample2StdDevsY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
        hold off
        
        legend(legendEntries, 'Location','southeast')
        xlabel('Depth (µm)')
        ylabel('Residual Stress [MPa]')
        
        %% Saving
        if saving
            if isempty(savingFilename)
                saveas(gcf,fullfile(savingPath,sprintf('comparison-%dum_pillar-%s_%s-%s.jpeg',pillarDiameter,plot1Name,plot2Name,mergeMode)))
            else
                if strcmp(savingFileExt,'svg')
                    exportgraphics(gcf, sprintf('%s.%s', savingFilename, savingFileExt),'ContentType','vector')
                else
                    saveas(gcf, fullfile(savingPath, sprintf('%s.%s', savingFilename, savingFileExt)))
                end
            end
        end
    end
end