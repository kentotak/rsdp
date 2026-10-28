function compare_plots_5_10_separated(saving,savingPath,savingFilename,sample1Path,sample2Path,plot1Name,plot2Name,xAxisLimits,yAxisLimits)
    % Function to compare two samples.
    % This code is meant to be used with the DP app.
    % Author: Kento Takahashi
    % Last edit: 23/09/2026

    %% Options
    globalFontName = 'Liberation Serif';
    globalFontSize = 20;
    plot1Color = '#489FB5';
    plot2Color = '#C16200';

    %% Compare 2 full curves
    % Data import
    filename = '5_10_um_separated.mat';
    filePath = fullfile('results', filename);

    data{1} = load(fullfile(sample1Path,filePath)).data;
    data{2} = load(fullfile(sample2Path,filePath)).data;

    % Plotting
    f = figure;
    hold on

    set(gcf,'Units','centimeters')
    set(gcf,'InnerPosition',[10 10 17 9])
    set(gcf,'Menu','none','ToolBar','none')

    % Stresses
    % Sample 1
    plot(data{1}.depths{1}, data{1}.stresses{1}, 'Color', plot1Color, 'LineWidth', 5)
    plot(data{1}.depths{2}, data{1}.stresses{2}, 'Color', plot1Color, 'LineWidth', 5)
    
    % Sample 2
    plot(data{2}.depths{1}, data{2}.stresses{1}, 'Color', plot2Color, 'LineWidth', 5)
    plot(data{2}.depths{2}, data{2}.stresses{2}, 'Color', plot2Color, 'LineWidth', 5)

    legendEntries{1} = plot1Name;
    legendEntries{2} = '';
    legendEntries{3} = plot2Name;

    % Standard deviation
    % Sample 1
    fill(data{1}.stdDevX{1}, data{1}.stdDevY{1}, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(data{1}.stdDevX{2}, data{1}.stdDevY{2}, '', 'FaceColor', plot1Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    % Sample 2
    fill(data{2}.stdDevX{1}, data{2}.stdDevY{1}, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    fill(data{2}.stdDevX{2}, data{2}.stdDevY{2}, '', 'FaceColor', plot2Color, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

    hold off

    ax = gca;
    ax.FontSize = globalFontSize;
    ax.FontName = globalFontName;
    ax.Position = [0.16,0.25,0.82,0.70];
    % set(ax,'FontSize', 16, 'FontName', 'Times New Roman', 'Position', [0.13 0.2 0.85 0.8])
    ax.Color = 'none';
    ax.Box = 'off';

    legend(legendEntries, 'Location','southeast')
    xlabel('Depth [µm]')
    ylabel('Residual Stress [MPa]')

    xlim(xAxisLimits)
    ylim(yAxisLimits)

    if saving == true
        if isempty(savingFilename)
            saveas(gcf,fullfile(savingPath,sprintf('comparison-plots_5_10_separated-%s_%s.png',plot1Name,plot2Name)))
        else
            [~,~,ext] = fileparts(savingFilename);
            if strcmp(ext,'svg')
                exportgraphics(f,fullfile(savingPath, savingFilename))
            else
                saveas(gcf, fullfile(savingPath, savingFilename));
            end
        end
    end
end