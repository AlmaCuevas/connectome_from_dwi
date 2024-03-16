% https://community.mrtrix.org/t/visualising-processing-tck2connectome-output/1941/6
% Code for viewing Connectomes

clear

%% Load per subject from the root subjects folder
ID = '143';
mainpath = '/root_folder/here/';
inputdir = strcat(mainpath, ID, '_pre/Diffusion/Connectome/', ID, '_pre');
inputdir2 = strcat(mainpath, ID, '_post/Diffusion/spared_post/', ID, '_post');
pre_con = load(strcat(inputdir, '_sum_streamline_connectome.csv'))';
post_con = load(strcat(inputdir2, '_sum_streamline_spared_connectome.csv'))';

%% Compare raw
figure()
suptitle(ID)
subplot(1,3,1)
surface(pre_con)
title('Pre')

subplot(1,3,2)
surface(post_con)
title('Post')

subplot(1,3,3)
surface(pre_con-post_con)
title('Pre-Post')
% set(gfc, 'color','w');

%% Compare normalized W

figure()
suptitle(ID)
subplot(1,3,1)
surface(pre_con)
title('Pre')

subplot(1,3,2)
surface(post_con)
title('Post')

subplot(1,3,3)
surface(pre_con-post_con)
title('Pre-Post')

change=(pre_con-post_con)/pre_con;
%% BCT graphs


