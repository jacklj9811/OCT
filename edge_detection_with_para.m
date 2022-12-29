function [imgs, edges, loc_topleft_corner] = edge_detection_with_para(location,ns_idxs,denoise_bounds,percentiles,canny_sigma,focus_region,threshold_length)
	% Inputs:
	%
	%  location = tifs' absolute location
	%  ns_idxs = [tifs' indexes], CAUTION, pic_00.tif's index = 1, pic_23.tif's index = 24!!!!(pic_idx <- idx +1)
	%  denoise_bounds = {left_bound, right_bound, down_bound, left_start_must_be_below} 
	%         = noise filter (:,1:left_bound) -> (down_bound:end,:) -> (:,right_bound:end) -> (:,:)
	%               and left-most starting edge's row index must be below left_start_must_be_below
	%  percentiles = {left_prc,right_prc,down_prc, all_prc}
	%              = value(positive)->0,if value < corresponding prc (region prc of positive points at corresponding step)
	%  canny_sigma = a value = edge funciton's canny method's para, see help file and original code for detailed info.
	%  focus_region = {[left_focus,right_focus,up_focus,down_focus],...} 
	%					strong & weak edge transitional zone, exact edge in this region is hard to detect
	%					some edge detection with small canny sigma will be done here, their result will be overlapped and thus make the edge in this area more accurate
	%					if not neccessary, do not use this para, because unexpected detection error might happen![A HIGH RISK PARA]
	% threshold_length = a value = reraining method's threshold. any line rained wet which has length < threshold_length will be deleted from img and edge
	%
	% Outputs:
	%
	%  imgs = {img,...}, img with highlighted edges
	%  edges = {{[row,col],...},...} cell of cells with corresponding corordinates of detected edges.
	%  loc_topleft_corner = {row,col} = row_idx and col_idx of the topleft corner of the screening box, CAUSTION!!!! ALL PICTURES SHOULD SHARE THE SAME SCREENING BOX!!!!OTHERWISE THIS OUTPUT BIASES IS NOT RIGHT!!![TO FIRST PICTURE, IT IS RIGHT]
	% 
	% TIPS:
	%  nargin < 6 starts at row 90...
	if nargin < 7
		threshold_length = 20;
	elseif length(threshold_length) == 0
		threshold_length = 20;
	end
	if nargin < 5
		canny_sigma = 2.5; % 2
	elseif length(canny_sigma) == 0
		canny_sigma = 2.5; % 2		
	end
	if nargin < 4
		left_prc = 60; right_prc = 30;
		down_prc = 56; all_prc = 7;
	elseif length(percentiles) == 0
		left_prc = 60; right_prc = 30;
		down_prc = 56; all_prc = 7;
	else
		[left_prc, right_prc, down_prc, all_prc] = percentiles{:};
	end
	if nargin < 3
		left_bound = 140; right_bound = 190;
		down_bound = 280; left_start_must_be_below = 230;
	elseif length(denoise_bounds) == 0
		left_bound = 140; right_bound = 190;
		down_bound = 280; left_start_must_be_below = 230;
	else
		[left_bound, right_bound, down_bound, left_start_must_be_below] = denoise_bounds{:};
	end
	if nargin < 2
		ns_idxs = [1];
	end

	cd(location);
	filenames = dir([location,'*.tif']);
	N = length(filenames);
	reference_counterclockwise = [-1,+1; -1,0; -1,-1; 0,-1;...
								  +1,-1; +1,0; +1,+1; 0,+1];
	rcc = reference_counterclockwise;
	pos_init_next = @(x) mod(x + 3, 8) + 1;

	canny_sigma_ori = canny_sigma;
	count = 1;
	loc_topleft_corner = {};
	for ns_idx = ns_idxs
		t = Tiff(filenames(ns_idx).name,'r');
		if sum(filenames(ns_idx).name == 'yy02035.tif') == 11
			ttttttttt = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		end
		if ns_idx == 9
			ttttttt = 1;
		end
		imageData = read(t);
		if length(loc_topleft_corner) == 0
			green_255 = imageData(:,:,2); green_255(green_255<255) = 0;
			[~,top_2] = sort(sum(green_255),'descend'); top_2 = top_2(1:2);
			col_bias_location = min(top_2);
			% row_bias_location = min(find(diff(double(green_255(:,col_bias_location)))<0));
			row_bias_location = min(find(diff(double(green_255(:,col_bias_location)))>0)) + 1;
			% loc_topleft_corner = [row_bias_location-1,col_bias_location-1];
			loc_topleft_corner = {row_bias_location,col_bias_location};
		end
		canny_sigma = canny_sigma_ori;
		not_reach_right_boundary = 1;
		while not_reach_right_boundary
			Y = imageData(:,:,1);
			Y = Y(1:466,510:814);
			Y_left = Y(:,1:left_bound);
			Y_left(Y_left<prctile(Y_left(Y_left>0),left_prc)) = 0;
			Y(:,1:left_bound) = Y_left;
			Y_down = Y(down_bound:end,:);
			Y_down(Y_down<prctile(Y_down(Y_down>0),down_prc)) = 0;
			Y(down_bound:end,:) = Y_down;
			Y_right = Y(:,right_bound:end);
			Y_right(Y_right<prctile(Y_right(Y_right>0),right_prc)) = 0;
			Y(:,right_bound:end) = Y_right;
			Y(Y<prctile(Y(Y>0),all_prc)) = 0;
			% Y = Y.*2.2;
			% Y(Y>=255) = 255;
			% Y = movmean(Y,6,2);
			edge_tmp = edge(Y,'canny',[],canny_sigma);
			img = imageData(1:466,510:814,:);
			img(:,:,3) = img(:,:,1).*2;
			img(:,:,2) = edge_tmp.*255;
			img(:,:,1) = zeros(size(edge_tmp)); 
			if nargin < 6 
				imgs{count} = img;
			elseif length(focus_region) == 0
				imgs{count} = img;
			elseif isequal(focus_region{1},0)
				edge_190_213 = edge(Y(:,191:214),'canny',[],canny_sigma / 2);
				% edge_190_213 = edge_190_213 + edge(movmean(movmean(movmean(Y(:,191:214),20),20),20),'canny',[],canny_sigma*2);
				edge_214_225 = edge(Y(:,213:226),'canny',[],canny_sigma / 2);
				% edge_214_225 = edge_214_225 + edge(movmean(movmean(movmean(Y(:,213:226),20),20),20),'canny',[],canny_sigma*2);
				% edge_tmp(:,191:214) = edge_tmp(:,191:214) + edge_190_213;
				edge_tmp(:,191:214) = edge_tmp(:,191:214) + edge_190_213; 
				edge_tmp(:,213:226) = edge_tmp(:,213:226) + edge_214_225;	
				img(:,191:214,1) = edge_190_213; img(:,213:226,1) = edge_214_225;
				img(:,:,1) = img(:,:,1).* 255;
				imgs{count} = img;
			else
				for focus_idx = 1:length(focus_region)
					[left_focus,right_focus,up_focus,down_focus] = focus_region{focus_idx};
					edge_focus{focus_idx} = edge(Y(up_focus:down_focus,left_focus:right_focus),'canny',[],canny_sigma / 2);
					img(up_focus:down_focus,left_focus:right_focus,1) = edge_focus{focus_idx};
					edge_tmp(up_focus:down_focus,left_focus:right_focus) = edge_tmp(up_focus:down_focus,left_focus:right_focus) + edge_focus{focus_idx};
				end 
				img(:,:,1) = img(:,:,1).* 255;
				imgs{count} = img;
			end
			% %%%%%%%%%%%%%%%%%%%%%%%
			% % START RAINING
			% %%%%%%%%%%%%%%%%%%%%%%%
			% % rain. then pick up pixels that is rained wet 
			% for col_idx = 1:size(edge_tmp,2)
			% 	if find(edge_tmp(:,col_idx))
			% 		edge_rainwet(col_idx) = min(find(edge_tmp(:,col_idx)));
			% 	else
			% 		edge_rainwet(col_idx) = 0;
			% 	end
			% end

			% %%%%%%%%%%%%%%%%%%%%%%%
			% Y_ori = Y;
			% edge_tmp_ori = edge_tmp;
			% edge_rainwet_ori = edge_rainwet;
			% %%%%%%%%%%%%%%%%%%%%%%%

			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%
			% START RAINING
			%%%%%%%%%%%%%%%%%%%%%%%
			% rain. then pick up pixels that is rained wet 
			for col_idx = 1:size(edge_tmp,2)
				if find(edge_tmp(:,col_idx))
					edge_rainwet(col_idx) = min(find(edge_tmp(:,col_idx)));
				else
					edge_rainwet(col_idx) = 0;
				end
			end
			%%%%%%%%%%%%%%%%%%%%%%%
			Y_ori = Y;
			edge_tmp_ori = edge_tmp;
			edge_rainwet_ori = edge_rainwet;
			%%%%%%%%%%%%%%%%%%%%%%%
			threshold = -1;
			maxiter = 500;
			neccessary = 1;
			% threshold_length = 20; % noise that length < 20 will be deleted from the img and edge
			while neccessary
				neccessary = 0;
				Y = Y_ori;
				edge_tmp = edge_tmp_ori;
				edge_rainwet = edge_rainwet_ori; %%%%%%%%%%%%%%%%%%
				line_number = 1;
				length_record = []; 
				% lenght_record is [start_point_row, start_point_col,
				%                   start_next_point_row, start_next_point_col,
				%                   length]
				for r2l_idx = length(edge_rainwet):-1:2
					if r2l_idx == 151
						hhhsshshhshhs = 1;
					end
					if edge_rainwet(r2l_idx) == 0
						continue;
					end
					pointpos = [edge_rainwet(r2l_idx), r2l_idx];
					if line_number > size(length_record,1) % a new first point in length record, with prev and next unknown
						start_point = pointpos; start_next_point = [-2,-2];
						length_record(line_number,:) = [start_point, start_next_point, 1];
						% prepare for next round
						 pointpos_prevprev = [-2,-2]; pointpos_prev = pointpos;
						 Y(pointpos(1),pointpos(2)) = 0;
						 edge_tmp(pointpos(1),pointpos(2)) = 0;
						 edge_rainwet(r2l_idx) = 0;
						continue;
					end
					if abs(pointpos(1) - pointpos_prev(1)) <= 1 && abs(pointpos(2)-pointpos_prev(2)) <= 1 % if strict neighbor
						start_next_point = length_record(line_number,3:4);
						if isequal(start_next_point, [-2,-2]) % update start_next_point
							length_record(line_number,3:4) = pointpos;
						end
						length_record(line_number,5) = length_record(line_number,5) + 1;
						 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos;
						 Y(pointpos(1),pointpos(2)) = 0;
						 edge_tmp(pointpos(1),pointpos(2)) = 0;
						 edge_rainwet(r2l_idx) = 0;
					else
						pointpos_newstart = pointpos;
						start_point = length_record(line_number,1:2);
						start_next_point = length_record(line_number,3:4);
						if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
							pointpos_prevprev = start_point + [-1, 0]; % hairless general is min(find(edge(:,col))) in its column
							% here, I choose not to update this start_next_point to length_record...
						end
						% r2l
						% trackback one step[pointpos is not on current edge line_number]
						pointpos = pointpos_prev; pointpos_prev = pointpos_prevprev;
						pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
						if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
							&& pointpos_searched(1) <= size(Y,1) - 1 ...
							&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
							% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
						    % if above requirement is not satisfied, pointpos_searched is not legal
							 length_record(line_number,5) = length_record(line_number,5) + 1;
							 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
							 Y(pointpos(1),pointpos(2)) = 0;
							 edge_tmp(pointpos(1),pointpos(2)) = 0;
							% check if start_next_point is tmp point
							start_next_point = length_record(line_number,3:4);
							if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
								start_next_point = pointpos_searched; % hairless general is min(find(edge(:,col))) in its column
								length_record(line_number,3:4) = start_next_point; % hairless general is min(find(edge(:,col))) in its column
							end
							if edge_rainwet(pointpos_searched(2)) == pointpos_searched(1)
								edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
							end
							while 1
									pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
									if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
										&& pointpos_searched(1) <= size(Y,1) - 1 ...
										&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
										% && edge_rainwet(pointpos_searched(2))~= pointpos_searched(1)
										 length_record(line_number,5) = length_record(line_number,5) + 1;
										 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
										 Y(pointpos(1),pointpos(2)) = 0;
										 edge_tmp(pointpos(1),pointpos(2)) = 0;
										if edge_rainwet(pointpos_searched(2)) == pointpos_searched(1)
											edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
										end
									else
										break;
									end
							end
						end
						% l2r
						
						Y = flip(Y,2); edge_tmp = flip(edge_tmp,2);
						if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
							start_next_point = start_point + [-1, 0]; % hairless general is min(find(edge(:,col))) in its column
							% here, I choose not to update this start_next_point to length_record...
						end
						pointpos = position_flip_LvsR(start_point,Y);
						pointpos_prev = position_flip_LvsR(start_next_point,Y);
						% all pos search's column number = ncol.Y + 1 - real.column.number
						pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
						if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
							&& pointpos_searched(1) <= size(Y,1) - 1 ...
							&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
							% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
						    % if above requirement is not satisfied, pointpos_searched is not legal
							 length_record(line_number,5) = length_record(line_number,5) + 1;
							 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
							 Y(pointpos(1),pointpos(2)) = 0;
							 edge_tmp(pointpos(1),pointpos(2)) = 0;
							% update start_next_point here is actually a useless step, because only in l2r we will use start_next_point, and it has already been used in step "pointpos_prev = position_flip_LvsR(start_next_point,Y);", here we update it to make debugging easy...
							if isequal(start_next_point, start_point + [-1, 0]) % start point here is hairless general hhhhh...
								tobeswapped = start_point;
								start_next_point = position_flip_LvsR(pointpos_searched, Y); % hairless general is min(find(edge(:,col))) in its column
								length_record(line_number,1:2) = start_next_point; % hairless general is min(find(edge(:,col))) in its column
								length_record(line_number,3:4) = tobeswapped;
								% here in round l2r, point searched and start point should be swapped, because clockwise prev is counterclockwise next.
							end
							if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) == pointpos_searched(1)
								edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
							end
							while 1
									pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
									if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
										&& pointpos_searched(1) <= size(Y,1) - 1 ...
										&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
										% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
										 length_record(line_number,5) = length_record(line_number,5) + 1;
										 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
										 Y(pointpos(1),pointpos(2)) = 0;
										 edge_tmp(pointpos(1),pointpos(2)) = 0;
										if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) == pointpos_searched(1)
											edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
										end
									else
										break;
									end
							end
						end
						Y = flip(Y,2); edge_tmp = flip(edge_tmp,2);

						line_number = line_number + 1;
						%% record new position if hasm't been stepped over by above process
						pointpos = pointpos_newstart;
						if edge_rainwet(pointpos(2)) == 0
							continue; % start point has already been stepped over by the former process in this round, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
						end
						start_point = pointpos; start_next_point = [-2,-2];
						length_record(line_number,:) = [start_point, start_next_point, 1];
						% prepare for next round
						 pointpos_prevprev = [-2,-2]; pointpos_prev = pointpos;
						 Y(pointpos(1),pointpos(2)) = 0;
						 edge_tmp(pointpos(1),pointpos(2)) = 0;
						 edge_rainwet(r2l_idx) = 0;
					end
				end
				%% denoising
				% detect little noise and delete them from Y and edge_tmp
				% operate on Y and edge_tmp, pass the result from them to Y_ori and edge_tmp_ori
				Y = Y_ori;
				edge_tmp = edge_tmp_ori;
				edge_rainwet = edge_rainwet_ori;
				if length(find(length_record(:,5)<threshold_length))
					neccessary = 1;
					% delete pos in edge_tmp_ori connected with pointpos whose length < threshold 
					for line_number = 1:size(length_record,1)
						if 	length_record(line_number,5) < threshold_length
							if length_record(line_number,5) == 1
								Y(length_record(line_number,1),length_record(line_number,2)) = 0;
								edge_tmp(length_record(line_number,1),length_record(line_number,2)) = 0;
								continue;
							end
							Y(length_record(line_number,1),length_record(line_number,2)) = 0;
							edge_tmp(length_record(line_number,1),length_record(line_number,2)) = 0;
							Y(length_record(line_number,3),length_record(line_number,4)) = 0;
							edge_tmp(length_record(line_number,3),length_record(line_number,4)) = 0;
							if length_record(line_number,5) == 2
								continue;
							end
							% r2l
							% trackback one step[pointpos is not on current edge line_number]
							pointpos = length_record(line_number,3:4); pointpos_prev = length_record(line_number,1:2);
							pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
							if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
								&& pointpos_searched(1) <= size(Y,1) - 1 ...
								&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
								% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
							    % if above requirement is not satisfied, pointpos_searched is not legal
								 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
								 Y(pointpos(1),pointpos(2)) = 0;
								 edge_tmp(pointpos(1),pointpos(2)) = 0;
								if edge_rainwet(pointpos_searched(2)) == pointpos_searched(1)
									edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
								end
								while 1
										pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
										if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
											&& pointpos_searched(1) <= size(Y,1) - 1 ...
											&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
											% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
											 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
											 Y(pointpos(1),pointpos(2)) = 0;
											 edge_tmp(pointpos(1),pointpos(2)) = 0;
											if edge_rainwet(pointpos_searched(2)) == pointpos_searched(1)
												edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
											end
										else
											break;
										end
								end
							end
							% l2r
							Y = flip(Y,2); edge_tmp = flip(edge_tmp,2);
							if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
								start_next_point = start_point + [-1, 0]; % hairless general is min(find(edge(:,col))) in its column
								% here, I choose not to update this start_next_point to length_record...
							end
							pointpos = position_flip_LvsR(start_point,Y);
							pointpos_prev = position_flip_LvsR(start_next_point,Y);
							% all pos search's column number = ncol.Y + 1 - real.column.number
							pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
							if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
								&& pointpos_searched(1) <= size(Y,1) - 1 ...
								&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
								% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
							    % if above requirement is not satisfied, pointpos_searched is not legal
								 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
								 Y(pointpos(1),pointpos(2)) = 0;
								 edge_tmp(pointpos(1),pointpos(2)) = 0;
								if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) == pointpos_searched(1)
									edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
								end
								while 1
										pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
										if  ~isequal(pointpos_searched, [-1,-1]) && pointpos_searched(1) >= 2 ...
											&& pointpos_searched(1) <= size(Y,1) - 1 ...
											&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
											% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
											 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
											 Y(pointpos(1),pointpos(2)) = 0;
											 edge_tmp(pointpos(1),pointpos(2)) = 0;
											if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) == pointpos_searched(1)
												edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
											end
										else
											break;
										end
								end
							end
							Y = flip(Y,2); edge_tmp = flip(edge_tmp,2);
						end			
					end
					Y_ori = Y;
					edge_tmp_ori = edge_tmp;
					%% redetect new edge_rainwet_ori from new edge_tmp_ori
					% RERAIN!!!!!!
					for col_idx = 1:size(edge_tmp,2)
						if find(edge_tmp(:,col_idx))
							edge_rainwet(col_idx) = min(find(edge_tmp(:,col_idx)));
						else
							edge_rainwet(col_idx) = 0;
						end
					end
					edge_rainwet_ori = edge_rainwet;
				end
			end


			%%%%%%%%%%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^^^^^%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			%% right to left edge counterclockwise detection
			threshold = 30;
			allwet_idx = 1;
			maxiter = 500;
			edge_allwet = [];
			if sum(filenames(ns_idx).name == 'yy02047.tif') == 11
				ttttttttt = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			end
			for r2l_idx = length(edge_rainwet):-1:2
				if edge_rainwet(r2l_idx) == 0
					continue;
				end
				edge_allwet(allwet_idx,:) = [edge_rainwet(r2l_idx), r2l_idx];
				 allwet_idx = allwet_idx + 1;
				edge_rainwet_now = edge_rainwet(r2l_idx);
				 edge_rainwet(r2l_idx) = 0;
				 Y(edge_rainwet_now,r2l_idx) = 0;
				 edge_tmp(edge_rainwet_now,r2l_idx) = 0;
				if abs(edge_rainwet_now - edge_rainwet(r2l_idx - 1)) >= 2
					% if r2l_idx == length(edge_rainwet) || norm(edge_allwet(allwet_idx-1,:)-edge_allwet(allwet_idx-2,:))^2 > 2
					if size(edge_allwet,1) < 2 %|| norm(edge_allwet(allwet_idx-1,:)-edge_allwet(allwet_idx-2,:))^2 > 2
						continue; % current pos is the first pos % or current pos is lonely pos, just like noise
					end
					pointpos = edge_allwet(allwet_idx - 1,:);
					% if norm(pointpos - [68 255]) == 0
					% 	hhhhhhhhhhhhh = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					% end
					pointpos_prev = edge_allwet(allwet_idx - 2,:);
					pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
					if  pointpos_searched == [-1,-1]
						continue
					end
					 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
					 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0;
					 edge_allwet(allwet_idx,:) = pointpos_searched;
					  allwet_idx = allwet_idx + 1;
					n_iter = 1;
					% while pointpos_searched not reach Y_terratory && not at edge_rainwet%%%%%%%%%%%%%%%%%
					while pointpos_searched(1) >= 2 && pointpos_searched(1) <= size(Y,1) - 1 ...
					  && pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 ...
					  && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1) ...
					  && n_iter <= maxiter
						pointpos = edge_allwet(allwet_idx - 1,:);
						pointpos_prev = edge_allwet(allwet_idx - 2,:);
						pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
						if  pointpos_searched == [-1,-1]
							continue
						end
						 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
						 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0; %
						 edge_allwet(allwet_idx,:) = pointpos_searched;
						  allwet_idx = allwet_idx + 1;
						  n_iter = n_iter + 1;
					end
				end
			end
			edge_allwet_r2l = edge_allwet;

			%% left to right edge clockwise detection
			Y = flip(Y_ori,2);
			edge_tmp = flip(edge_tmp_ori,2);
			edge_rainwet = flip(edge_rainwet_ori);

			threshold = 30;
			allwet_idx = 1;
			maxiter = 500;
			edge_allwet = [];	
			for r2l_idx = length(edge_rainwet):-1:2
				if edge_rainwet(r2l_idx) == 0
					continue;
				end
				edge_allwet(allwet_idx,:) = [edge_rainwet(r2l_idx), r2l_idx];
				 allwet_idx = allwet_idx + 1;
				edge_rainwet_now = edge_rainwet(r2l_idx);
				edge_rainwet(r2l_idx) = 0;
				 Y(edge_rainwet_now,r2l_idx) = 0;
				 edge_tmp(edge_rainwet_now,r2l_idx) = 0;
				if abs(edge_rainwet_now - edge_rainwet(r2l_idx - 1)) >= 2
					% if r2l_idx == length(edge_rainwet) || norm(edge_allwet(allwet_idx-1,:)-edge_allwet(allwet_idx-2,:))^2 > 2
					if size(edge_allwet,1) < 2 %|| norm(edge_allwet(allwet_idx-1,:)-edge_allwet(allwet_idx-2,:))^2 > 2
						continue; % current pos is the first pos % or current pos is lonely pos, just like noise
					end
					pointpos = edge_allwet(allwet_idx - 1,:);
					% if norm(pointpos - [68 255]) == 0
					% 	hhhhhhhhhhhhh = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
					% end
					pointpos_prev = edge_allwet(allwet_idx - 2,:);
					pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
					if  pointpos_searched == [-1,-1]
						continue
					end
					 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
					 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0;
					 edge_allwet(allwet_idx,:) = pointpos_searched;
					  allwet_idx = allwet_idx + 1;
					n_iter = 1;
					% while pointpos_searched not reach Y_terratory && not at edge_rainwet%%%%%%%%%%%%%%%%%
					while pointpos_searched(1) >= 2 && pointpos_searched(1) <= size(Y,1) - 1 ...
					  && pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 ...
					  && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1) ...
					  && n_iter <= maxiter
						pointpos = edge_allwet(allwet_idx - 1,:);
						pointpos_prev = edge_allwet(allwet_idx - 2,:);
						pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
						if  pointpos_searched == [-1,-1]
							continue
						end
						 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
						 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0; %
						 edge_allwet(allwet_idx,:) = pointpos_searched;
						  allwet_idx = allwet_idx + 1;
						  n_iter = n_iter + 1;
					end
				end
			end
			edge_allwet_l2r = edge_allwet;
			edge_allwet_l2r(:,2) = size(Y,2) + 1 - edge_allwet_l2r(:,2);

			%% merge r2l and l2r and take rows unique
			edge_allwet = unique([edge_allwet_r2l; edge_allwet_l2r],'rows');
			

			%%%%%%%%%%%%%%%%%%%%%%
			edge_allwet_ori = edge_allwet;
			%%%%%%%%%%%%%%%%%%%%%%
			% probe method->final denoising
			% probe method l2r start from [:,1]
			Y = flip(Y_ori,2);
			edge_allwet = edge_allwet_ori;
			edge_tmp = zeros(size(edge_tmp));
			for idx = 1:size(edge_allwet,1)
				edge_tmp(edge_allwet(idx,1),edge_allwet(idx,2)) = 255;
			end
			edge_tmp = flip(edge_tmp,2);
			if sum(filenames(ns_idx).name == 'yy02047.tif') == 11
				ttttttttt = 1;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			end
			allwet_idx = 1;
			for idx = size(edge_tmp,2):-1:1
				if find(edge_tmp(left_start_must_be_below:end,idx))
					start_col = idx;
					break;
				end
			end
			pointpos_prev = [min(left_start_must_be_below-1+find(edge_tmp(left_start_must_be_below:end,start_col))),start_col+1];
			pointpos = [min(left_start_must_be_below-1+find(edge_tmp(left_start_must_be_below:end,start_col))),start_col];
			edge_allwet = pointpos;
			 edge_tmp(pointpos(1),pointpos(2)) = 0;
			 Y(pointpos(1),pointpos(2)) = 0;
			allwet_idx = allwet_idx + 1;
			while pointpos(2) > 1
				pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
				if  pointpos_searched == [-1,-1]
					break;
				end
				edge_allwet(allwet_idx,:) = pointpos_searched;
				 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0;
				 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
				allwet_idx = allwet_idx + 1;
				pointpos_prev = pointpos;
				pointpos = pointpos_searched;
			end
			edge_allwet(:,2) = size(Y,2) + 1 - edge_allwet(:,2);
			edge_allwet_prob_l2r_1 = edge_allwet;


			% % probe method r2l start from [:, former colmax + 3]
			% col_maxidx = max(edge_allwet_prob_l2r_1(:,2));
			% if col_maxidx == size(Y,2)
			% 	edge_allwet_prob_r2l = [];
			% else
			% 	Y = Y_ori;
			% 	edge_allwet = edge_allwet_ori;
			% 	edge_tmp = zeros(size(edge_tmp));
			% 	for idx = 1:size(edge_allwet,1)
			% 		edge_tmp(edge_allwet(idx,1),edge_allwet(idx,2)) = 255;
			% 	end
			% 	allwet_idx = 1;
			% 	pointpos_prev = [min(find(edge_tmp(:,min(col_maxidx+3,size(Y,2)-1))))-1,min(col_maxidx+3,size(Y,2)-1)]; % this point selection is very tricky...
			% 	pointpos = [min(find(edge_tmp(:,min(col_maxidx+3,size(Y,2))-1))),min(col_maxidx+3,size(Y,2)-1)];
			% 	edge_allwet = pointpos;
			% 	 edge_tmp(pointpos(1),pointpos(2)) = 0;
			% 	 Y(pointpos(1),pointpos(2)) = 0;
			% 	allwet_idx = allwet_idx + 1;
			% 	while pointpos(2) > 1
			% 		pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
			% 		if  pointpos_searched == [-1,-1]
			% 			break;
			% 		end
			% 		edge_allwet(allwet_idx,:) = pointpos_searched;
			% 		 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0;
			% 		 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
			% 		allwet_idx = allwet_idx + 1;
			% 		pointpos_prev = pointpos;
			% 		pointpos = pointpos_searched;
			% 	end
			% 	edge_allwet_prob_r2l = edge_allwet;
			% end

			% % probe method l2r start from [:,colmax+3]
			% col_maxidx = max(edge_allwet_prob_l2r_1(:,2));
			% if col_maxidx == size(Y,2)
			% 	edge_allwet_prob_l2r_2 = [];
			% else
			% 	Y = flip(Y_ori,2);
			% 	edge_allwet = edge_allwet_ori;
			% 	edge_tmp = zeros(size(edge_tmp));
			% 	for idx = 1:size(edge_allwet,1)
			% 		edge_tmp(edge_allwet(idx,1),edge_allwet(idx,2)) = 255;
			% 	end
			% 	edge_tmp = flip(edge_tmp,2);
			% 	allwet_idx = 1;
			% 	pointpos_prev = [min(find(edge_tmp(:,end + 1 - min(col_maxidx+3,size(Y,2)-1))))+1,size(Y,2) + 1 - min(col_maxidx+3,size(Y,2)-1)];
			% 	pointpos = [min(find(edge_tmp(:,end + 1 - min(col_maxidx+3,size(Y,2)-1)))),size(Y,2) + 1 - min(col_maxidx+3,size(Y,2)-1)];
			% 	edge_allwet = pointpos;
			% 	 edge_tmp(pointpos(1),pointpos(2)) = 0;
			% 	 Y(pointpos(1),pointpos(2)) = 0;
			% 	allwet_idx = allwet_idx + 1;
			% 	while pointpos(2) > 1
			% 		pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
			% 		if  pointpos_searched == [-1,-1]
			% 			break;
			% 		end
			% 		edge_allwet(allwet_idx,:) = pointpos_searched;
			% 		 edge_tmp(pointpos_searched(1),pointpos_searched(2)) = 0;
			% 		 Y(pointpos_searched(1),pointpos_searched(2)) = 0;
			% 		allwet_idx = allwet_idx + 1;
			% 		pointpos_prev = pointpos;
			% 		pointpos = pointpos_searched;
			% 	end
			% 	edge_allwet(:,2) = size(Y,2) + 1 - edge_allwet(:,2);
			% 	edge_allwet_prob_l2r_2 = edge_allwet;
			% end

			% edge_allwet = unique([edge_allwet_prob_l2r_1;edge_allwet_prob_r2l;edge_allwet_prob_l2r_2],'rows');
			canny_sigma = canny_sigma + 0.5;
			edges{count} = edge_allwet;			
			if max(edge_allwet(:,2)) >= size(Y,2)*0.9 && min(edge_allwet(:,2)) <= size(Y,2)*0.1 || canny_sigma > 15
				not_reach_right_boundary = 0;
				count = count + 1;
			end
		end
end





