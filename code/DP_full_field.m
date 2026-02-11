% Purpose: Depth profiling code for the full field case. This code is meant to be used in the DP app.
% Authors: Kento Takahashi (KU Leuven, Belgium) and Enrico Salvati (University of Udine, Italy)
% Date of last change: 25/11/2025

function DP_full_field(saving,path,strainFile0,strainFile90,strainFile45, pillarDiameter,stepSize,pillarRedFactor,xData,xLowBound,xHighBound,yLowBound, ...
    yHighBound,pointsSpan,polynomialDegree,elasticModulus,poissonRatio)
    
    %% Results directory
    if saving == true
        resultsDir = fullfile(path, 'results', 'depth_profiling', imagesDirection);
        
        % Checking if it exists
        if ~exist(resultsDir, 'dir')
            mkdir(resultsDir)
        end
    end

    %% Import data
    strainMatrix0 = load(strainFile0);
    strainMatrix90 = load(strainFile90);
    strainMatrix45 = load(strainFile45);

    depth = (strainMatrix0(:, 1)-1)*stepSize;
    normalizedDepth = depth./pillarDiameter;

    for angle = {0,45,90}
        % Import strain relief
        eval(sprintf('strainRelief%d = strainMatrix%d(:, 2);',angle{1},angle{1}))

        % Create errors on depth
        eval(sprintf("errorDepth%d = 1e-6*ones(1,length(normalizedDepth));",angle{1}))
        
        % Create errors on strain
        eval(sprintf("errorStrain%d = 1e-6*ones(1,length(normalizedDepth));",angle{1}))
    end
    
    %% Influence factors
    H100=[1.882088166	-7.387650425	-11.73550289	0.822332739];
    H90=[10.76927908	6.896786885	58.57635119	1.002569357];    
    H80=[9.633366311	7.975102399	60.9850516	-0.614557234];
    H70=[11.26170093	9.871653965	16.63481805	-226.4528904];
    H60=[10.66181959	9.34859669	5.445524588	-240.5922412];
    
    D100=[9.246890091	3.21245195	-14.64952657	-95.7103254];
    D90=[7.043967313	4.745682377	20.84354673	0.115755753];    
    D80=[6.208466893	5.025840568	22.26465792	0.068616958];
    D70=[2.370723371	1.435050398	25.40373853	39.82381564];
    D60=[0.91881021	0.095274916	21.05066737	38.8313909];
  
    if pillarRedFactor == 1
        F_H = H100; F_D = D100;
    elseif pillarRedFactor == .9
        F_H = H90; F_D = D90;
    elseif pillarRedFactor == .7
        F_H = H70; F_D = D70;
    elseif pillarRedFactor == .6
        F_H = H60; F_D = D60;
    else
        F_H = H80; F_D = D80;
    end

    %% Principal strain relief computation
    % Initialization
    epsRelI = zeros(1,length(strainRelief0)); epsRelII = zeros(1,length(strainRelief0)); %errorEps10 = zeros(1,length(strainRelief0));
    % errorEps11 = zeros(1,length(strainRelief0)); errorEps1 = zeros(1,length(strainRelief0)); errorEps2 = zeros(1,length(strainRelief0));
    % errorEps3 = zeros(1,length(strainRelief0)); errorEps4 = zeros(1,length(strainRelief0)); errorEps = zeros(1,length(strainRelief0));
    dPhi = zeros(1,length(normalizedDepth)-1);

    for i = 1:length(normalizedDepth)-1
        % Those are the principal strain reliefs in direction I
        epsRelI(i) = (strainRelief0(i)+strainRelief90(i))/2 + sqrt((strainRelief0(i)-strainRelief45(i))^2/2+(strainRelief45(i)-strainRelief90(i))^2/2);
        epsRelII(i) = (strainRelief0(i)+strainRelief90(i))/2 - sqrt((strainRelief0(i)-strainRelief45(i))^2/2+(strainRelief45(i)-strainRelief90(i))^2/2);
        
        % % Parts of errorEps1
        % errorEps10(i) = sqrt((errorStrain90(i)/strainRelief90(i))^2 + (errorStrain0(i)/strainRelief0(i))^2);
        % errorEps11(i) = (strainRelief90(i) + strainRelief0(i))/2;
        % 
        % % Parts of errorEps
        % errorEps1(i) = (errorEps10(i)*errorEps11(i))^2;
        % errorEps2(i) = sqrt((errorStrain90(i)^2 + errorStrain45(i)^2)/4 * (strainRelief90(i) - strainRelief45(i)^2) + (errorStrain90(i)^2 + errorStrain45(i)^2)/4 * (strainRelief45(i) - strainRelief90(i)^2));
        % errorEps3(i) = sqrt(2)/4 / sqrt(2*(strainRelief90(i)-strainRelief45(i))^2);
        % errorEps4(i) = (errorEps3(i)/errorEps4(i))^2;
        % errorEps(i) = sqrt(errorEps1(i)+errorEps4(i));

        if i ~= length(strainRelief0)
            dPhi(i) = 0.5*atan( ...
                (strainRelief0(i+1)-strainRelief0(i) - 2*(strainRelief45(i+1)-strainRelief45(i))+strainRelief90(i+1) - strainRelief90(i)) / ...
                (strainRelief0(i+1)-strainRelief0(i) - (strainRelief90(i+1)-strainRelief90(i))));
        end
    end

    % Principal directions calculations
    % errorEps(1) = 0;
    errorEps = 1e-6*ones(size(strainRelief0));
    % Those are the hydrostatic and deviatoric components of strain reliefs
    epsHt = (epsRelI+epsRelII)./2;
    epsDt = (epsRelI-epsRelII)./2;

    %% Data smoothing
    % Smoothing
    SRCurveSmoothedH = smooth(normalizedDepth,epsHt,pointsSpan,'sgolay',polynomialDegree);
    SRCurveSmoothedD = smooth(normalizedDepth,epsDt,pointsSpan,'sgolay',polynomialDegree);

    SRCurveSmoothedI = smooth(normalizedDepth,epsRelI,pointsSpan,'sgolay',polynomialDegree);
    SRCurveSmoothedII = smooth(normalizedDepth,epsRelII,pointsSpan,'sgolay',polynomialDegree);
    

    %% h/D shift calculation
    midNormalizedDepth = nan(1,length(normalizedDepth)-1);
    deltaNormalizedDepth = nan(1,length(normalizedDepth)-1);
    
    for i = 1:(length(normalizedDepth)-1)
       midNormalizedDepth(i) = (normalizedDepth(i) + normalizedDepth(i+1))/2;
       deltaNormalizedDepth(i) = normalizedDepth(i+1) - normalizedDepth(i); % this is the h/D difference
    end


    %% Delta eps calculation
    deltaSRCurveSmoothedH = nan(1,length(SRCurveSmoothedH)-1);
    deltaSRCurveSmoothedD = nan(1,length(SRCurveSmoothedD)-1);

    deltaSRCurveSmoothedI = nan(1,length(SRCurveSmoothedI)-1);
    deltaSRCurveSmoothedII = nan(1,length(SRCurveSmoothedII)-1);
    
    for i = 1:(length(SRCurveSmoothedH)-1)
        deltaSRCurveSmoothedH(i) = SRCurveSmoothedH(i+1) - SRCurveSmoothedH(i);
        deltaSRCurveSmoothedD(i) = SRCurveSmoothedD(i+1) - SRCurveSmoothedD(i);
    end

    for i = 1:length(SRCurveSmoothedI)-1
        deltaSRCurveSmoothedI(i) = SRCurveSmoothedI(i+1) - SRCurveSmoothedI(i);
        deltaSRCurveSmoothedII(i) = SRCurveSmoothedII(i+1) - SRCurveSmoothedII(i);
    end
    
    %% Delta h/D calculation
    % Replacing 0 with NaN
    for i = 1:(length(normalizedDepth)-1)
        if deltaNormalizedDepth(i) == 0
            deltaNormalizedDepth(i) = nan;

            deltaSRCurveSmoothedH(i) = nan;
            deltaSRCurveSmoothedD(i) = nan;
        end
        if midNormalizedDepth(i) == 0
            midNormalizedDepth(i) = nan;
            
            deltaSRCurveSmoothedH(i) = nan;
            deltaSRCurveSmoothedD(i) = nan;
        end
    end
    
    %% G(h/D) and F(h/D) influence functions
    epsResI = nan(size(normalizedDepth)-1);
    epsResII = nan(size(normalizedDepth)-1);

    GtempH = deltaSRCurveSmoothedH./deltaNormalizedDepth;
    GtempD = deltaSRCurveSmoothedD./deltaNormalizedDepth;

    FtempH = exp(-F_H(1).*(midNormalizedDepth)).*(F_H(1).*F_H(4).*(midNormalizedDepth.^3)) + (-3*F_H(4)-F_H(1).*F_H(3)).*(midNormalizedDepth.^2) + ...
        (2*F_H(3)+F_H(1).*F_H(2)).*(midNormalizedDepth) - F_H(2)+F_H(1);
    FtempD = exp(-F_D(1).*(midNormalizedDepth)).*(F_D(1).*F_D(4).*(midNormalizedDepth.^3)) + (-3*F_D(4)-F_D(1).*F_D(3)).*(midNormalizedDepth.^2) + ...
        (2*F_D(3)+F_D(1).*F_D(2)).*(midNormalizedDepth) - F_D(2)+F_D(1);

    epsResI(1:length(deltaSRCurveSmoothedH)) = -(GtempH./FtempH) - (GtempD./FtempD);
    epsResII(1:length(deltaSRCurveSmoothedD)) = -(GtempH./FtempH) + (GtempD./FtempD);

    depthShift = midNormalizedDepth*pillarDiameter;

    %% Fitting of two points at a time
    for i = 1:(length(normalizedDepth)-1)
        reducedNormalizedDepth = [normalizedDepth(i)  normalizedDepth(i+1)];
        reducedEpsH = [SRCurveSmoothedH(i)  SRCurveSmoothedH(i+1)];
        reducedEpsD = [SRCurveSmoothedD(i)  SRCurveSmoothedD(i+1)];
        reducedErrorStrain = [errorEps(i)  errorEps(i+1)];
        reducedErrorNormalizedDepth = [errorDepth90(i)  errorDepth90(i+1)];

        % Linear fit between 2 points with errors on normalized depth and strain
        [~, spH, lowerH, upperH, ~] = linfitxy(reducedNormalizedDepth,reducedEpsH,reducedErrorNormalizedDepth,reducedErrorStrain,'Verbosity',0);
        [~, spD, lowerD, upperD, xplot] = linfitxy(reducedNormalizedDepth,reducedEpsD,reducedErrorNormalizedDepth,reducedErrorStrain,'Verbosity',0);

        lowerBandcH(i,:) = lowerH;
        upperBandcH(i,:) = upperH;
        deltaBandH(i) = spH(1); % sp is the uncertainty on ydata, therefore sp(1) is the uncertainty on the slope.
        deltaStrainH(i) = deltaBandH(i)./abs(FtempH(i)); % Not sure where this formula comes from
        
        lowerBandcD(i,:) = lowerD;
        upperBandcD(i,:) = upperD;
        deltaBandD(i) = spD(1);
        deltaStrainD(i) = deltaBandD(i)./abs(FtempD(i));

        deltaStrain(i) = sqrt(deltaStrainH(i)^2 + deltaStrainD(i)^2);

        upperStrain(i) = epsResI(i) + deltaStrain(i);
        lowerStrain(i) = epsResI(i) - deltaStrain(i);
        x_error(i,:) = xplot; % This is chi2 (goodness-of-fit)
    end

    %% Plotting the smoothed strain relief
    % Hydrostatic part
    figure
    plot(normalizedDepth, SRCurveSmoothedH, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, epsHt, 'b.-', 'LineWidth', 2)
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Profile of the hydrostatic component of the strain relief')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(SRCurveSmoothedH)-5e-4 max(SRCurveSmoothedH)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')

    if saving == true
        saveas(gcf, fullfile(resultsDir, 'strain_relief_profile_H.jpg'));
    end

    % Deviatoric part
    figure
    plot(normalizedDepth, SRCurveSmoothedD, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, epsDt, 'b.-', 'LineWidth', 2)
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Profile of the deviatoric component of the strain relief')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(SRCurveSmoothedD)-5e-4 max(SRCurveSmoothedD)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')

    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('strain_relief_profile_D.jpg')));
    end

    % Principal direction I
    figure
    plot(normalizedDepth, SRCurveSmoothedI, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, epsRelI, 'b.-', 'LineWidth', 2)
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in principal direction I')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(SRCurveSmoothedI)-5e-4 max(SRCurveSmoothedI)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')

    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('strain_relief_profile_I.jpg')));
    end

    % Principal direction II
    figure
    plot(normalizedDepth, SRCurveSmoothedII, 'r', 'LineWidth', 2)
    hold on
    plot(normalizedDepth, epsRelII, 'b.-', 'LineWidth', 2)
    
    legend('Smoothed Data','Original Data','Location','best')
    title('Strain relief profile in principal direction II')
    box off
    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Strain Relief')
    ylim([min(SRCurveSmoothedII)-5e-4 max(SRCurveSmoothedII)+5e-4])
    hold off
    set(gca,'FontSize',12)
    set(gca, 'FontName', 'Times New Roman')

    if saving == true
        saveas(gcf, fullfile(resultsDir, sprintf('strain_relief_profile_II.jpg')));
    end

    %% Define limits
    for i = 1:(length(normalizedDepth)-1)
        if upperStrain(i) == 0
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
        % Only keeping values if h/D in interval
        if (midNormalizedDepth(i)<xLowBound)||(midNormalizedDepth(i)>xHighBound)||midNormalizedDepth(i) == 0||depthShift(i) == 0
            midNormalizedDepth(i) = nan;
            depthShift(i) = nan;
            epsResI(i) = nan;
            epsResII(i) = nan;
            dPhi(i) = nan;
            upperStrain(i) = nan;
            lowerStrain(i) = nan;
        end
    end
    
    %% Interpolations + calculation of stress
    x = linspace(0, xHighBound, 500);

    [midNormalizedDepthWithoutNaN, epsResIWithoutNaN, epsResIIWithoutNaN, dPhiWithoutNaN, upperStrainWithoutNaN, lowerStrainWithoutNaN] = removeNaNColumns( ...
        midNormalizedDepth, epsResI, epsResII, dPhi, upperStrain, lowerStrain);

    strainI = interp1(midNormalizedDepthWithoutNaN, epsResIWithoutNaN, x, 'linear');
    strainII = interp1(midNormalizedDepthWithoutNaN, epsResIIWithoutNaN, x, 'linear');
    dPhi = interp1(midNormalizedDepthWithoutNaN, dPhiWithoutNaN, x, 'linear');

    upperStrain = interp1(midNormalizedDepthWithoutNaN, upperStrainWithoutNaN, x, 'linear');
    lowerStrain = interp1(midNormalizedDepthWithoutNaN, lowerStrainWithoutNaN, x, 'linear');
    deltaStrain = (abs(upperStrain-lowerStrain)./2);

    % Stress computation
    stressI = (elasticModulus*1000)./(1-poissonRatio^2).*(strainI+poissonRatio.*(strainII));
    stressII = (elasticModulus*1000)./(1-poissonRatio^2).*(strainII+poissonRatio.*(strainI));
    deltaStress = deltaStrain.*(elasticModulus*1000)./(1-poissonRatio^2)*sqrt(1+poissonRatio^2);

    %% Residual Stress Plots
    % Calculations
    meanStrainI = mean(strainI, 1, 'omitnan');
    meanStrainII = mean(strainII, 1, 'omitnan');

    squaredError = deltaStress.^2;
    elements = length(errorStrain90) - sum(isnan(squaredError));
    errorStress = sqrt(sum(squaredError, 2))./elements; % This might sometimes be s_error = sqrt(nansum(squared_error))./elements;

    meanStressI = (elasticModulus*1000)./(1-poissonRatio^2).*(meanStrainI+(poissonRatio.*meanStrainII));
    maxErrorStressI = meanStressI + errorStress;
    minErrorStressI = meanStressI - errorStress;

    meanStressII = (elasticModulus*1000)./(1-poissonRatio^2).*(meanStrainII+(poissonRatio.*meanStrainI));
    maxErrorStressII = meanStressII + errorStress;
    minErrorStressII = meanStressII - errorStress;

    % Plotting
    % Principal direction I
    figure
    set(gcf,'WindowState','maximized')

    plot(x, meanStressI, 'b', 'LineWidth', 3);

    if ~isempty(yLowBound) && ~isempty(yHighBound)
        ylim([yLowBound yHighBound])
    elseif isempty(yLowBound) && ~isempty(yHighBound)
        ylim([-inf yHighBound])
    elseif ~isempty(yLowBound) && isempty(yHighBound)    
        ylim([yLowBound inf])
    end

    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Residual Stress [MPa]')

    title('Residual stress in principal direction I')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off

    if saving == true
        % Save plot as image
        saveas(gcf, fullfile(resultsDir, 'RS_profile_I.jpg'));

        % Save results in mat file
        filename = 'residualStress_I.mat';
        normalizedDepth = x;
        depth = normalizedDepth * pillarDiameter;
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','stressI','pillarDiameter')
    end


    % Deviatoric part
    figure
    set(gcf,'WindowState','maximized')
    % plot(x, stress,'LineWidth', 1);

    % hold on
    % 
    % yline(0,'k--')
    % 
    plot(x, meanStressII, 'b', 'LineWidth', 3);

    if ~isempty(yLowBound) && ~isempty(yHighBound)
        ylim([yLowBound yHighBound])
    elseif isempty(yLowBound) && ~isempty(yHighBound)
        ylim([-inf yHighBound])
    elseif ~isempty(yLowBound) && isempty(yHighBound)    
        ylim([yLowBound inf])
    end

    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Residual Stress [MPa]')

    title('Residual stress in principal direction II')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off

    if saving == true
        % Save plot as image
        saveas(gcf, fullfile(resultsDir, 'RS_profile_II.jpg'));

        % Save results in mat file
        filename = 'residualStress_II.mat';
        save(fullfile(resultsDir,filename),'normalizedDepth','depth','stressII','pillarDiameter')
    end
    

    dPhi = rad2deg(dPhi);
    % [dPhi] = removeNaNColumns(dPhi);
    
    figure
    plot(x,dPhi,'b','LineWidth',3)

    if strcmp(xData,"Depth")
        xlabel('Depth [µm]')
    else
        xlabel('Normalized depth (h/D)')
    end
    ylabel('Angle (°)')

    title('Angle between original coordinates system and principal directions system')
    set(gca,'FontSize',13)
    set(gca, 'FontName', 'Times New Roman')
    box off

    if saving == true
        saveas(gcf, fullfile(resultsDir, 'angle_original_principal.jpg'));
    end
end
