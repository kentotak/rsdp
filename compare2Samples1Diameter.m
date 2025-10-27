% Script to compare two samples for the same pillar diameter.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024

function compare2Samples1Diameter(saving, pillarDiameter, sample1Path, sample2Path, sample1Name, sample2Name)
    %% Data import    
    fullPath1 = fullfile(sample1Path,sprintf('%02dum_pillar',pillarDiameter),'results','meanRS.mat');
    fullPath2 = fullfile(sample2Path,sprintf('%02dum_pillar',pillarDiameter),'results','meanRS.mat');
    
    sample1Data = load(fullPath1);
    sample2Data = load(fullPath2);
    
    % Extract relevant data
    sample1Depths = sample1Data.normalizedDepth;
    sample1Stresses = sample1Data.meanRS;
    sample2Depths = sample2Data.normalizedDepth;
    sample2Stresses = sample2Data.meanRS;
    
    sample1StdDevsX = sample1Data.stdDevX;
    sample1StdDevsY = sample1Data.stdDevY;
    
    sample2StdDevsX = sample2Data.stdDevX;
    sample2StdDevsY = sample2Data.stdDevY;
    
    %% Plotting
    figure
    hold on
    set(gcf,'WindowState','maximized')
    
    % Plot stresses
    plot(sample1Depths,sample1Stresses, 'Color', '#0072BD', 'LineWidth', 3)
    legendEntries{1} = sample1Name;
    
    plot(sample2Depths,sample2Stresses, 'Color', '#D95319', 'LineWidth', 3)
    legendEntries{2} = sample2Name;
    
    ylim([-500 150])
    
    % Plot standard deviations
    fill(sample1StdDevsX, sample1StdDevsY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(sample2StdDevsX, sample2StdDevsY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    hold off
    
    legend(legendEntries, 'Location','southeast')
    xlabel('Normalized depths (h/D)')
    ylabel('Residual Stress [MPa]')
    
    if saving == true
        [sample1ParentFolder, ~] = fileparts(sample1Path);
        [sample2ParentFolder, ~] = fileparts(sample2Path);
        if strcmp(sample1ParentFolder,sample2ParentFolder)
            resultsDir = fullfile(sample1ParentFolder,'results');
            if ~exist(resultsDir, 'dir')
                mkdir(resultsDir)
            end
        else
            msgbox('Select a folder to save your results.')
            resultsDir = uigetdir(sample1ParentFolder,'Select a folder to save your results.');
        end
        saveas(gcf,fullfile(resultsDir,sprintf('comparison-%s_%s-%s.jpeg',sample1Name,sample2Name,plotOption)))
    end
end