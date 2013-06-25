function model = makeLogisticModelNway2(n,Nterms,expt)
% n2way=nchoosek(100,2); %determine # of 2-ways possible
% prop2way=.1;
% model = makeLogisticModelNway2(100,[100 prop2way*n2way],1)
% calls it with 100 features all having main effect, 10% of 2-way interactions, and experiment number 1
if nargin < 2
    Nterms=n;
end

if nargin < 3
    expt=sum(clock*100);
end

L=sum(Nterms)+1;
mo.stddev=1./sqrt(L);
mo.n=n;
mo.nterms=Nterms;
mo.rsm= RandStream.create('mrg32k3a','Seed',expt);
mo.Pqualitative=nan;

model.whichX=zeros(L,length(Nterms));
% model.B=zeros(L,1)+1;
model.B=zeros(L,1);

% choose first order terms, guaranteeing no duplicates
forder=randperm(mo.rsm,n);
model.whichX(2:Nterms(1)+1,1)=forder(1:Nterms(1))';
model.B(2:Nterms(1)+1)=randn(mo.rsm,Nterms(1),1).*mo.stddev;

forder=forder(Nterms(1)+1:end); %remember remaining unused features

temp=zeros(L-Nterms(1)-1,2);
indeces=randperm(mo.rsm,length(temp(:)));
temp(indeces(1:length(forder)))=forder; %use up remaining terms
model.whichX(Nterms(1)+2:end,1:2)=temp;

next=Nterms(1)+2;
if length(Nterms)>1 && Nterms(2)>=nchoosek(n,2)/2 %in this case just make all 2-ways
    pairs=makeallpairs(n);
    rorder=randperm(mo.rsm,Nterms(2));
    model.whichX(next:next+Nterms(2)-1,1:2)=pairs(rorder(1:Nterms(2)),:);
    model.B(next:next+Nterms(2)-1)=randn(mo.rsm).*mo.stddev;
    next=next+Nterms(2);
    startorder=3;
else
    startorder=2;
end
%choose remaining terms

% founddup=0;
for termorder=startorder:length(Nterms)
    orderstart=next;
    for term=1:Nterms(termorder)
        needterm=true;
        while needterm
            forder=randperm(mo.rsm,n);
            need=model.whichX(next,1:termorder)==0;
            indeces=find(need);
            if length(indeces)<termorder % we already have one or more values here
                skip=model.whichX(next,~need);
                for s=1:length(skip)
                    forder(forder==skip(s))=[];
                end
            end
            model.whichX(next,indeces)=forder(1:length(indeces));
            if uniquerow(model.whichX(next,:),model.whichX([orderstart:next-1 next+1:orderstart+Nterms(termorder)-1],:))
                needterm=false;% new term was unique so keep it
            else %loop back to find a unique new term
                model.whichX(next,need)=0; %indicate we need new values here
%                 founddup=founddup+1; %debugging code
%                 [next founddup]
            end
        end
        model.B(next)=randn(mo.rsm).*mo.stddev;
        next=next+1;
    end
end

% termorders=sum(model.whichX>0,2);
% for termorder=1:length(Nterms)
%     mo.nterms(termorder)=sum(termorders==termorder);
% end

model.mo=mo;

%may want to comment next line out to speed up
%model.sampley=SampleFunction(model,1e6); %sample 1,000,000 pts

function pairs=makeallpairs(n)
pairs=zeros(nchoosek(n,2),2); %make all unique pairs
ct=0;
for i=1:n-1
    for j=i+1:n
        ct=ct+1;
        pairs(ct,1:2)=[i j];
    end
end
