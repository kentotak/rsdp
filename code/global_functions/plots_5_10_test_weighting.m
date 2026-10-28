function plots_5_10_test_weighting(samplePath,saving,weightedMeanOption,weightedMeanType,polyFitOption,polyDegree,xAxisLimits,yAxisLimits)
    % Plot 5 and 10 µm PD results on the same graph.
    % A polynomial fit can be added and a weighted average, either linear or adjusted to the
    % influence function can be calculated between 0.5 and 1 µm.
    % Author: Kento Takahashi
    % Date of last edit: 29/09/2026

    arguments
        samplePath string
        saving = 0
        weightedMeanOption = 0
        weightedMeanType = 'linear'
        polyFitOption = 0
        polyDegree = 3
        xAxisLimits = [-inf inf]
        yAxisLimits = [-inf inf]
    end

    % Options
    globalFontName = 'Liberation Serif';
    globalFontSize = 28;
    plotColor = '#489fb5';

    % Importing other functions
    [functionPath,~] = fileparts(mfilename("fullpath"));
    addpath(functionPath)

    % Sample name
    filepath = fullfile('results', 'meanRS.mat');
    [~, data.sampleName] = fileparts(samplePath);

    % Creating the directory for saving the plots
    resultsDir = fullfile(samplePath, 'results');

    if ~exist(resultsDir, 'dir')
        mkdir(resultsDir)
    end
    
    % See ..\get_parameters_influence_function.m for more details about the value of factors
    % and pillarRedFactor.
    if strcmp(weightedMeanType,'sensitivity')
        factors = 1;
        pillarRedFactor = .8;
    end

    %% Import data
    pillarsDirs = {fullfile(samplePath,'05um_pillar'),fullfile(samplePath,'10um_pillar')};

    for pillar = 1:length(pillarsDirs)
        fileData = load(fullfile(pillarsDirs{pillar},filepath));
        data.depths{pillar} = fileData.depth;
        depth = fileData.depth;
        data.stresses{pillar} = fileData.meanRS;
        stress = fileData.meanRS;
        data.stdDev{pillar} = sqrt(fileData.variance);

        validPoints = ~isnan(stress + data.stdDev{pillar});
        data.stdDevX{pillar} = [depth(validPoints); flipud(depth(validPoints))];
        data.stdDevY{pillar} = [stress(validPoints) + data.stdDev{pillar}(validPoints); flipud(stress(validPoints) - data.stdDev{pillar}(validPoints))];
        
        % 2nd order polynomial fit
        if polyFitOption
            [data.p{pillar},data.S{pillar}] = polyfit(depth,stress,polyDegree);
        end
    end

    %% Plot 5 and 10 µm on the same graph
    for profile = 1:length(pillarsDirs)/2
        figure
        % Create a tiled layout if a weighted average is computed. Useful for comparisons.
        if weightedMeanOption
            t = tiledlayout(1,2);
            t.XLabel.String = 'Depth (µm)';
            t.XLabel.FontSize = globalFontSize;
            t.XLabel.FontName = globalFontName;
            t.TileSpacing = 'compact';
            % titleTiledLayout = title(t,sprintf('Sample %s', data.sampleName));
            % titleTiledLayout.FontSize = 24;
            % titleTiledLayout.FontName = 'Liberation Serif';
            nexttile
        end
        hold on
    
        % Plot RS and standard deviation
        for i = 1:2
            scatter(data.depths{i},data.stresses{i},20,'filled','MarkerFaceColor',plotColor)
            fill(data.stdDevX{i},data.stdDevY{i},'','FaceColor',plotColor,'FaceAlpha',0.2,'EdgeColor','none')
        end
        grid on

        % Plot polynomial fit (not maintained since 04/2026)
        if polyFitOption
            hold on
            pillarsNames = ["5 µm pillar", "10 µm pillar"];
            for i = 1:2
                xFit = linspace(min(data.depths{i}), max(data.depths{i}), 100);
                yFit = polyval(data.p{i}, xFit);
                plot(xFit, yFit, 'r-', 'LineWidth', 2, 'DisplayName', sprintf('Polynomial fit (order %d) for %s', polyDegree, pillarsNames(i)));
                % Show equation and r squared value at the end of the plot
                if polyDegree == 2
                    text(max(data.depths{i}), yFit(end), sprintf('y = %.2fx^2 + %.2fx + %.2f', data.p{i}(1), data.p{i}(2), data.p{i}(3)), 'FontSize', 12, 'Color', 'r', 'VerticalAlignment', 'bottom');
                elseif polyDegree == 3
                    text(max(data.depths{i}), yFit(end), sprintf('y = %.2fx^3 + %.2fx^2 + %.2fx + %.2f', data.p{i}(1), data.p{i}(2), data.p{i}(3), data.p{i}(4)), 'FontSize', 12, 'Color', 'r', 'VerticalAlignment', 'bottom');
                end
                text(max(data.depths{i}), yFit(end) - 10, sprintf('R^2 = %.2f', data.S{i}.rsquared), 'FontSize', 12, 'Color', 'r', 'VerticalAlignment', 'top');
                % Predict value of x>1 for which y = 0
                xZero = fzero(@(x) polyval(data.p{i}, x), 1);
                plot(xZero, 0, 'ko', 'MarkerFaceColor', 'g', 'DisplayName', 'x where y=0');
            end
        end

        % Plot details
        xlim(xAxisLimits)
        ylim(yAxisLimits)
        % xlabel('Depth (µm)')
        ylabel('Residual Stress [MPa]')
        % title(sprintf('Sample %s', data.sampleName))
        % legend({'Averaged stress','Standard deviation'},'Location','southeast')
        hold off
        ax = gca;
        set(ax,'Color','none')
        set(ax,'FontSize',globalFontSize)
        set(ax,'FontName',globalFontName)
        set(ax,'Box','off')

        % Saving
        if saving == true
            saveas(gcf, fullfile(resultsDir, sprintf('5_10_um_profiles_separated-%s.png',data.sampleName)))
            filename = '5_10_um_separated.mat';
            save(fullfile(resultsDir,filename),'data')
        end
    end

    %% Weighted mean between 0.5 and 1 µm, linear or adjusted to sensitivity function
    if weightedMeanOption
        % Data attribution
        depths5 = data.depths{1};
        depths10 = data.depths{2};
        stresses5 = data.stresses{1};
        stresses10 = data.stresses{2};
        std5 = data.stdDev{1};
        std10 = data.stdDev{2};
        
        % Filter in depth range
        filter5 = depths5 >= .5;
        filter10 = depths10 >= .5 & depths10 <= 1;
        
        depthsInterval5 = depths5(filter5);
        depthsInterval5 = depthsInterval5(1:2:end); % 250 values for 5 µm and 125 for 10 µm between 0.5 and 1 µm
        depthsInterval10 = depths10(filter10);
        
        stressesInterval5 = stresses5(filter5);
        stressesInterval5 = stressesInterval5(1:2:end);
        stressesInterval10 = stresses10(filter10);

        stdInterval5 = std5(filter5);
        stdInterval5 = stdInterval5(1:2:end);
        stdInterval10 = std10(filter10);

        % Compute weighted mean and std
        switch weightedMeanType
            case "linear"
                weights5 = linspace(1,0,size(depthsInterval5,1))';
                weights10 = linspace(0,1,size(depthsInterval10,1))';
            case "sensitivity"
                parametersInfluenceFunction = get_parameters_influence_function(factors,pillarRedFactor);
                weights5 = compute_influence_function(factors,parametersInfluenceFunction,linspace(.1,.2,size(depthsInterval5,1)))';
                weights10 = compute_influence_function(factors,parametersInfluenceFunction,linspace(.05,.1,size(depthsInterval10,1)))';
        end
        weightedMeanStresses = mean([stressesInterval5 stressesInterval10],2,'omitmissing','Weights',[weights5 weights10]);
        weightedStdStresses = mean([stdInterval5 stdInterval10],2,'omitmissing','Weights',[weights5 weights10]);
        % (variance approach) weightedStdStresses = sqrt(weights5.*(stressesInterval5-weightedMeanStresses).^2+weights10.*(stressesInterval10-weightedMeanStresses).^2) 

        %% Plot data with weighted mean
        % Data preparation
        depths5 = depths5(~filter5);
        depths5 = [depths5;depthsInterval5];
        depths10(filter10) = NaN;

        stresses5 = stresses5(~filter5);
        stresses5 = [stresses5;weightedMeanStresses];
        stresses10(filter10) = NaN;

        std5 = std5(~filter5);
        std5 = [std5;weightedStdStresses];
        std10(filter10) = NaN;

        % Standard deviation
        validPoints5 = ~isnan(stresses5+std5);
        depths5 = depths5(validPoints5);
        stresses5 = stresses5(validPoints5);
        std5 = std5(validPoints5);
        stdX5 = [depths5; flipud(depths5)];
        stdY5 = [stresses5 + std5; flipud(stresses5 - std5)];
        
        validPoints10 = ~isnan(stresses10+std10);
        depths10 = depths10(validPoints10);
        stresses10 = stresses10(validPoints10);
        std10 = std10(validPoints10);
        % std10 starts at end of std5 to leave no gap
        stdX10 = [depths5(end); depths10; flipud(depths10); depths5(end)];
        stdY10 = [stresses5(end) + std5(end); stresses10 + std10; flipud(stresses10 - std10); stresses5(end) - std5(end)];

        nexttile % See comment on tiled layout
        hold on

        % Plot RS and standard deviation
        scatter(depths5,stresses5,20,'filled','MarkerFaceColor',plotColor)
        scatter(depths10,stresses10,20,'filled','MarkerFaceColor',plotColor,'HandleVisibility','off')
        fill(stdX5,stdY5,'','FaceColor',plotColor,'FaceAlpha',0.2,'EdgeColor','none')
        fill(stdX10,stdY10,'','FaceColor',plotColor,'FaceAlpha',0.2,'EdgeColor','none','HandleVisibility','off')

        % Plot details
        % xlabel('Depth (µm)')
        % ylabel('Residual Stress [MPa]')
        % title(sprintf('Sample %s - Weighted mean between 0.5 and 1 µm', data.sampleName))
        legend({'Averaged stress','Standard deviation'},'Location','northwest','Color','white')
        hold off
        ax = gca;
        set(ax,'Color','none')
        set(ax,'FontSize',globalFontSize)
        set(ax,'FontName',globalFontName)
        set(ax,'Box','off')
        set(ax,'YTickLabel',[])
        xlim(xAxisLimits)
        ylim(yAxisLimits)
        grid on

        % Data struct for export
        weightedData = struct("depths5",depths5,"depths10",depths10, ...
        "stresses5",stresses5,"stresses10",stresses10, ...
        "stdX5",stdX5,"stdX10",stdX10,"stdY5",stdY5,"stdY10",stdY10);

        % Saving
        if saving
            saveas(gcf,fullfile(resultsDir,sprintf('[weighted][%s]5_10_um_profiles_separated-%s.png',weightedMeanType,data.sampleName)))
            filename = sprintf('5_10_um_separated-%s.mat', weightedMeanType);
            save(fullfile(resultsDir,filename),'weightedData')
        end

        %% Show sensitivity function for 5 and 10 µm between 0.5 and 1 µm
        if strcmp(weightedMeanType,'sensitivity')
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
            set(gca,"FontSize",16)
            set(gca,"FontName","Times New Roman");
            set(gca,"Color","none")
            legend("5 µm","10 µm",'Location','southeast')
        end
    end
end
