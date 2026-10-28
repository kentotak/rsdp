function parametersInfluenceFunction = get_parameters_influence_function(factors,pillarRedFactor)
    % Get parameters for the influence function.
    % Values of factors (see in code for more details):
    % - 1 = unpublished code
    % - 2 = generalised (2019)
    % - 3 = nanoscale (2018)
    % Pillar reduction factor:
    % - 100, 90, ..., 60% for cases 1 and 2
    % - 100, 80, 60% for case 3
    % Author: Kento Takahashi, based on FEM from Enrico Salvati
    % Last edit: 13/10/2026 (added arguments definition)

    arguments
        factors (1,1) double % 1, 2 or 3
        pillarRedFactor (1,1) double % 1, .9, ..., .6
    end

    switch factors
        case 1
        % Parameters from previously unpublished code (3rd degree polynomial)
            switch pillarRedFactor
                case 1
                    parametersInfluenceFunction.a = 0.00830034053038588;
                    parametersInfluenceFunction.b = 9.25922162105114;
                    parametersInfluenceFunction.c = -29.6417462628184;
                    parametersInfluenceFunction.d = 52.7012477049435;
                    parametersInfluenceFunction.e = -61.4990443762142;
                case .9
                    parametersInfluenceFunction.a = -0.00945049583207283;
                    parametersInfluenceFunction.b = 4.39489857028253;
                    parametersInfluenceFunction.c = 57.2053013646654;
                    parametersInfluenceFunction.d = -478.701839023408;
                    parametersInfluenceFunction.e = 1048.52238184067;
                case .8
                    parametersInfluenceFunction.a = -0.000990981823284585;
                    parametersInfluenceFunction.b = 2.01310949415724;
                    parametersInfluenceFunction.c = 73.2269852005373;
                    parametersInfluenceFunction.d = -473.693634336682;
                    parametersInfluenceFunction.e = 901.051810968267;
                case .7
                    parametersInfluenceFunction.a = 0.000869681387113860;
                    parametersInfluenceFunction.b = 1.38191730352271;
                    parametersInfluenceFunction.c = 63.6764174007203;
                    parametersInfluenceFunction.d = -350.436721347812;
                    parametersInfluenceFunction.e = 580.442082093759;
                case .6
                    parametersInfluenceFunction.a = 0.000993471878818204;
                    parametersInfluenceFunction.b = 1.16867051444566;
                    parametersInfluenceFunction.c = 54.2916125035276;
                    parametersInfluenceFunction.d = -263.845816970949;
                    parametersInfluenceFunction.e = 386.769477697306;
                otherwise
                    error('Unsupported pillar reduction factor: %.3g.', pillarRedFactor);
            end
        case 2
            % Pillar reduction factors from Generalised ... (2019) (3rd degree pol + exp)
            switch pillarRedFactor
                case 1
                    parametersInfluenceFunction.a = 1.882;
                    parametersInfluenceFunction.b = -7.388;
                    parametersInfluenceFunction.c = -1.174e1;
                    parametersInfluenceFunction.d = 8.223e-1;
                    parametersInfluenceFunction.e = 0;
                case .9
                    parametersInfluenceFunction.a = 1.077e1;
                    parametersInfluenceFunction.b = 6.897;
                    parametersInfluenceFunction.c = 5.858e1;
                    parametersInfluenceFunction.d = 1.003;
                    parametersInfluenceFunction.e = 0;
                case .8
                    parametersInfluenceFunction.a = 9.633;
                    parametersInfluenceFunction.b = 7.975;
                    parametersInfluenceFunction.c = 6.099e1;
                    parametersInfluenceFunction.d = -6.146e-1;
                    parametersInfluenceFunction.e = 0;
                case .7
                    parametersInfluenceFunction.a = 1.126e1;
                    parametersInfluenceFunction.b = 9.872;
                    parametersInfluenceFunction.c = 1.663e1;
                    parametersInfluenceFunction.d = -2.265e2;
                    parametersInfluenceFunction.e = 0;
                case .6
                    parametersInfluenceFunction.a = 1.066e1;
                    parametersInfluenceFunction.b = 9.349;
                    parametersInfluenceFunction.c = 5.446;
                    parametersInfluenceFunction.d = -2.406e2;
                    parametersInfluenceFunction.e = 0;
                otherwise
                    error('Unsupported pillar reduction factor: %.3g.', pillarRedFactor);
            end
        case 3
            % Pillar reduction factors from Nanoscale ... (2018) (2nd degree pol + exp)
            switch pillarRedFactor
                case 1
                    parametersInfluenceFunction.alpha = 7.575;
                    parametersInfluenceFunction.beta = -1.512;
                    parametersInfluenceFunction.gamma = 16.452;
                case .8
                    parametersInfluenceFunction.alpha = 8.813;
                    parametersInfluenceFunction.beta = 6.647;
                    parametersInfluenceFunction.gamma = 53.852;
                case .6
                    parametersInfluenceFunction.alpha = 7.944;
                    parametersInfluenceFunction.beta = 7.618;
                    parametersInfluenceFunction.gamma = 50.940;
                otherwise
                    error('Unsupported pillar reduction factor: %.3g.', pillarRedFactor);
            end
    end
end