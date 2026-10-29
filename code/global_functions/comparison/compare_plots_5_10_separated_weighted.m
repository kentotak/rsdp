function compare_plots_5_10_separated_weighted(sample1Path,sample2Path,plot1Name,plot2Name,saving,savingPath,savingFilename,xAxisLimits,yAxisLimits)
    % Function to compare two samples where the area between 0.5 and 1 µm is averaged with linear weights.
    % This code is meant to be used with the DP app.
    % Author: Kento Takahashi
    % Last edit: 29/09/2026

    arguments
        sample1Path string
        sample2Path string
        plot1Name = 'Sample 1'
        plot2Name = 'Sample 2'
        saving = 0
        savingPath = sample1Path
        savingFilename = sprintf('comparison-plots_5_10_separated-weighted-%s_%s.png',plot1Name,plot2Name)
        xAxisLimits = -inf
        yAxisLimits = inf
    end
    
    %% Data import
    filename = '5_10_um_separated-linear.mat';
    filePath = fullfile('results', filename);
    
    sample1Data = load(fullfile(sample1Path,filePath)).weightedData;
    sample2Data = load(fullfile(sample2Path,filePath)).weightedData;
    
    %% Plot
    f = figure;
    set(gcf,'Menu','none','ToolBar','none')
    
    hold on
    
    % Stresses
    plot([sample1Data.depths5;sample1Data.depths10],[sample1Data.stresses5;sample1Data.stresses10], 'Color', '#489fb5', 'LineWidth', 5)
    plot([sample2Data.depths5;sample2Data.depths10],[sample2Data.stresses5;sample2Data.stresses10], 'Color', '#C16200', 'LineWidth', 5)
    
    % Standard deviation
    % Sample 1
    fill(sample1Data.stdX5, sample1Data.stdY5, '', 'FaceColor', '#489fb5', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(sample1Data.stdX10, sample1Data.stdY10, '', 'FaceColor', '#489fb5', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    % Sample 2
    fill(sample2Data.stdX5, sample2Data.stdY5, '', 'FaceColor', '#C16200', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(sample2Data.stdX10, sample2Data.stdY10, '', 'FaceColor', '#C16200', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    hold off
    
    %% Plot options
    % Figure
    f.Color = '#f0f2ef';
    f.Units = 'centimeters';
    f.InnerPosition = [10 10 17 9];

    % Axes
    ax = gca;
    ax.FontSize = 20;
    ax.FontName = 'Corbel';
    ax.Position = [0.16,0.25,0.82,0.70];
    ax.Color = '#f0f2ef';
    ax.Box = 'off';
    ax.XColor = '#565264';
    ax.YColor = '#565264';
    % x and y axes
    xlabel('Depth [µm]')
    ylabel('Residual Stress [MPa]')
    xlim(xAxisLimits)
    ylim(yAxisLimits)
    
    % Legend
    legendEntries{1} = plot1Name;
    legendEntries{2} = plot2Name;
    legend(legendEntries, 'Location','southeast','TextColor','#565264','Color','#f0f2ef','FontName','Corbel')
    
    %% Saving
    if saving == true
        saveas(gcf,fullfile(savingPath,savingFilename))
    end
end