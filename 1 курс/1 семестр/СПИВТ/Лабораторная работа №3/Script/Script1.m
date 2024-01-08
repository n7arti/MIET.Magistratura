obych=[3 4 3 3 4 3
	3 4 4 3 4 4
	5 2 5 5 3 5
	3 2 5 2 2 2];
vxod=obych(:,1:5);
vixod=obych(:,6);
prognoz=newff(minmax(vxod'),[5 1],{'logsig' 'purelin'});
prognoz=train(prognoz,vxod',vixod');

test=[ 2 4 3 3 3 3
	5 3 4 5 5 5
	2 4 4 5 4 4
	2 2 2 2 2 2];
test_vxod=test(:,1:5);
test_vixod=test(:,6);
sim(prognoz,test_vxod);
print(test_vixod);
