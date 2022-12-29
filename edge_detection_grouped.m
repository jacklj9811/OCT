dbstop if error
clear;
close all;
location = 'D:/OCT/';
cd(location);
filenames = dir([location,'*.tif']);
N = length(filenames);
reference_counterclockwise = [-1,+1; -1,0; -1,-1; 0,-1;...
							  +1,-1; +1,0; +1,+1; 0,+1];
reference_counterclockwise_r2 = [-2,+2; -2,+1; -2,0; -2,-1; -2,-2; -1,-2; 0,-2; +1,-2;...
								 +2,-2; +2,-1; +2,0; +2,+1; +2,+2; +1,+2; 0,+2; -1,+2];
rcc = reference_counterclockwise;
rccr = reference_counterclockwise_r2;
pos_init_next = @(x) mod(x + 3, 8) + 1;
errs = 0;
% prc = 27.5;
prc = 55;
pics_not_successful = [];
screensize = get( groot, 'Screensize' );
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. grouping_generation                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here, I will take turn to finish up those little job
% GROUP 1: 00~23
ns_idxs = 1:24;
[imgs_00_23, edges_00_23] = edge_detection_with_para(location,ns_idxs);
imgs_show(imgs_00_23, 0:23);
edges_show(edges_00_23, 0:23, imgs_00_23);
% GROUP 1: 24~30
ns_idxs = 25:31;
[imgs_24_30, edges_24_30] = edge_detection_with_para(location,ns_idxs);%,{},{},5);
imgs_show(imgs_24_30, 24:30);
edges_show(edges_24_30, 24:30, imgs_24_30);
% GROUP 1: 31~37
ns_idxs = 32:38;
[imgs_32_38, edges_32_38] = edge_detection_with_para(location,ns_idxs);%,{},{},5); %%
imgs_show(imgs_32_38, 32:38);
edges_show(edges_32_38, 32:38, imgs_32_38);
% GROUP 1: 38~44
ns_idxs = 39:45;
[imgs_39_45, edges_39_45] = edge_detection_with_para(location,ns_idxs);%,{},{},8); %%
imgs_show(imgs_39_45, 39:45);
edges_show(edges_39_45, 39:45, imgs_39_45);
% GROUP 1: 45~59
ns_idxs = 46:60;
[imgs_46_60, edges_46_60] = edge_detection_with_para(location,ns_idxs);%,{},{},4); %%
imgs_show(imgs_46_60, 46:60);
edges_show(edges_46_60, 46:60, imgs_46_60);
% GROUP 1: 60~70
ns_idxs = 61:71;
[imgs_61_71, edges_61_71] = edge_detection_with_para(location,ns_idxs);
imgs_show(imgs_61_71, 61:71);
edges_show(edges_61_71, 61:71, imgs_61_71);
% GROUP 1: 71~96
ns_idxs = 72:97;
[imgs_72_97, edges_72_97] = edge_detection_with_para(location,ns_idxs);
imgs_show(imgs_72_97, 72:97);
edges_show(edges_72_97, 72:97, imgs_72_97);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. valumn calculation                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 = 
