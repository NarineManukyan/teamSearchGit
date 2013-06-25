function D = eucDist(o, v, mat )

V = repmat(v,size(mat,1),1);
%D= sum((V'-mat').^2).^0.5;
D = sum(V==mat,2)/o.N;
end

