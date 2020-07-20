%% Try to find the sturcture for each channel
orig=[96.5 114.5 96.5]; % This is the origin of the MNI space
radius=10*ones(45,1);
[BA_result_sort, Brain_Region_result_sort]=BAfinding_ALLCH_withplot(ptsProj_cortex_adjust-repmat(orig,size(ptsProj_cortex_adjust,1),1),radius,orig);


%% Try to list the results as a table
nV=100; % 80% of the region were picked
mode='BA';

CH_table=CHtabulate(BA_result_sort,nV,mode);

writetable(CH_table,'CHmapping.xlsx','Sheet','BA');
