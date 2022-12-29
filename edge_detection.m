clear;
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
% for pic_idx = 1:97  % 2 46 btw, pic yy02000's idx is 1 and pic yy02003's idx is 4.
% 	%% Show input
% 	err = 0;
% 	t = Tiff(filenames(pic_idx).name,'r');
% 	imageData = read(t);
% 	Y = imageData(:,:,1);
% 	Y = Y(1:466,510:880);
% 	Y = Y.*2;
% 	Y_170left = Y(:,1:170);
% 	Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),prc)) = 0;
% 	Y(:,1:170) = Y_170left;
% 	Y_280up = Y(280:end,:);
% 	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),prc)) = 0;
% 	Y(280:end,:) = Y_280up;
% 	% Y(Y<prctile(Y(Y>0),prc)) = 0;
% 	ori = Y;
% 	p_ori=ori;p_ori(p_ori>0)=255;
% 	Y = double(Y)/255;
% 	Y_edge = edge(Y,'canny');
% 	if length(find(Y_edge(2,:)))
% 		top_leftright_first_positive = min(find(Y_edge(2,:)));
% 		pos_row = 2;pos_col = top_leftright_first_positive;
% 		old_idx = 4;
% 	elseif length(find(Y_edge(:,end-1)))
% 		right_topdown_first_positive = min(find(Y_edge(:,end-1)));
% 		pos_row = right_topdown_first_positive;	pos_col = size(Y_edge,2) - 1;
% 		old_idx = 2;
% 	else
% 		% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
% 		err = 1;
% 		errs = errs + 1;
% 		pics_not_successful(errs) = pic_idx;
% 		continue;
% 	end
% 	final_pos_pairidx = 1;
% 	positions = [pos_row,pos_col];
% 	maxlen = 3000;
% 	len = 0;
% 	while positions(final_pos_pairidx,2) > 2
% 		if len >= maxlen
% 			err = 1;
% 			errs = errs + 1;
% 			pics_not_successful(errs) = pic_idx;	
% 			break;
% 		end
% 		tmp_idx = mod(old_idx, 8) + 1;
% 		while tmp_idx ~= old_idx
% 			tmp_pos = positions(final_pos_pairidx,:) + rcc(tmp_idx,:);
% 			if Y_edge(tmp_pos(1),tmp_pos(2))
% 				Y_edge(tmp_pos(1),tmp_pos(2)) = 0; % delete traveled trial
% 				final_pos_pairidx = final_pos_pairidx + 1;
% 				positions(final_pos_pairidx,:) = positions(final_pos_pairidx-1,:) ...
% 				 + rcc(tmp_idx,:);
% 			 	len = len + 1;
% 			 	old_idx = pos_init_next(tmp_idx);
% 				break;
% 			end
% 			tmp_idx = mod(tmp_idx, 8) + 1;
% 		end
% 		if tmp_idx == old_idx
% 			% fprintf([filenames(i).name,',Oops! Try implementing some code here to fix this outlier case!\n']);
% 			outside_start_idx = mod(2*old_idx+1-mod(old_idx+1,2),16)+1;
% 			outside_final_idx = mod(outside_start_idx+11-2*mod(old_idx,2),16)+1;
% 			tmp_idx = outside_start_idx;
% 			while tmp_idx ~= mod(outside_final_idx-1,16)+1
% 				tmp_pos = positions(final_pos_pairidx,:) + rccr(tmp_idx,:);
% 				if tmp_pos(1) == 0 || tmp_pos(2) == 0 || tmp_pos(2) > 371 || tmp_pos(1) > 466
% 					err = 1;
% 					errs = errs + 1;
% 					pics_not_successful(errs) = pic_idx;
% 					break;
% 				end
% 				if Y_edge(tmp_pos(1),tmp_pos(2))
% 					% rule 1 fill up the gap; 
% 					% rule 2 fill the block which makes volumn larger
% 					% rule 3 add two blocks into POSITIONS this time;
% 					% rule 4 old position is the block manually added into POSITIONS
% 					Y_edge(tmp_pos(1),tmp_pos(2)) = 0;
% 					% add manual postion
% 					final_pos_pairidx = final_pos_pairidx + 1;
% 					manual_idx = mod(floor(tmp_idx/2),8) + 1;
% 					positions(final_pos_pairidx,:) = positions(final_pos_pairidx-1,:) ...
% 					 + rcc(manual_idx,:);
% 					len = len + 1;
% 					% add r2 position
% 					final_pos_pairidx = final_pos_pairidx + 1;
% 					positions(final_pos_pairidx,:) = positions(final_pos_pairidx-2,:) ...
% 					 + rccr(tmp_idx,:);
% 					len = len + 1;
% 				 	old_idx = pos_init_next(manual_idx);
% 					break;
% 				end
% 				tmp_idx = mod(tmp_idx, 16) + 1;
% 			end
% 			if err
% 				break;
% 			end
% 			if 	tmp_idx == mod(outside_final_idx-1,16) + 1
% 				% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
% 				err = 1;
% 				errs = errs + 1;
% 				pics_not_successful(errs) = pic_idx;
% 				break;
% 			end
% 		end
% 	end
% 	if err
% 		continue;
% 	end
% 	edge_im = zeros(size(ori));
% 	for idx = 1:final_pos_pairidx
% 		edge_im(positions(idx,1),positions(idx,2)) = 1;
% 	end
% 	% pic = figure('Name', filenames(i).name, 'NumberTitle', 'off');
% 	% subplot(1,4,1);imshow(ori);title("ori");
% 	% subplot(1,4,2);imshow(p_ori);title("positive ori");
% 	% subplot(1,4,3);imshow(edge(ori,'canny'));title('ori canny');
% 	% subplot(1,4,4);imshow(edge_im);title('oneline');
% 	imwrite(im2uint16(edge_im), ['D:/OCT/oneline/img/oneline_',filenames(pic_idx).name]);
% 	fid = fopen(['D:/OCT/oneline/dat/oneline_',filenames(pic_idx).name,'.txt'],'wt');
% 	for ii = 1:size(positions,1)
% 	    fprintf(fid,'%g\t',positions(ii,:));
% 	    fprintf(fid,'\n');
% 	end
% 	fclose(fid);
% end
% fprintf('prc=%d,errs=%d,successes=%d\n',prc,errs,97-errs);
% counter = 0;
% for ns_idx = pics_not_successful
% 	if mod(counter, 12) == 0
% 		figure(ns_idx+1);
% 		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
% 		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
% 	end
% 	axes(fig(mod(counter,12)+1));
% 	t = Tiff(filenames(ns_idx).name,'r');
% 	imageData = read(t);
% 	Y = imageData(:,:,1);
% 	Y = Y(1:466,510:880);
% 	Y = Y.*2;
% 	Y_170left = Y(:,1:170);
% 	Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),prc)) = 0;
% 	Y(:,1:170) = Y_170left;
% 	Y_280up = Y(280:end,:);
% 	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),prc)) = 0;
% 	Y(280:end,:) = Y_280up;
% 	Y_170right = Y(:,170:end);
% 	Y_170right(Y_170right<prctile(Y_170right(Y_170right>0),prc)) = 0;
% 	Y(:,170:end) = Y_170right.*3;
% 	Y(Y<prctile(Y(Y>0),prc)) = 0;
% 	Y = double(Y)/255;
% 	left = edge(Y(:,1:120),'canny');
% 	right = edge(Y(:,118:end),'canny');
% 	edge_l_r = zeros(size(Y));edge_l_r(:,1:120)=left;
% 	edge_l_r(:,118:end) = edge_l_r(:,118:end) + right;
% 	% imshow(edge(Y,'canny'));title(['edge ',filenames(ns_idx).name]);
% 	imshow(edge_l_r);title(['edge ',filenames(ns_idx).name]);
% 	counter = counter + 1;
% end



