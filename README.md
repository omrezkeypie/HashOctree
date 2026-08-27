# About

BinaryOctree is an optimized octree that is both memory effiecent and cpu effiecent. 

**Note** The module has no update function for dynamic objects as the updating was slower than just recreating a new octree per frame.

Memory optimizations and data structure implementations heavily inspired by the following paper:
https://thomas.lewiner.org/pdfs/octree_cgf.pdf

# Performance

**All the benchmarks shown use 1000 objects**

Octree updating.
![image](https://github.com/user-attachments/assets/5696fb01-e564-4306-92fb-e120682807f4)

Octree querying.
![image](https://github.com/user-attachments/assets/35280f13-0c03-4f23-84f5-68528062539d)

**Note** The old octree module is a previous version of BinaryOctree before any optimizations.

Link to sleitnicks octree module:
https://github.com/Sleitnick/rbxts-octo-tree

# API

```lua
BinaryOctreeModule.new(Size : number, MaxDepth : number?,OffsetPosition : Vector3?) : BinaryOctree
```

Takes in a number for the size of the octree and an optional max subdivision depth (The top limit is 10 depth) and an optional OffsetPosition and returns the octree.

```lua
BinaryOctreeModule.InsertObjects(BinaryOctree : BinaryOctree,Objects : {Object})
```

Takes in a table of objects (anything with a Position value) and inserts them into the octree.

```lua
BinaryOctreeModule.RemoveObject(BinaryOctree : BinaryOctree,Object : Object)
```

Takes in an object and removes it from the octree.

```lua
BinaryOctreeModule.InsertObject(BinaryOctree : BinaryOctree,Object : Object)
```

Takes in an object and inserts it into the octree.

```lua
BinaryOctreeModule.QueryBox(BinaryOctree : BinaryOctree,Position : Vector3,Size : Vector3) : {Object}
```

Takes in the box's position and size and returns all the objects in the octree inside said box.

```lua
BinaryOctreeModule.QuerySphere(BinaryOctree : BinaryOctree,Position : Vector3,Radius : number) : {Object}
```

Takes in the sphere's position and radius and returns all the objects in the octree inside said sphere.

```lua
BinaryOctreeModule.VisualizeOctree(BinaryOctree : BinaryOctree)
```

Takes in an octree and visualizes it.
