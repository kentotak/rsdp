function selectedFolders = selectMultipleFolders()
    selectedFolders = {};

    while true
        folder = uigetdir('','Select a pillar folder.');
        
        if folder == 0
            break
        end
        
        selectedFolders{end+1} = folder;
        
        choice = questdlg('Do you want to select another folder?', ...
                          'Continue', 'Yes', 'No', 'No');
        if strcmp(choice, 'No')
            break
        end
    end
end