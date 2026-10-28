function DP_equibiaxial(path,strainFile,pillarDiameter,stepSize,pillarRedFactor,elasticModulus,poissonRatio,saving,seriesName,scanDirection,xAxisData,xAxisLimits,yAxisLimits,pointsSpan,polynomialDegree,normalizedDepthLimits,fontName,fontSize)
    % Depth profiling of residual stresses - Equibiaxial case.
    % This code is meant to be used with the Matlab application rsdp.
    % Authors: Kento Takahashi (KU Leuven, Belgium) and Enrico Salvati (University of Udine, Italy)
    % Date of last change: 13/10/2026 (added arguments definition)

    arguments
        path string {mustBeFolder}
        strainFile string {mustBeFile}
        pillarDiameter double {mustBeNonempty}
        stepSize double {mustBeNonempty}
        pillarRedFactor double {mustBeNonempty}
        elasticModulus double {mustBeNonempty}
        poissonRatio double {mustBeNonempty}
        saving (1,1) logical = 0
        seriesName string = ''
        scanDirection double = 0
        xAxisData string = "normalizedDepth"
        xAxisLimits (1,2) double = [-inf inf]
        yAxisLimits (1,2) double = [-inf inf]
        pointsSpan (1,1) double= 6
        polynomialDegree (1,1) double = 3
        normalizedDepthLimits (1,2) double = [.06 .2]
        fontName string = 'Arial'
        fontSize (1,1) double = 20
    end

    %% Options
    plot1Color = '#489fb5';
    plot2Color = '#ff8c42';

    %% Paths
    if saving
        resultsDir = fullfile(path, 'results', 'depth_profiling', num2str(scanDirection));
        if ~exist(resultsDir, 'dir')
            mkdir(resultsDir)
        end
    end
    
    %% Data import
    if isfile(strainFile)
        strainMatrix = load(strainFile);
    else
        msgbox(sprintf('Strain file %s not found.',strainFile))
        return
    end

    %% Data pre-treatment
    % Create uncertainty matrices
    uncertaintyNormalizedDepth = 1e-6*ones(size(strainMatrix));
    errorStrain = 1e-6*ones(size(strainMatrix));
    
    % Variables definition
    depth = (strainMatrix(:, 1)-1)*stepSize; % The first column of the strain file is the image number
    strainRelief = strainMatrix(:, 2); % The second column of the strain file is the strain relief
    normalizedDepth = depth./pillarDiameter;
    
    %% Influence factors
    factors = 1; % 1 = unpublished code, 2 = generalised... code, 3 = nanoscale... paper
    parametersInfluenceFunction = get_parameters_influence_function(factors,pillarRedFactor);
    
    %% Calculation of parameters (eigenstrain, h/D differences, ...)
    % Data regularization
    strainRelief = strainRelief';
    normalizedDepth = normalizedDepth';
    
    % Calculation of eps
    SRCurveSmoothed = smooth(normalizedDepth,strainRelief,pointsSpan,'sgolay',polynomialDegree); % This smoothes every 6 (pointsSpan) values with a 3rd degree (polynomialDegree) polynomial
    
    % h/D shift and delta calculation
    midNormalizedDepth = nan(1,length(normalizedDepth)-1);
    deltaNormalizedDepth = nan(1,length(normalizedDepth)-1);
    
    for i = 1:(length(normalizedDepth)-1)
       midNormalizedDepth(i) = (normalizedDepth(i) + normalizedDepth(i+1))/2;
       deltaNormalizedDepth(i) = normalizedDepth(i+1) - normalizedDepth(i); % this is the h/D difference
    end

    % Delta eps calculation
    deltaSRCurveSmoothed = nan(1,length(SRCurveSmoothed)-1);
    
    for i = 1:(length(SRCurveSmoothed)-1)
        deltaSRCurveSmoothed(i) = SRCurveSmoothed(i+1) - SRCurveSmoothed(i);
    end
    
    % Replacing 0 with NaN
    for i = 1:(length(normalizedDepth)-1)
        if deltaNormalizedDepth(i) == 0
            deltaNormalizedDepth(i) = nan;
            deltaSRCurveSmoothed(i) = nan;
        end
        if midNormalizedDepth(i) == 0
            midNormalizedDepth(i) = nan;
            deltaSRCurveSmoothed(i) = nan;
        end
    end
     
    %% G(h/D) and F(h/D) influence functions
    eps = nan(size(strainRelief)-1);
    
    Gtemp = deltaSRCurveSmoothed./deltaNormalizedDepth;
    switch factors
        case {1,2}
            a = parametersInfluenceFunction.a;
            b = parametersInfluenceFunction.b;
            c = parametersInfluenceFunction.c;
            d = parametersInfluenceFunction.d;
            e = parametersInfluenceFunction.e;
            switch factors
                case 1
                    Ftemp = b + c*midNormalizedDepth + d*midNormalizedDepth.^2 + e*midNormalizedDepth.^3;
                case 2
                    Ftemp = exp(-a*midNormalizedDepth).*(a-b+(2*c+a*b)*midNormalizedDepth-(3*d+a*c)*midNormalizedDepth.^2+a*d*midNormalizedDepth.^3);
            end
        case 3
            alpha = parametersInfluenceFunction.alpha;
            beta = parametersInfluenceFunction.beta;
            gamma = parametersInfluenceFunction.gamma;
            Ftemp = exp(-alpha*midNormalizedDepth).*(alpha-beta+(alpha*beta+2*gamma)*midNormalizedDepth-alpha*gamma*midNormalizedDepth.^2);
    end

    eps(1:length(deltaSRCurveSmoothed)) = -Gtemp./Ftemp; % eps is the residual elastic strain, which is the opposite of the eigenstrain
    depthShift = midNormalizedDepth*pillarDiameter;
    
    %% Fit two points by two points
    for i = 1:(length(normalizedDepth)-1)
        reducedNormalizedDepth = [normalizedDepth(i)  normalizedDepth(i+1)];
        reducedEps = [SRCurveSmoothed(i)  SRCurveSmoothed(i+1)];
        reducedErrorStrain = [errorStrain(i)  errorStrain(i+1)];
        reducedErrorNormalizedDepth = [uncertaintyNormalizedDepth(i)  uncertaintyNormalizedDepth(i+1)];
    
        % Linear fit between 2 points with errors on normalized depth and strain
        [~, sp, lower, upper, xplot] = linfitxy(reducedNormalizedDepth, reducedEps, reducedErrorNormalizedDepth, reducedErrorStrain, 'Verbosity', 0);
    
        lower_bandc(i,:) = lower;
        upper_bandc(i,:) = upper;
        delta_band(i) = sp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.
        
        deltaStrain(i) = delta_band(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        upperStrain(i) = eps(i) + deltaStrain(i);
        lowerStrain(i) = eps(i) - deltaStrain(i);
        x_error(i,:) = xplot; % This is chi2 (goodness-of-fit)
    end
    
    % close % linfitxy opens a figure by default
    
    
    %% Plot smoothed strain relief
    figure
    hold on

    switch xAxisData
        case 'depth'
            plot(depth, strainRelief, 'Color', plot1Color, 'LineWidth', 3)
            plot(depth, SRCurveSmoothed, 'Color', plot2Color, 'LineWidth', 3)
            xlabel('Depth [µm]')
        case 'normalizedDepth'
            plot(normalizedDepth, strainRelief, 'Color', plot1Color, 'LineWidth', 3)
            plot(normalizedDepth, SRCurveSmoothed, 'Color', plot2Color, 'LineWidth', 3)
            xlabel('Normalized depth (h/D)')
    end

    hold off

    % Plot details
    legend('Original Data', 'Smoothed Data', 'Location', 'best')
    % title('Strain relief profile')

    ylabel('Strain Relief')
    ylim([min(strainRelief)-5e-4 max(strainRelief)+5e-4])

    box off
    set(gca, 'Color', 'none')

    set(gca,'FontSize',fontSize)
    set(gca, 'FontName', fontName)

    if saving
        filename = sprintf('strain_relief_profile-%d.jpg', scanDirection);
        saveas(gcf, fullfile(resultsDir, filename));
    end
    
    % Define limits
    for i = 1:(length(normalizedDepth)-1)
        if upperStrain(i) == 0
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
        % Only keeping values if h/D in interval
        if (midNormalizedDepth(i)<min(normalizedDepth))||(midNormalizedDepth(i)>max(normalizedDepth))||midNormalizedDepth(i) == 0||depthShift(i) == 0
            midNormalizedDepth(i) = nan;
            depthShift(i) = nan;
            eps(i) = nan;
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
    end
    
    %% Interpolations + calculation of stress
    % (assuming elastic isotropy!)
    normalizedDepthLinspace = linspace(normalizedDepthLimits(1), normalizedDepthLimits(2), 500);
    
    [midNormalizedDepthWithoutNaN, epsWithoutNaN, upperStrainWithoutNaN, lowerStrainWithoutNaN] = removeNaNColumns( ...
        midNormalizedDepth, eps, upperStrain, lowerStrain);
    
    strain = interp1(midNormalizedDepthWithoutNaN, epsWithoutNaN, normalizedDepthLinspace, 'linear');
    upperStrain = interp1(midNormalizedDepthWithoutNaN, upperStrainWithoutNaN, normalizedDepthLinspace, 'linear');
    lowerStrain = interp1(midNormalizedDepthWithoutNaN, lowerStrainWithoutNaN, normalizedDepthLinspace, 'linear');
    
    % Stress computation
    stress = (elasticModulus*1000.*strain)./(1-poissonRatio);
    upperStress = (elasticModulus*1000.*upperStrain)./(1-poissonRatio);
    lowerStress = (elasticModulus*1000.*lowerStrain)./(1-poissonRatio);
    deltaStress = (upperStress - lowerStress)./2;
    
    %% Residual Stress Plots
    figure('Name',seriesName)
    % set(gcf,'WindowState','maximized')
    
    % hold on
    % yline(0,'k--')

    % Calculation
    meanStress = (elasticModulus*1000.*strain)./(1-poissonRatio);
    squaredError = deltaStress.^2;
    elements = length(errorStrain) - sum(isnan(squaredError));
    errorStress = sqrt(sum(squaredError, 2))./elements; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    maxErrorStress = meanStress + errorStress;
    minErrorStress = meanStress - errorStress;
    
    %% Plot
    switch xAxisData
        case 'depth'
            scatter(normalizedDepthLinspace*pillarDiameter, meanStress, 20, 'filled', 'MarkerFaceColor', plot1Color);
            xlabel('Depth [µm]')
        case 'normalizedDepth'
            scatter(normalizedDepthLinspace, meanStress, 20, 'filled', 'MarkerFaceColor', plot1Color);
            xlabel('Normalized depth (h/D)')
    end
    
    % Plot details
    xlim(xAxisLimits)
    ylim(yAxisLimits)
    
    % title('Residual stress depth profile.')

    ylabel('Residual Stress [MPa]')

    set(gca,'FontSize',fontSize)
    set(gca, 'FontName', fontName)

    set(gca, 'Color', 'none')
    box off
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('RS_profile-%d.jpg', scanDirection)));
    end
    
    hold off
    
    if saving
        filename = sprintf('residualStress-%d.mat', scanDirection);
        normalizedDepth = normalizedDepthLinspace;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','stress','pillarDiameter','strain','meanStress','eps','Gtemp','Ftemp')
    end
end
