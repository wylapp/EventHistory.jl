using EventHistory

##################################################
### EventClass
##################################################

## Right-censored event-time
stop   = [2,3,3];
status = [false,true,true];
e1 = Event(stop,status)

Time(e1)
Status(e1)

## Right-censored+left truncation
start  = [0,1,2];
e2 = Event(start,stop,status)

Entry(e2)

## Competing risks model
cause = [0,2,1];
e3 = Event(start,stop,cause)

Status(e3)
Cause(e3)

## Interval censoring
right  =  [2,3,Inf];
left =  [1,-Inf,1];
e4=Event(left,right,:interval)

## Formula syntax (see also below)
using DataFrames
d = DataFrame(start=start,stop=stop,status=status);
Event([:stop,:status],d)
Event([:start,:stop,:status],d)


##################################################
### Cox regression
##################################################
using EventHistory
using RDatasets
ovarian = dataset("survival", "ovarian");
ovarian[:Group] = ovarian[:Rx].-1;
ovarian[:S] = Event([:FUTime,:FUStat],ovarian);

mm = phreg(S~Age+Group,ovarian)

## Prediction
predict(mm,surv=false,X=[0 0]); ## Baseline
s56 = predict(mm,X=[56 1],order=true); ## Survival probabilities age 40, group 1
predict(mm,X=[56 0],time=[100,400,600]); ## ... at time 100,400,600
predict(mm,X=[56 1; 56 0],time=[600,100,400]) ## ... both groups

using Winston
plot(s56[:,1],s56[:,2])

s = predict(mm,X=[56 1; 56 0],order=true);
pr = DataFrame(Time=[s[:,1];s[:,1]], S=[s[:,2];s[:,3]], Group=rep(["Group1","Group2"],each=size(s,1)));

using Gadfly
p = plot(pr[,Time, x="Time", y="S",color="Group",
         Guide.ylabel("Survival probability"), Guide.title("Age 56"))        
draw(PNG("surv.png",7inch,7inch),p)

##################################################
### Cox regression with left truncation
##################################################
d = DataFrame(start=[1,2,5,2,1,7,3,4,8,8],
              stop=[2,3,6,7,8,9,9,9,14,17],
              event=[1,1,1,1,1,1,1,0,0,0],
              x=[1,0,0,1,0,1,1,1,0,0]);
d[:S] = Event([:start,:stop,:event],d);
mm = phreg(S~x,d)




