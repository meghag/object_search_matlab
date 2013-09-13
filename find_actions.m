function actions = find_actions(visible,known,dim1,dim2,res)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

nrows = dim1/res;
ncols = dim2/res;

actions = [];

for obj = 1:size(visible,1)
    objId = visible(obj,1);
    objRow = visible(obj,2);
    objCol = visible(obj,3);
    %Find valid moves    
    if (objRow <= nrows && objRow ~= 1 && ...
            numel(setdiff([objRow-1,objCol], known(:,2:3),'rows')) ~= 0)
        %Can move forward
        actions = [actions;[objId,-1,0]];
    end
    
    if (objRow >= 1 && objRow ~= nrows && ...
            numel(setdiff([objRow+1,objCol], known(:,2:3),'rows')) ~= 0)
        %Can move back
        actions = [actions;[objId,1,0]];
    end
    
    if (objCol <= ncols && objCol ~= 1 && ...
            numel(setdiff([objRow,objCol-1], known(:,2:3),'rows')) ~= 0)
        %Can move left
        actions = [actions;[objId,0,-1]];
    end
    
    if (objCol ~= ncols && objCol >= 1 && ...
            numel(setdiff([objRow,objCol+1], known(:,2:3),'rows')) ~= 0)
        %Can move right
        actions = [actions;[objId,0,1]];
    end
end

