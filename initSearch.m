function o = initSearch( argv, n )

if n ~= -1
    argv = argv{1};
end
% Initialize all the parameters for team search
o = struct;

% CREATE DEFAULT PARAMETERS
% Number of the teams and individuals in each team
o.nTeams = [10 10 10 10 10 10 10 10 10 10];%[16 6 3 11 4 7 4];
% Number of genes in each genome
o.N = 93;
% Number of epistatic relations K
o.K = 0;
% Number of the steps each gene of each indv should wait before the next update
o.memory = 0;
% Number of generations
o.generations = 10;%0;
% Fitness function
%o.fitnessFnc = @evalNKFitness;
o.fitnessFnc = @evalLogistic;
% Proportion of two way interactions if using logistic function
o.prop2way = 0.1;
% Crossover method to compare to
% 1 - one point crossover
% 2 - uniform crossover
o.crossMethod = 2;
% Team initialization flag
% 1 - RANDOM; randomly initialize the population
% 2 - HAMMING DIST FOR POPULATION; any two indv in population have
%          less then the specified hamming distance difference
% 3 - HAMMING DIST FOR TEAMS;  any two indv in any time have less
%          then the specified hamming distance difference
o.teamInit = 1;
% Team structure
% 1 - Keep the initial random teams over generations
% 2 - Create random teams in each generation
% 3 - In each generation select the most similar guys to be in the same
%     team
o.teamStructure = 4;
% Maximum hamming distance for cases when o.teamInit is either 2 or 3,
% given as the proportion of bits that can be different for any two indv
o.maxH = 0.5;
o.sN = 10;
o.sInds = 10;
% Swap rate between teams if option 7 is chosen
o.reformRate = 1;
% Number of times to recreate the teams
o.nMethod = 10;
% Crossover rate for regular one point crossover
% o.crossoverRate = 1-1/o.nIndPerTeam;
% Binary flag for the existance of known best fitness
o.knownBestFitness = 0;
% If we are using noise through number of cases in each hospital
o.noise = 1;
% Cases in each hospital
o.nCases = 40;
% Visualize output flag
o.vis = 0;
% Calculate Networks charachteristics flag
o.networkChars = 0;
% Time for fileName
o.curClock = 0;
% Fixed random seed
o.seed = 1;

% If any parameters are specified
if exist('n')
    
    % override parameters that have been passed to the function
    for i = 1:2:size(argv,2)
        eval(['o.' argv{i} ' = ' num2str(argv{i+1}) ';']);
    end
    
end

% Number of individuals in population
o.nPop = sum(o.nTeams);
% Number of teams
o.nTeam = size(o.nTeams,2);
% Number of individuals per snake circle
o.sInd = 10;

o.rsm = RandStream.create('mrg32k3a','Seed',o.seed);
% Generate NK landscape
%o.model = generateNKLandscape(o.N, o.K, o.rsm);
%rng(o.seed);

o.model = makeLogisticModelNway2(o.N,[o.N round(o.prop2way*nchoosek(o.N,2))],o.seed);

if o.knownBestFitness
    % Load true solution for comparision
    load(['TrueSolutionsLG/trueSolution' num2str(o.N) num2str(o.prop2way*10) num2str(o.seed)]);
    o.trueBestFitness = trueBestFitness;
end

end

