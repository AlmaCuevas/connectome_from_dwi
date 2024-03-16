% https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy
% Code for the position of figures


clear

%% Load per subject from the root subjects folder 
ID = '146_post';
mainpath = '/root_folder/here/';
inputdir = strcat(mainpath, ID, '/Diffusion/Preproc_files/PreEddy/', ID);
bvecs = load(strcat(inputdir, '_diffusion.bvec'))'; % Assuming your filename is bvecs

%% or load from the subject preEddy folder
% bvecs=load('019.bvec');


figure('position',[100 100 500 500]);
plot3(bvecs(1,:),bvecs(2,:),bvecs(3,:),'*r');
axis([-1 1 -1 1 -1 1]);
axis vis3d;
rotate3d

%savefig(strcat(inputdir, '_alldirections.fig'))