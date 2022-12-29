function [pointpos_searched] = search_first_proper(Y, edge_tmp, pointpos, pointpos_prev,threshold)
    % you'd better set threshold 50
    % if threshold is set to be -1, only 1st priority point can be selected[i.e. real neighbors in 3x3 tile while current point in the middle of the tile]
	reference_counterclockwise = [-1,+1; -1,0; -1,-1; 0,-1;...
							      +1,-1; +1,0; +1,+1; 0,+1];
	rcc = reference_counterclockwise;
	pos_init_next = @(x) mod(x + 3, 8) + 1;
	pos_row = pointpos(1); pos_col = pointpos(2);
	delta = pointpos_prev - pointpos;
	for idx = 1:8
		if reference_counterclockwise(idx,:) == delta
			break;
		end
	end
	old_idx = idx;
	dontsearch_idx = mod(old_idx + 6,8) + 1; % traceback-proof: idx + 7 not allowed[1(say no to 8),2(1),3(2),...]
	% start finding proper point
	found = 0;
	% 1st priority: point right on edge_tmp + counterclockwise 1st + traceback-proof
	tmp_idx = mod(old_idx, 8) + 1;
	while tmp_idx ~= dontsearch_idx
		tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
		if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
			tmp_idx = mod(tmp_idx, 8) + 1;
			continue;
		end
		if edge_tmp(tmp_pos(1),tmp_pos(2))
			% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
			pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
			found = 1;
			break;
		end
		tmp_idx = mod(tmp_idx, 8) + 1;
	end
	% threshold = -1 can terminate this process ahead of time
	strict_neighbor_only = threshold;
	if strict_neighbor_only == -1 % i.e. only select 1st priority point!!!
		if found == 0
			% error('Oops! Try implementing some code here to fix this outlier case!\n');
			pointpos_searched = [-1, -1];  % not found!
			return;
		end
	end
	% 2nd priority: point with edge_tmp points neighbors + counterclockwise 1st + traceback-proof
	if found == 0
		tmp_idx = mod(old_idx, 8) + 1;
		while tmp_idx ~= dontsearch_idx
			tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
			if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
				tmp_idx = mod(tmp_idx, 8) + 1;
				continue;
			end
			row_min = max(tmp_pos(1)-1, 1); row_max = min(tmp_pos(1)+1, size(Y,1));
			col_min = max(tmp_pos(2)-1, 1); col_max = min(tmp_pos(2)+1, size(Y,2)); 
			if sum(sum(edge_tmp( row_min:row_max, col_min:col_max ))) >= 1 % previous point location has value 0, check former code[line 110:112,...] to confirm this
				% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
				if Y(tmp_pos(1),tmp_pos(2)) == 0
					tmp_idx = mod(tmp_idx, 8) + 1;
					continue;
				end
				pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
				found = 1;
				break;
			end
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
	end
	% 3rd priority: point larger than threshold + counterclockwise 1st + traceback-proof
	if found == 0
		tmp_idx = mod(old_idx, 8) + 1;
		while tmp_idx ~= dontsearch_idx
			tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
			if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
				tmp_idx = mod(tmp_idx, 8) + 1;
				continue;
			end
			if Y(tmp_pos(1),tmp_pos(2)) >= threshold 
				% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
				pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
				found = 1;
				break;
			end
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
	end
	% 4th priority: point with edge_tmp points distanced([-2:+2,-2:0]) neighbors + counterclockwise 1st + traceback-proof
	if found == 0
		tmp_idx = mod(old_idx, 8) + 1;
		while tmp_idx ~= dontsearch_idx
			tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
			if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
				tmp_idx = mod(tmp_idx, 8) + 1;
				continue;
			end
			row_min = max(tmp_pos(1)-2, 1); row_max = min(tmp_pos(1)+2, size(Y,1));
			col_min = max(tmp_pos(2)-2, 1); col_max = min(tmp_pos(2), size(Y,2)); % columnwise tracevback prevention
			if sum(sum(edge_tmp( row_min:row_max, col_min:col_max ))) >= 1 % previous point location has value 0, check former code[line 110:112,...] to confirm this
				% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
				if Y(tmp_pos(1),tmp_pos(2)) == 0
					tmp_idx = mod(tmp_idx, 8) + 1;
					continue;
				end
				pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
				found = 1;
				break;
			end
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
	end
	% 5th priority: point with edge_tmp points distanced([-1:+3,-1:+1]) neighbors + counterclockwise 1st + traceback-proof
	if found == 0
		tmp_idx = mod(old_idx, 8) + 1;
		while tmp_idx ~= dontsearch_idx
			tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
			if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
				tmp_idx = mod(tmp_idx, 8) + 1;
				continue;
			end
			row_min = max(tmp_pos(1)-1, 1); row_max = min(tmp_pos(1)+3, size(Y,1));
			col_min = max(tmp_pos(2)-1, 1); col_max = min(tmp_pos(2)+1, size(Y,2)); % columnwise tracevback prevention
			if sum(sum(edge_tmp( row_min:row_max, col_min:col_max ))) >= 1 % previous point location has value 0, check former code[line 110:112,...] to confirm this
				% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
				if Y(tmp_pos(1),tmp_pos(2)) == 0
					tmp_idx = mod(tmp_idx, 8) + 1;
					continue;
				end
				pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
				found = 1;
				break;
			end
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
	end
	% 6th priority: point with edge_tmp points distanced([-5:+1,-9:+1]) neighbors + counterclockwise 1st + traceback-proof
	if found == 0
		tmp_idx = mod(old_idx, 8) + 1;
		while tmp_idx ~= dontsearch_idx
			tmp_pos = [pos_row,pos_col] + rcc(tmp_idx,:);
			if tmp_pos(1) < 1 || tmp_pos(1) > size(Y,1) || tmp_pos(2) < 1 || tmp_pos(2) > size(Y,2)
				tmp_idx = mod(tmp_idx, 8) + 1;
				continue;
			end
			row_min = max(tmp_pos(1)-5, 1); row_max = min(tmp_pos(1)+1, size(Y,1));
			col_min = max(tmp_pos(2)-9, 1); col_max = min(tmp_pos(2)+1, size(Y,2)); % columnwise tracevback prevention
			if sum(sum(edge_tmp( row_min:row_max, col_min:col_max ))) >= 1 % previous point location has value 0, check former code[line 110:112,...] to confirm this
				% Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
				if Y(tmp_pos(1),tmp_pos(2)) == 0
					tmp_idx = mod(tmp_idx, 8) + 1;
					continue;
				end
				pointpos_searched = [pos_row,pos_col] + rcc(tmp_idx,:);
				found = 1;
				break;
			end
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
	end
	if found == 0
		% error('Oops! Try implementing some code here to fix this outlier case!\n');
		pointpos_searched = [-1, -1];  % not found!
	end
end