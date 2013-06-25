function y=evalLogistic(model,x)
% SAMPLE CALL: y=evalLogistic(model,randi([0 1],5,10)) % e.g. 5 cases, 10 attribures
x=real(x);
x(x==0)=-1;% JB'S NEW FORMULATION

y=model.B(1);
for term=2:length(model.B)
    f=model.whichX(term,model.whichX(term,:)~=0);
    if ~isempty(f)
        y=y+model.B(term)*prod(x(:,f),2); %bug!!! prod returns 1 if f is []
    end
end

y=logistic(y);% apply logistic function