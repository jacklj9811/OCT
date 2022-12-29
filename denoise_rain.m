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
	threshold_length = 100;
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
				start_point = length_record(line_nmber,1:2);
				start_next_point = length_record(line_nmber,3:4);
				if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
					pointpos_prevprev = start_point + [-1, 0]; % hairless general is min(find(edge(:,col))) in its column
					% here, I choose not to update this start_next_point to length_record...
				end
				% r2l
				% trackback one step[pointpos is not on current edge line_nmber]
				pointpos = pointpos_prev; pointpos_prev = pointpos_prevprev;
				pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
				if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
					&& pointpos_searched(1) <= size(Y,1) - 1 ...
					&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
					% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
				    % if above requirement is not satisfied, pointpos_searched is not legal
					 length_record(line_number,5) = length_record(line_number,5) + 1;
					 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
					 Y(pointpos(1),pointpos(2)) = 0;
					 edge_tmp(pointpos(1),pointpos(2)) = 0;
					% check if start_next_point is tmp point
					start_next_point = length_record(line_nmber,3:4);
					if isequal(start_next_point, [-2,-2]]) % start point here is hairless general hhhhh...
						start_next_point = pointpos_searched; % hairless general is min(find(edge(:,col))) in its column
						length_record(line_nmber,3:4) = start_next_point; % hairless general is min(find(edge(:,col))) in its column
					end
					if edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
						edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
					end
					while 1
							pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
							if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
								&& pointpos_searched(1) <= size(Y,1) - 1 ...
								&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
								% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
								 length_record(line_number,5) = length_record(line_number,5) + 1;
								 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
								 Y(pointpos(1),pointpos(2)) = 0;
								 edge_tmp(pointpos(1),pointpos(2)) = 0;
								if edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
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
				if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
					&& pointpos_searched(1) <= size(Y,1) - 1 ...
					&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
					% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
				    % if above requirement is not satisfied, pointpos_searched is not legal
					 length_record(line_number,5) = length_record(line_number,5) + 1;
					 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
					 Y(pointpos(1),pointpos(2)) = 0;
					 edge_tmp(pointpos(1),pointpos(2)) = 0;
					% update start_next_point here is actually a useless step, because only in l2r we will use start_next_point, and it has already been used in step "pointpos_prev = position_flip_LvsR(start_next_point,Y);", here we update it to make debugging easy...
					if isequal(start_next_point, [-2,-2]) % start point here is hairless general hhhhh...
						tobeswapped = start_point;
						start_next_point = position_flip_LvsR(pointpos_searched); % hairless general is min(find(edge(:,col))) in its column
						length_record(line_number,1:2) = start_next_point; % hairless general is min(find(edge(:,col))) in its column
						length_record(line_number,3:4) = tobeswapped;
						% here in round l2r, point searched and start point should be swapped, because clockwise prev is counterclockwise next.
					end
					if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
						edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
					end
					while 1
							pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
							if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
								&& pointpos_searched(1) <= size(Y,1) - 1 ...
								&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
								% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
								 length_record(line_number,5) = length_record(line_number,5) + 1;
								 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
								 Y(pointpos(1),pointpos(2)) = 0;
								 edge_tmp(pointpos(1),pointpos(2)) = 0;
								if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
									edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
								end
							else
								break;
							end
					end
				Y = flip(Y,2); edge_tmp = flip(edge_tmp,2);
			
				line_number = line_nmber + 1;
				%% record new position if hasm't been stepped over by above process
				if edge_rainwet(pointpos_newstart(2)) == 0
					continue; % start point has already been stepped over by the former process in this round, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
				end
				start_point = pointpos_newstart; start_next_point = [-2,-2];
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
					% trackback one step[pointpos is not on current edge line_nmber]
					pointpos = length_record(line_nmber,3:4); pointpos_prev = length_record(line_nmber,1:2);
					pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
					if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
						&& pointpos_searched(1) <= size(Y,1) - 1 ...
						&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
						% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
					    % if above requirement is not satisfied, pointpos_searched is not legal
						 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
						 Y(pointpos(1),pointpos(2)) = 0;
						 edge_tmp(pointpos(1),pointpos(2)) = 0;
						if edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
							edge_rainwet(pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
						end
						while 1
								pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
								if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
									&& pointpos_searched(1) <= size(Y,1) - 1 ...
									&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
									% && edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
									 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
									 Y(pointpos(1),pointpos(2)) = 0;
									 edge_tmp(pointpos(1),pointpos(2)) = 0;
									if edge_rainwet(pointpos_searched(2)) ~= pointpos_searched(1)
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
					if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
						&& pointpos_searched(1) <= size(Y,1) - 1 ...
						&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
						% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
					    % if above requirement is not satisfied, pointpos_searched is not legal
						 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
						 Y(pointpos(1),pointpos(2)) = 0;
						 edge_tmp(pointpos(1),pointpos(2)) = 0;
						if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
							edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
						end
						while 1
								pointpos_searched = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev, threshold);
								if  pointpos_searched ~= [-1,-1] && pointpos_searched(1) >= 2 ...
									&& pointpos_searched(1) <= size(Y,1) - 1 ...
									&& pointpos_searched(2) >= 2 && pointpos_searched(2) <= size(Y,2) - 1 %...
									% && edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
									 pointpos_prevprev = pointpos_prev; pointpos_prev = pointpos; pointpos = pointpos_searched;
									 Y(pointpos(1),pointpos(2)) = 0;
									 edge_tmp(pointpos(1),pointpos(2)) = 0;
									if edge_rainwet(size(Y,2)+1-pointpos_searched(2)) ~= pointpos_searched(1)
										edge_rainwet(size(Y,2)+1-pointpos_searched(2)) = 0; % belong to this line, try drawing this to see why: [-y,x]=[row,col]=[0,0][1,1][2,0][3,1][3,2][3,3]
									end
								else
									break;
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
	%%%%%%%%%%%%%%%%%%%%%%%
	% calculate line length. then filter
	%%%%%%%%%%%%%%%%%%%%%%%
	%% right to left edge counterclockwise detection with length filter
	threshold = 30;
	allwet_idx = 1;
	maxiter = 500;
	edge_allwet = [];
	edge_len = [];  % is [start_row, start_col, length]
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



function [fliped_pos] = position_flip_LvsR(pointpos, Y)
	ncol = size(Y,2);
	fliped_pos = [pointpos(1), ncol + 1 - pointpos(2)];
end