% Calculate means

%% degrees
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_degrees.mat');
load('All_pre_sum_streamline_degrees.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).degrees);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).degrees);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"degrees.mat"));

%% net_cluster_mean_sr
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_net_cluster_mean_sr.mat');
load('All_pre_sum_streamline_net_cluster_mean_sr.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).net_cluster_mean_sr);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).net_cluster_mean_sr);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"net_cluster_mean_sr.mat"));

%% net_trans_sr
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_net_trans_sr.mat');
load('All_pre_sum_streamline_net_trans_sr.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).net_trans_sr);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).net_trans_sr);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"net_trans_sr.mat"));

%% cluster_by_shortpath
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_cluster_by_shortpath.mat');
load('All_pre_sum_streamline_cluster_by_shortpath.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).cluster_by_shortpath);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).cluster_by_shortpath);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"cluster_by_shortpath.mat"));

%% efficiency_local
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_efficiency_local.mat');
load('All_pre_sum_streamline_efficiency_local.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).efficiency_local);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).efficiency_local);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"efficiency_local.mat"));

%% efficiency_global
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_efficiency_global.mat');
load('All_pre_sum_streamline_efficiency_global.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).efficiency_global);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).efficiency_global);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"efficiency_global.mat"));

%% clustering
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_clustering.mat');
load('All_pre_sum_streamline_clustering.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).clustering);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).clustering);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"clustering.mat"));

%% transitivity
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_transitivity.mat');
load('All_pre_sum_streamline_transitivity.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).transitivity);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).transitivity);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"transitivity.mat"));

%% Betweenness
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_betweenness.mat');
load('All_pre_sum_streamline_betweenness.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).betweenness);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).betweenness);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"dbetweennness.mat"));

%% strength
clear
out_path='/root_folder/here/All_stats/Means/';

load('All_post_sum_streamline_strength.mat');
load('All_pre_sum_streamline_strength.mat');


for iID = 1:length(pre)
    pre_mean(iID).value=mean(pre(iID).strength);
    pre_mean(iID).code=pre(iID).code;
end

for iID = 1:length(post)
    post_mean(iID).value=mean(post(iID).strength);
    post_mean(iID).code=post(iID).code;
end
clear iID
save(strcat(out_path,"strength.mat"));