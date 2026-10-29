% Plot all data on one graph
path = 'I:\PhD\exp\FIB-DIC\dataFIB\DoE';
dirs = dir(fullfile(path, 't2*'));

figure
hold on
set(gcf,'WindowState','maximized')
set(gca,'FontSize',20)

xlabel('Depth [µm]')
ylabel('Residual Stress [MPa]')
xlim([.2 2.05])

for directory = 1:length(dirs)
    data = load(fullfile(dirs(directory).folder, dirs(directory).name,'results','strung_data-combined.mat'));
    h = plot(data.strungData.allDepths,data.strungData.allStresses,'DisplayName',dirs(directory).name);
    if contains(dirs(directory).name,'d1')
        set(h, 'Color', '#0072BD')
        fill(data.strungData.allStdDevsX, data.strungData.allStdDevsY, '', 'FaceColor', '#0072BD', 'FaceAlpha', 0.2, 'EdgeColor', 'none','HandleVisibility','off');
    else
        set(h,'Color','#D95319')
        fill(data.strungData.allStdDevsX, data.strungData.allStdDevsY, '', 'FaceColor', '#D95319', 'FaceAlpha', 0.2, 'EdgeColor', 'none','HandleVisibility','off');
    end
    if contains(dirs(directory).name,'v150')
        set(h,'LineStyle',':')
    end
    if contains(dirs(directory).name,'t20')
        set(h,'LineWidth',3)
    else
        set(h,'LineWidth',2)
    end
end
legend('Location','best')