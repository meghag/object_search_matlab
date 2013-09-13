function plot_config(config,visible,known,free,dim1,dim2,res,title_text,target_id)
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

figure;

%Drawing the grid
draw_grid(dim1,dim2,res);
%plot(cellCentres(:,:,1), cellCentres(:,:,2),'b. ');
xlim([0,dim2]);
ylim([0,dim1]);
title(title_text);

%[visible,~,known] = find_visible(config,prev_seen);
%[~,free] = find_occupied(known,dim1/res,dim2/res);

hold on;

color = {[0 0 0],[1 0 0],[0 1 0],[0 0 1],[0.3 0.6 0.4],[1 0 1],[0 1 1],...
    [1 1 0],[0.1 0.3 0.3],[0.8 0 0.5],[0.7,0.4,0],[0.1 0.3 0.8]};

%Draw objects
for i = 1:size(config,1)
    centre = cellCentres(config(i,2),config(i,3),:);
    if (config(i,1) == target_id)
        %This is the target object
        plot(centre(1),centre(2),'-*','MarkerFaceColor',color{config(i,1)},'MarkerSize',50);
    elseif (isempty(find(config(i,1) == visible(:,1), 1)))
        %The object is not visible
        if (numel(find(config(i,1) == known(:,1))) ~= 0)
            %But the object is known
            plot(centre(1),centre(2),'-d','MarkerFaceColor',color{config(i,1)},'MarkerSize',50);
        %circle(centre,res/4,1000,'-',color{config(i,1)});
        else
            % The object is unknown
            plot(centre(1),centre(2),'-s','MarkerFaceColor',color{config(i,1)},'MarkerSize',50);
        end
    else
        hCircles = plot(centre(1),centre(2),'-o','MarkerFaceColor',color{config(i,1)},'MarkerSize',50);
        %circle(centre,res/4,1000,'-',color{config(i,1)});
    end
end

if (numel(free) ~= 0)
    [sub_free(:,1),sub_free(:,2)] = ind2sub([dim1/res,dim2/res],free);
    for i = 1:size(sub_free,1)
        centre = cellCentres(sub_free(i,1),sub_free(i,2),:);
        plot(centre(:,:,1),centre(:,:,2),'g+','MarkerSize',30);
    end
end

% hCircleGroup = hggroup;
% set(hCircles,'Parent',hCircleGroup);
% % Include these hggroups in the legend:
% set(get(get(hCircleGroup,'Annotation'),'LegendInformation'),...
%     'IconDisplayStyle','on'); 
% legend('Visible');

hold off;

end