% for pic_idx = 1:97  % 2 46 btw, pic yy02000's idx is 1 and pic yy02003's idx is 4.
% 	%% Show input
% 	err = 0;
% 	t = Tiff(filenames(45).name,'r');
% 	imageData = read(t);
% 	Y = imageData(:,:,1);
% 	Y = Y(1:466,510:880);
% 	Y = Y.*2;
% 	Y_170left = Y(:,1:170);
% 	Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),55)) = 0;
% 	Y(:,1:170) = Y_170left;
% 	Y_280up = Y(280:end,:);
% 	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),56)) = 0;
% 	Y(280:end,:) = Y_280up;
% 	Y_170right = Y(:,170:end);
% 	Y_170right(Y_170right<prctile(Y_170right(Y_170right>0),30)) = 0;
% 	Y(:,170:end) = Y_170right;
% 	Y(Y<prctile(Y(Y>0),7)) = 0;
% 	% Y(Y<prctile(Y(Y>0),prc)) = 0;
% 	if length(find(Y(2,:)))
% 		top_leftright_first_positive = min(find(Y(2,:)));
% 		pos_row = 2;pos_col = top_leftright_first_positive;
% 		old_idx = 4;
% 	elseif length(find(Y(:,end-1)))
% 		right_topdown_first_positive = min(find(Y(:,end-1)));
% 		pos_row = right_topdown_first_positive;	pos_col = size(Y,2) - 1;
% 		old_idx = 2;
% 	else
% 		% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
% 		err = 1;
% 		errs = errs + 1;
% 		pics_not_successful(errs) = pic_idx;
% 		continue;
% 	end
% 	final_pos_pairidx = 1;
% 	positions = [pos_row,pos_col];
% 	maxlen = 3000;
% 	len = 0;
% 	while positions(final_pos_pairidx,2) > 2 %%%%%%%%%%%%%%
% 		if len >= maxlen
% 			err = 1;
% 			errs = errs + 1;
% 			pics_not_successful(errs) = pic_idx;	
% 			break;
% 		end
% 		tmp_idx = mod(old_idx, 8) + 1;
% 		tmp_pos = positions(final_pos_pairidx,:);
% 		l = max([1 tmp_pos(2)-1]); r = min([371 tmp_pos(2)+1]);
% 		u = max([1 tmp_pos(1)-1]); d = min([466 tmp_pos(2)+1]);
% 		low = min(min(Y(u:d,l:r))); high = max(max(Y(u:d,l:r)));
% 		gap_thres = (high - low)/4;
% 		former_tmp_pos = positions(final_pos_pairidx,:) + rcc(old_idx,:);
% 		while tmp_idx ~= old_idx
% 			tmp_pos = positions(final_pos_pairidx,:) + rcc(tmp_idx,:);
% 			if Y(tmp_pos(1),tmp_pos(2)) - Y(former_tmp_pos(1),former_tmp_pos(2)) >= gap_thres
% 				final_pos_pairidx = final_pos_pairidx + 1;
% 				positions(final_pos_pairidx,:) = positions(final_pos_pairidx-1,:) ...
% 				 + rcc(tmp_idx,:);
% 			 	len = len + 1;
% 			 	old_idx = pos_init_next(tmp_idx);
% 				break;
% 			end
% 			former_tmp_pos = tmp_pos;
% 			tmp_idx = mod(tmp_idx, 8) + 1;
% 		end
% 		if tmp_idx == old_idx
% 			% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
% 			err = 1;
% 			errs = errs + 1;
% 			pics_not_successful(errs) = pic_idx;
% 			break;
% 		end
% 	end
% 	if err
% 		continue;
% 	end
% 	edge_im = zeros(size(ori));
% 	for idx = 1:final_pos_pairidx
% 		edge_im(positions(idx,1),positions(idx,2)) = 1;
% 	end
% 	% pic = figure('Name', filenames(i).name, 'NumberTitle', 'off');
% 	% subplot(1,4,1);imshow(ori);title("ori");
% 	% subplot(1,4,2);imshow(p_ori);title("positive ori");
% 	% subplot(1,4,3);imshow(edge(ori,'canny'));title('ori canny');
% 	% subplot(1,4,4);imshow(edge_im);title('oneline');
% 	imwrite(im2uint16(edge_im), ['D:/OCT/oneline/img/oneline_',filenames(pic_idx).name]);
% 	fid = fopen(['D:/OCT/oneline/dat/oneline_',filenames(pic_idx).name,'.txt'],'wt');
% 	for ii = 1:size(positions,1)
% 	    fprintf(fid,'%g\t',positions(ii,:));
% 	    fprintf(fid,'\n');
% 	end
% 	fclose(fid);
% end
% fprintf('prc=%d,errs=%d,successes=%d\n',prc,errs,97-errs);
% counter = 0;
% for ns_idx = pics_not_successful
% 	if mod(counter, 12) == 0
% 		figure(ns_idx+1);
% 		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
% 		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
% 	end
% 	axes(fig(mod(counter,12)+1));
% 	t = Tiff(filenames(ns_idx).name,'r');
% 	imageData = read(t);
% 	Y = imageData(:,:,1);
% 	Y = Y(1:466,510:880);
% 	Y = Y.*2;
% 	Y_170left = Y(:,1:170);
% 	Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),55)) = 0;
% 	Y(:,1:170) = Y_170left;
% 	Y_280up = Y(280:end,:);
% 	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),56)) = 0;
% 	Y(280:end,:) = Y_280up;
% 	Y_170right = Y(:,170:end);
% 	Y_170right(Y_170right<prctile(Y_170right(Y_170right>0),30)) = 0;
% 	Y(:,170:end) = Y_170right;
% 	Y(Y<prctile(Y(Y>0),7)) = 0;
% 	% imshow(edge(Y,'canny'));title(['edge ',filenames(ns_idx).name]);
% 	imshow(Y);title(['Y',filenames(ns_idx).name]);
% 	counter = counter + 1;
% end


