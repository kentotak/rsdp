% Script to compare two samples for the same pillar diameter.
% This code is meant to be used with the DP app.
% Author: Kento Takahashi
% Date: End of 2024

function compareNSamples(saving,sample1Path,sample2Path,sample1Name,sample2Name)

    strungDataPath = fullfile('results', 'strung_data.mat');
    
    sample1Data = load(fullfile(sample1Path, strungDataPath));
    sample1Data = sample1Data.strungData;
    
    sample2Data = load(fullfile(sample2Path, strungDataPath));
    sample2Data = sample2Data.strungData;
    
    savingPath = 'C:\Users\u0166823\OneDrive - KU Leuven\PhD\exp\FIB-DIC\dataFIB\DoE\results\comparisons';
    if ~exist(savingPath, 'dir')
        mkdir(savingPath)
    end
    
    figure
    set(gcf,'WindowState','maximized')
    
    plot(sample1Data.fullDepth,sample1Data.fullMeanRS, 'Color', '#0072BD', 'LineWidth', 3)
    legendEntries{1} = sprintf('Sample %s',sample1Name);
    numCurves = 1;
    
    hold on
    
    for pillar = 1:(length(fieldnames(sample1Data))-2)/2
        eval(sprintf("fill(sample1Data.stdDevX%d, sample1Data.stdDevY%d, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');",pillar,pillar))
        numCurves = numCurves + 1;
        legendEntries{numCurves} = '';
    end
    
    plot(sample2Data.fullDepth,sample2Data.fullMeanRS, 'Color', '#D95319', 'LineWidth', 3)
    numCurves = numCurves + 1;
    legendEntries{numCurves} = sprintf('Sample %s',sample2Name);
    
    for pillar = 1:(length(fieldnames(sample2Data))-2)/2
        eval(sprintf("fill(sample2Data.stdDevX%d, sample2Data.stdDevY%d, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');",pillar,pillar))
        numCurves = numCurves + 1;
        legendEntries{numCurves} = '';
    end
    hold off
    
    legend(legendEntries, 'Location','best')
    xlabel('Depth [µm]')
    ylabel('Residual Stress [MPa]')
    
    if saving == true
        saveas(gcf,fullfile(savingPath,sprintf('comparison-%s_%s.jpeg',sample1Name,sample2Name)))
    end
end