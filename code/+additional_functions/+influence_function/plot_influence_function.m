function plot_influence_function(factors,normalizedDepth)
    % Plot influence function vs normalized depth for all pillar reduction factors
    % Values of factors:
    % - 1 = unpublished code
    % - 2 = generalised (2019)
    % - 3 = nanoscale (2018)
    % Pillar reduction factor:
    % - 100, 90, ..., 60% for cases 1 and 2
    % - 100, 80, 60% for case 3
    % Author: Kento Takahashi, based on FEM from Enrico Salvati
    % Last edit: 17/09/2026

    figure
    hold on

    for pillarRedFactor = [1,.9,.8,.7,.6]
        parametersInfluenceFunction = get_parameters_influence_function(factors,pillarRedFactor);
        influenceFunction = compute_influence_function(factors,parametersInfluenceFunction,normalizedDepth);
        scatter(normalizedDepth,influenceFunction)
    end
    
    switch factors
        case {1,2}
            legend("100%","90%","80%","70%","60%",Location="northeast");
        case 3
            legend("100%","80%","60%",Location="northeast");
    end
    
    xlabel('h/D')
    ylabel('Influence Function')
    title(sprintf('Influence Function vs Normalized Depth, case %d',factors))
    grid on
    set(gca,"FontSize",16)
    set(gca,"FontName","Times New Roman");
    set(gca,"Color","none")
    ylim([-2 10])
end