for pic_idx = 1:97  % 2 46 btw, pic yy02000's idx is 1 and pic yy02003's idx is 4.
	%% Show input
	err = 0;
	t = Tiff(filenames(45).name,'r');
	imageData = read(t);
	imageData = read(t);
	Y = imageData(:,:,1);
	Y = Y(1:466,510:880);
	Y = Y.*2;
	left_bound = 140;
	Y_left = Y(:,1:left_bound);
	Y_left(Y_left<prctile(Y_left(Y_left>0),65)) = 0;
	Y(:,1:left_bound) = Y_left;
	Y_280up = Y(280:end,:);
	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),56)) = 0;
	Y(280:end,:) = Y_280up;
	right_bound = 190;
	Y_right = Y(:,right_bound:end);
	Y_right(Y_right<prctile(Y_right(Y_right>0),30)) = 0;
	Y(:,right_bound:end) = Y_right;
	Y(Y<prctile(Y(Y>0),7)) = 0;
	% FOUR PICTURE
	
	edge_intact = edge(Y,'canny',0.06,2);
	Y_down = Y(1:280,:);
	Y_down(Y_down<prctile(Y_down(Y_down>0),56)) = 0;
	Y(1:280,:) = Y_down; 



	% Y(Y<prctile(Y(Y>0),prc)) = 0;
	if length(find(Y(2,:)))
		top_leftright_first_positive = min(find(Y(2,:)));
		pos_row = 2;pos_col = top_leftright_first_positive;
		old_idx = 4;
	elseif length(find(Y(:,end-1)))
		right_topdown_first_positive = min(find(Y(:,end-1)));
		pos_row = right_topdown_first_positive;	pos_col = size(Y,2) - 1;
		old_idx = 2;
	else
		% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
		err = 1;
		errs = errs + 1;
		pics_not_successful(errs) = pic_idx;
		continue;
	end
	final_pos_pairidx = 1;
	positions = [pos_row,pos_col];
	maxlen = 3000;
	len = 0;
	while positions(final_pos_pairidx,2) > 2 %%%%%%%%%%%%%%
		if len >= maxlen
			err = 1;
			errs = errs + 1;
			pics_not_successful(errs) = pic_idx;	
			break;
		end
		tmp_idx = mod(old_idx, 8) + 1;
		tmp_pos = positions(final_pos_pairidx,:);
		l = max([1 tmp_pos(2)-1]); r = min([371 tmp_pos(2)+1]);
		u = max([1 tmp_pos(1)-1]); d = min([466 tmp_pos(2)+1]);
		low = min(min(Y(u:d,l:r))); high = max(max(Y(u:d,l:r)));
		gap_thres = (high - low)/4;
		former_tmp_pos = positions(final_pos_pairidx,:) + rcc(old_idx,:);
		while tmp_idx ~= old_idx
			tmp_pos = positions(final_pos_pairidx,:) + rcc(tmp_idx,:);
			if Y(tmp_pos(1),tmp_pos(2)) - Y(former_tmp_pos(1),former_tmp_pos(2)) >= gap_thres
				final_pos_pairidx = final_pos_pairidx + 1;
				positions(final_pos_pairidx,:) = positions(final_pos_pairidx-1,:) ...
				 + rcc(tmp_idx,:);
			 	len = len + 1;
			 	old_idx = pos_init_next(tmp_idx);
				break;
			end
			former_tmp_pos = tmp_pos;
			tmp_idx = mod(tmp_idx, 8) + 1;
		end
		if tmp_idx == old_idx
			% fprintf([filenames(i).name,',Threshold too big! Use smaller Threshold to filter noise!\n']);
			err = 1;
			errs = errs + 1;
			pics_not_successful(errs) = pic_idx;
			break;
		end
	end
	if err
		continue;
	end
	edge_im = zeros(size(ori));
	for idx = 1:final_pos_pairidx
		edge_im(positions(idx,1),positions(idx,2)) = 1;
	end
	% pic = figure('Name', filenames(i).name, 'NumberTitle', 'off');
	% subplot(1,4,1);imshow(ori);title("ori");
	% subplot(1,4,2);imshow(p_ori);title("positive ori");
	% subplot(1,4,3);imshow(edge(ori,'canny'));title('ori canny');
	% subplot(1,4,4);imshow(edge_im);title('oneline');
	imwrite(im2uint16(edge_im), ['D:/OCT/oneline/img/oneline_',filenames(pic_idx).name]);
	fid = fopen(['D:/OCT/oneline/dat/oneline_',filenames(pic_idx).name,'.txt'],'wt');
	for ii = 1:size(positions,1)
	    fprintf(fid,'%g\t',positions(ii,:));
	    fprintf(fid,'\n');
	end
	fclose(fid);
