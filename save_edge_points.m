function save_edge_points(edges_3d, save_location)
	% Inputs:
	%
	%  edges_3d = [x,z,y;...] of edges, xyzorder can change the order
	%  location = tifs' absolute location
	%  biases = [row,col] = row_idx and col_idx of the left bottom corner of the screening box, CAUSTION!!!! ALL PICTURES SHOULD SHARE THE SAME SCREENING BOX!!!!OTHERWISE THIS OUTPUT BIASES IS NOT RIGHT!!![TO FIRST PICTURE, IT IS RIGHT]
	% 
	% Tips:
	%               [x,z,y]                                     [x,z,y] 
	%				1 = row = y, 2 = col = x, 3 = z
	%				normal axis:   /|x /|y   , this 3 1 2 axis /|y /|z  means 3(z) replace 1(y), 1(y) replace 2(x), 
    %                               | /                         | /        2(x) replace 3(z)
	%                               |/____ z                    |/__  x    (screening yy...tif)
	%                                    /                          /
    % 
    
	% if nargin < 3
	% 	biases = [0,0];
	% elseif length(biases) == 0
	% 	biases = [0,0];
	% end
	% edges_3d(:,1) = edges_3d(:,1) + biases(2);
	% edges_3d(:,1) = 0;
	% edges_3d(:,3) = edges_3d(:,3) + biases(1);			
	% edges_3d(:,3) = 0;			
	fileID = fopen(save_location,'w');
	fprintf(fileID,'v %f %f %f\n', edges_3d');
	fclose(fileID);
end