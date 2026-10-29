function merge_plots_weighted(samplePath, weightingType, saving, savingPath, xAxisLimits, yAxisLimits, fontName, fontSize)
    % Plot 5 and 10 µm PD results on the same graph.
    % A weighted average is calculated between 0.5 and 1 µm, either linear or adjusted to the influence function.
    % Author: Kento Takahashi - KU Leuven

    arguments
        samplePath string {mustBeFolder}
        weightingType string = 'linear' % 'linear' or 'sensitivity'
        saving (1,1) logical = 0
        savingPath string {mustBeFolder} = fullfile(samplePath, 'results')
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    % Options
    plotColor = '#489fb5';
    axesColor = 'black';

    % Importing other functions
    [functionPath,~] = fileparts(mfilename("fullpath"));
    addpath(functionPath)

    % Automatically detect sample name
    filepath = fullfile('results', 'meanRS.mat');
    [~, data.sampleName] = fileparts(samplePath);
    
    if ~exist(savingPath, 'dir')
        mkdir(savingPath)
    end
    
    % See ..\additional_functions\influence_function\get_parameters_influence_function.m for more details about the value of factors and pillarRedFactor.
    if strcmp(weightingType, 'sensitivity')
        factors = 1;
        pillarRedFactor = .8;
    end

    %% Import data
    pillarsDirs = {fullfile(samplePath,'05um_pillar'), fullfile(samplePath,'10um_pillar')};

    for pillar = 1:length(pillarsDirs)
        fileData = load(fullfile(pillarsDirs{pillar}, filepath)).data;
        data.depth{pillar} = fileData.depth;
        depth = fileData.depth;
        data.stresses{pillar} = fileData.meanRS;
        data.stdDev{pillar} = fileData.stdDev;

        validPoints = ~isnan(data.stresses{pillar} + data.stdDev{pillar});
        data.stdDevX{pillar} = [depth(validPoints); flipud(depth(validPoints))];
        data.stdDevY{pillar} = [data.stresses{pillar}(validPoints) + data.stdDev{pillar}(validPoints); flipud(data.stresses{pillar}(validPoints) - data.stdDev{pillar}(validPoints))];
    end

    %% Weighted mean between 0.5 and 1 µm, linear or adjusted to sensitivity function
    % Data attribution
    depths5 = data.depth{1};
    depths10 = data.depth{2};
    stresses5 = data.stresses{1};
    stresses10 = data.stresses{2};
    stdDev5 = data.stdDev{1};
    stdDev10 = data.stdDev{2};
    
    % Filter in depth range
    filter5 = depths5 >= .5;
    filter10 = depths10 >= .5 & depths10 <= 1;
    
    depthsInterval5 = depths5(filter5);
    depthsInterval5 = depthsInterval5(1:2:end); % 250 values for 5 µm and 125 for 10 µm between 0.5 and 1 µm
    depthsInterval10 = depths10(filter10);
    
    stressesInterval5 = stresses5(filter5);
    stressesInterval5 = stressesInterval5(1:2:end);
    stressesInterval10 = stresses10(filter10);

    stdInterval5 = stdDev5(filter5);
    stdInterval5 = stdInterval5(1:2:end);
    stdInterval10 = stdDev10(filter10);

    % Compute weighted mean and std
    switch weightingType
        case "linear"
            weights5 = linspace(1, 0, size(depthsInterval5,1))';
            weights10 = linspace(0, 1, size(depthsInterval10,1))';
        case "sensitivity"
            parametersInfluenceFunction = get_parameters_influence_function(factors, pillarRedFactor);
            weights5 = compute_influence_function(factors, parametersInfluenceFunction, linspace(.1,.2,size(depthsInterval5,1)))';
            weights10 = compute_influence_function(factors, parametersInfluenceFunction, linspace(.05,.1,size(depthsInterval10,1)))';
    end
    weightedMeanStresses = mean([stressesInterval5 stressesInterval10], 2, 'omitmissing', 'Weights', [weights5 weights10]);
    weightedStdStresses = mean([stdInterval5 stdInterval10], 2, 'omitmissing', 'Weights', [weights5 weights10]);
    % (variance approach) weightedStdStresses = sqrt(weights5.*(stressesInterval5-weightedMeanStresses).^2+weights10.*(stressesInterval10-weightedMeanStresses).^2) 

    %% Plot data with weighted mean
    % Data preparation
    depths5 = depths5(~filter5);
    depths5 = [depths5; depthsInterval5];
    depths10(filter10) = NaN;

    stresses5 = stresses5(~filter5);
    stresses5 = [stresses5; weightedMeanStresses];
    stresses10(filter10) = NaN;

    stdDev5 = stdDev5(~filter5);
    stdDev5 = [stdDev5;weightedStdStresses];
    stdDev10(filter10) = NaN;

    % Standard deviation
    validPoints5 = ~isnan(stresses5+stdDev5);
    depths5 = depths5(validPoints5);
    stresses5 = stresses5(validPoints5);
    stdDev5 = stdDev5(validPoints5);
    stdDevX5 = [depths5; flipud(depths5)];
    stdDevY5 = [stresses5 + stdDev5; flipud(stresses5 - stdDev5)];
    
    validPoints10 = ~isnan(stresses10+stdDev10);
    depths10 = depths10(validPoints10);
    stresses10 = stresses10(validPoints10);
    stdDev10 = stdDev10(validPoints10);
    % stdDev10 starts at end of stdDev5 to leave no gap
    stdDevX10 = [depths5(end); depths10; flipud(depths10); depths5(end)];
    stdDevY10 = [stresses5(end) + stdDev5(end); stresses10 + stdDev10; flipud(stresses10 - stdDev10); stresses5(end) - stdDev5(end)];

    %% Plot
    f = figure;
    hold on

    % Plot RS and standard deviation
    scatter(depths5, stresses5, 20, 'filled', 'MarkerFaceColor', plotColor)
    scatter(depths10, stresses10, 20, 'filled', 'MarkerFaceColor', plotColor, 'HandleVisibility', 'off')
    fill(stdDevX5, stdDevY5, '', 'FaceColor', plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none')
    fill(stdDevX10, stdDevY10, '', 'FaceColor', plotColor, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'HandleVisibility', 'off')

    % Plot details
    xlabel('Depth (µm)')
    ylabel('Residual Stress [MPa]')
    % title(sprintf('Sample %s - Weighted mean between 0.5 and 1 µm', data.sampleName))
    legend({'Averaged stress','Standard deviation'},'Location','southeast')
    hold off
    ax = gca;
    set(ax,'Color','none')
    set(ax,'FontSize',fontSize)
    set(ax,'FontName',fontName)
    set(ax,'Box','off')
    set(ax,'XColor',axesColor)
    set(ax,'YColor',axesColor)
    xlim(xAxisLimits)
    ylim(yAxisLimits)

    % Data struct for export
    depth = [depths5; depths10];
    meanRS = [stresses5; stresses10];
    stdDevX = [depths5; depths10; flipud(depths10); flipud(depths5)];
    stdDevY = [stresses5 + stdDev5; stresses10 + stdDev10; flipud(stresses10 - stdDev10); flipud(stresses5 - stdDev5)];
    mergedData = struct('depth',depth,'meanRS',meanRS,'stdDevX',stdDevX,'stdDevY',stdDevY);

    %% Saving
    if saving
        % Export figure
        figName = sprintf('merged_data-weighted-%s-%s.svg',weightingType,data.sampleName);
        exportgraphics(f,fullfile(savingPath,figName))
        % Save data
        filename = sprintf('merged_data-weighted-%s.mat', weightingType);
        save(fullfile(savingPath,filename),'mergedData')
    end

    %% Show sensitivity function for 5 and 10 µm between 0.5 and 1 µm
    if strcmp(weightingType,'sensitivity')
        % Calculate sensitivity function
        normalizedDepth5 = linspace(.1,.2,125);
        normalizedDepth10 = linspace(.05,.1,125);
        influenceFunction5 = compute_influence_function(factors,parametersInfluenceFunction,normalizedDepth5);
        influenceFunction10 = compute_influence_function(factors,parametersInfluenceFunction,normalizedDepth10);

        % Plot
        depth = linspace(.5,1,125);

        figure
        hold on
        scatter(depth,influenceFunction5)
        scatter(depth,influenceFunction10)
        hold off
        
        xlabel('Depth (µm)')
        ylabel('Influence Function')
        title('Influence Function vs Depth')
        grid on
        set(gca,"FontSize",fontSize)
        set(gca,"FontName",fontName);
        set(gca,"Color","none")
        legend("5 µm","10 µm",'Location','southeast')
    end
end
