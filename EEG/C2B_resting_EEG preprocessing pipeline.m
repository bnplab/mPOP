%% Preparation of all parameters 
% Collectalldata 
subject_ID=[3 4 13  18 19 20 21 23 26 27 28 29 30 32 34 38 39  40 41 45 47 48 49]

cd 'T:\Experimental Data\2021-10 CHASMEC\Results\TEP'


% read EEG data 

for i=1: length(PreResting_Finalpath)



 if ~exist(['T:\Experimental Data\2021-10 CHASMEC\Results\TEP\enhanced1\Sub_',num2str(subject_ID(i))], 'dir')
       mkdir(['T:\Experimental Data\2021-10 CHASMEC\Results\TEP\enhanced1\Sub_',num2str(subject_ID(i)),'\'])
 end

folderpath=['T:\Experimental Data\2021-10 CHASMEC\Results\TEP\enhanced1\Sub_',num2str(subject_ID(i)),'\'];
%% prepare for source reconstruction

fprintf('Read the MRI data for subject PRE %i\n', subject_ID(i))
fprintf('Load \n')
disp(MRI_pathfull_all{i})

%read MRI
mri = ft_read_mri(MRI_pathfull_all{i});


%check and save the MRI
cfg = [];
cfg.method = 'ortho';
ft_sourceplot(cfg, mri)

set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'MRI before slice_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 


%MRi slice to have a iniform thicknesss for each slice and This step reslices the anatomical volume in a way that voxels will be isotropic
cfg  = [];
mrirs = ft_volumereslice(cfg,mri);

save([folderpath,'PRE_MRIRS_sub',num2str(subject_ID(i)),'.mat'],'mrirs', '-v7.3')

cfg = [];
ft_sourceplot(cfg,mrirs);
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'MRI after slice_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 

% check the coordsys system 
mri_coordsys=ft_determine_coordsys(mri, 'interactive', 'no')


mrirs.coordsys='acpc';
% segment the anatomical MRI and make the headmodel for visulization 
cfg        = [];
cfg.output = {'brain','skull','scalp'};
seg        = ft_volumesegment(cfg, mrirs);

ft_checkdata(seg , 'feedback', 'yes')

save([folderpath,'PRE_MRI_seg_sub',num2str(subject_ID(i)),'.mat'],'seg', '-v7.3')


cfg=[];
cfg.tissue={'brain','skull','scalp'};
cfg.numvertices = [6000 4000 2000];
bnd=ft_prepare_mesh(cfg,seg);

save([folderpath,'PRE_MRI_Mesh_sub',num2str(subject_ID(i)),'.mat'],'bnd', '-v7.3')


cfg        = [];
cfg.method = 'bemcp';
headmodel  = ft_prepare_headmodel(cfg, bnd);

save([folderpath,'PRE_MRI_headmodel_sub',num2str(subject_ID(i)),'.mat'],'headmodel', '-v7.3')

%save the BEM modeling
close all
figure 
ft_plot_mesh(headmodel.bnd(3),'facecolor',[0 0.4470 0.7410]); %scalp
title('Scalp')
view(90,0)
camlight

set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'Scalp_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 



close all
figure
ft_plot_mesh(headmodel.bnd(2),'facecolor',[0 0.4470 0.7410]); %skull
title('Skull')
view(90,0)
camlight
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'Skull_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 


close all
figure
ft_plot_mesh(headmodel.bnd(1),'facecolor',[0.3010 0.7450 0.9330]); %brain
title('Brain')
view(90,0)
camlight
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'Brain_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 


% ensure that the electrode coordinates are in mm
elec=ft_read_sens(Enhanced_1XML_path{i});
elec = ft_convert_units(elec,'mm'); % should be the same unit as MRI

% interactively coregister the electrodes to the BEM head model
% this is a visual check and refinement step

cfg = [];
cfg.method    = 'interactive';
cfg.elec      = elec;
cfg.headshape = headmodel.bnd(3);
elec_new = ft_electroderealign(cfg);


figure
hold on
ft_plot_sens(elec_new, 'elecsize', 40);
ft_plot_mesh(headmodel.bnd(3)); 
view(90, 0)



exportgraphics(gcf,[folderpath,'ElecAlignment_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all

save([folderpath,'Elec_position_sub',num2str(subject_ID(i)),'.mat'],'elec_new', '-v7.3')




% Wrap to MNI space  based on individual subject MRI 
cfg              = [];
cfg.resolution=8;
cfg.mri=mrirs;
cfg.method = 'basedonmni';
% cfg.headmodel    = headmodel;
cfg.nonlinear = 'yes';
cfg.elec=elec_new;
cfg.unit      ='mm';
grid    = ft_prepare_sourcemodel(cfg);

save([folderpath,'Grid_sub',num2str(subject_ID(i)),'.mat'],'grid', '-v7.3')


figure; 
ft_plot_headmodel(headmodel, 'facecolor',[0.4660 0.6740 0.1880],'vertexcolor' ,[0.3010 0.7450 0.9330],'edgecolor', [0.9290 0.6940 0.1250], 'facealpha', 0.1);
hold on;
ft_plot_mesh(grid.pos(grid.inside,:));
view(90,0)
camlight


set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'Grid_eletrode_All_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)

close all 



% prepare the Leadfield matrix 

cfg             = [];
% cfg.normalize='yes';
cfg.sourcemodel  = grid;
cfg.headmodel   = headmodel;
cfg.elec     =  elec_new;
lf              = ft_prepare_leadfield(cfg);


save([folderpath,'Leadfield_PRE_DS_sub',num2str(subject_ID(i)),'.mat'],'lf')
 

%% PRE EEG 
fprintf('Read the data for subject PRE %i\n', subject_ID(i))
fprintf('Load \n')
disp(PostResting_Finalpath{i})

cfg            = [];
cfg.dataset    = PreResting_Finalpath{i}; % note that you may need to add the full path to the .ds directory
cfg.continuous = 'yes';
cfg.channel = {'all' '-FDIr' }; % indicate the channels we would like to read and/or exclude.
cfg.reref = 'yes';        % We want to rereference our data
cfg.refchannel = {'all'}; % Here we specify our reference channels
cfg.implicitref = 'Cz';    % Here we can specify the name of the implicit reference electrode used during the acquisition
dataRaw           = ft_preprocessing(cfg);

% save([folderpath,'PRE_Raw_sub',num2str(subject_ID(i)),'.mat'],'dataRaw','-v7.3')



% segment the EEG data in to 2 seconds per epochs 
cfg         = [];
cfg.length  = 2;
cfg.overlap = 0;
dataR_epoched        = ft_redefinetrial(cfg, dataRaw);



% this step is needed to 1) remove the 5 s data whenstarting record and stop the record.
cfg        = [];
cfg.demean = 'yes';
cfg.trials = 2:(numel(dataR_epoched.trial)-2);
dataR_epoched_clean       = ft_preprocessing(cfg, dataR_epoched);


% remove the line noise 
cfg = [];
cfg.channel    = 'all';
cfg.dftfilter  = 'yes';
cfg.dftfreq    =[50 100 150];
dataR_3S = ft_preprocessing(cfg,dataR_epoched_clean);



% remove bad channels and bad trials 

cfg         = [];
cfg.method  = 'summary';
dataclean   = ft_rejectvisual(cfg, dataR_3S);


% mark the bad trials so that keep consistant with the EMG data (match)

badchannels              = dataclean.cfg.badchannel;    



cfg = [];
ft_databrowser(cfg, dataclean);

% downsampling the data to the 1000Hz
cfg            = [];
cfg.resamplefs = 1000;
cfg.detrend    = 'yes';
datads         = ft_resampledata(cfg, dataclean);

% save the raw dta before ICA 

save([folderpath,'PRE_downsample_clean_sub',num2str(subject_ID(i)),'.mat'],'datads', '-v7.3')

% use ICA in order to identify cardiac and blink components
cfg                 = [];
cfg.method          = 'runica';
cfg.runica.pca=    25; 
ICAcompR                = ft_componentanalysis(cfg, datads);

save([folderpath,'PRE_ICAcom_sub',num2str(subject_ID(i)),'.mat'],'ICAcompR', '-v7.3')

% visualize components
% these were the indices of the bad components that were identified
% they may be different if you re-run the ICA decomposition with a random randomseed.

cfg            = [];
% cfg.channel    = badcomp;
cfg.layout     = 'easycapM11';
cfg.compscale  = 'local';
cfg.continuous = 'yes';
ft_databrowser(cfg, ICAcompR);


figure;
cfg           = [];
cfg.component = 1:25;
cfg.comment   = 'no';
cfg.layout    = 'easycapM11'; % If you use a function that requires plotting of topographical information you need to supply the function with the location of your channels
ft_topoplotIC(cfg,  ICAcompR);

% save ICA Plot 
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'PRE_ICA_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)
close all 


% remove bd components
badcomp = [1 2 4 5 6 7  9:25 ];% muannal checking 
cfg           = [];
cfg.component = badcomp;
dataR_ica       = ft_rejectcomponent(cfg, ICAcompR);

save([folderpath,'PRE_badcoms_sub',num2str(subject_ID(i)),'.mat'],'badcomp', '-v7.3')


% visual rejections again 
cfg         = [];
cfg.method  = 'summary';
datacR_icalean   = ft_rejectvisual(cfg, dataR_ica);

save([folderpath,'PRE_datacR_ICAlean_sub',num2str(subject_ID(i)),'.mat'],'datacR_icalean', '-v7.3')


% repair channles 
load easycapM11_neighb.mat
load easycapM11
elec=ft_read_sens(Enhanced_1XML_path{i});

if isempty(badchannels)==0
cfg = [];
cfg.badchannel     = badchannels ;
cfg.method         = 'weighted';
cfg.neighbours     = neighbours;
cfg.elec=elec;
dataR_fixed = ft_channelrepair(cfg,datacR_icalean);
else 
    dataR_fixed=datacR_icalean;
end 


% common reference all channel 
cfg=[];
cfg.reref         = 'yes';
cfg.refchannel    = 'all';
t=ft_preprocessing(cfg,dataR_fixed);

save([folderpath,'PRE_Final_Clean_sub',num2str(subject_ID(i)),'.mat'],'t', '-v7.3')

figure 
cfg = [];
ft_databrowser(cfg, t);

cfg=[];
cfg.bpfilter='yes';
cfg.bpfreq=[1 30];
data=ft_preprocessing(cfg,t);


cfg = [];
ft_databrowser(cfg, data);

save([folderpath,'PRE_Final_Clean_30hzfilter_sub',num2str(subject_ID(i)),'.mat'],'data', '-v7.3')



% PRe data 
% frequency analysis 
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'fourier';
cfg.keeptrials = 'yes';
cfg.tapsmofrq  = 2;
cfg.foi        = 10;
freqR           = ft_freqanalysis(cfg, data);

save([folderpath,'Frequency_PRE_sub',num2str(subject_ID(i)),'.mat'],'freqR')
% do the source reconstruction
cfg                   = [];
cfg.frequency         = 10;
cfg.method            = 'pcc';
cfg.sourcemodel       = lf;
cfg.headmodel         = headmodel;
cfg.keeptrials        = 'yes';
% cfg.pcc.lambda        = '5%';
% cfg.pcc.projectnoise  = 'yes';
cfg.pcc.fixedori      = 'yes';
sourceR = ft_sourceanalysis(cfg, freqR);

save([folderpath,'Resource_PRE_sub',num2str(subject_ID(i)),'.mat'],'sourceR')

% compute connectivity
cfg         = [];
cfg.method  ='coh';
cfg.complex = 'absimag';
source_connR = ft_connectivityanalysis(cfg, sourceR);

save([folderpath,'Conn_ALL_PRE_sub',num2str(subject_ID(i)),'.mat'],'source_connR')

atlas = ft_read_atlas('ROI_MNI_V4.nii');


cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel2 = ft_sourceinterpolate(cfg, atlas, lf);

sourcemodel2.tissue(isnan(sourcemodel2.tissue)) =0;



sourcemodel2.pos = source_connR.pos; % otherwise the parcellation won't work


cfg = [];
cfg.parcellation = 'tissue';
cfg.parameter    = 'cohspctrm';
parc_connR = ft_sourceparcellate(cfg, source_connR, sourcemodel2);

save([folderpath,'parc_Conn_ALL_PRE_sub',num2str(subject_ID(i)),'.mat'],'parc_connR')

W_thrR = threshold_proportional(parc_connR.cohspctrm, 1);

connR_density=W_thrR(1:90,1:90);

conn_density1 = threshold_proportional(connR_density([1 2 19 20 ],[1 2 19 20]), 1);



SMA_L_2_M1_L_Rest=connR_density(19,1);
SMA_L_2_M1_R_Rest=connR_density(19,2);
SMA_R_2_M1_L_Rest=connR_density(20,1);
SMA_R_2_M1_R_Rest=connR_density(20,2);


Rest_state=[SMA_L_2_M1_L_Rest,SMA_L_2_M1_R_Rest,SMA_R_2_M1_L_Rest,SMA_R_2_M1_R_Rest];

save([folderpath,'SMAM1_Conn_ALL_PRE_sub',num2str(subject_ID(i)),'.mat'],'Rest_state')


%% Post Data 
fprintf('Read the data for subject POST %i\n', subject_ID(i))
fprintf('Load \n')
disp(PostResting_Finalpath{i})

cfg            = [];
cfg.dataset    = PostResting_Finalpath{i}; % note that you may need to add the full path to the .ds directory
cfg.continuous = 'yes';
cfg.channel = {'all' '-FDIr' }; % indicate the channels we would like to read and/or exclude.
cfg.reref = 'yes';        % We want to rereference our data
cfg.refchannel = {'all'}; % Here we specify our reference channels
cfg.implicitref = 'Cz';    % Here we can specify the name of the implicit reference electrode used during the acquisition
dataRaw2           = ft_preprocessing(cfg);

save([folderpath,'POST_Raw_sub',num2str(subject_ID(i)),'.mat'],'dataRaw2','-v7.3')



% segment the EEG data in to 2 seconds per epochs 
cfg         = [];
cfg.length  = 2;
cfg.overlap = 0;
dataR_epoched2        = ft_redefinetrial(cfg, dataRaw2);



% this step is needed to 1) remove the 10 s data whenstarting record and stop the record.
cfg        = [];
cfg.demean = 'yes';
cfg.trials = 2:(numel(dataR_epoched2.trial)-2);
dataR_epoched_clean2       = ft_preprocessing(cfg, dataR_epoched2);


% remove the line noise 
cfg = [];
cfg.channel    = 'all';
cfg.dftfilter  = 'yes';
cfg.dftfreq    =[50 100 150];
dataR_3S2 = ft_preprocessing(cfg,dataR_epoched_clean2);



% remove bad channels and bad trials 

cfg         = [];
cfg.method  = 'summary';
dataclean2   = ft_rejectvisual(cfg, dataR_3S2);


% mark the bad trials so that keep consistant with the EMG data (match)

badchannels2              = dataclean2.cfg.badchannel;    



cfg = [];
ft_databrowser(cfg, dataclean2);

% downsampling the data to the 1000Hz
cfg            = [];
cfg.resamplefs = 1000;
cfg.detrend    = 'yes';
datads2         = ft_resampledata(cfg, dataclean2);

% save the raw dta before ICA 

save([folderpath,'POST_downsample_clean_sub',num2str(subject_ID(i)),'.mat'],'datads2', '-v7.3')

% use ICA in order to identify cardiac and blink components
cfg                 = [];
cfg.method          = 'runica';
cfg.runica.pca=    25; 
ICAcompR2                = ft_componentanalysis(cfg, datads2);

save([folderpath,'POST_ICAcom_sub',num2str(subject_ID(i)),'.mat'],'ICAcompR2', '-v7.3')

% visualize components
% these were the indices of the bad components that were identified
% they may be different if you re-run the ICA decomposition with a random randomseed.
close all 
cfg            = [];
% cfg.channel    = badcomp;
cfg.layout     = 'easycapM11';
cfg.compscale  = 'local';
cfg.continuous = 'yes';
ft_databrowser(cfg, ICAcompR2);


figure;
cfg           = [];
cfg.component = 1:25;
cfg.comment   = 'no';
cfg.layout    = 'easycapM11'; % If you use a function that requires plotting of topographical information you need to supply the function with the location of your channels
ft_topoplotIC(cfg,  ICAcompR2);

% save ICA Plot 
set(gcf, 'Position', get(0, 'Screensize'));
exportgraphics(gcf,[folderpath,'POST_ICA_sub',num2str(subject_ID(i)), '.png'],'Resolution',300)


close all 


% remove bd components
badcomp = [ 1 2 3 8 14 16 17 18 23 24 25];% muannal checking 
cfg           = [];
cfg.component = badcomp;
dataR_ica2       = ft_rejectcomponent(cfg, ICAcompR2);

save([folderpath,'POST_badcoms_sub',num2str(subject_ID(i)),'.mat'],'badcomp', '-v7.3')


% visual rejections again 
cfg         = [];
cfg.method  = 'summary';
datacR_icalean2   = ft_rejectvisual(cfg, dataR_ica2);

save([folderpath,'POST_datacR_ICAlean_sub',num2str(subject_ID(i)),'.mat'],'datacR_icalean2', '-v7.3')


% repair channles 
load easycapM11_neighb.mat
load easycapM11


badchannels2=datads2.cfg.previous.badchannel;
if isempty(badchannels2)==0
cfg = [];
cfg.badchannel     = badchannels2 ;
cfg.method         = 'weighted';
cfg.neighbours     = neighbours;
cfg.elec=elec_new;
dataR_fixed2 = ft_channelrepair(cfg,datacR_icalean2);
else 
    dataR_fixed2=datacR_icalean2;
end 


% common reference all channel 
cfg=[];
cfg.reref         = 'yes';
cfg.refchannel    = 'all';
t2=ft_preprocessing(cfg,dataR_fixed2);

save([folderpath,'POST_Final_Clean_sub',num2str(subject_ID(i)),'.mat'],'t2', '-v7.3')

figure 
cfg = [];
ft_databrowser(cfg, t2);

cfg=[];
cfg.bpfilter='yes';
cfg.bpfreq=[1 30];
data2=ft_preprocessing(cfg,t2);


cfg = [];
ft_databrowser(cfg, data2);

save([folderpath,'POST_Final_Clean_30hzfilter_sub',num2str(subject_ID(i)),'.mat'],'data2', '-v7.3')


%POST data 
% frequency analysis 
cfg            = [];
cfg.method     = 'mtmfft';
cfg.output     = 'fourier';
cfg.keeptrials = 'yes';
cfg.tapsmofrq  = 2;
cfg.foi        = 10;
freqR2           = ft_freqanalysis(cfg, data2);

save([folderpath,'Frequency_POST_sub',num2str(subject_ID(i)),'.mat'],'freqR2')
% do the source reconstruction
cfg                   = [];
cfg.frequency         = 10;
cfg.method            = 'pcc';
cfg.sourcemodel       = lf;
cfg.headmodel         = headmodel;
cfg.keeptrials        = 'yes';
% cfg.pcc.lambda        = '5%';
% cfg.pcc.projectnoise  = 'yes';
cfg.pcc.fixedori      = 'yes';
sourceR2 = ft_sourceanalysis(cfg, freqR2);

save([folderpath,'Resource_POST_sub',num2str(subject_ID(i)),'.mat'],'sourceR2')

% compute connectivity
cfg         = [];
cfg.method  ='coh';
cfg.complex = 'absimag';
source_connR2 = ft_connectivityanalysis(cfg, sourceR2);

save([folderpath,'Conn_ALL_POST_sub',num2str(subject_ID(i)),'.mat'],'source_connR2')

atlas = ft_read_atlas('ROI_MNI_V4.nii');

%prepare for source interpolate
cfg = [];
cfg.interpmethod = 'nearest';
cfg.parameter = 'tissue';
sourcemodel2 = ft_sourceinterpolate(cfg, atlas, lf);

sourcemodel2.tissue(isnan(sourcemodel2.tissue)) =0;



sourcemodel2.pos = source_connR2.pos; % otherwise the parcellation won't work

% parcellate the brain nodes with functional data 
cfg = [];
cfg.parcellation = 'tissue';
cfg.parameter    = 'cohspctrm';
parc_connR2 = ft_sourceparcellate(cfg, source_connR2, sourcemodel2);

save([folderpath,'parc_Conn_ALL_POST_sub',num2str(subject_ID(i)),'.mat'],'parc_connR2')

% take network density 1
W_thrR = threshold_proportional(parc_connR2.cohspctrm, 1);

connR_density2=W_thrR(1:90,1:90);

% the precentral(M1) 1 and 2 in AAL  and SMA 19 and 20 in AAL

conn_density2 = threshold_proportional(connR_density2([1 2 19 20 ],[1 2 19 20]), 1);


% take coherence almong SMA, and M1
SMA_L_2_M1_L_Rest2=connR_density2(19,1);
SMA_L_2_M1_R_Rest2=connR_density2(19,2);
SMA_R_2_M1_L_Rest2=connR_density2(20,1);
SMA_R_2_M1_R_Rest2=connR_density2(20,2);


Rest_state2=[SMA_L_2_M1_L_Rest2,SMA_L_2_M1_R_Rest2,SMA_R_2_M1_L_Rest2,SMA_R_2_M1_R_Rest2];

save([folderpath,'SMAM1_Conn_ALL_POST_sub',num2str(subject_ID(i)),'.mat'],'Rest_state2')

end 