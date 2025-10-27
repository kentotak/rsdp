% Script to compare two samples.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024

function compare2Samples(saving,savingPath,filename,fullOption,plotOption,pillarDiameter,sample1Path,sample2Path,sample1Name,sample2Name,curve1Name,curve2Name)
    if fullOption == true
        %% Data import
        if strcmp(plotOption,'Succession')
            dataFilename = 'strung_data-succession.mat';
        else
            dataFilename = 'strung_data-combined.mat';
        end
        strungDataPath = fullfile('results', dataFilename);
    
        %% Data attribution
        for sampleNumber = 1:2
            eval(sprintf('sample%dData = load(fullfile(sample%dPath, strungDataPath));',sampleNumber,sampleNumber))
            eval(sprintf('sample%dData = sample%dData.strungData;',sampleNumber,sampleNumber))
            if strcmp(plotOption,'Succession')
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
    
        %% Plotting
        figure
        hold on
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
            legendEntries{1} = sprintf('Sample %s',sample1Name);
        else
            legendEntries{1} = curve1Name;
        end

        if curve2Name == 0
            legendEntries{2} = sprintf('Sample %s',sample2Name);
        else
            legendEntries{2} = curve2Name;
        end
               
        ylim([-500 150])
    
        % Plot standard deviation
        if strcmp(plotOption, 'Succession')
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
        
        legend(legendEntries, 'Location','southeast')
        xlabel('Depth [µm]')
        ylabel('Residual Stress [MPa]')
    
        if saving == true
            if isempty(filename)
                saveas(gcf,fullfile(savingPath,sprintf('comparison-full-%s_%s-%s.jpeg',sample1Name,sample2Name,plotOption)))
            else
                saveas(gcf, fullfile(savingPath, sprintf('%s.jpeg', filename)));
            end
        end
    else
        %% Data import    
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
        
        %% Plotting
        figure
        hold on
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
            legendEntries{1} = sprintf('Sample %s',sample1Name);
        else
            legendEntries{1} = curve1Name;
        end

        if curve2Name == 0
            legendEntries{2} = sprintf('Sample %s',sample2Name);
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
                saveas(gcf,fullfile(savingPath,sprintf('comparison-%dum_pillar-%s_%s-%s.jpeg',pillarDiameter,sample1Name,sample2Name,plotOption)))
            else
                saveas(gcf, fullfile(savingPath, sprintf('%s.jpeg', filename)));
            end
        end
end