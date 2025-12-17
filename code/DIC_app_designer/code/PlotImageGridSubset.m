% Plot image with grid and subset (cpcorr CORRSIZE)
clearvars

% Get grid x
[GridXName,GridXPath]=uigetfile('*.*','Open gridx.dat');
cd(GridXPath);
GridX=importdata(GridXName,'\t');

% Get grid y
[GridYName,GridYPath]=uigetfile('*.*','Open gridy.dat');
cd(GridYPath);
GridY=importdata(GridYName,'\t');

% Get and show image
[ImageName,ImagePath]=uigetfile('*.*','Open image');
cd(ImagePath);
Figure=figure;
imshow(ImageName);
hold on

% Get corrsize
CorrSize=15;
Prompt={'Enter corrsize (size of image part selected for correlation):'};
DlgTitle='Corrsize';
DefValue={num2str(CorrSize)};
Answer=inputdlg(Prompt,DlgTitle,1,DefValue);
CorrSize=str2double(cell2mat(Answer(1,1)));

% Plot subset
NumOfGridMarkers=size(GridX,1);
Subsets=[GridX(:,1)-CorrSize,GridY(:,1)-CorrSize,repmat(2*CorrSize+1,NumOfGridMarkers,1),repmat(2*CorrSize+1,NumOfGridMarkers,1)];

rectangle('Position',Subsets(1,:),'EdgeColor','b','LineWidth',5);
for Marker=2:NumOfGridMarkers
    rectangle('Position',Subsets(Marker,:),'EdgeColor','b');
end

% Plot grid
plot(GridX(:,1),GridY(:,1),'.g','MarkerSize',10);
plot(GridX(1,1),GridY(1,1),'.g','MarkerSize',20);
axis on

hold off
