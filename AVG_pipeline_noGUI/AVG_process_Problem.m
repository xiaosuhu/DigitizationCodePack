function [probe, refpts,ptsProj, ptsProj_cortex, ptsProj_cortex_mni, brain_vol] = AVG_process(option,dirnameSubj,dirnameAtlas, digptsfilename, sdfilename, sdfileext)
% This fucntion tries to implement the AtlasViewerGUI process without GUI
% Input parameters:
%     option: 1=register optode 2=register channels
%     digptsfilename: file name containing the digitized points
%     sdfilename: file name containing the source-detector information file, usually a .sd file
%     sdfileext: file extention of the source-detector information file, usually '.sd'

searchPaths={dirnameSubj,dirnameAtlas};

%% Variables initilization
headvol     = initHeadvol();
headsurf    = initHeadsurf();
refpts      = initRefpts();
pialsurf    = initPialsurf();
labelssurf  = initLabelssurf();
probe       = initProbe();
digpts      = initDigpts();
axesv       = initAxesv();


digpts     = ReadDigpts(digpts, dirnameSubj,digptsfilename);
headvol    = getHeadvol(headvol, searchPaths);
headsurf   = getHeadsurf(headsurf, headvol.pathname);
refpts     = getRefpts(refpts, headvol.pathname);
pialsurf   = getPialsurf(pialsurf, headvol.pathname);
labelssurf = getLabelssurf(labelssurf, headvol.pathname);
probe      = ReadProbe(probe, dirnameSubj, headsurf, digpts, refpts, sdfilename, sdfileext);

close all

[headvol, headsurf, pialsurf, labelssurf, probe] = ...
        setOrientationRefpts(refpts, headvol, headsurf, pialsurf, labelssurf, probe);
    

%% Register Atlas to digitized points
% Generate transformation from head volume to digitized points space
[rp_atlas, rp_subj] = findCorrespondingRefpts(refpts, digpts);

headvol.imgOrig = headvol.img;
headvol.T_2digpts = gen_xform_from_pts(rp_atlas, rp_subj); % This is an affine transformation

% Register headvol to digpts but first check fwmodel if it's volume
% is already registered to digpts. if it is then set the headvol object
% to the fwmodel's headvol and reuse it.
[headvol.img, digpts.T_2mc] = ...
        xform_apply_vol_smooth(headvol.img, headvol.T_2digpts);
    
headvol.T_2mc   = digpts.T_2mc * headvol.T_2digpts;
headvol.center = xform_apply(headvol.center, headvol.T_2mc);
headvol.orientation = digpts.orientation;

% We know that headvol.T_2mc = digpts.T_2mc * headvol.T_2digpts.
% Here we need to recover digpts.T_2mc. We can do this from
% headvol.T_2mc and headvol.T_2digpts with a little matrix algebra
% digpts.T_2mc = headvol.T_2mc / headvol.T_2digpts;


% Move digitized pts to monte carlo space
digpts.refpts.pos = xform_apply(digpts.refpts.pos, digpts.T_2mc);
digpts.pcpos      = xform_apply(digpts.pcpos, digpts.T_2mc);
digpts.srcpos     = xform_apply(digpts.srcpos, digpts.T_2mc);
digpts.detpos     = xform_apply(digpts.detpos, digpts.T_2mc);
digpts.optpos     = [digpts.srcpos; digpts.detpos];
digpts.center     = digpts.refpts.center;

% Copy digitized optodes to probe object
probe.optpos = digpts.optpos;

% move head surface to monte carlo space
headsurf.mesh.vertices   = xform_apply(headsurf.mesh.vertices, headvol.T_2mc);
headsurf.center          = xform_apply(headsurf.center, headvol.T_2mc);
headsurf.centerRotation  = xform_apply(headsurf.centerRotation, headvol.T_2mc);

% move pial surface to monte carlo space
pialsurf.mesh.vertices   = xform_apply(pialsurf.mesh.vertices, headvol.T_2mc);
pialsurf.center          = xform_apply(pialsurf.center, headvol.T_2mc);

% move anatomical labels surface to monte carlo space
labelssurf.mesh.vertices = xform_apply(labelssurf.mesh.vertices, headvol.T_2mc);
labelssurf.center        = xform_apply(labelssurf.center, headvol.T_2mc);

