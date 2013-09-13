function plot_config2(config,visible,known,occupied_indices,free,dim1,dim2,res,title_text,target_id)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

% config: Nx3 matrix, 1st column is id, 2nd column is grid row no., 3rd
% column is grid column no.

%Calculating centres of grid cells
cellCentres = zeros(dim1/res,dim2/res,2);
for i = 1:dim1/res
    for j = 1:dim2/res
        cellCentres(i,j,1) = (j-1)*res + res/2;
        cellCentres(i,j,2) = (i-1)*res + res/2;
    end
end

%figure;
figure('Color',[1.0 1.0 1.0]);
set(gca,'xtick',[])
set(gca,'xticklabel',[])
set(gca,'ytick',[])
set(gca,'yticklabel',[])

%Drawing the grid
draw_grid(dim1,dim2,res);
%plot(cellCentres(:,:,1), cellCentres(:,:,2),'b. ');
xlim([0,dim2]);
ylim([0,dim1]);
title(title_text);

[occupied(:,1),occupied(:,2)] = ind2sub([dim1/res,dim2/res],occupied_indices);
%unknown_occupying_objects = setdiff(occupied,known(:,2:3),'rows');

hold on;

color = {[1 0 0],[0 1 0],[0 0 1],[0.3 0.6 0.4],[1 0 1],[0 1 1],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8],[0 0 0]};

%Draw objects
for i = 1:size(config,1)
    centre = cellCentres(config(i,2),config(i,3),:);
%     if (config(i,1) == target_id)
%         %This is the target object
%         plot(centre(1),centre(2),'-d','MarkerFaceColor',color{config(i,1)},'MarkerSize',50);
    if (isempty(find(config(i,1) == visible(:,1), 1)))
        %The object is not visible
        if (numel(find(config(i,1) == known(:,1))) ~= 0)
            %But the object is known
            plot(centre(1),centre(2),'-d','MarkerFaceColor',color{config(i,1)},'MarkerSize',30);
        %circle(centre,res/4,1000,'-',color{config(i,1)});
        else
            % The object is unknown
            plot(centre(1),centre(2),'-s','MarkerFaceColor',color{config(i,1)},'MarkerSize',30);
        end
    else
        plot(centre(1),centre(2),'-o','MarkerFaceColor',color{config(i,1)},'MarkerSize',30);
        %circle(centre,res/4,1000,'-',color{config(i,1)});
    end
end

% for i = 1:size(unknown_occupying_objects,1)
%     % Some cells are known to be occupied but the object unknown.
%     centre = cellCentres(unknown_occupying_objects(i,1),unknown_occupying_objects(i,2),:);
%     plot(centre(1),centre(2),'k+','MarkerSize',50);
% end

% for i = 1:size(occupied,1)
%     % Some cells are known to be occupied but the object unknown.
%     centre = cellCentres(occupied(i,1),occupied(i,2),:);
%     plot(centre(1),centre(2),'k+','MarkerSize',30);
% end
            
all = [1:dim1/res*dim2/res]';
unknown = setdiff(all,union(occupied_indices,free));
[unknown_idx(:,1),unknown_idx(:,2)] = ind2sub([dim1/res,dim2/res],unknown);

for i = 1:size(unknown,1)
    % Never seen or felt objects
    centre = cellCentres(unknown_idx(i,1),unknown_idx(i,2),:);
    plot(centre(1),centre(2),'kx','MarkerSize',30, 'LineWidth', 2);
end

% if (numel(free) ~= 0)
%     [sub_free(:,1),sub_free(:,2)] = ind2sub([dim1/res,dim2/res],free);
%     for i = 1:size(sub_free,1)
%         centre = cellCentres(sub_free(i,1),sub_free(i,2),:);
%         plot(centre(:,:,1),centre(:,:,2),'g+','MarkerSize',30);
%     end
% end

hold off;

end

