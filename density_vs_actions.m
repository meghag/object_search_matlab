function [ output_args ] = density_vs_actions( horizon )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


%%%%%%%%% Incomplete  %%%%%%%%%%%

%result = compare_all_configs(dim1,dim2,res,N,horizon,algo_id);
res = 1;
answer = zeros(5*5*42, 5);
%for horizon = 1:2
i = 1;
for dim1 = 3:7
    for dim2 = 3:7
        for N = 4:(dim1*dim2 - 3) 
            density = N/(dim1*dim2);
            result = compare_all_configs(dim1,dim2,res,N,horizon,2);
            answer(i,:) = [density,result'];
        end
    end
end




end

