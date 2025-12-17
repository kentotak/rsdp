% Clean markers
% Programmed by Chris
% Revised by Melanie
% Last revision: 04/28/16
function [ValidX,ValidY,StdX,StdY,CorrCoef,GoodMarkers]=CleanMarkers(ValidX,ValidY,StdX,StdY,CorrCoef,Direction,Mode,LogFileName,MetaData)

    GoodMarkers=0;

    % Silent mode
    if strcmp(Mode,'silent')
        [ValidX,ValidY,StdX,StdY,CorrCoef,GoodMarkers]=RemoveSelectedCorrCoef(ValidX,ValidY,StdX,StdY,CorrCoef,MetaData.PostProc_SelectedCorrCoef);
        
    % Non silent mode (called from GUI)    
    else
        switch Direction
            case 'x' % x-direction
                Valid1=ValidX;
                Valid2=ValidY;
                Std1=StdX;
                Std2=StdY;
            case 'y' % y-direction
                Valid1=ValidY;
                Valid2=ValidX;
                Std1=StdY;
                Std2=StdX;
            otherwise % invalid
                return
        end

        Displ1=GetMeanDisplacement(Valid1);
        Displ2=GetMeanDisplacement(Valid2);
        CurrentFigureHandle=0;

        Selection = menu(sprintf('How do you want to visualize your data?'),'Remove badly tracked markers (point)','Remove badly tracked markers (area)',...
                                 'Remove markers from displacement vs. position plot','Remove markers moving relative to their neighbours',...
                                 'Remove markers by standard deviation thresholding','Remove markers by distance thresholding','Remove markers by correlation coefficient','Go Back');
        switch Selection
            case 1 % Remove bad markers (point)
                [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemovePoint(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName);
            case 2 % Remove bad markers (area)
                [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveArea(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName);
            case 3 % Remove markers from displacement vs. position plot
                [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveDisplPos(Valid1,Valid2,Std1,Std2,CorrCoef,Displ1,Displ2,Direction,LogFileName);
            case 4 % Remove markers moving relative to their neighbours
                [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveJumpers(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName);  
            case 5 % Remove markers by standard deviation
                [Valid1,Valid2,Std1,Std2,CorrCoef]=RemoveStd(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName); 
            case 6 % Remove markers by distance to fit
                [Valid1,Valid2,Std1,Std2,CorrCoef]=RemoveDist(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName); 
            case 7 % Remove markers by correlation coefficient
                [Valid1,Valid2,Std1,Std2,CorrCoef,GoodMarkers]=RemoveCorrCoef(Valid1,Valid2,Std1,Std2,CorrCoef,LogFileName); 
            otherwise % Cancel
                return
        end

        switch Direction
            case 'x' % x-direction
                ValidX=Valid1;
                ValidY=Valid2;
                StdX=Std1;
                StdY=Std2;
            case 'y' % y-direction
                ValidX=Valid2;
                ValidY=Valid1;
                StdX=Std2;
                StdY=Std1;
            otherwise % invalid
                return
        end

        if CurrentFigureHandle~=0
            close(CurrentFigureHandle);
        end
    end
    
% Draw grid
function DrawGrid(Valid1,Valid2,Displ1,SelectedImage)

    % Find max and min point
    MinDispl1=find(Displ1(:,SelectedImage)==min(Displ1(:,SelectedImage)));
    MaxDispl1=find(Displ1(:,SelectedImage)==max(Displ1(:,SelectedImage)));
    
    GridSizeX=10*round(min(min(Valid1))/10):10:10*round(max(max(Valid1))/10);
    GridSizeY=10*round(min(min(Valid2))/10):10:10*round(max(max(Valid2))/10);
    [XI,YI]=meshgrid(GridSizeX,GridSizeY);
    
    ZI=griddata(Valid1(:,SelectedImage),Valid2(:,SelectedImage),Displ1(:,SelectedImage),XI,YI,'cubic');
    EpsXX = gradient(ZI,10,10);
    pcolor(XI,YI,EpsXX);
    axis('equal');
    caxis([min(min(EpsXX)) max(max(EpsXX))]);
    colorbar;
    shading('interp');
    hold on
    plot3(Valid1(:,SelectedImage),Valid2(:,SelectedImage),Displ1(:,SelectedImage)-min(Displ1(:,SelectedImage)),'o','MarkerEdgeColor','k','MarkerFaceColor','g');
    plot3(Valid1(MinDispl1,SelectedImage),Valid2(MinDispl1,SelectedImage),Displ1(MinDispl1,SelectedImage)-min(Displ1(:,SelectedImage)),'o','MarkerEdgeColor','y','MarkerFaceColor','b');
    plot3(Valid1(MaxDispl1,SelectedImage),Valid2(MaxDispl1,SelectedImage),Displ1(MaxDispl1,SelectedImage)-min(Displ1(:,SelectedImage)),'o','MarkerEdgeColor','y','MarkerFaceColor','r');
    axis([min(min(XI))-10 max(max(XI))+10 min(min(YI))-10 max(max(YI))+10]);
    drawnow
    hold off
    
% Remove bad markers (point)
function [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemovePoint(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName)
  
    WriteToLogFile(LogFileName,'Remove markers by point in direction',Direction,'s'); 
    
    CurrentFigureHandle=UseCurrentFigureHandle(0);
    CurrentSelection=1;
    SelectedImage=0;

    % More bad points to mark
    while CurrentSelection==1
        SizeValid1=size(Valid1);
        NumOfImages=SizeValid1(1,2);

        % Get displacement
        Displ1=GetDisplacement(Valid1);

        % Update temporary data
        Displ1Temp=Displ1;
        Valid1Temp=Valid1;
        Valid2Temp=Valid2;
        Std1Temp=Std1;
        Std2Temp=Std2;
        CorrCoefTemp=CorrCoef;

        % Select image
        SelectedImage=SelectImage(NumOfImages);

        % Draw figure
        DrawGrid(Valid1,Valid2,Displ1,SelectedImage);

        % Get point position
        title('Click on the bad point');
        BadPoint=ginput(1);

        % Find point at given position (smallest distance)
        RelativePos=abs(Valid1(:,SelectedImage)-BadPoint(1,1))+abs(Valid2(:,SelectedImage)-BadPoint(1,2));
        SelectedPoint=find(RelativePos==min(RelativePos));

        % Update temporary data and delete point
        Displ1Temp(SelectedPoint,:)=[];
        Valid1Temp(SelectedPoint,:)=[];
        Valid2Temp(SelectedPoint,:)=[];
        Std1Temp(SelectedPoint,:)=[];
        Std2Temp(SelectedPoint,:)=[];
        CorrCoefTemp(SelectedPoint,:)=[];
        
        % Update figure
        DrawGrid(Valid1Temp,Valid2Temp,Displ1Temp,SelectedImage);

        % Delete points permanently?
        Selection=menu(sprintf('Do you want to delete this point permanently?'),'Yes','No');
        if Selection==1
            WriteToLogFile(LogFileName,'Image',SelectedImage,'d');
            SelectedPoint=sprintf(' (%f,%f)',BadPoint(1,1),BadPoint(1,2));
            WriteToLogFile(LogFileName,'Point',SelectedPoint,'s');
            
            Valid1=Valid1Temp;
            Valid2=Valid2Temp;
            Std1=Std1Temp;
            Std2=Std2Temp;
            CorrCoef=CorrCoefTemp;
        end
        CurrentSelection = menu(sprintf('Do you want to mark another bad point?'),'Yes','No');
        
        % Abort
        if CurrentSelection==2
            return
        end
    end
   
  % Remove bad markers (area)
  function [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveArea(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName)
      
    WriteToLogFile(LogFileName,'Remove markers by area in direction',Direction,'s'); 

    CurrentFigureHandle=UseCurrentFigureHandle(0);
    CurrentSelection=1;
    SelectedImage=0;

    % More bad points to mark
    while CurrentSelection==1
        SizeValid1=size(Valid1);
        NumOfImages=SizeValid1(1,2);

        % Get displacement
        Displ1=GetDisplacement(Valid1);

        % Update temporary data
        Displ1Temp=Displ1;
        Valid1Temp=Valid1;
        Valid2Temp=Valid2;
        Std1Temp=Std1;
        Std2Temp=Std2;
        CorrCoefTemp=CorrCoef;

        % Select image
        SelectedImage=SelectImage(NumOfImages);
      
         % Draw figure
        DrawGrid(Valid1,Valid2,Displ1,SelectedImage);

        title('Define the region of interest.\n  All points outside that region will be deleted.');
        [XGrid,YGrid]=ginput(2);
        X(1,1)=XGrid(1);
        X(1,2)=XGrid(2);
        Y(1,1)=YGrid(2);
        Y(1,2)=YGrid(1);

        SelectedPoints=find(Valid1Temp(:,SelectedImage)>min(X) & Valid1Temp(:,SelectedImage)<max(X) & Valid2Temp(:,SelectedImage)<max(Y) & Valid2Temp(:,SelectedImage)>min(Y));

        % Update temporary data and delete points
        Displ1Temp(SelectedPoints,:)=[];
        Valid1Temp(SelectedPoints,:)=[];
        Valid2Temp(SelectedPoints,:)=[];
        Std1Temp(SelectedPoints,:)=[];
        Std2Temp(SelectedPoints,:)=[];
        CorrCoefTemp(SelectedPoints,:)=[];

        % Update figure
        DrawGrid(Valid1Temp,Valid2Temp,Displ1Temp,SelectedImage);
        
        % Delete points permanently?
        Selection=menu(sprintf('Do you want to delete these points permanently?'),'Yes','No');
        if Selection==1
            WriteToLogFile(LogFileName,'Image',SelectedImage,'d');
            SelectedArea=sprintf('rect point 1: (%f,%f), rect point 2: (%f,%f)',XGrid(1),YGrid(1),XGrid(2),YGrid(2));
            WriteToLogFile(LogFileName,'Area',SelectedArea,'s');
            Valid1=Valid1Temp;
            Valid2=Valid2Temp;
            Std1=Std1Temp;
            Std2=Std2Temp;
            CorrCoef=CorrCoefTemp;
        end
        CurrentSelection = menu(sprintf('Do you want to mark more bad points?'),'Yes','No');
        
        % Abort
        if CurrentSelection==2
            return
        end
    end
    
 % Remove markers from displacement vs. position plot
 function [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveDisplPos(Valid1,Valid2,Std1,Std2,CorrCoef,Displ1,Displ2,Direction,LogFileName)
   
    WriteToLogFile(LogFileName,'Remove markers from displacement vs. position plot in direction',Direction,'s'); 
     
    CurrentFigureHandle=UseCurrentFigureHandle(0);  
    NumOfImages=size(Valid1,2);
    
    % More bad points to mark
    CurrentSelection=1;
    while CurrentSelection==1
        
        % Update temporary data
        Valid1Temp=Valid1;
        Valid2Temp=Valid2;
        Displ1Temp=Displ1;
        Displ2Temp=Displ2;
        Std1Temp=Std1;
        Std2Temp=Std2;
        CorrCoefTemp=CorrCoef;

        % Select image
        SelectedImage=SelectImage(NumOfImages);
        
        % Init linear fit        
        Beta=[0 0];
        [Beta]=lsqcurvefit(@Line,Beta,Valid1(:,SelectedImage),Displ1(:,SelectedImage));
        LinearFit=Line(Beta,Valid1(:,SelectedImage));
        plot(Valid1(:,SelectedImage),Displ1(:,SelectedImage),'o',Valid1(:,SelectedImage),LinearFit,'r-');
        xlabel([Direction,'-position [pixel]']);
        ylabel([Direction,'-displacement [pixel]']);
        title(['Displacement versus position',sprintf('(current image #: %1g)',SelectedImage)]);    

        title(sprintf('Define the region of interest. \n  All points outside that region will be deleted.'))
        [XGrid,YGrid]=ginput(2);
        X(1,1)=XGrid(1);
        X(1,2)=XGrid(2);
        Y(1,1)=YGrid(2);
        Y(1,2)=YGrid(1);

        SelectedPoints=find(Valid1Temp(:,SelectedImage)>min(X) & Valid1Temp(:,SelectedImage)<max(X) & Displ1Temp(:,SelectedImage)<max(Y) & Displ1Temp(:,SelectedImage)>min(Y));

        % Update temporary data and delete points
        Displ1Temp(SelectedPoints,:)=[];
        Displ2Temp(SelectedPoints,:)=[];
        Valid1Temp(SelectedPoints,:)=[];
        Valid2Temp(SelectedPoints,:)=[];
        Std1Temp(SelectedPoints,:)=[];
        Std2Temp(SelectedPoints,:)=[];
        CorrCoefTemp(SelectedPoints,:)=[];
        
        % New linear fit
        [Beta]=lsqcurvefit(@Line,Beta,Valid1Temp(:,SelectedImage),Displ1Temp(:,SelectedImage));
        LinearFit=Line(Beta,Valid1Temp(:,SelectedImage));
        plot(Valid1Temp(:,SelectedImage),Displ1Temp(:,SelectedImage),'o',Valid1Temp(:,SelectedImage),LinearFit,'r-');

        % Delete point permanently?
        Selection=menu(sprintf('Do you want to delete these points permanently?'),'Yes','No');
        if Selection==1
            WriteToLogFile(LogFileName,'Image',SelectedImage,'d');
            SelectedArea=sprintf('rect point 1: (%f,%f), rect point 2: (%f,%f)',XGrid(1),YGrid(1),XGrid(2),YGrid(2));
            WriteToLogFile(LogFileName,'Area',SelectedArea,'s');
            Valid1=Valid1Temp;
            Valid2=Valid2Temp;
            Displ1=Displ1Temp;
            Displ2=Displ2Temp;
            Std1=Std1Temp;
            Std2=Std2Temp;
            CorrCoef=CorrCoefTemp;
        end
        CurrentSelection = menu(sprintf('Do you want to mark more bad points?'),'Yes','No');
        
        % Abort
        if CurrentSelection==2
            return
        end
    end
    
% Remove markers moving relative to their neighbours:
% This is a filter which helps to find jumpy data points which are oscillating or stop moving. The Filter starts by finding the next 10 data point neighbours, 
% calculates their mean position and then plots the difference between each data point and its neighbours versus image number. If a data point is jumping around, it will show up as a spike. But
% be careful, one bad one will also affect its neighbours, therefore it is worthwhile to use this filter step by step.
function [Valid1,Valid2,Std1,Std2,CorrCoef,CurrentFigureHandle]=RemoveJumpers(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName)

    WriteToLogFile(LogFileName,'Remove jumpers in direction',Direction,'s');
    CurrentFigureHandle=UseCurrentFigureHandle(0);
    NumOfNeighbors=10;
    Continue=1;

    while Continue==1
        SizeValid1=size(Valid1);
        NumOfPoints=SizeValid1(1,1);
        NumOfImages=SizeValid1(1,2);
        
        % Calculate the distance to all other points
        MeanDistance=zeros(SizeValid1);
        MaxDistance=zeros(NumOfPoints,1);
        MinDistance=zeros(NumOfPoints,1);
        
        Waitbar=waitbar(0,'Processing the markers...');
        for CurrentPoint=1:NumOfPoints
            waitbar(CurrentPoint/NumOfPoints);
            Distance=(((Valid1(:,1)-Valid1(CurrentPoint,1)).^2+(Valid2(:,1)-Valid2(CurrentPoint,1)).^2).^(0.5));

            % Find the next neighbours by smallest distance
            [~,DistanceSortedIndices]=sort(Distance);

            % Take the mean position of the closest data points for all images
            MeanDistance(CurrentPoint,:)= Valid1(CurrentPoint,:)-mean(Valid1(DistanceSortedIndices(2:NumOfNeighbors),:),1);
            MaxDistance(CurrentPoint,1)= max(diff(MeanDistance(CurrentPoint,:)-MeanDistance(CurrentPoint,1)));
            MinDistance(CurrentPoint,1)= min(diff(MeanDistance(CurrentPoint,:)-MeanDistance(CurrentPoint,1)));
        end
        close(Waitbar)
        
        for CurrentPoint=1:NumOfPoints
            plot(diff(MeanDistance(CurrentPoint,:)-MeanDistance(CurrentPoint,1)))
            hold on
        end
         
        % Select upper and lower boundary
        xlabel('image number');
        ylabel(['relative marker ',Direction,'-displacement [pixel]']);
        title(['Define the upper and lower bound by clicking above and below the valid points',sprintf('\n(number of markers #: %1g, ',NumOfPoints),sprintf('number of images #: %1g).',NumOfImages)]);

        try Point1=(ginput(1)); catch; return; end
        plot([1;NumOfImages],[Point1(2);Point1(2)],'r');
        try Point2=(ginput(1)); catch; return; end
        plot([1;NumOfImages],[Point2(2);Point2(2)],'r');
        hold off

        PointsY=[Point1(2);Point2(2)];
        UpperBound=max(PointsY);
        LowerBound=min(PointsY);

        Valid1Temp=Valid1;
        Valid2Temp=Valid2;
        Std1Temp=Std1;
        Std2Temp=Std2;
        CorrCoefTemp=CorrCoef;
        MeanDistanceTemp=MeanDistance;

        RemoveIndices=find(MaxDistance>UpperBound | MinDistance<LowerBound);
        Valid1Temp(RemoveIndices,:)=[];
        Valid2Temp(RemoveIndices,:)=[];
        Std1Temp(RemoveIndices,:)=[];
        Std2Temp(RemoveIndices,:)=[];
        CorrCoefTemp(RemoveIndices,:)=[];
        MeanDistanceTemp(RemoveIndices,:)=[];
        SizeValid1Temp=size(Valid1Temp);
        NumOfPointsTemp=SizeValid1Temp(1,1);

        for CurrentPoint=1:NumOfPointsTemp
            plot(diff(MeanDistanceTemp(CurrentPoint,:)-MeanDistanceTemp(CurrentPoint,1)));
            hold on
        end
        plot([1;NumOfImages],[Point1(2);Point1(2)],'r');
        plot([1;NumOfImages],[Point2(2);Point2(2)],'r');
        xlabel('image number');
        ylabel(['relative marker ',Direction,'-displacement [pixel]']);
        title(['Define the upper and lower bound by clicking above and below the valid points',sprintf('\n(number of markers #: %1g, ',NumOfPoints),sprintf('number of deleted markers #: %1g).',NumOfPoints-NumOfPointsTemp)]);
        hold off
        
        Selection = menu('Do you like the result?','Apply','Apply and refine','Revert and try again','Cancel');
        switch Selection
            case 1
                if SizeValid1Temp(1,1)>0 % avoid to remove all markers
                    Valid1=Valid1Temp;
                    Valid2=Valid2Temp;
                    Std1=Std1Temp;
                    Std2=Std2Temp;
                    CorrCoef=CorrCoefTemp;
                    WriteToLogFile(LogFileName,'Upper bound',UpperBound,'d');
                    WriteToLogFile(LogFileName,'Lower bound',LowerBound,'d');
                end
                Continue=0;
            case 2
                if SizeValid1Temp(1,1)>0 % avoid to remove all markers
                    Valid1=Valid1Temp;
                    Valid2=Valid2Temp;
                    Std1=Std1Temp;
                    Std2=Std2Temp;
                    CorrCoef=CorrCoefTemp;
                    WriteToLogFile(LogFileName,'Upper bound',UpperBound,'d');
                    WriteToLogFile(LogFileName,'Lower bound',LowerBound,'d');
                end
                Continue=1;
            case 3
                Continue=1;
            otherwise
                return
        end
    end
    
% Remove markers by standard deviation    
function [Valid1,Valid2,Std1,Std2,CorrCoef]=RemoveStd(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName) 
        
    % Abort if no valid standard deviation given
    if isempty(find(Std1)) || isempty(find(Std2))
        msgbox('Please open standard deviation first');
    else
        WriteToLogFile(LogFileName,'Remove markers by standard deviation in direction',Direction,'s');
        [Valid1,Valid2,Std1,Std2,CorrCoef]=CleanMarkersStdDev(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName); 
    end
    
% Remove markers by distancetofit    
function [Valid1,Valid2,Std1,Std2,CorrCoef]=RemoveDist(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName) 
    
    % Abort if no valid standard deviation given
    if isempty(find(Std1)) || isempty(find(Std2))
        msgbox('Please open standard deviation first');
    else
        WriteToLogFile(LogFileName,'Remove markers by distance to fit in direction',Direction,'s');
        [Valid1,Valid2,Std1,Std2,CorrCoef]=CleanMarkersDist(Valid1,Valid2,Std1,Std2,CorrCoef,Direction,LogFileName); 
    end
   
% Remove markers by correlation coefficient    
function [Valid1,Valid2,Std1,Std2,CorrCoef,GoodMarkers]=RemoveCorrCoef(Valid1,Valid2,Std1,Std2,CorrCoef,LogFileName) 
        
    % Abort if no valid correlation coefficient given
    if isempty(find(CorrCoef))
        msgbox('Please open correlation coefficient first');
    else
        WriteToLogFile(LogFileName,'Remove markers by correlation coefficient','','s');
        Prompt={'Which threshold do you want to use for marker deletion?'};
        DlgTitle='Threshold selection';
        SelectedCorrCoef=0.9;
        DefValue={num2str(SelectedCorrCoef)};
        Answer=inputdlg(Prompt,DlgTitle,1,DefValue);
        SelectedCorrCoef=str2num(cell2mat(Answer(1,1)));
                
        % Delete points from temporary data
        [Valid1Temp,Valid2Temp,Std1Temp,Std2Temp,CorrCoefTemp,GoodMarkersTemp]=RemoveSelectedCorrCoef(Valid1,Valid2,Std1,Std2,CorrCoef,SelectedCorrCoef);
        
        % Delete point permanently?
        Selection=menu(sprintf('Do you want to delete these points permanently?'),'Yes','No');
        if Selection==1
            WriteToLogFile(LogFileName,'Selected threshold',SelectedCorrCoef,'d');
            Valid1=Valid1Temp;
            Valid2=Valid2Temp;
            Std1=Std1Temp;
            Std2=Std2Temp;
            CorrCoef=CorrCoefTemp;
            GoodMarkers=GoodMarkersTemp;
        end   
    end

% Remove markers by selected correlation coefficient        
function [Valid1,Valid2,Std1,Std2,CorrCoef,GoodMarkers]=RemoveSelectedCorrCoef(Valid1,Valid2,Std1,Std2,CorrCoef,SelectedCorrCoef)
    
    [RemoveIndicesRow,~]=find(CorrCoef<SelectedCorrCoef);
    RemoveIndicesRow=unique(RemoveIndicesRow);
    GoodMarkers=(1:size(Valid1,1))';
    GoodMarkers(RemoveIndicesRow,:)=[];
    Valid1(RemoveIndicesRow,:)=[];
    Valid2(RemoveIndicesRow,:)=[];
    Std1(RemoveIndicesRow,:)=[];
    Std2(RemoveIndicesRow,:)=[];
    CorrCoef(RemoveIndicesRow,:)=[];