% Purpose: Depth profiling code for the equibiaxial case. This code is meant to be used in the DP app.
% Authors: Kento Takahashi (KU Leuven, Belgium) and Enrico Salvati (University of Udine, Italy)
% Date of last change: 25/11/2025

function DP_equibiaxial(saving,path,strainFile,imagesDirection,pillarDiameter,stepSize,pillarRedFactor,xData,xLowBound,xHighBound,yLowBound,yHighBound, ...
    pointsSpan,polynomialDegree,elasticModulus,poissonRatio)
    %% Results directory
    if saving == true
        resultsDir = fullfile(path, 'results', 'depth_profiling', imagesDirection);
        
        % Checking if it exists
        if ~exist(resultsDir, 'dir')
            mkdir(resultsDir)
        end
    end

    % % Converting depending on x axis
    % if strcmp(xData,'Depth')
    %     xLowBound = xLowBound/pillarDiameter;
    %     xHighBound = xHighBound/pillarDiameter;
    % end
    
    % Load strain
    if isfile(strainFile)
        strainMatrix = load(strainFile);
    else
        msgbox(sprintf('Strain file %s not found.',strainFileName))
        return
    end

    % Create uncertainty matrices
    uncertaintyNormalizedDepth = 1e-6*ones(size(strainMatrix));
    errorStrain = 1e-6*ones(size(strainMatrix));
    % try
    %     errorStrain = num2cell(read_csv(fullfile(directionDirectory, 'error_strain.csv')));
    % catch
    %     errorStrain = num2cell(zeros(size(strainMatrix)));
    % end
    
    %% Data pre-treatment
    % Reshape data and transform to array
    % errorStrain = reshape([errorStrain{:}], size(errorStrain))';
    % uncertaintyNormalizedDepth = reshape([uncertaintyNormalizedDepth{:}], size(uncertaintyNormalizedDepth))';
    
    % Variables definition
    % stepSize = uncertaintyNormalizedDepthReworked.meanDepth;
    depth = (strainMatrix(:, 1)-1)*stepSize; % The first column of the strain file is the image number
    strainRelief = strainMatrix(:, 2); % The second column of the strain file is the strain relief
    normalizedDepth = depth./pillarDiameter;
    
    
    %% Influence factors
    if pillarRedFactor == 1
        alpha = 7.575;
        beta = -1.512;
        gamma = 16.452;
    elseif pillarRedFactor == .8
        alpha = 8.813;
        beta = 6.647;
        gamma = 53.852;
    elseif pillarRedFactor == .6
        alpha = 7.944;
        beta = 7.618;
        gamma = 50.94;
    end
    
    %% Calculation of parameters (eigenstrain, h/D differences, ...)
    % Data regularisation
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
    Ftemp = exp(-alpha*midNormalizedDepth).*(alpha-beta+(alpha*beta+2*gamma)*midNormalizedDepth-alpha*gamma*midNormalizedDepth.^2);
    
    eps(1:length(deltaSRCurveSmoothed)) = -Gtemp./Ftemp; % eps is the residual elastic strain, which is the opposite of the eigenstrain
    depthShift = midNormalizedDepth*pillarDiameter;
    
    %% Fitting of two points at a time
    for i = 1:(length(normalizedDepth)-1)
        reducedNormalizedDepth = [normalizedDepth(i)  normalizedDepth(i+1)];
        reducedEps = [SRCurveSmoothed(i)  SRCurveSmoothed(i+1)];
        reducedErrorStrain = [errorStrain(i)  errorStrain(i+1)];
        reducedErrorNormalizedDepth = [uncertaintyNormalizedDepth(i)  uncertaintyNormalizedDepth(i+1)];
    
        % Linear fit between 2 points with errors on normalized depth and strain
        [~, sp, lower, upper, xplot] = linfitxy(reducedNormalizedDepth, reducedEps, reducedErrorNormalizedDepth, ...
            reducedErrorStrain, 'Verbosity', 0);
    
        lower_bandc(i,:) = lower;
        upper_bandc(i,:) = upper;
        delta_band(i) = sp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.
        
        deltaStrain(i) = delta_band(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        upperStrain(i) = eps(i) + deltaStrain(i);
        lowerStrain(i) = eps(i) - deltaStrain(i);
        x_error(i,:) = xplot; % This is chi2 (goodness-of-fit)
    end
    
    % close % linfitxy opens a figure by default
    
    
    %% Plotting the smoothed strain relief
    figure
    plot(normalizedDepth, SRCurveSmoothed, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, strainRelief, 'b.-', 'LineWidth', 2)
    
    % for i = 1:(length(normalizedDepth)-1)
    %     plot (squeeze(x_error(i,:)), squeeze(lower_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    %     hold on
    %     plot (squeeze(x_error(i,:)), squeeze(upper_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    % end
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(strainRelief)-5e-4 max(strainRelief)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('strain_relief_profile-%s.jpg', strainDirection)));
    end
    
    % Define limits
    for i = 1:(length(normalizedDepth)-1)
        if upperStrain(i) == 0
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
        % Only keeping values if h/D in interval
        if (midNormalizedDepth(i)<xLowBound)||(midNormalizedDepth(i)>xHighBound)||midNormalizedDepth(i) == 0||depthShift(i) == 0
            midNormalizedDepth(i) = nan;
            depthShift(i) = nan;
            eps(i) = nan;
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
    end
    
    %% Interpolations + calculation of stress
    % (assuming elastic isotropy!)
    x = linspace(0, xHighBound, 500);
    
    [midNormalizedDepthWithoutNaN, epsWithoutNaN, upperStrainWithoutNaN, lowerStrainWithoutNaN] = removeNaNColumns( ...
        midNormalizedDepth, eps, upperStrain, lowerStrain);
    
    strain = interp1(midNormalizedDepthWithoutNaN, epsWithoutNaN, x, 'linear');
    upperStrain = interp1(midNormalizedDepthWithoutNaN, upperStrainWithoutNaN, x, 'linear');
    lowerStrain = interp1(midNormalizedDepthWithoutNaN, lowerStrainWithoutNaN, x, 'linear');
    
    % Stress computation
    stress = (elasticModulus*1000.*strain)./(1-poissonRatio);
    upperStress = (elasticModulus*1000.*upperStrain)./(1-poissonRatio);
    lowerStress = (elasticModulus*1000.*lowerStrain)./(1-poissonRatio);
    deltaStress = (upperStress - lowerStress)./2;
    
    %% Residual Stress Plots
    figure
    set(gcf,'WindowState','maximized')
    % plot(x, stress,'LineWidth', 1);
    
    % hold on
    % 
    % yline(0,'k--')
    % 
    % Calculation
    meanStrain = mean(strain, 1, 'omitnan');
    meanStress = (elasticModulus*1000.*meanStrain)./(1-poissonRatio);
    squaredError = deltaStress.^2;
    elements = length(errorStrain) - sum(isnan(squaredError));
    errorStress = sqrt(sum(squaredError, 2))./elements; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    maxErrorStress = meanStress + errorStress;
    minErrorStress = meanStress - errorStress;
    
    % Plotting
    % plot([x x], [maxErrorStress minErrorStress], 'b', 'LineStyle', '--');
    plot(x, meanStress, 'b', 'LineWidth', 3);
    
    if ~isempty(yLowBound) && ~isempty(yHighBound)
        ylim([yLowBound yHighBound])
    elseif isempty(yLowBound) && ~isempty(yHighBound)
        ylim([-inf yHighBound])
    elseif ~isempty(yLowBound) && isempty(yHighBound)    
        ylim([yLowBound inf])
    end
    
    % lgd = legend(sprintf('D = %d um', pillarDiameter), 'Confidence band limits', 'Averaged profile');
    % lgd = legend('')
    % lgd.Location = 'best';
    title('Residual stress depth profile.')
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Residual Stress [MPa]')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('RS_profile-%s.jpg', strainDirection)));
    end
    
    hold off
    
    if saving == true
        filename = sprintf('residualStress-%s.mat', strainDirection);
        normalizedDepth = x;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','stress','pillarDiameter')
    end
end
