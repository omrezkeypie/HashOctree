# About

HashOctree is an optimized hash octree that is both memory effiecent and cpu effiecent. 

# Performance

**All the benchmarks shown use 1k objects**

![image](https://github.com/omrezkeypie/HashOctree/assets/104690138/857c2655-69d5-43ed-8f1b-017678392ad3)
![image](https://github.com/omrezkeypie/HashOctree/assets/104690138/14c25158-0e93-4518-ba29-a04e44554de0)

# API

* HashOctreeModule.new(Size : number, MaxDepth : number?) : HashOctree

Takes in a number for the size of the octree and an optional max subdivision depth (The top limit is 10 depth) and returns the hash octree.

* HashOctreeModule.InsertObjects(HashOctree : HashOctree,Objects : {Object})

Takes in a table of objects (anything with a Position value) and inserts them into the hash octree.

* HashOctreeModule.QueryBox(HashOctree : HashOctree,Position : Vector3,Size : Vector3) : {Object}

Takes in the box's position and size and returns all the objects in the octree inside said box.

* HashOctreeModule.QuerySphere(HashOctree : HashOctree,Position : Vector3,Radius : number) : {Object}

Takes in the sphere's position and radius and returns all the objects in the octree inside said sphere.