end
fprintf('prc=%d,errs=%d,successes=%d\n',prc,errs,97-errs);
% counter = 0;
% for ns_idx = pics_not_successful
% 	if mod(counter, 12) == 0
% 		figure(ns_idx+1);
% 		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
% 		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
% 	end
% 	axes(fig(mod(counter,12)+1));
% 	t = Tiff(filenames(ns_idx).name,'r');
% 	imageData = read(t);
% 	Y = imageData(:,:,1);
% 	Y = Y(1:466,510:880);
% 	Y = Y.*2;
% 	Y_170left = Y(:,1:170);
% 	Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),55)) = 0;
% 	Y(:,1:170) = Y_170left;
% 	Y_280up = Y(280:end,:);
% 	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),56)) = 0;
% 	Y(280:end,:) = Y_280up;
% 	Y_170right = Y(:,170:end);
% 	Y_170right(Y_170right<prctile(Y_170right(Y_170right>0),30)) = 0;
% 	Y(:,170:end) = Y_170right;
% 	Y(Y<prctile(Y(Y>0),7)) = 0;
% 	% imshow(edge(Y,'canny'));title(['edge ',filenames(ns_idx).name]);
% 	imshow(Y);title(['Y',filenames(ns_idx).name]);
% 	counter = counter + 1;
% end



