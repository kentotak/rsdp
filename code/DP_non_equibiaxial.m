% Purpose: Depth profiling code for the non-equibiaxial case. This code is meant to be used in the DP app.
% Authors: Kento Takahashi (KU Leuven, Belgium) and Enrico Salvati (University of Udine, Italy)
% Date of last change: 12/01/2026

function DP_non_equibiaxial(saving,path,zeroStrainFile,ninetyStrainFile,pillarDiameter,stepSize,pillarRedFactor,xAxisData,xAxisLowLimit,xAxisHighLimit, ...
    yAxisLowLimit,yAxisHighLimit,pointsSpan,polynomialDegree,elasticModulus,poissonRatio)
    %% Saving files
    if saving == true
        resultsDir = fullfile(path, 'results', 'depth_profiling', 'biaxial');
        
        % Checking if it exists
        if ~exist(resultsDir, 'dir')
            mkdir(resultsDir)
        end
    end
    
    % Load strains
    if isfile(zeroStrainFile)
        zeroStrainMatrix = load(zeroStrainFile);
    else
        msgbox(sprintf('Strain file %s not found.',zeroStrainFile))
        return
    end

    if isfile(ninetyStrainFile)
        ninetyStrainMatrix = load(ninetyStrainFile);
    else
        msgbox(sprintf('Strain file %s not found.',ninetyStrainFile))
        return
    end

    % Create uncertainty matrices
    zeroUncertaintyNormalizedDepth = 1e-6*ones(size(zeroStrainMatrix));
    zeroErrorStrain = 1e-6*ones(size(zeroStrainMatrix));

    ninetyUncertaintyNormalizedDepth = 1e-6*ones(size(ninetyStrainMatrix));
    ninetyErrorStrain = 1e-6*ones(size(ninetyStrainMatrix));
    
    % Variables definition
    depth = (zeroStrainMatrix(:, 1)-1)*stepSize; % The first column of the strain file is the image number
    zeroStrainRelief = zeroStrainMatrix(:, 2); % The second column of the strain file is the strain relief
    ninetyStrainRelief = ninetyStrainMatrix(:, 2);

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
    zeroStrainRelief = zeroStrainRelief';
    ninetyStrainRelief = ninetyStrainRelief';
    normalizedDepth = normalizedDepth';
    
    % Calculation of eps
    zeroSRCurveSmoothed = smooth(normalizedDepth,zeroStrainRelief,pointsSpan,'sgolay',polynomialDegree); % This smoothes every 6 (pointsSpan) values with a 3rd degree (polynomialDegree) polynomial
    ninetySRCurveSmoothed = smooth(normalizedDepth,ninetyStrainRelief,pointsSpan,'sgolay',polynomialDegree);

    % h/D shift and delta calculation
    midNormalizedDepth = nan(1,length(normalizedDepth)-1);
    deltaNormalizedDepth = nan(1,length(normalizedDepth)-1);
    
    for i = 1:(length(normalizedDepth)-1)
       midNormalizedDepth(i) = (normalizedDepth(i) + normalizedDepth(i+1))/2;
       deltaNormalizedDepth(i) = normalizedDepth(i+1) - normalizedDepth(i); % this is the h/D difference
    end

    % Delta eps calculation
    deltaZeroSRCurveSmoothed = nan(1,length(zeroSRCurveSmoothed)-1);
    deltaNinetySRCurveSmoothed = nan(1,length(ninetySRCurveSmoothed)-1);
    
    for i = 1:(length(zeroSRCurveSmoothed)-1)
        deltaZeroSRCurveSmoothed(i) = zeroSRCurveSmoothed(i+1) - zeroSRCurveSmoothed(i);
    end

    for i = 1:(length(ninetySRCurveSmoothed)-1)
        deltaNinetySRCurveSmoothed(i) = ninetySRCurveSmoothed(i+1) - ninetySRCurveSmoothed(i);
    end
    
    % Replacing 0 with NaN
    for i = 1:(length(normalizedDepth)-1)
        if deltaNormalizedDepth(i) == 0
            deltaNormalizedDepth(i) = nan;
            deltaZeroSRCurveSmoothed(i) = nan;
            deltaNinetySRCurveSmoothed(i) = nan;
        end
        if midNormalizedDepth(i) == 0
            midNormalizedDepth(i) = nan;
            deltaZeroSRCurveSmoothed(i) = nan;
            deltaNinetySRCurveSmoothed(i) = nan;
        end
    end
    
    
    %% G(h/D) and F(h/D) influence functions
    zeroEps = nan(size(zeroStrainRelief)-1);
    ninetyEps = nan(size(ninetyStrainRelief)-1);
    
    zeroGtemp = deltaZeroSRCurveSmoothed./deltaNormalizedDepth;
    ninetyGtemp = deltaNinetySRCurveSmoothed./deltaNormalizedDepth;
    Ftemp = exp(-alpha*midNormalizedDepth).*(alpha-beta+(alpha*beta+2*gamma)*midNormalizedDepth-alpha*gamma*midNormalizedDepth.^2);
    
    zeroEps(1:length(deltaZeroSRCurveSmoothed)) = -zeroGtemp./Ftemp; % eps is the residual elastic strain, which is the opposite of the eigenstrain
    ninetyEps(1:length(deltaNinetySRCurveSmoothed)) = -ninetyGtemp./Ftemp;
    depthShift = midNormalizedDepth*pillarDiameter;
    

    %% Fitting of two points at a time
    for i = 1:(length(normalizedDepth)-1)
        reducedNormalizedDepth = [normalizedDepth(i)  normalizedDepth(i+1)];

        reducedZeroEps = [zeroSRCurveSmoothed(i)  zeroSRCurveSmoothed(i+1)];
        reducedZeroErrorStrain = [zeroErrorStrain(i)  zeroErrorStrain(i+1)];
        reducedZeroErrorNormalizedDepth = [zeroUncertaintyNormalizedDepth(i)  zeroUncertaintyNormalizedDepth(i+1)];

        reducedNinetyEps = [ninetySRCurveSmoothed(i)  ninetySRCurveSmoothed(i+1)];
        reducedNinetyErrorStrain = [ninetyErrorStrain(i)  ninetyErrorStrain(i+1)];
        reducedNinetyErrorNormalizedDepth = [ninetyUncertaintyNormalizedDepth(i)  ninetyUncertaintyNormalizedDepth(i+1)];

        % Linear fit between 2 points with errors on normalized depth and strain
        % 0° data
        [~, zeroSp, zeroLower, zeroUpper, zeroXplot] = linfitxy(reducedNormalizedDepth, reducedZeroEps, reducedZeroErrorNormalizedDepth,reducedZeroErrorStrain, ...
            'Verbosity', 0);

        zeroLowerBandc(i,:) = zeroLower;
        zeroUpperBandc(i,:) = zeroUpper;
        zeroDeltaBand(i) = zeroSp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.

        zeroDeltaStrain(i) = zeroDeltaBand(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        zeroUpperStrain(i) = zeroEps(i) + zeroDeltaStrain(i);
        zeroLowerStrain(i) = zeroEps(i) - zeroDeltaStrain(i);
        zeroXError(i,:) = zeroXplot; % This is chi2 (goodness-of-fit)


        % 90° data
        [~, ninetySp, ninetyLower, ninetyUpper, ninetyXplot] = linfitxy(reducedNormalizedDepth, reducedNinetyEps, reducedNinetyErrorNormalizedDepth,reducedNinetyErrorStrain, ...
            'Verbosity', 0);

        ninetyLowerBandc(i,:) = ninetyLower;
        ninetyUpperBandc(i,:) = ninetyUpper;
        ninetyDeltaBand(i) = ninetySp(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.

        ninetyDeltaStrain(i) = ninetyDeltaBand(i)./abs(Ftemp(i)); % Not sure where this formula comes from
        ninetyUpperStrain(i) = ninetyEps(i) + ninetyDeltaStrain(i);
        ninetyLowerStrain(i) = ninetyEps(i) - ninetyDeltaStrain(i);
        ninetyXError(i,:) = ninetyXplot; % This is chi2 (goodness-of-fit)
    end
    
    % close % linfitxy opens a figure by default
    
    
    %% Plotting the smoothed strain relief
    % 0° data
    figure
    if strcmp(xAxisData,"Depth")
        plot(depth, zeroSRCurveSmoothed, 'r', 'LineWidth', 2)
        hold on
        plot(depth, zeroStrainRelief, 'b.-', 'LineWidth', 2)
    else
        plot(normalizedDepth, zeroSRCurveSmoothed, 'r', 'LineWidth', 2)
        hold on
        plot(normalizedDepth, zeroStrainRelief, 'b.-', 'LineWidth', 2)
    end

    % for i = 1:(length(normalizedDepth)-1)
    %     plot (squeeze(x_error(i,:)), squeeze(lower_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    %     hold on
    %     plot (squeeze(x_error(i,:)), squeeze(upper_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    % end
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in 0° direction')
    box off
    if strcmp(xAxisData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(zeroStrainRelief)-5e-4 max(zeroStrainRelief)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'strain_relief_profile-0.jpg'));
    end
    
    % 90° data
    figure
    if strcmp(xAxisData,"Depth")
        plot(depth, ninetySRCurveSmoothed, 'r', 'LineWidth', 2)
        hold on
        plot(depth, ninetyStrainRelief, 'b.-', 'LineWidth', 2)
    else
        plot(normalizedDepth, ninetySRCurveSmoothed, 'r', 'LineWidth', 2)
        hold on
        plot(normalizedDepth, ninetyStrainRelief, 'b.-', 'LineWidth', 2)
    end
    
    % for i = 1:(length(normalizedDepth)-1)
    %     plot (squeeze(x_error(i,:)), squeeze(lower_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    %     hold on
    %     plot (squeeze(x_error(i,:)), squeeze(upper_bandc(i,:)), 'k', 'LineWidth', 1, 'LineStyle', ':');
    % end
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in 90° direction')
    box off
    if strcmp(xAxisData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(ninetyStrainRelief)-5e-4 max(ninetyStrainRelief)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'strain_relief_profile-90.jpg'));
    end


    %% Interpolations + calculation of stress
    % (assuming elastic isotropy!)
    % Define limits
    for i = 1:(length(normalizedDepth)-1)
        if zeroUpperStrain(i) == 0
            zeroUpperStrain(i) = nan;
            zeroLowerStrain(i) = nan;
        end
        if ninetyUpperStrain(i) == 0
            ninetyUpperStrain(i) = nan;
            ninetyLowerStrain(i) = nan;
        end
        % Only keeping values if h/D in interval
        if (midNormalizedDepth(i)<xAxisLowLimit)||(midNormalizedDepth(i)>xAxisHighLimit)||midNormalizedDepth(i) == 0||depthShift(i) == 0
            midNormalizedDepth(i) = nan;
            depthShift(i) = nan;
            
            zeroEps(i) = nan;
            zeroUpperStrain(i) = nan;
            zeroLowerStrain(i) = nan;

            ninetyEps(i) = nan;
            ninetyUpperStrain(i) = nan;
            ninetyLowerStrain(i) = nan;
        end
    end
    
    normalizedDepthLinspace = linspace(0, max(normalizedDepth), 500);
    
    % [midNormalizedDepthWithoutNaN, epsWithoutNaN, xUpperStrainWithoutNaN, xLowerStrainWithoutNaN, yUpperStrainWithoutNaN, yLowerStrainWithoutNaN] = removeNaNColumns( ...
    %     midNormalizedDepth, xEps, zeroUpperStrain, xLowerStrain, yUpperStrain, yLowerStrain);
    [midNormalizedDepthWithoutNaN, zeroEpsWithoutNaN, ninetyEpsWithoutNaN] = removeNaNColumns(midNormalizedDepth, zeroEps, ninetyEps);
    
    % 0° data
    zeroStrain = interp1(midNormalizedDepthWithoutNaN, zeroEpsWithoutNaN, normalizedDepthLinspace, 'linear');
    % zeroUpperStrain = interp1(midNormalizedDepthWithoutNaN, xUpperStrainWithoutNaN, normalizedDepthLinspace, 'linear');
    % xLowerStrain = interp1(midNormalizedDepthWithoutNaN, xLowerStrainWithoutNaN, normalizedDepthLinspace, 'linear');

    % 90° data
    ninetyStrain = interp1(midNormalizedDepthWithoutNaN, ninetyEpsWithoutNaN, normalizedDepthLinspace, 'linear');
    % yUpperStrain = interp1(midNormalizedDepthWithoutNaN, yUpperStrainWithoutNaN, normalizedDepthLinspace, 'linear');
    % yLowerStrain = interp1(midNormalizedDepthWithoutNaN, yLowerStrainWithoutNaN, normalizedDepthLinspace, 'linear');
    
    % % Stress computation
    zeroStress = (elasticModulus*1000)./(1-poissonRatio^2)*(zeroStrain + poissonRatio*ninetyStrain);
    % xUpperStress = (elasticModulus*1000.*zeroUpperStrain)./(1-poissonRatio);
    % xLowerStress = (elasticModulus*1000.*xLowerStrain)./(1-poissonRatio);
    % xDeltaStress = (xUpperStress - xLowerStress)./2;
    % 
    ninetyStress = (elasticModulus*1000)./(1-poissonRatio^2)*(ninetyStrain + poissonRatio*zeroStrain);
    % yUpperStress = (elasticModulus*1000.*yUpperStrain)./(1-poissonRatio);
    % yLowerStress = (elasticModulus*1000.*yLowerStrain)./(1-poissonRatio);
    % yDeltaStress = (yUpperStress - yLowerStress)./2;
    
    
    %% Residual Stress Plots 
    % Calculation
    meanZeroStrain = mean(zeroStrain, 1, 'omitnan');
    meanNinetyStrain = mean(ninetyStrain, 1, 'omitnan');

    meanZeroStress = (elasticModulus*1000)./(1-poissonRatio^2)*(meanZeroStrain+poissonRatio*meanNinetyStrain);
    % squaredxError = xDeltaStress.^2;
    % elementsx = length(xErrorStrain) - sum(isnan(squaredxError));
    % errorxStress = sqrt(sum(squaredxError, 2))./elementsx; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    % maxxErrorStress = meanZeroStress + errorxStress;
    % minxErrorStress = meanZeroStress - errorxStress;

    meanNinetyStress = (elasticModulus*1000)./(1-poissonRatio^2)*(meanNinetyStrain + poissonRatio*meanZeroStrain);
    % squaredyError = yDeltaStress.^2;
    % elementsy = length(yErrorStrain) - sum(isnan(squaredyError));
    % erroryStress = sqrt(sum(squaredyError, 2))./elementsy; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;
    % maxyErrorStress = meanNinetyStress + erroryStress;
    % minyErrorStress = meanNinetyStress - erroryStress;
    

    % Plotting
    % 0° data
    figure
    set(gcf,'WindowState','maximized')
    % plot([normalizedDepthLinspace normalizedDepthLinspace], [maxErrorStress minErrorStress], 'b', 'LineStyle', '--');
    if strcmp(xAxisData,"Depth")
        plot(normalizedDepthLinspace*pillarDiameter, meanZeroStress, 'b', 'LineWidth', 3);
    else
        plot(normalizedDepthLinspace, meanZeroStress, 'b', 'LineWidth', 3);
    end
    
    xlim([xAxisLowLimit xAxisHighLimit])
    ylim([yAxisLowLimit yAxisHighLimit])
    
    % lgd = legend(sprintf('D = %d um', pillarDiameter), 'Confidence band limits', 'Averaged profile');
    % lgd = legend('')
    % lgd.Location = 'best';
    title('Residual stress depth profile in 0° direction')
    if strcmp(xAxisData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Residual Stress [MPa]')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'RS_profile-0.jpg'));
    end
    
    hold off
    
    if saving == true
        filename = 'residualStress-0.mat';
        normalizedDepth = normalizedDepthLinspace;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','zeroStress','pillarDiameter')
    end

    % 90° data
    figure
    set(gcf,'WindowState','maximized')
    % plot([normalizedDepthLinspace normalizedDepthLinspace], [maxErrorStress minErrorStress], 'b', 'LineStyle', '--');
    if strcmp(xAxisData,"Depth")
        plot(normalizedDepthLinspace*pillarDiameter, meanNinetyStress, 'b', 'LineWidth', 3);
    else
        plot(normalizedDepthLinspace, meanNinetyStress, 'b', 'LineWidth', 3);
    end
    
    xlim([xAxisLowLimit xAxisHighLimit])
    ylim([yAxisLowLimit yAxisHighLimit])
    
    % lgd = legend(sprintf('D = %d um', pillarDiameter), 'Confidence band limits', 'Averaged profile');
    % lgd = legend('')
    % lgd.Location = 'best';
    title('Residual stress depth profile in 90° direction')
    if strcmp(xAxisData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Residual Stress [MPa]')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off
    
    if saving == true
        saveas(gcf, fullfile(resultsDir, 'RS_profile-90.jpg'));
    end
    
    hold off
    
    if saving == true
        filename = 'residualStress-90.mat';
        normalizedDepth = normalizedDepthLinspace;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','ninetyStress','pillarDiameter')
    end
end
