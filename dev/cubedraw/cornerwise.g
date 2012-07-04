#solving the cube cornerwise, first the position of the corner, then its orientation, for each corner
#very mechanistic way of understanding, but at least has a very clear pattern, symmetric groups with Z3s

cornerwise := [pocket_cube];

 Add(cornerwise, Stabilizer(cornerwise[1], [1,5,18], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[2], [1,5,18], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[3], [2,14,17], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[4], [2,14,17], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[5], [3,10,13], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[6], [3,10,13], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[7], [4,6,9], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[8], [4,6,9], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[9], [7,12,21], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[10], [7,12,21], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[11], [11,16,22], OnSets));   
 Add(cornerwise, Stabilizer(cornerwise[12], [11,16,22], OnTuples));   
 
Add(cornerwise, Stabilizer(cornerwise[13], [15,20,23], OnSets));   
#this one is already the trivial group
 Add(cornerwise, Stabilizer(cornerwise[14], [15,20,23], OnTuples));   

#Add(cornerwise, Stabilizer(cornerwise[15], [8,19,24], OnSets));   
# Add(cornerwise, Stabilizer(cornerwise[16], [8,19,24], OnTuples));   
 
#Add(cornerwise, Group(()) );

