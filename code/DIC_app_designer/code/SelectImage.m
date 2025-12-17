function SelectedImage=SelectImage(NumOfImages)
    Prompt={'From which image do you want to select the markers?'};
    DlgTitle='Image selection';
    DefValue={num2str(NumOfImages)};
    Answer=inputdlg(Prompt,DlgTitle,1,DefValue);
    if isempty(Answer)
        SelectedImage = -1;
    else
        SelectedImage=str2double(cell2mat(Answer(1,1)));
        if SelectedImage>NumOfImages
            SelectedImage=NumOfImages;
        elseif SelectedImage<1
            SelectedImage=1;
        end
    end
