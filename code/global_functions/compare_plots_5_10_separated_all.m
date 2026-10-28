% Compare samples parameter by parameter and put the plots in a tiled layout.
% Author: Kento Takahashi
% Last edit: 06/10/2026

% close all

%% Paths
% Add rsdp path
rsdpPath = mfilename("fullpath");
for i = 1:2
    [rsdpPath,~] = fileparts(rsdpPath);
end
addpath(rsdpPath)

rootPath = 'I:\PhD_IDrive\exp\FIB-DIC\dataFIB\DoE';
savingPath = "I:\PhD_IDrive\exp\FIB-DIC\dataFIB\DoE\results\comparisons-tiled-paper\tiled_layout\non_weighted";

%% Options
saving = 1;
weightedMeanOption = 0;
parameterNames = {'disk_speed','diamond_size','duration','load'};
tiledLayoutOption = 1;

% Appearance
globalFontName = 'Liberation Serif';
globalFontSize = 16;
% Depth limits
xAxisLimits = [.2 2.1];
% Residual stress limits
yAxisLimits = [-750 150];

% Colors
colorPalette = {
    'black', ... % Text
    'none', ... % Background
    '#489FB5', ... % Color plot 1
    '#FF8C42', ...
    '#C16200' % Color plot 2
    };

%% Main script
for parameter = parameterNames
    [plot1Name,plot2Name,sample1Names,sample2Names,filenameRoots] = get_names(parameter{1});

    % Plot comparisons
    if tiledLayoutOption
        %% Tiled layout -> 4 comparisons in a 2x2 array
        f = figure;
        t = tiledlayout(2,2);
        for sampleNumber = 1:4
            % Import data
            sample1Path = fullfile(rootPath,sample1Names{sampleNumber});
            sample2Path = fullfile(rootPath,sample2Names{sampleNumber});
    
            if weightedMeanOption
                filename = '5_10_um_separated-linear.mat';
                filePath = fullfile('results', filename);
                sample1Data = load(fullfile(sample1Path,filePath)).weightedData;
                sample2Data = load(fullfile(sample2Path,filePath)).weightedData;
            else
                filename = '5_10_um_separated.mat';
                filePath = fullfile('results', filename);
                sample1Data = load(fullfile(sample1Path,filePath)).data;
                sample2Data = load(fullfile(sample2Path,filePath)).data;
            end

            ax = nexttile(t);
            hold(ax,'on')
            
            if weightedMeanOption
                % Stresses
                plot(ax,[sample1Data.depths5;sample1Data.depths10],[sample1Data.stresses5;sample1Data.stresses10], 'Color', colorPalette{3}, 'LineWidth', 5)
                plot(ax,[sample2Data.depths5;sample2Data.depths10],[sample2Data.stresses5;sample2Data.stresses10], 'Color', colorPalette{5}, 'LineWidth', 5, 'LineStyle', '-.')
        
                % Standard deviation
                % Sample 1
                fill(ax,sample1Data.stdX5, sample1Data.stdY5, '', 'FaceColor', colorPalette{3}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                fill(ax,sample1Data.stdX10, sample1Data.stdY10, '', 'FaceColor', colorPalette{3}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
        
                % Sample 2
                fill(ax,sample2Data.stdX5, sample2Data.stdY5, '', 'FaceColor', colorPalette{5}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                fill(ax,sample2Data.stdX10, sample2Data.stdY10, '', 'FaceColor', colorPalette{5}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            else
                % Stresses
                plot(ax,sample1Data.depths{1},sample1Data.stresses{1}, 'Color', colorPalette{3}, 'LineWidth', 5)
                plot(ax,sample1Data.depths{2},sample1Data.stresses{2}, 'Color', colorPalette{3}, 'LineWidth', 5,'HandleVisibility','off')
                plot(ax,sample2Data.depths{1},sample2Data.stresses{1}, 'Color', colorPalette{5}, 'LineWidth', 5, 'LineStyle', '-.')
                plot(ax,sample2Data.depths{2},sample2Data.stresses{2}, 'Color', colorPalette{5}, 'LineWidth', 5, 'LineStyle', '-.','HandleVisibility','off')

                % Standard deviation
                % Sample 1
                fill(ax,sample1Data.stdDevX{1},sample1Data.stdDevY{1}, '', 'FaceColor', colorPalette{3}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                fill(ax,sample1Data.stdDevX{2},sample1Data.stdDevY{2}, '', 'FaceColor', colorPalette{3}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');

                % Sample 2
                fill(ax,sample2Data.stdDevX{1},sample2Data.stdDevY{1}, '', 'FaceColor', colorPalette{5}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
                fill(ax,sample2Data.stdDevX{2},sample2Data.stdDevY{2}, '', 'FaceColor', colorPalette{5}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
            end

            hold(ax,'off')
    
            % Plot details
            ax.Box = 'off';
            ax.Color = colorPalette{2};
            ax.XColor = colorPalette{1};
            ax.YColor = colorPalette{1};
            ax.FontSize = globalFontSize;
            ax.FontName = globalFontName;
            grid(ax,'on')
            xlim(ax,xAxisLimits)
            ylim(ax,yAxisLimits)
    
            % Remove ticks for specific tiles
            switch sampleNumber
                case 1
                    ax.XTickLabel = [];
                case 2
                    ax.XTickLabel = [];
                    ax.YTickLabel = [];
                case 4
                    ax.YTickLabel = [];
            end
        end
    
        %% Figure appearance
        if ~strcmp(colorPalette{2},'none')
            f.Color = colorPalette{2};
        end
    
        %% Tiled layout appearance
        % t.Padding = "tight";
        t.TileSpacing = "tight";
    
        % Axes labels
        xLab = xlabel(t,'Depth [µm]');
        xLab.Color = colorPalette{1};
        xLab.FontName = globalFontName;
        xLab.FontSize = globalFontSize;

        yLab = ylabel(t,'Residual Stress [MPa]');
        yLab.Color = colorPalette{1};
        yLab.FontName = globalFontName;
        yLab.FontSize = globalFontSize;
    
        % % Legend
        % legendEntries{1} = plot1Name;
        % legendEntries{2} = plot2Name;
        % lg = legend(legendEntries, 'TextColor',colorPalette{1},'Color',colorPalette{2},'FontName',globalFontName,'FontSize',globalFontSize);%,'Orientation','horizontal');
        % lg.Layout.Tile = 'east';

        if saving
            if weightedMeanOption
                savingFilename = sprintf('%s-comparison-weighted_avg.svg',parameter{1});
            else
                savingFilename = sprintf('%s-comparison-non_weighted.svg',parameter{1});
            end
            exportgraphics(t,fullfile(savingPath,savingFilename),ContentType="vector");

            % savingFilename = sprintf('%s-comparison-weighted_avg.png',parameter{1});
            % saveas(f,fullfile(savingPath,savingFilename))
        end
        % close(f)
    else
        %% Individual plots
        for sampleNumber = 1:4 % there are 4 comparisons
            sample1Path = fullfile(rootPath,sample1Names{sampleNumber});
            sample2Path = fullfile(rootPath,sample2Names{sampleNumber});
            if weightedMeanOption
                savingFilename = sprintf('%s-comparison-5_10_separated-weighted.png',filenameRoots{sampleNumber});
                compare_plots_5_10_separated_weighted(saving,savingPath,savingFilename,sample1Path,sample2Path,plot1Name,plot2Name,xAxisLimits,yAxisLimits)
            else
                % savingFilename = sprintf('%s-comparison-5_10_separated.png',filenameRoots{sampleNumber});
                savingFilename = sprintf('%s-comparison-5_10_separated.svg',filenameRoots{sampleNumber});
                compare_plots_5_10_separated(saving,savingPath,savingFilename,sample1Path,sample2Path,plot1Name,plot2Name,xAxisLimits,yAxisLimits)
            end
        end
    end
end

%% Help functions
function [plot1Name,plot2Name,sample1Names,sample2Names,filenameRoots] = get_names(parameter)
    % Get names of relevant samples for comparisons.
    switch parameter
        case 'disk_speed'
            plot1Name = '50 rpm';
            plot2Name = '150 rpm';

            sample1Names = {'t2-P10-v50-d1','t2-P10-v50-d9','t20-P10-v50-d1','t20-P10-v50-d9'};
            sample2Names = {'t2-P10-v150-d1','t2-P10-v150-d9','t20-P10-v150-d1','t20-P10-v150-d9'};

            filenameRoots = {'t2-P10-d1','t2-P10-d9','t20-P10-d1','t20-P10-d9'};
        case 'diamond_size'
            plot1Name = '1 µm';
            plot2Name = '9 µm';

            sample1Names = {'t2-P10-v50-d1','t2-P10-v150-d1','t20-P10-v50-d1','t20-P10-v150-d1'};
            sample2Names = {'t2-P10-v50-d9','t2-P10-v150-d9','t20-P10-v50-d9','t20-P10-v150-d9'};

            filenameRoots = {'t2-P10-v50','t2-P10-v150','t20-P10-v50','t20-P10-v150'};
        case 'duration'
            plot1Name = '2 min';
            plot2Name = '20 min';

            sample1Names = {'t2-P10-v50-d1','t2-P10-v150-d1','t2-P10-v50-d9','t2-P10-v150-d9'};
            sample2Names = {'t20-P10-v50-d1','t20-P10-v150-d1','t20-P10-v50-d9','t20-P10-v150-d9'};

            filenameRoots = {'P10-v50-d1','P10-v150-d1','P10-v50-d9','P10-v150-d9'};
        case 'load'
            plot1Name = '10 N';
            plot2Name = '20 N';

            sample1Names = {'t2-P10-v50-d9','t2-P10-v150-d9','t20-P10-v50-d9','t20-P10-v150-d9'};
            sample2Names = {'t2-P20-v50-d9','t2-P20-v150-d9','t20-P20-v50-d9','t20-P20-v150-d9'};

            filenameRoots = {'t2-v50-d9','t2-v150-d9','t20-v50-d9','t20-v150-d9'};
    end
end