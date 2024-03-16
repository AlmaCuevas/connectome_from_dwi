% Join stats by type (instead of subject)

clc
clear

% Paths
mainpath = '/root_folder/here/';
outdir=strcat(mainpath, 'All_stats');
mkdir(outdir);

% Names
%subjects = ["25_post", "143_post", "0_post", "183_post", "154_post", "1_post", "17_post", "21_post", "83_post", "120_post", "107_post", "127_post", "146_post"]; % , "23_post"
subjects = ["25_pre", "95_pre", "143_pre", "0_pre", "89_pre", "154_pre", "1_pre", "4_pre", "183_pre", "9_pre", "17_pre", "20_pre", "21_pre", "23_pre", "83_pre", "107_pre", "120_pre", "126_pre", "127_pre", "128_pre", "146_pre"];
%stat = ["_W.mat", "_strength", "_transitivity.mat", "_degrees.mat", "_efficiency_local.mat", "_efficiency_global.mat",  "_D.mat", "_B.mat", "_characteristic_path_length.mat", "_betweenness.mat", "_cluster_by_shortpath.mat", "_clustering.mat", "_net_cluster_mean_sr.mat", "_net_eglob_sr.mat", "_net_shortpath_sr.mat", "_net_trans_sr.mat"];
stat = ["_lambda_char"];
for iStat = 1:length(stat)
    type= strcat('_sum_streamline', stat(iStat));
    for iID = 1:length(subjects)

        inputdir = strcat(mainpath, subjects(iID), '/Diffusion/Full_Connectome_Outputs_0to1norm/', subjects(iID));
        data = load(strcat(inputdir, type))';
        Complete(iID)=data;
    end
    
    for iID = 1:length(subjects)
        Complete(iID).code=subjects(iID);
    end
    pre=Complete; % Change to post if using post data
    save(strcat(outdir, '/All_pre', type),'pre'); % Change to post if using post data
    clear Complete
    
end



