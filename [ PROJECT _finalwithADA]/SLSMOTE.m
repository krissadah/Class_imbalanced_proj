function [final_features final_mark] = SLSMOTE(original_features, original_mark)
ind = find(original_mark == 1);
% P = candidate points
P = original_features(ind,:);
%T = P';
[r c]=size(P);
synthetic_features=ones(r,c); 
D=zeros(r,c);
%finding nearest neighbours of all the original features
I=nearestneighbour(original_features',original_features','NumberOfNeighbours',6);
I=I';
% Extracting the indices of the nearest neighbours of positive points only
I_pos=I(ind,:);
numattrs=c;
%randomly select one nearest neighbor for each positive point p and call it
%n. Thereafter calculate slp and sln.
for j=1:length(ind)
    n=datasample(I_pos(j,2:6),1); %selecting one nearest neighbour randomly
    slp=length(find(original_mark(I_pos(j,2:6))==original_mark(ind(j,1))));
    %sln=length(find(original_mark(I_pos(j,2:6))==1));
    %finding sln
    sln=0;
    for i=1:6
    if(I_pos(j,i)==n);
    else
        if(find(original_mark(I_pos(j,i))==1))
            sln=sln+1;
        end
    end
    end
    
    if(sln~=0) %sl is safe level
        sl_ratio=slp/sln; %sl_ratio is safelevel ratio
    else
        sl_ratio=Inf;
    end
    
    
    if(sl_ratio==Inf && slp==0); %1st case: do not generate positive synthetic instance
    else
        for atti=1:numattrs
            if(sl_ratio==Inf && slp~=0) % 2nd case
                gap=0;
            elseif(sl_ratio==1) % 3rd case
                    gap=rand;
            elseif (sl_ratio>1) % 4th case
                    gap=(1/sl_ratio)*rand;
            elseif (sl_ratio<1) % 5th case
                    gap=(1-sl_ratio)+(1-(1-sl_ratio))*rand;
                    
            end
            dif=original_features(n,atti)-P(j,atti);
            synthetic_features(j,atti)=P(j,atti)+gap*dif;
        end
         D(j,:)=synthetic_features(j,:);
       
    end
    [r c]=size(D)
    D_mark=ones(r,1);
        
    
end
final_features = [original_features;D];
final_mark=[original_mark;D_mark];
end