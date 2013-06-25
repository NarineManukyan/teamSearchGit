function isunique=uniquerow(row,matrix)
isunique=true;
for r=1:size(matrix,1)
    if all(sort(row)==sort(matrix(r,:)))
        isunique=false;
        return
    end
end