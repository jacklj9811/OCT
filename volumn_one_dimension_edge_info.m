function [volumn, edges_3d, all_3d] = volumn_one_dimension_edge_info(edges, reference_img, loc_topleft_corner, length_info, confident_bounds, xyzorder)
	% Inputs:
	%
	%  edges = {{[row,col],...},...} cell of cells with corresponding corordinates of detected edges.
	%  reference_img = one picture of edges' actual size. It does not matter whether the picture is RGB or grey.
	%  loc_topleft_corner = {row,col} = row_idx and col_idx of the topleft corner of the screening box, CAUSTION!!!! ALL PICTURES SHOULD SHARE THE SAME SCREENING BOX!!!!OTHERWISE THIS OUTPUT BIASES IS NOT RIGHT!!![TO FIRST PICTURE, IT IS RIGHT]
	%  length_info = {x_length,z_length} 
	%		where they share unit length 
	%		and x_length means reference_img ncols actually length under unit length[i.e. the width, or the horizonal length of reference_img, or the length of the arrow on left part of the original picture]
	%		and z_length means the length of the road screening box travelled through. This road is perpendicular to edge_picture's surface
	%  confident_bounds = {left_bound,right_bound,up_bound,down_bound} 
	%         = edge_points that within the region (up_bound:down_bound,left_bound:right_bound) will be finally selected to calculate the volumn
	%  xyzorder = I'will give you an example: output [y x z] -> [z y x] if xyzorder = [3 1 2]; 
	%				1 = row = y, 2 = col = x, 3 = z
	%				normal axis:   /|x /|y   , this 3 1 2 axis /|y /|z  means 3(z) replace 1(y), 1(y) replace 2(x), 
    %                               | /                         | /        2(x) replace 3(z)
	%                               |/____ z                    |/__  x    (screening yy...tif)
	%                                    /                          /
    %                                                          
	%				normal axis:   /|x /|y  , this 2 1 -3 axis  /|y /|x  means 2(x) replace 1(y), 1(y) replace 2(x),
    %                               | /                          | /        3(z)=3(z) BUT take opposite direction
	%                               |/____ z                 /___|/___ z   (screening xx...l2r.tif, for r2l.tif that will be 2 1 3)
	%                                    /                            
	%                                                          
	%                                                          
	% Outputs:
	%
	%  volumn = volumn of the tissue
	%  edges_3d = [y,x,z;...] of edges, xyzorder can change the order
	%  all_3d = [y,x ,z;...] of inner part, xyzorder can change the order
	%
	% Example:
	%  volumn = volumn_one_dimension_edge_info(edges, reference_img)
	if length(size(reference_img)) == 3 % reference_img is RGB picture
		[nrows,ncols,~] = size(reference_img);
	else % reference_img is grey picture
		[nrows,ncols] = size(reference_img);
	end
	if nargin < 6
		% xyzorder = [3 1 2];
		xyzorder = [2 -1 -3];
	end

	if nargin < 5
		left_bound = floor(ncols * 0.1) + 1; right_bound = floor(ncols * 0.85);
		up_bound = 1 ; down_bound = nrows;
	elseif length(confident_bounds) == 0						
		left_bound = floor(ncols * 0.1) + 1; right_bound = floor(ncols * 0.85);
		up_bound = 1 ; down_bound = nrows;
	else
		[left_bound,right_bound,up_bound,down_bound] = confident_bounds{:};
	end

	if nargin < 4
		x_length = 500/2; z_length = 500/3;
	elseif length(length_info) == 0
		x_length = 500/2; z_length = 500/3;
	else
		[x_length, z_length] = length_info{:};
	end
	
	x_actual_length = x_length / ncols * (right_bound-left_bound+1);
	y_actual_length = x_length / ncols * (down_bound-up_bound+1);
	edge_color = 127;
	content_color = 255;
	for ns_idx = 1:length(edges)
		img = zeros(nrows,ncols);
		tmp = edges{ns_idx};
		for idx = 1:size(tmp,1)
			img(tmp(idx,1),tmp(idx,2)) = edge_color;
		end
		img = img(up_bound:down_bound,left_bound:right_bound);
		count_inner_point = 0;
		count_edge_point = 0;

		queue = {};
		img(1,1) = content_color;
		count_inner_point = count_inner_point + 1;
		queue{count_inner_point} = [1,1];
		head = 0;
		while head < count_inner_point
			head = head + 1;
			point = queue{head};
			if point(1) > 1
				if img(point(1)-1,point(2)) == 0 
					img(point(1)-1,point(2)) = content_color;
					count_inner_point = count_inner_point + 1;
					queue{count_inner_point} = [point(1)-1,point(2)];
				end
			end
			if point(2) > 1
				if img(point(1),point(2)-1) == 0 
					img(point(1),point(2)-1) = content_color;
					count_inner_point = count_inner_point + 1;
					queue{count_inner_point} = [point(1),point(2)-1];
				end
			end
			if point(1) < size(img,1)
				if img(point(1)+1,point(2)) == 0 
					img(point(1)+1,point(2)) = content_color;
					count_inner_point = count_inner_point + 1;
					queue{count_inner_point} = [point(1)+1,point(2)];
				end
			end
			if point(2) < size(img,2)
				if img(point(1),point(2)+1) == 0 
					img(point(1),point(2)+1) = content_color;
					count_inner_point = count_inner_point + 1;
					queue{count_inner_point} = [point(1),point(2)+1];
				end
			end
		end
		count_edge_point = length(find(img == edge_color));
		img_area = (size(img,1)*size(img,2)) / (nrows*ncols) * (x_actual_length*y_actual_length);
		areas(ns_idx) = img_area * (count_inner_point / (size(img,1)*size(img,2)-count_edge_point)); % edge does not belong to either inner points set or outer points set, so exclude them from inner+outer ..
		all_img_3d(:,:,ns_idx) = img; 
	end
	dens_x_axis = 1:0.1:length(areas);
	areas_more_values_pchip = pchip(1:length(areas),areas,dens_x_axis);
	% areas_more_values_spline = spline(1:length(areas),areas,dens_x_axis);
	% figure();
	% plot(1:length(edges),areas,'o',dens_x_axis,areas_more_values_pchip,'-',dens_x_axis,areas_more_values_spline);
	% legend('Sample Points','pchip','spline');
	h = z_length/(length(dens_x_axis)-1); % CAUTION!!! our final volumn will be bigger than all volumn inside screening box, because final picture's height makes it stand outside the box!
	volumn = h * sum(areas_more_values_pchip);

	x_unit = x_actual_length / size(img,2);
	y_unit = y_actual_length / size(img,1);
	z_unit = z_length / length(edges);
	if find(xyzorder==0) ~= 0
		[yy,xx,zz] = ind2sub(size(all_img_3d),find(all_img_3d == edge_color | all_img_3d == content_color));
		all_3d = [(yy-mean(yy)).*y_unit,(xx-mean(xx)).*x_unit,(zz-mean(zz)).*z_unit];
		all_3d = [all_3d(:,xyzorder(1)),all_3d(:,xyzorder(2)),all_3d(:,xyzorder(3))];

		[yy,xx,zz] = ind2sub(size(all_img_3d),find(all_img_3d == edge_color));
		edges_3d = [(yy-mean(yy)).*y_unit,(xx-mean(xx)).*x_unit,(zz-mean(zz)).*z_unit];
		edges_3d = [edges_3d(:,xyzorder(1)),edges_3d(:,xyzorder(2)),edges_3d(:,xyzorder(3))];
	else
		if xyzorder(1) < 0
			flag_one = -1;
		else
			flag_one = 1;
		end
		if xyzorder(2) < 0
			flag_two = -1;
		else
			flag_two = 1;
		end
		if xyzorder(3) < 0
			flag_three = -1;
		else
			flag_three = 1;
		end
		unit_lens = [y_unit,x_unit,z_unit];
		[yy,xx,zz] = ind2sub(size(all_img_3d),find(all_img_3d == edge_color | all_img_3d == content_color));
		all_3d = [(yy+up_bound-1).*y_unit,(xx+left_bound-1).*x_unit,zz.*z_unit];
		all_3d = [all_3d(:,flag_one*xyzorder(1)).*flag_one,  all_3d(:,flag_two*xyzorder(2)).*flag_two,  all_3d(:,flag_three*xyzorder(3)).*flag_three];
		all_3d(:,1) = all_3d(:,1) + (loc_topleft_corner{2}-1)*unit_lens(abs(xyzorder(1)))*flag_one; % this is x
		% edges_3d(:,1) = 0;
		all_3d(:,3) = all_3d(:,3) + (loc_topleft_corner{1}-1)*unit_lens(abs(xyzorder(3)))*flag_three; % this is z

		[yy,xx,zz] = ind2sub(size(all_img_3d),find(all_img_3d == edge_color));
		% edges_3d = [(xx-mean(xx)).*x_unit,(yy-mean(yy)).*y_unit,(zz-mean(zz)).*z_unit];
		edges_3d = [(yy+up_bound-1).*y_unit,(xx+left_bound-1).*x_unit,zz.*z_unit];
		edges_3d = [edges_3d(:,flag_one*xyzorder(1)).*flag_one,  edges_3d(:,flag_two*xyzorder(2)).*flag_two,  edges_3d(:,flag_three*xyzorder(3)).*flag_three];
		edges_3d(:,1) = edges_3d(:,1) + (loc_topleft_corner{2}-1)*unit_lens(abs(xyzorder(1)))*flag_one;
		% edges_3d(:,1) = 0;
		edges_3d(:,3) = edges_3d(:,3) + (loc_topleft_corner{1}-1)*unit_lens(abs(xyzorder(3)))*flag_three;	
end
