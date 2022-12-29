function imgs_plugedin = imgs_plugin(imgs,reference_img,n_plugin_per_gap,is_output_points)
	imgs_plugin = {}; loc = 1;
	if length(reference_img)
		is_input_points = 1;
	else
		is_input_points = 0;
	end
	for idx = 1:(length(imgs)-1)
		img_left = imgs{idx};
		img_right = imgs{idx+1};
		if is_input_points:
			img_left = point_to_img(img_left, reference_img);
			img_right = point_to_img(img_right, reference_img);
		end
		imgs_plugin{loc} = img_left;
		loc = loc + 1;
		...
	end
	imgs_plugin{loc} = img_right;
	if is_output_points
		for idx = 1:length(imgs_plugin):
			img = imgs_plugin{idx};
			edge_points = img_to_point(img);
			imgs_plugin{idx} = edge_points;
		end
	end
end

function img = point_to_img(points, reference_img);
	img = zeros(size(reference_img));
	for idx = 1:length(points)
		point = points(idx,:);
		img(point(1),point(2)) = 127;
	end
end


function edge_points = img_to_point(img)
	idx = 1
	for col = 1:size(img,2)
		rowlis = find(img(:,col));
		for row = 1:length(rowlis)
			edge_points(idx,:) = [row,col];
			idx = idx + 1;
		end
	end
end