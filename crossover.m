function [ team, newTabu] = crossover( o, team, fitness, tabu, k )

newTeam = team;
newTabu = tabu;
% Sort individuals according to their fitness values
[~, sortedPop] = sort(fitness,'descend');
for p = 1:size(sortedPop,1)
    if size(team,1) ==1
        arrangedSortDiffs = randperm(o.rsm,o.N);
    else
        if p==1
            meanOfBetterGuys = team(sortedPop(p),:);
        else
            meanOfBetterGuys = mean(team(sortedPop(1:p-1),:),1);
        end
        if p == size(sortedPop,1)
            meanOfWorstGuys = team(sortedPop(p),:);%zeros(1,o.N);
        else
            meanOfWorstGuys = mean(team(sortedPop(p+1:end),:),1);
        end
        
        betterGuysBit = double(meanOfBetterGuys > 0.5);
        MaskSort = team(sortedPop(p),:) ~= betterGuysBit;
        allIndex = 1:o.N;
        DescIndex = allIndex(MaskSort);
        AscIndex = allIndex(~MaskSort);
        [~,sortDiffsDesc] = sort(abs(meanOfBetterGuys(MaskSort) - meanOfWorstGuys(MaskSort)),'descend');
        [~,sortDiffsAsc] = sort(abs(meanOfBetterGuys(~MaskSort) - meanOfWorstGuys(~MaskSort)));
        arrangedSortDiffs = [DescIndex(sortDiffsDesc) AscIndex(sortDiffsAsc)];
    end
    %%%%discoveredFeatures;
    for i = 1:size(arrangedSortDiffs,2)
        if tabu(sortedPop(p),arrangedSortDiffs(i))==0
            temp = team(sortedPop(p),:);
            temp(1,arrangedSortDiffs(i)) = ~temp(1,arrangedSortDiffs(i));
            ftemp = feval(o.fitnessFnc, o.model, temp);
            fold = fitness(sortedPop(p));
            if o.noise == 1
                frealObserved=mybinornd(o.nCases,fold,o.rsm)*2/o.nCases;
                ftempObserved=mybinornd(o.nCases,ftemp,o.rsm)*2/o.nCases;
                ftemp = ftempObserved;
                fold = frealObserved;
            end
            
            if ftemp >= fold
                newTeam(sortedPop(p),arrangedSortDiffs(i)) = ~team(sortedPop(p),arrangedSortDiffs(i));
            end
            newTabu(sortedPop(p),arrangedSortDiffs(i)) = o.memory;
            break;
            
        end
    end
end
team = newTeam;
end



