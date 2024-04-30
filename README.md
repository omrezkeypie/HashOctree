# About

HashOctree is an optimized octree that is both memory effiecent and cpu effiecent. 

**Note** The module has no update function for dynamic objects as the updating was slower than just recreating a new octree per frame.

# Performance

**All the benchmarks shown use 1000 objects**

Octree updating.
![image](https://github.com/omrezkeypie/HashOctree/assets/104690138/7fac122a-370d-496b-98e9-69b730b6665f)

Octree querying.
![image](https://github.com/omrezkeypie/HashOctree/assets/104690138/1c9aac34-b5aa-4f8a-9d6f-e2c2336d11bb)

# API

```lua
HashOctreeModule.new(Size : number, MaxDepth : number?,OffsetPosition : Vector3?) : HashOctree
```

Takes in a number for the size of the octree and an optional max subdivision depth (The top limit is 10 depth) and an optional OffsetPosition and returns the octree.

```lua
HashOctreeModule.InsertObjects(HashOctree : HashOctree,Objects : {Object})
```

Takes in a table of objects (anything with a Position value) and inserts them into the octree.

```lua
HashOctreeModule.RemoveObject(HashOctree : HashOctree,Object : Object)
```

Takes in an object and removes it from the octree.

```lua
HashOctreeModule.InsertObject(HashOctree : HashOctree,Object : Object)
```

Takes in an object and inserts it into the octree.

```lua
HashOctreeModule.QueryBox(HashOctree : HashOctree,Position : Vector3,Size : Vector3) : {Object}
```

Takes in the box's position and size and returns all the objects in the octree inside said box.

```lua
HashOctreeModule.QuerySphere(HashOctree : HashOctree,Position : Vector3,Radius : number) : {Object}
```

Takes in the sphere's position and radius and returns all the objects in the octree inside said sphere.

```lua
HashOctreeModule.VisualizeOctree(HashOctree : HashOctree)
```

Takes in an octree and visualizes it.
