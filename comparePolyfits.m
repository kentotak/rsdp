% Script to compare two samples for the same pillar diameter
close all
clear

saving = true;

strungDataPath = fullfile('results', 'polynomial_fit.mat');

sample1Path = uigetdir('', "Select the first sample directory.");
if sample1Path == 0 | isempty(sample1Path)
    disp('No directory selected. Stopping the execution.')
    return
end
[~, sample1Name] = fileparts(sample1Path);
sample1Data = load(fullfile(sample1Path, strungDataPath));
sample1Data = sample1Data.polynomialFit;

sample2Path = uigetdir('', "Select the second sample directory.");
if sample2Path == 0 | isempty(sample2Path)
    disp('No directory selected. Stopping the execution.')
    return
end
[~, sample2Name] = fileparts(sample2Path);
sample2Data = load(fullfile(sample2Path, strungDataPath));
sample2Data = sample2Data.polynomialFit;

savingPath = 'C:\Users\u0166823\OneDrive - KU Leuven\PhD\exp\FIB-DIC\dataFIB\DoE\results\comparison-V20-t20-P10-v50_150-d1';
if ~exist(savingPath, 'dir')
    mkdir(savingPath)
end

figure
set(gcf,'WindowState','maximized')

plot(sample1Data.depth,sample1Data.RS, 'Color', '#0072BD', 'LineWidth', 3)
legendEntries{1} = sprintf('Sample %s',sample1Name);

hold on

fill(sample1Data.stdDevX, sample1Data.stdDevY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
legendEntries{2} = '';

plot(sample2Data.depth,sample2Data.RS, 'Color', '#D95319', 'LineWidth', 3)
legendEntries{3} = sprintf('Sample %s',sample2Name);

fill(sample2Data.stdDevX, sample2Data.stdDevY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
legendEntries{4} = '';

hold off

legend(legendEntries, 'Location','best')
xlabel('Depth [µm]')
ylabel('Residual Stress [MPa]')

if saving == true
    saveas(gcf,fullfile(savingPath,'comparison-polyfits-V20-t20-P10-v150-d1_d9.jpg'))
end
