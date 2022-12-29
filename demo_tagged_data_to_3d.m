dbstop if error
cd('D:/OCT/tagged/left1(micron) (1) [MConverter.eu]');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 1. Original Edge to 3D „Äêpixel is point here„Ä?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_location='D:/OCT/tagged/left1(micron) (1) [MConverter.eu]/3dl1.obj';
color_target_edge = [255;13;13];
fileID = fopen(save_location,'w');
for x = 1 : 97
	if x < 10
		name = strcat('0000',num2str(x));
	elseif x < 100
		name = strcat('000',num2str(x));
	elseif x < 1000
		name = strcat('00',num2str(x));
	elseif x < 10000
		name = strcat('0',num2str(x));
	else
		name = num2str(x);
	end
	I = imread(strcat(name,'.tiff'));
	It = ones(size(I(:,:,1))).*255;
	It(I(:,:,1)~=255 | I(:,:,2)~=13 | I(:,:,3)~=13) = 0; % need to be changed if color changes
	% It = imfill(It);
	if sum(sum(It))==0
		continue;
    end
	[nrow,ncol] = size(It);
	for r = 1:nrow 
		for c = find(It(r,:))
			fprintf(fileID,'v %f %f %f 1\n', r,c,x*(52.66/97)*(384/79)); % 15/2 is too rough est.! 384/79 is better, 52.66=79/3*2~~53
		end
	end
end
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Part 2. Interpolated Edge to 3D „Ä?1 pixel lengths 1, needs 2 point to represent, and all edges are true points„Ä?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
save_location='D:/OCT/tagged/left1(micron) (1) [MConverter.eu]/3dl2.obj';
color_target_edge = [255;13;13];
fileID = fopen(save_location,'w');
BW = {};
for x = 1 : 97
	if x < 10
		name = strcat('0000',num2str(x));
	elseif x < 100
		name = strcat('000',num2str(x));
	elseif x < 1000
		name = strcat('00',num2str(x));
	elseif x < 10000
		name = strcat('0',num2str(x));
	else
		name = num2str(x);
	end
	I = imread(strcat(name,'.tiff'));
	It = ones(size(I(:,:,1))).*255;
	It(I(:,:,1)~=255 | I(:,:,2)~=13 | I(:,:,3)~=13) = 0; % need to be changed if color changes
	It = imfill(It);
	%% calculate max bw number
	[nrow,ncol] = size(It);
	maxi = 1;
	for c = 1:ncol 
		status = 0;
		bw_number = 1;
		for r = 1:nrow
			if xor(It(r,c),status)
				status = ~status;
				bw_number = bw_number + 1;
			end
		end
		maxi = max(bw_number, maxi);
	end
	bw_number_max = maxi;

	%% fill in BW_content with bw lengths
	[nrow,ncol] = size(It);
	BW_content = zeros(bw_number_max,ncol);
	for c = 1:ncol
		status = 0;
		bw_idx = 1;
		bw_length = 0;
		for r = 1:nrow
			if ~xor(It(r,c),status)
				bw_length = bw_length + 1;
			else
				BW_content(bw_idx,c) = bw_length;
				status = ~status;
				bw_idx = bw_idx + 1;
				bw_length = 1;
			end
		end
		BW_content(bw_idx,c) = bw_length;
    end
	BW{x} = BW_content;
end

%% remake whole BW's content to be one size with important content remaking inside each BW_content
%% store final result inside tensor BW_3d.
maxi = 1;
for x = 1:97
	BW_content = BW{x};
	[nrow,ncol] = size(BW_content);
	maxi = max(nrow,maxi);
end
bw_number_max = maxi;
for x = 1:97
    if x == 69
        aaa = 1;
    end
	BW_content = BW{x};
	[nrow,ncol] = size(BW_content);
	BW_content = [BW_content;zeros(bw_number_max-nrow,ncol)];
	[nrow,ncol] = size(BW_content);
	%% relocate content inside BW_content
	for c = 1:ncol
		if BW_content(end,c) == 0
			BW_content_number = length(find(BW_content(:,c))); % must be odd number
			half_length = round(BW_content_number/2);
			head = BW_content(1:half_length,c);
			tail = BW_content(BW_content_number-half_length+1:BW_content_number,c);
			BW_content(:,c) = [head;zeros(bw_number_max-2*half_length,1);tail];
		end
	end
	BW_3d(:,:,x) = BW_content; % In BW_3d's cols, there will be sum(bw_lengths) having exceeding length
end

% interpolation 3D 
[nrow,ncol,nhei] = size(BW_3d);
[X,Y,Z] = meshgrid(1:ncol,1:nrow,(1:nhei)*(52.66/97)*(384/79));
si = (52.66/97)*(384/79);
[Xq,Yq,Zq] = meshgrid(1:0.04:ncol,1:nrow,(1:(0.04/si):nhei)*si);
BW_3d_q = interp3(X,Y,Z,BW_3d,Xq,Yq,Zq);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nrow,ncol,nhei] = size(BW_3d_q);
I = imread(strcat(name,'.tiff'));
[bw_length_sum_max,~,~] = size(I);
htht = @(x) round(nrow/2) + (-1).^x.*round((nrow-x)/2);
htht_seq = htht(1:nrow-1);
for x = 1:nhei
	if sum(BW_3d_q(2,:,x))==0
		continue;
    end
	for c = 1:ncol 
		bw_length_sum = 0;
		up_pos = 1;
		down_pos = 1 + bw_length_sum_max;
		legal_idx_max = 0;
		for r = htht_seq
			if BW_3d_q(r,c,x) == 0 % this if should be useless, and worth further thinking...
				break;
			end
			bw_length_sum = bw_length_sum + BW_3d_q(r,c,x);
			if bw_length_sum < bw_length_sum_max
				legal_idx_max = legal_idx_max + 1;
			else
				legal_idx_max = legal_idx_max - 1; % former point added is also illegal, so -1!
				break;
			end
		end
		for r = htht_seq(1:legal_idx_max)
			if r < round(nrow/2)
				up_pos = up_pos + BW_3d_q(r,c,x);
				fprintf(fileID,'v %f %f %f 1\n', Xq(r,c,x),up_pos,Zq(r,c,x)); % 15/2 is too rough est.! 384/79 is better, 52.66=79/3*2~~53
			else
				down_pos = down_pos - BW_3d_q(r,c,x);
				fprintf(fileID,'v %f %f %f 1\n', Xq(r,c,x),down_pos,Zq(r,c,x)); % 15/2 is too rough est.! 384/79 is better, 52.66=79/3*2~~53
			end
		end
	end
end
fclose(fileID);