% move ref points to monte carlo space
refpts.pos = xform_apply(refpts.pos, headvol.T_2mc);
refpts.cortexProjection.pos = xform_apply(refpts.cortexProjection.pos, headvol.T_2mc);
refpts.center = xform_apply(refpts.center, headvol.T_2mc);

%% Pull probe to head surface

% Optional, try to move everything out of range
% probe.pullToSurfAlgorithm='nearest';
% displacement=[20 0 0];
% probe.optpos=probe.optpos+repmat(displacement,size(probe.optpos,1),1);
%
probe = pullProbeToHeadsurf(probe,headvol);
probe = findMeasMidPts(probe);

%% Register probe to head (Projection PROBES)
% probe = probe2atlasSpace(headsurf,probe,digpts,refpts);
% Assign variables from the main objects
optpos_reg         = probe.optpos_reg;
optpos_reg_mean    = probe.optpos_reg_mean;
hOptodes           = probe.handles.hOptodes;
hProjectionPts     = probe.handles.hProjectionPts;
hProjectionTbl     = probe.handles.hProjectionTbl;
hProjectionRays    = probe.handles.hProjectionRays;
nopt               = probe.noptorig;
ml                 = probe.ml;
ptsProj_cortex     = probe.ptsProj_cortex;
ptsProj_cortex_mni = probe.ptsProj_cortex_mni;
attractPt          = headvol.center;
T_labelssurf2vol   = labelssurf.T_2vol;

labelssurf     = initLabelssurfProbeProjection(labelssurf);
hLabelsSurf    = labelssurf.handles.surf;
mesh           = labelssurf.mesh;
vertices       = labelssurf.mesh.vertices;
idxL           = labelssurf.idxL;
namesL         = labelssurf.names;

T_headvol2mc       = headvol.T_2mc;

iTbl = 1;
tblPos = [.1,.02,.45,.8];
ptsProj = [];

%----------------------------------------
% option = 1;
% 1 = probe
% 2 = channel
%----------------------------------------
switch(option)
    case 1
        
        if ~isempty(optpos_reg)
            ptsProj = optpos_reg(1:nopt,:);
            
            % If projecting optodes rather than meas channels, display optodes
            % in their original registered positions rather than the
            % ones which were lifted off the head surface for easier viewing.
            probe.hOptodesIdx = 2;
            probe = setProbeDisplay(probe,headsurf);
            figname = 'Curr Subject Optode Projection to Cortex Labels';
            
            tblPos(1)= tblPos(1)-.1;
        end
        
    case 2
        
        ptsProj = probe.mlmp;
        figname = 'Curr Subject Channel Projection to Cortex Labels';
        tblPos(1)= tblPos(1)-.1;
        
    case 3
        
        if ~isempty(optpos_reg_mean)
            ptsProj = optpos_reg_mean(1:nopt,:);
            
            % If projecting optodes rather than meas channels, display optodes
            % in their original registered positions rather than the
            % ones which were lifted off the head surface for easier viewing.
            probe.hOptodesIdx = 2;
            probe = setProbeDisplay(probe,headsurf);
            figname = 'Group Optode Projection to Cortex Labels';
            iTbl = 2;
            tblPos(1)= tblPos(1)+.2;
        end
        
    case 4
        
        ptsProj = probe.mlmp_mean;
        figname = 'Group Channel Projection to Cortex Labels';
        iTbl = 2;
        tblPos(1)= tblPos(1)+.2;
        
    case 5
        
        return;
        
end


if isempty(ptsProj)
    menu('Warning: Projection is Empty', 'OK');
    return;
end

probe = clearProbeProjection(probe, iTbl);

% ptsProj_cortex is in viewer space. To get back to MNI coordinates take the
% inverse of the tranformation from mni to viewer space.
ptsProj_cortex = ProjectionBI(ptsProj, vertices);
[ptsClosest, iP] = nearest_point(vertices, ptsProj_cortex);
if ~labelssurf.isempty(labelssurf)
    ptsProj_cortex_mni = xform_apply(ptsProj_cortex,inv(T_headvol2mc*T_labelssurf2vol));
end

brain_vol=pialsurf.mesh;

end

