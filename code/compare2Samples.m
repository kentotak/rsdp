% Script to compare two samples.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024

function compare2Samples(saving,savingPath,filename,fullComparisonOption,stringingMode,pillarDiameter,sample1Path,sample2Path,plot1Name,plot2Name, ...
    xAxisLowLimit,xAxisHighLimit,yAxisLowLimit,yAxisHighLimit)
    numPillars=0;

    if fullComparisonOption == true
        %% Compare 2 full curves
        % Data import
        if strcmp(stringingMode,'Succession')
            dataFilename = 'strung_data-succession.mat';
        else
            dataFilename = 'strung_data-combined.mat';
        end
        strungDataPath = fullfile('results', dataFilename);
    
        % Data attribution
        for sampleNumber = 1:2
            eval(sprintf('sample%dData = load(fullfile(sample%dPath, strungDataPath));',sampleNumber,sampleNumber))
            eval(sprintf('sample%dData = sample%dData.strungData;',sampleNumber,sampleNumber))
            if strcmp(stringingMode,'Succession')
                eval(sprintf('sample%dDepths = sample%dData.fullDepth;',sampleNumber,sampleNumber))
                eval(sprintf('sample%dStresses = sample%dData.fullMeanRS;',sampleNumber,sampleNumber))
                eval(sprintf('numPillars = (length(fieldnames(sample%dData))-2)/2;',sampleNumber))
                for numCurve = 1:numPillars
                    eval(sprintf('sample%dStdDevX%d = sample%dData.stdDevX%d;',sampleNumber,numCurve,sampleNumber,numCurve))
                    eval(sprintf('sample%dStdDevY%d = sample%dData.stdDevY%d;',sampleNumber,numCurve,sampleNumber,numCurve))
                end
            else
                for variable = {'Depths','Stresses','Variances','StdDevsX','StdDevsY'}
                    eval(sprintf('sample%d%s = sample%dData.all%s;',sampleNumber,variable{1},sampleNumber,variable{1}))
                end
            end
        end
    
        % Plotting
        figure
        % Window options
        % set(gcf,'WindowState','maximized')
        set(gcf,'Units','centimeters')
        set(gcf,'InnerPosition',[10 10 17 8])
        set(gcf,'Menu','none','ToolBar','none')
        
        % Plot stresses
        plot(sample1Depths,sample1Stresses, 'Color', '#0072BD', 'LineWidth', 3)
        hold on
        plot(sample2Depths,sample2Stresses, 'Color', '#D95319', 'LineWidth', 3)
        
        legendEntries{1} = plot1Name;
        legendEntries{2} = plot2Name;
        
        xlim([xAxisLowLimit xAxisHighLimit])
        ylim([yAxisLowLimit yAxisHighLimit])
    
        % Plot standard deviation
        if strcmp(stringingMode, 'Succession')
            eval(sprintf('numPillars = (length(fieldnames(sample%dData))-2)/2;',sampleNumber))
            for pillar = 1:numPillars
                eval(sprintf("fill(sample1StdDevX%d, sample1StdDevY%d, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');",pillar,pillar))
                eval(sprintf("fill(sample2StdDevX%d, sample2StdDevY%d, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');",pillar,pillar))
            end
        else
            fill(sample1StdDevsX, sample1StdDevsY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            fill(sample2StdDevsX, sample2StdDevsY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        end
        
        hold off
        
        ax = gca;
        ax.FontSize = 16;
        ax.FontName = 'Times New Roman';
        ax.Position = [0.13 0.2 0.85 0.8];
        % set(ax,'FontSize', 16, 'FontName', 'Times New Roman', 'Position', [0.13 0.2 0.85 0.8])
        ax.Color = 'none';
        ax.Box = 'off';

        legend(legendEntries, 'Location','southeast')
        xlabel('Depth [µm]')
        ylabel('Residual Stress [MPa]')
    
        if saving == true
            if isempty(filename)
                saveas(gcf,fullfile(savingPath,sprintf('comparison-full-%s_%s-%s.jpeg',plot1Name,plot2Name,stringingMode)))
            else
                saveas(gcf, fullfile(savingPath, sprintf('%s.jpeg', filename)));
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
        set(gcf,'Units','centimeters')
        set(gcf,'InnerPosition',[10 10 17 8])
        set(gcf,'Menu','none','ToolBar','none')

        set(gca,'FontSize',16)
        set(gca, 'FontName', 'Times New Roman')
        set(gca,'Position',[0.13 0.2 0.85 0.8])
        
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
        
        xlim([.5 2])
        ylim([-500 150])
        
        % Plot standard deviations
        fill(sample1StdDevsX, sample1StdDevsY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        fill(sample2StdDevsX, sample2StdDevsY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
        hold off
        
        legend(legendEntries, 'Location','southeast')
        xlabel('Depth (µm)')
        ylabel('Residual Stress [MPa]')
        
        if saving == true
            if isempty(filename)
                saveas(gcf,fullfile(savingPath,sprintf('comparison-%dum_pillar-%s_%s-%s.jpeg',pillarDiameter,plot1Name,plot2Name,stringingMode)))
            else
                saveas(gcf, fullfile(savingPath, sprintf('%s.jpeg', filename)));
            end
        end
end