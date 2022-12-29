dbstop if error
clear;
close all;
location = 'D:/OCT/';
% location2 = 'D:/OCT/l2r/';
location2 = 'D:/OCT/r2l/';
location_test1 = 'D:/OCT/test1/';
location2_test2 = 'D:/OCT/test2/';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1. edge detection                                                    %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here, I will take turn to finish up those little job
% 00~96
cd(location);
ns_idxs = 1:97;
[imgs, edges, loc_topleft_corner] = edge_detection_with_para(location,ns_idxs,{},{},{},{0});
% imgs_show(imgs, 0:96);
% edges_show(edges, 0:96, imgs);
cd(location2);
ns_idxs = 1:97;
left_bound = 100; right_bound = 210;
down_bound = 280; left_start_must_be_below = 100;
bounds = {left_bound, right_bound, down_bound, left_start_must_be_below};
[imgs2, edges2, loc_topleft_corner2] = edge_detection_with_para(location2,ns_idxs,bounds,{},{},{},100);
% imgs_show(imgs2, 0:96);
% edges_show(edges2, 0:96, imgs2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 2. edges plugging-in                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reference_img = imgs{1};
% n_plugin_per_gap = 10;
% is_output_points = 1;
% edges = imgs_plugin(edges,reference_img,n_plugin_per_gap,is_output_points);
% edges2 = imgs_plugin(edges2,reference_img,n_plugin_per_gap,is_output_points);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. volumn calculation                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reference_img = imgs{1};
[volumn, edges_3d, all_3d] = volumn_one_dimension_edge_info(edges, reference_img, loc_topleft_corner);
reference_img2 = imgs2{1};
[volumn2, edges_3d2, all_3d2] = volumn_one_dimension_edge_info(edges2, reference_img2, loc_topleft_corner2, {}, {}, [3 -1 -2]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. save edge points                                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_location = 'D:/OCT/edge_points.obj';
% save_edge_points(edges_3d, save_location, loc_topleft_corner);
save_edge_points(edges_3d, save_location);
save_location = 'D:/OCT/edge_points2.obj';
% save_edge_points(edges_3d2, save_location, loc_topleft_corner2);
save_edge_points(edges_3d2, save_location);

save_location = 'D:/OCT/edge_points_merge.obj';
% save_edge_points([edges_3d+[loc_topleft_corner(1) 0 loc_topleft_corner(2)];edges_3d2+[loc_topleft_corner2(1) 0 loc_topleft_corner2(2)]], save_location);
save_edge_points([edges_3d;edges_3d2], save_location);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 1. edge detection                                                    %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Here, I will take turn to finish up those little job
% % 00~09
% cd(location_test1);
% ns_idxs = 1:10;
% left_bound = 140; right_bound = 190;
% down_bound = 280; left_start_must_be_below = 1;
% bounds = {left_bound, right_bound, down_bound, left_start_must_be_below};
% [imgs_test1, edges_test1, loc_topleft_corner_test1] = edge_detection_with_para(location_test1,ns_idxs,bounds,{},{},{0});
% % imgs_show(imgs, 0:9);
% % edges_show(edges, 0:9, imgs_test1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 2. volumn calculation                                                %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reference_img_test1 = imgs_test1{1};
% [volumn_test1, edges_3d_test1, all_3d_test1] = volumn_one_dimension_edge_info(edges_test1, reference_img_test1, loc_topleft_corner_test1);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 3. save edge points                                                 %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save_location = 'D:/OCT/edge_points_test1.obj';
% % save_edge_points(edges_3d_test1, save_location, loc_topleft_corner_test1);
% save_edge_points(edges_3d_test1, save_location);



% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 1. edge detection                                                    %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cd(location2_test2);
% ns_idxs = 1:10;
% left_bound = 140; right_bound = 190;
% down_bound = 280; left_start_must_be_below = 1;
% bounds = {left_bound, right_bound, down_bound, left_start_must_be_below};
% [imgs2_test2, edges2_test2, loc_topleft_corner2_test2] = edge_detection_with_para(location2_test2,ns_idxs,bounds,{},{},{},100);
% % imgs_show(imgs2_test2, 0:9);
% % edges_show(edges2_test2, 0:9, imgs2_test2);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 2. volumn calculation                                                %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% reference_img2_test2 = imgs2_test2{1};
% [volumn2_test2, edges_3d2_test2, all_3d2_test2] = volumn_one_dimension_edge_info(edges2_test2, reference_img2_test2, loc_topleft_corner2_test2, {}, {}, [3 -1 -2]);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 3. save edge points                                                 %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% save_location = 'D:/OCT/edge_points2_test2.obj';
% % save_edge_points(edges_3d2_test2, save_location, loc_topleft_corner2_test2);
% save_edge_points(edges_3d2_test2, save_location);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. 3D image generation                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% using meshlab to proceed .obj file
% Step
%  1. Filters > Normals, Curvatures and Orientaion > Smooths normals on a point sets > Number of neighbors[set to 100] > Apply
%  2. Filters > Remeshing, Simplification and Reconstruction > Surface Reconstruction: Ball Pivoting > Pivoting Ball radius[set perc on to 1] > Apply
%  3. File > Export Mesh as ... > [save as obj]
% using blender to see .obj final result
% Step
%  1. Select the cube generated by default and delete it with "DEL"
%  2. File > Import > [import that obj]
%  3. Enjoy！！
