% script to loop through the data folder and perform the QTI+ fit

subjs_path = '/home/denbo78/test_folder_covid_preproc';
cd(subjs_path)

%% get list of subjects without '.', '..'
d = dir;
d = d(~ismember({d.name}, {'.','..'}));

%% loop through subjects
for i = 1:numel(d)
   
    path_tmp = strcat(subjs_path,'/',d(i).name);
    cd(path_tmp)
    
    % cd the temporary folder with copied file for pre/post processing
    cd('analysis')
    
    % run qti+ fit
    qtiplus_run_fit()
    
    % clear path and data for next subject
    clear path_tmp
    
end
