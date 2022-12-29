function model_exhibition(edges, reference_img, length_info, confident_bounds)
	% Inputs:
	%
	%  edges = {{[row,col],...},...} cell of cells with corresponding corordinates of detected edges.
	%  reference_img = one picture of edges' actual size. It does not matter whether the picture is RGB or grey.
	%  length_info = {x_length,z_length} 
	%		where they share unit length 
	%		and x_length means reference_img ncols actually length under unit length[i.e. the width, or the horizonal length of reference_img, or the length of the arrow on left part of the original picture]
	%		and z_length means the length of the road screening box travelled through. This road is perpendicular to edge_picture's surface
	%  confident_bounds = {left_bound,right_bound,up_bound,down_bound} 
	%         = edge_points that within the region (up_bound:down_bound,left_bound:right_bound) will be finally selected to calculate the volumn
	%
	% Example:
	%  volumn = volumn_one_dimension_edge_info(edges, reference_img)
	if length(size(reference_img)) == 3 % reference_img is RGB picture
		[nrows,ncols,~] = size(reference_img);
	else % reference_img is grey picture
		[nrows,ncols] = size(reference_img);
	end

	if nargin < 4
		left_bound = floor(ncols * 0.1) + 1; right_bound = floor(ncols * 0.85);
		up_bound = 1 ; down_bound = nrows;
	elseif length(confident_bounds) == 0						
		left_bound = floor(ncols * 0.1) + 1; right_bound = floor(ncols * 0.85);
		up_bound = 1 ; down_bound = nrows;
	else
		[left_bound,right_bound,up_bound,down_bound] = confident_bounds{:};
	end

	if nargin < 3
		x_length = 500/2; z_length = 500/3;
	elseif length(length_info) == 0
		x_length = 500/2; z_length = 500/3;
	else
		[x_length, z_length] = length_info{:};
	end
	x_actual_length = x_length / ncols * (right_bound-left_bound+1);
	y_actual_length = x_length / ncols * (down_bound-up_bound+1);
	for ns_idx = 1:length(edges)
		img = zeros(nrows,ncols);
		tmp = edges{ns_idx};
		for idx = 1:size(tmp,1)
			img(tmp(idx,1),tmp(idx,2)) = 127;
		end
		img = img(up_bound:down_bound,left_bound:right_bound);
		count_inner_point = 0;
		count_edge_point = 0;
		for col_idx = 1:size(img,2)
			is_inner = 1;
			for row_idx = 1:size(img,1)
				if img(row_idx,col_idx) == 0 && is_inner == 1
					% img(row_idx,col_idx) = 255; % useful for debugging, othrewise useless. 
					count_inner_point = count_inner_point + 1;
				elseif img(row_idx,col_idx) ~= 0
					is_inner = ~is_inner;
					count_edge_point = count_edge_point + 1;
				end
			end
		end
		img_area = (size(img,1)*size(img,2)) / (nrows*ncols) * (x_actual_length*y_actual_length);
		areas(ns_idx) = img_area * (count_inner_point / (size(img,1)*size(img,2)-count_edge_point)); % edge does not belong to either inner points set or outer points set, so exclude them from inner+outer ..
		edge_3d(:,:,ns_idx) = img;
	end
	dens_x_axis = 1:0.1:length(areas);
	areas_more_values_pchip = pchip(1:length(areas),areas,dens_x_axis);
	% areas_more_values_spline = spline(1:length(areas),areas,dens_x_axis);
	% figure();
	% plot(1:length(edges),areas,'o',dens_x_axis,areas_more_values_pchip,'-',dens_x_axis,areas_more_values_spline);
	% legend('Sample Points','pchip','spline');
	h = z_length/(length(dens_x_axis)-1); % CAUTION!!! our final volumn will be bigger than all volumn inside screening box, because final picture's height makes it stand outside the box!
	volumn = h * sum(areas_more_values_pchip);
end