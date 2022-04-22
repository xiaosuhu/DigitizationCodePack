%% This is an example code showing how to locate the estimated brain regions for each channel

%% Try to find the sturcture for each channel
orig=[96.5 114.5 96.5]; % This is the origin of the MNI space
radius=10*ones(45,1);

% if not MNI coord need to shift the orig
[BA_result_sort, Brain_Region_result_sort]=BAfinding_ALLCH_withplot(ptsProj_cortex_adjust-repmat(orig,size(ptsProj_cortex_adjust,1),1),radius,orig);


% if MNIcoord
[BA_result_sort, Brain_Region_result_sort]=BAfinding_ALLCH_withplot(MNIcoord,radius,orig);

%% Try to list the results as a table
nV=100; % 80% of the region were picked
mode='Region';

CH_table=CHtabulate(Brain_Region_result_sort,nV,mode);

writetable(CH_table,'CHmapping2.xlsx','Sheet','Region');
