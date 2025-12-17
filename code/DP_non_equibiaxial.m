% Purpose: Depth profiling code for the non-equibiaxial case. This code is meant to be used in the DP app.
% Authors: Kento Takahashi (KU Leuven, Belgium) and Enrico Salvati (University of Udine, Italy)
% Date of last change: 25/11/2025

function DP_non_equibiaxial(saving,path,xStrainFile,yStrainFile,imagesDirection,pillarDiameter,stepSize,pillarRedFactor,xData,xLowBound,xHighBound, ...
    yLowBound,yHighBound,pointsSpan,polynomialDegree,elasticModulus,poissonRatio)
    %% Saving files
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
    
    % Load strains
    if isfile(xStrainFile)
        xStrainMatrix = load(xStrainFile);
    else
        msgbox(sprintf('Strain file %s not found.',xStrainFile))
        return
    end

    if isfile(yStrainFile)
        yStrainMatrix = load(yStrainFile);
    else
        msgbox(sprintf('Strain file %s not found.',yStrainFile))
        return
    end

    % Create uncertainty matrices
    xUncertaintyNormalizedDepth = 1e-6*ones(size(xStrainMatrix));
    xErrorStrain = 1e-6*ones(size(xStrainMatrix));

    yUncertaintyNormalizedDepth = 1e-6*ones(size(yStrainMatrix));
    yErrorStrain = 1e-6*ones(size(yStrainMatrix));
    
    % Variables definition
    depth = (xStrainMatrix(:, 1)-1)*stepSize; % The first column of the strain file is the image number
    xStrainRelief = xStrainMatrix(:, 2); % The second column of the strain file is the strain relief
    yStrainRelief = yStrainMatrix(:, 2);

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
    xStrainRelief = xStrainRelief';
    yStrainRelief = yStrainRelief';
    normalizedDepth = normalizedDepth';
    
    % Calculation of eps
    xSRCurveSmoothed = smooth(normalizedDepth,xStrainRelief,pointsSpan,'sgolay',polynomialDegree); % This smoothes every 6 (pointsSpan) values with a 3rd degree (polynomialDegree) polynomial
    ySRCurveSmoothed = smooth(normalizedDepth,yStrainRelief,pointsSpan,'sgolay',polynomialDegree);

    % h/D shift and delta calculation
    midNormalizedDepth = nan(1,length(normalizedDepth)-1);
    deltaNormalizedDepth = nan(1,length(normalizedDepth)-1);
    
    for i = 1:(length(normalizedDepth)-1)
       midNormalizedDepth(i) = (normalizedDepth(i) + normalizedDepth(i+1))/2;
       deltaNormalizedDepth(i) = normalizedDepth(i+1) - normalizedDepth(i); % this is the h/D difference
    end

    % Delta eps calculation
    deltaxSRCurveSmoothed = nan(1,length(xSRCurveSmoothed)-1);
    deltaySRCurveSmoothed = nan(1,length(ySRCurveSmoothed)-1);
    
    for i = 1:(length(xSRCurveSmoothed)-1)
        deltaxSRCurveSmoothed(i) = xSRCurveSmoothed(i+1) - xSRCurveSmoothed(i);
    end

    for i = 1:(length(ySRCurveSmoothed)-1)
        deltaySRCurveSmoothed(i) = ySRCurveSmoothed(i+1) - ySRCurveSmoothed(i);
    end
    
    % Replacing 0 with NaN
    for i = 1:(length(normalizedDepth)-1)
        if deltaNormalizedDepth(i) == 0
            deltaNormalizedDepth(i) = nan;
            deltaxSRCurveSmoothed(i) = nan;
            deltaySRCurveSmoothed(i) = nan;
        end
        if midNormalizedDepth(i) == 0
            midNormalizedDepth(i) = nan;
            deltaxSRCurveSmoothed(i) = nan;
            deltaySRCurveSmoothed(i) = nan;
        end
    end
    
    
    %% G(h/D) and F(h/D) influence functions
    xEps = nan(size(xStrainRelief)-1);
    yEps = nan(size(yStrainRelief)-1);
    
    xGtemp = deltaxSRCurveSmoothed./deltaNormalizedDepth;
    yGtemp = deltaySRCurveSmoothed./deltaNormalizedDepth;
    Ftemp = exp(-alpha*midNormalizedDepth).*(alpha-beta+(alpha*beta+2*gamma)*midNormalizedDepth-alpha*gamma*midNormalizedDepth.^2);
    
    xEps(1:length(deltaxSRCurveSmoothed)) = -xGtemp./Ftemp; % eps is the residual elastic strain, which is the opposite of the eigenstrain
    yEps(1:length(deltaySRCurveSmoothed)) = -yGtemp./Ftemp;
    depthShift = midNormalizedDepth*pillarDiameter;
    

    %% Fitting of two points at a time
    for i = 1:(length(normalizedDepth)-1)
        reducedNormalizedDepth = [normalizedDepth(i)  normalizedDepth(i+1)];

        reducedxEps = [xSRCurveSmoothed(i)  xSRCurveSmoothed(i+1)];
        reducedxErrorStrain = [xErrorStrain(i)  xErrorStrain(i+1)];
        reducedxErrorNormalizedDepth = [xUncertaintyNormalizedDepth(i)  xUncertaintyNormalizedDepth(i+1)];

        reducedyEps = [ySRCurveSmoothed(i)  ySRCurveSmoothed(i+1)];
        reducedyErrorStrain = [yErrorStrain(i)  yErrorStrain(i+1)];
        reducedyErrorNormalizedDepth = [yUncertaintyNormalizedDepth(i)  yUncertaintyNormalizedDepth(i+1)];

        % Linear fit between 2 points with errors on normalized depth and strain
        % x data
        [~, xSp, xLower, xUpper, xXplot] = linfitxy(reducedNormalizedDepth, reducedxEps, reducedxErrorNormalizedDepth,reducedxErrorStrain, ...
            'Verbosity', 0);

        xLowerBandc(i,:) = xLower;
        xUpperBandc(i,:) = xUpper;
        xDeltaBand(i) = xSp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.

        xDeltaStrain(i) = xDeltaBand(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        xUpperStrain(i) = xEps(i) + xDeltaStrain(i);
        xLowerStrain(i) = xEps(i) - xDeltaStrain(i);
        xXError(i,:) = xXplot; % This is chi2 (goodness-of-fit)


        % y data
        [~, ySp, yLower, yUpper, yXplot] = linfitxy(reducedNormalizedDepth, reducedyEps, reducedyErrorNormalizedDepth,reducedyErrorStrain, ...
            'Verbosity', 0);

        yLowerBandc(i,:) = yLower;
        yUpperBandc(i,:) = yUpper;
        yDeltaBand(i) = ySp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.

        yDeltaStrain(i) = yDeltaBand(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        yUpperStrain(i) = yEps(i) + yDeltaStrain(i);
        yLowerStrain(i) = yEps(i) - yDeltaStrain(i);
        yXError(i,:) = yXplot; % This is chi2 (goodness-of-fit)
    end
    
    % close % linfitxy opens a figure by default
    
    
    %% Plotting the smoothed strain relief
    % x data
    figure
    plot(normalizedDepth, xSRCurveSmoothed, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, xStrainRelief, 'b.-', 'LineWidth', 2)
    
    % for i = 1:(length(normalizedDepth)-1)
    %     plot (squeeze(x_error(i,:)), squeeze(lower_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    %     hold on
    %     plot (squeeze(x_error(i,:)), squeeze(upper_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    % end
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in x')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(xStrainRelief)-5e-4 max(xStrainRelief)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'strain_relief_profile-x.jpg'));
    end
    
    % y data
    figure
    plot(normalizedDepth, ySRCurveSmoothed, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, yStrainRelief, 'b.-', 'LineWidth', 2)
    
    % for i = 1:(length(normalizedDepth)-1)
    %     plot (squeeze(x_error(i,:)), squeeze(lower_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    %     hold on
    %     plot (squeeze(x_error(i,:)), squeeze(upper_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    % end
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in y')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(yStrainRelief)-5e-4 max(yStrainRelief)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'strain_relief_profile-y.jpg'));
    end


    %% Interpolations + calculation of stress
    % (assuming elastic isotropy!)
    % Define limits
    for i = 1:(length(normalizedDepth)-1)
        if xUpperStrain(i) == 0
            xUpperStrain(i) = nan;
            xLowerStrain(i) = nan;
        end
        if yUpperStrain(i) == 0
            yUpperStrain(i) = nan;
            yLowerStrain(i) = nan;
        end
        % Only keeping values if h/D in interval
        if (midNormalizedDepth(i)<xLowBound)||(midNormalizedDepth(i)>xHighBound)||midNormalizedDepth(i) == 0||depthShift(i) == 0
            midNormalizedDepth(i) = nan;
            depthShift(i) = nan;
            
            xEps(i) = nan;
            xUpperStrain(i) = nan;
            xLowerStrain(i) = nan;

            yEps(i) = nan;
            yUpperStrain(i) = nan;
            yLowerStrain(i) = nan;
        end
    end
    
    x = linspace(0, xHighBound, 500);
    
    % [midNormalizedDepthWithoutNaN, epsWithoutNaN, xUpperStrainWithoutNaN, xLowerStrainWithoutNaN, yUpperStrainWithoutNaN, yLowerStrainWithoutNaN] = removeNaNColumns( ...
    %     midNormalizedDepth, xEps, xUpperStrain, xLowerStrain, yUpperStrain, yLowerStrain);
    [midNormalizedDepthWithoutNaN, xEpsWithoutNaN, yEpsWithoutNaN] = removeNaNColumns(midNormalizedDepth, xEps, yEps);
    
    % x data
    xStrain = interp1(midNormalizedDepthWithoutNaN, xEpsWithoutNaN, x, 'linear');
    % xUpperStrain = interp1(midNormalizedDepthWithoutNaN, xUpperStrainWithoutNaN, x, 'linear');
    % xLowerStrain = interp1(midNormalizedDepthWithoutNaN, xLowerStrainWithoutNaN, x, 'linear');

    % y data
    yStrain = interp1(midNormalizedDepthWithoutNaN, yEpsWithoutNaN, x, 'linear');
    % yUpperStrain = interp1(midNormalizedDepthWithoutNaN, yUpperStrainWithoutNaN, x, 'linear');
    % yLowerStrain = interp1(midNormalizedDepthWithoutNaN, yLowerStrainWithoutNaN, x, 'linear');
    
    % % Stress computation
    xStress = (elasticModulus*1000)./(1-poissonRatio^2)*(xStrain + poissonRatio*yStrain);
    % xUpperStress = (elasticModulus*1000.*xUpperStrain)./(1-poissonRatio);
    % xLowerStress = (elasticModulus*1000.*xLowerStrain)./(1-poissonRatio);
    % xDeltaStress = (xUpperStress - xLowerStress)./2;
    % 
    yStress = (elasticModulus*1000)./(1-poissonRatio^2)*(yStrain + poissonRatio*xStrain);
    % yUpperStress = (elasticModulus*1000.*yUpperStrain)./(1-poissonRatio);
    % yLowerStress = (elasticModulus*1000.*yLowerStrain)./(1-poissonRatio);
    % yDeltaStress = (yUpperStress - yLowerStress)./2;
    
    
    %% Residual Stress Plots 
    % Calculation
    meanxStrain = mean(xStrain, 1, 'omitnan');
    meanyStrain = mean(yStrain, 1, 'omitnan');

    meanxStress = (elasticModulus*1000)./(1-poissonRatio^2)*(meanxStrain+poissonRatio*meanyStrain);
    % squaredxError = xDeltaStress.^2;
    % elementsx = length(xErrorStrain) - sum(isnan(squaredxError));
    % errorxStress = sqrt(sum(squaredxError, 2))./elementsx; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    % maxxErrorStress = meanxStress + errorxStress;
    % minxErrorStress = meanxStress - errorxStress;

    meanyStress = (elasticModulus*1000)./(1-poissonRatio^2)*(meanyStrain + poissonRatio*meanxStrain);
    % squaredyError = yDeltaStress.^2;
    % elementsy = length(yErrorStrain) - sum(isnan(squaredyError));
    % erroryStress = sqrt(sum(squaredyError, 2))./elementsy; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    % maxyErrorStress = meanyStress + erroryStress;
    % minyErrorStress = meanyStress - erroryStress;
    

    % Plotting
    % x data
    figure
    set(gcf,'WindowState','maximized')
    % plot([x x], [maxErrorStress minErrorStress], 'b', 'LineStyle', '--');
    plot(x, meanxStress, 'b', 'LineWidth', 3);
    
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
    title('Residual stress depth profile in x')
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
        saveas(gcf, fullfile(resultsDir, 'RS_profile-x.jpg'));
    end
    
    hold off
    
    if saving == true
        filename = 'residualStress-x.mat';
        normalizedDepth = x;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','xStress','pillarDiameter')
    end

    % y data
    figure
    set(gcf,'WindowState','maximized')
    % plot([x x], [maxErrorStress minErrorStress], 'b', 'LineStyle', '--');
    plot(x, meanyStress, 'b', 'LineWidth', 3);
    
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
    title('Residual stress depth profile in y')
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
        saveas(gcf, fullfile(resultsDir, 'RS_profile-y.jpg'));
    end
    
    hold off
    
    if saving == true
        filename = 'residualStress-y.mat';
        normalizedDepth = x;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','yStress','pillarDiameter')
    end
end
