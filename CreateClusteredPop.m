function population = CreateClusteredPop(N, nCircles, nInds, d )


% N:             Number of features
% nCircles:  # of circles
% nInds:       # of agents per circle
% seed:       Seed for random number generator

% Example calls 
% population = CreateClusteredPop( 100, 10, 10, 0.125 )

if nargin < 4
    d = 0.125;
end

if nargin < 2
    nCircles = 10;
    nInds = 10;
    d = 0.125;
end
        ct = 1;
        maxHamDist = round(N*d);
        coreIndv = rand(1, N)>0.5;
        population = ones(nCircles*nInds,N);
        for i = 1:nCircles
            if i~=1
                rInt = randi(nInds,1,1);
                coreIndv = population((i-2)*nInds + rInt,:);
            end
            population((i-1)*nInds+1,:) = coreIndv;
            for j = 2:nInds
                r = randperm(N);
                nBitsToFlip = maxHamDist; %min(o.N,randi(maxHamDist,1,1));
                temp = coreIndv;
                temp(r(1:nBitsToFlip)) = ~ temp(r(1:nBitsToFlip));
                population(ct,:) = temp;
                ct = ct+1;
            end
        end
        population = population(1:nCircles*nInds,:);
end

