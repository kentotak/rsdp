% Combines data of multiple pillar diameters.
% Author: Kento Takahashi
% Date: 02/2025

function string_plots_together_combined(saving,samplePath,lowerLimitStress,higherLimitStress)
    highestDepth = 0;

    [functionPath,~] = fileparts(mfilename("fullpath"));
    addpath(functionPath)

    filepath = fullfile('results', 'meanRS.mat');
    [~, sampleName] = fileparts(samplePath);

    % Creating the directory for saving the plots
    resultsDir = fullfile(samplePath, 'results'); 

    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end

    cd(samplePath)
    pillarsDirs = selectMultipleFolders();

    allDepths = zeros(1,500*length(pillarsDirs));

    % Import data
    for pillar = 1:length(pillarsDirs)
        eval(sprintf('[~,pillarDiameter%d] = fileparts(pillarsDirs{pillar});',pillar))
        eval(sprintf('pillarDiameter%d = str2double(pillarDiameter%d(1:2));',pillar,pillar))

        eval(sprintf("fileData%d = load(fullfile(pillarsDirs{pillar},filepath));",pillar))
        eval(sprintf("depth%d = fileData%d.depth';",pillar,pillar))
        eval(sprintf("stress%d = fileData%d.meanRS';",pillar,pillar))
        eval(sprintf("variance%d = fileData%d.variance';",pillar,pillar))

        eval(sprintf('allDepths(pillar*500-499:pillar*500) = depth%d;',pillar))
    end

    allUniqueDepths = unique(allDepths);
    allStresses = nan(length(pillarsDirs),length(allUniqueDepths));
    allVariances = nan(length(pillarsDirs),length(allUniqueDepths));

    % Interpolate stresses and standard deviations between lowest and highest depths
    for pillar = 1:length(pillarsDirs)
        % filter values
        eval(sprintf('highestDepth = max(depth%d);',pillar))
        interpolationDepth = allUniqueDepths(allUniqueDepths<=highestDepth);
        otherValues = nan(size(allUniqueDepths(allUniqueDepths>highestDepth)));

        % interpolate stress values
        eval(sprintf('interpolatedStress%d = interp1(depth%d,stress%d,interpolationDepth);',pillar,pillar,pillar))
        eval(sprintf('interpolatedStress%d = [interpolatedStress%d otherValues];',pillar,pillar))
        eval(sprintf('allStresses(pillar,:) = interpolatedStress%d;',pillar))

        % interpolate standard deviation values
        eval(sprintf('interpolatedVariance%d = interp1(depth%d,variance%d,interpolationDepth);',pillar,pillar,pillar))
        eval(sprintf('interpolatedVariance%d = [interpolatedVariance%d otherValues];',pillar,pillar))
        eval(sprintf('allVariances(pillar,:) = interpolatedVariance%d;',pillar))
    end

    allStresses = mean(allStresses,'omitnan');
    allVariances = mean(allVariances,'omitnan');
    allStdDevs = sqrt(allVariances);

    validPoints = ~isnan(allStresses+allStdDevs);
    allStdDevsX = [allUniqueDepths(validPoints), fliplr(allUniqueDepths(validPoints))];
    allStdDevsY = [allStresses(validPoints) + allStdDevs(validPoints), fliplr(allStresses(validPoints) - allStdDevs(validPoints))];

    figure
    hold on
    set(gcf,'WindowState','maximized')
    % set(gcf,'InnerPosition',[0 0 1 1])
    set(gcf,'Menu','none','ToolBar','none')

    set(gca,'FontSize',16)
    set(gca, 'FontName', 'Times New Roman')

    plot(allUniqueDepths,allStresses,'LineWidth',3)
    fill(allStdDevsX,allStdDevsY,'b','FaceAlpha',0.2,'EdgeColor','none')
    
    % Setting limits of the stress axis
    if ~isempty(lowerLimitStress) && ~isempty(higherLimitStress)
        ylim([lowerLimitStress higherLimitStress])
    elseif isempty(lowerLimitStress) && ~isempty(higherLimitStress)
        ylim([-inf higherLimitStress])
    elseif ~isempty(lowerLimitStress) && isempty(higherLimitStress)    
        ylim([lowerLimitStress inf])
    end
    
    xlim([.3 2])

    % vertical line at 0
    yline(0,'k--')
    
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    % title(sprintf('Curves strung together for sample %s', sampleName))
    legend({'Averaged stress','Standard deviation'},'Location','best')
    hold(gca,'off')
    set(gca,'Color','none');

    if saving == true
        strungData = struct('allDepths',allUniqueDepths,'allStresses',allStresses,'allVariances',allVariances, ...
            'allStdDevsX',allStdDevsX,'allStdDevsY',allStdDevsY);
        saveas(gcf, fullfile(resultsDir, sprintf('%s-strung_plots-combined_pillars.jpg',sampleName)))
        filename = 'strung_data-combined.mat';
        save(fullfile(resultsDir,filename),'strungData')
    end
end