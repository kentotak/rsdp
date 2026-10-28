function influenceFunction = compute_influence_function(factors,parametersInfluenceFunction,normalizedDepth)
    % Compute influence function value.
    % Values of factors:
    % - 1 = unpublished code
    % - 2 = generalised (2019)
    % - 3 = nanoscale (2018)
    % Author: Kento Takahashi, based on FEM from Enrico Salvati
    % Last edit: 17/09/2026

    switch factors
        case 1
            influenceFunction = parametersInfluenceFunction.b + parametersInfluenceFunction.c*normalizedDepth + parametersInfluenceFunction.d*normalizedDepth.^2 + parametersInfluenceFunction.e*normalizedDepth.^3;
        case 2
            influenceFunction = exp(-parametersInfluenceFunction.a*normalizedDepth).*(parametersInfluenceFunction.a-parametersInfluenceFunction.b+(2*parametersInfluenceFunction.c+parametersInfluenceFunction.a*parametersInfluenceFunction.b)*normalizedDepth-(3*parametersInfluenceFunction.d+parametersInfluenceFunction.a*parametersInfluenceFunction.c)*normalizedDepth.^2+parametersInfluenceFunction.a*parametersInfluenceFunction.d*normalizedDepth.^3);
        case 3
            influenceFunction = exp(-parametersInfluenceFunction.alpha*normalizedDepth).*(parametersInfluenceFunction.alpha-parametersInfluenceFunction.beta+(parametersInfluenceFunction.alpha*parametersInfluenceFunction.beta+2*parametersInfluenceFunction.gamma)*normalizedDepth-parametersInfluenceFunction.alpha*parametersInfluenceFunction.gamma*normalizedDepth.^2);
    end
end