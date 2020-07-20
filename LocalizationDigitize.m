%% Reorganizing text files
optodeorder=['nz ';'cz ';'iz ';'ar ';'al ';'s1 ';'s2 ';'s3 ';'s4 ';'s5 ';'s6 ';'s7 ';'s8 ';'s9 ';'s10';'s11';'s12';'s13';'s14';'s15';'d1 ';'d2 ';...
    'd3 ';'d4 ';'d5 ';'d6 ';'d7 ';'d8 ';'d9 ';'d10';'d11';'d12';'d13';'d14';'d15';'d16';'d17';'d18';'d19';'d20';'d21';'d22'];
filename=uigetfile('*.*');
adjacent_thresh=0;
dif_fileread(filename,optodeorder,0,strcat('formated_',filename),adjacent_thresh);
%% Atlas Viewer GUI process
option = 2; % =1 optode =2 channel
% displaycolorswitch=15; % optode mode
displaycolorswitch=8; % channel mode

sdfilename='Nathan.sd';
sdfileext='.sd';
% dirnameSubj='/Users/xiaosuhu/Documents/MATLAB/DATA_VRB/DATA_Digitizer';
% dirnameAtlas='/Users/xiaosuhu/Documents/MATLAB/A_fNIRS_analyses_scripts/CODE_fNIRS_localization/AtlasViewerGUI/Data/Colin';
dirnameSubj='/Users/xiaosuhu/Documents/MATLAB/PROJECT_VRB/CODE_VRB/Digitization_Probe';
dirnameAtlas='/Users/xiaosuhu/Documents/MATLAB/Digitization/AtlasViewerGUIAugment/Data/MNI152Nonlinear_reduced';

filetoestimate=uigetfile('*.*');
[probe,refpts, ptsProj_cortex,estimatedmni,brain_vol]=AVG_process_V2_MNI152Nonlinear(option, dirnameSubj,dirnameAtlas,filetoestimate, sdfilename, sdfileext);

% load Opticalmodel1.txt -ascii
% Opticalmodel1=Opticalmodel1*10;
% figure
% scatter3(Opticalmodel1(1:5,1),Opticalmodel1(1:5,2),Opticalmodel1(1:5,3),500,'redo','Linewidth',2,'MarkerFaceColor',[1 0 0])
% hold on
% scatter3(Opticalmodel1(6:end,1),Opticalmodel1(6:end,2),Opticalmodel1(6:end,3),500,'blueo','Linewidth',2,'MarkerFaceColor',[1 0 0])

depth=0;
mode='center'; % Tested Center, Nearest, and Normal. Found Center is the best mode

for i=1:size(ptsProj_cortex,1)
    ptsProj_cortex_adjust(i,:)=pullPtsToSurf(ptsProj_cortex(i,:),surf,mode,depth);
end

ptsProj_cortex=ptsProj_cortex_adjust;
%% Plot individual images

load('MNI152_downsampled.mat');
surf.vertices=vertices;
surf.faces=faces;

figure
subplot(1,2,1);

% Adult MRI session

set(gcf,'color',[1 1 1])
% subplot(1,2,1)
h1=patch('faces',surf.faces,'vertices',surf.vertices,'Facecolor',[.9 .9 .9],'EdgeColor','none','Facealpha',1);
hold on
h2=scatter3(ptsProj_cortex(1:displaycolorswitch,1),ptsProj_cortex(1:displaycolorswitch,2),ptsProj_cortex(1:displaycolorswitch,3),500,'redo','Linewidth',2,'MarkerFaceColor',[1 0 0]);
hold on
h3=scatter3(ptsProj_cortex(displaycolorswitch+1:length(ptsProj_cortex),1),ptsProj_cortex(displaycolorswitch+1:length(ptsProj_cortex),2),ptsProj_cortex(displaycolorswitch+1:length(ptsProj_cortex),3),500,'blueo','Linewidth',2,'MarkerFaceColor',[0 0 1]);
hold on

set(gca, 'visible', 'off')
light
view(-90,0)
camlight
lighting phong;
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

subplot(1,2,2)


% Adult MRI session
set(gcf,'color',[1 1 1])
% subplot(1,2,1)
h1=patch('faces',surf.faces,'vertices',surf.vertices,'Facecolor',[.9 .9 .9],'EdgeColor','none','Facealpha',1);
hold on
h2=scatter3(ptsProj_cortex_adjust(1:displaycolorswitch,1),ptsProj_cortex_adjust(1:displaycolorswitch,2),ptsProj_cortex_adjust(1:displaycolorswitch,3),500,'redo','Linewidth',2,'MarkerFaceColor',[1 0 0]);
hold on
h3=scatter3(ptsProj_cortex_adjust(displaycolorswitch+1:length(ptsProj_cortex),1),ptsProj_cortex_adjust(displaycolorswitch+1:length(ptsProj_cortex),2),ptsProj_cortex_adjust(displaycolorswitch+1:length(ptsProj_cortex),3),500,'blueo','Linewidth',2,'MarkerFaceColor',[0 0 1]);
hold on

set(gca, 'visible', 'off')
light
view(-90,0)
camlight
lighting phong;
set(gca,'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1]);

