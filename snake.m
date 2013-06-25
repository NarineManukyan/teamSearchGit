function population = snake(o )
d = 0.125;
maxHamDist = round(o.N*d);
coreIndv = rand(1, o.N)>0.5;
%population = zeros(o.nPop,o.N);
for i = 1:o.sN
    if i~=1
%         rInt = randi(o.sInds,1,1);
%         coreIndv = population((i-2)*o.sInds + rInt,:);
        D = squareform(pdist(population,'hamming'));
        FIX = eye(size(population,1));
        D = D-FIX; % make all the elements on the diagonal of D to be -1
        [~, indM] =  max(mean(D));
        coreIndv = population(indM,:);
    end
    population((i-1)*o.sInds+1,:) = coreIndv;
    for j = 2:o.sInds
        r = randperm(o.N);
        nBitsToFlip = maxHamDist; %min(o.N,randi(maxHamDist,1,1));
        temp = coreIndv;
        temp(r(1:nBitsToFlip)) = ~ temp(r(1:nBitsToFlip));
        population((i-1)*o.nTeams(i)+j,:) = temp;
        o.sInds =
    end
end


%%%%%%%%%%%%%%Vis only
p = population;
figure
subplot(2,1,1)
p=pdist(population,'Hamming');
hist(p);
title(['med = ',num2str(median(p)) ', mean: ' num2str(mean(p))])
set(gca,'xlim',[0 1])
meds(1)=median(p);

mean(meds)

subplot(2,1,2)
load realpopulation
p=pdist(population,'Hamming');
hist(p);
title(['Real pop: med = ',num2str(median(p)) 'mean: ' num2str(mean(p))])
set(gca,'xlim',[0 1])
figure(gcf)
end