screensize = get( groot, 'Screensize' );
counter = 0;
pic_sum = [];
for ns_idx = 1:97
	if mod(counter, 12) == 0
		fig = figure(ns_idx+1);
		set(fig,'Position',screensize);
		fig = tight_subplot(2,6,[.01 .01],[.03 .01],[.01 .01]);
		set(fig,'XTickLabel',''); set(fig,'YTickLabel','');
	end
	axes(fig(mod(counter,12)+1));
	t = Tiff(filenames(ns_idx).name,'r');
	imageData = read(t);
	Y = imageData(:,:,1);
	Y = Y(1:466,510:880);
	if size(pic_sum,1)
		pic_sum = pic_sum + double(Y);
	else
		pic_sum = double(Y);
	end
	Y = Y.*2;
	% Y_170left = Y(:,1:170);
	% Y_170left(Y_170left<prctile(Y_170left(Y_170left>0),55)) = 0;
	% Y(:,1:170) = Y_170left;
	Y = Y.*2;
	imwrite(im2uint16(Y), ['D:/OCT/ori/ori_',filenames(ns_idx).name]);
	Y = Y.*0.5;
	left_bound = 140;
	Y_left = Y(:,1:left_bound);
	Y_left(Y_left<prctile(Y_left(Y_left>0),80)) = 0;
	Y(:,1:left_bound) = Y_left;
	Y_280up = Y(280:end,:);
	Y_280up(Y_280up<prctile(Y_280up(Y_280up>0),56)) = 0;
	Y(280:end,:) = Y_280up;
	% Y_240up = Y(240:end,:);
	% Y_240up(Y_240up<prctile(Y_240up(Y_240up>0),56)) = 0;
	% Y(240:end,:) = Y_240up;
	% Y_170right = Y(:,170:end);
	% Y_170right(Y_170right<prctile(Y_170right(Y_170right>0),30)) = 0;
	% Y(:,170:end) = Y_170right;

	right_bound = 190;
	Y_right = Y(:,right_bound:end);
	Y_right(Y_right<prctile(Y_right(Y_right>0),30)) = 0;
	Y(:,right_bound:end) = Y_right;
	Y(Y<prctile(Y(Y>0),7)) = 0;

	% Col sum normalize
	% for tmp_idx = 1 :371
	% 	col = Y(:,tmp_idx);
	% 	tmp(tmp_idx) = double(prctile(col(col>0),60));
	% end
	% Y = double(Y) ./ (tmp+1);
	Y_down = Y(1:280,:);
	Y_down(Y_down<prctile(Y_down(Y_down>0),56)) = 0;
	Y(1:280,:) = Y_down; 

	edge_tmp = edge(Y,'canny',0.06,2);
	img = imageData(1:466,510:880,:);
	img(:,:,1) = img(:,:,1).*2;
	img(:,:,2) = edge_tmp.*255;
	% imshow(edge(Y,'canny',[],5));title(['edge ',filenames(ns_idx).name]);
	imshow(img);title(['edge ',filenames(ns_idx).name]);
	counter = counter + 1;
end
imwrite(im2uint16(Y), 'D:/OCT/ori/ori_sum.tiff');


tmpt(:,:,1) = pic_sum./max(max(pic_sum));
% ttt = tmpt(:,:,1);ttt(ttt<prctile(ttt,40)) = 0; tmpt(:,:,1) = ttt;
% tmpt(:,:,3) = edge(pic_sum./max(max(pic_sum)),'canny',[],6);
% figure();imshow(tmpt);

mask = tmpt(:,:,1); mask(mask < prctile(mask, 50)) = -1; mask(mask>0) = 0; mask(mask<0) = 1; tmpt(:,:,2) = mask;
figure();imshow(tmpt)