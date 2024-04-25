--!optimize 2
--!native

type Object = {
	Position: Vector3
}

export type HashOctree = {
	MaxDepth: number,
	Size: number,
	Nodes: {{Object}},
	StartPosition: Vector3,
}

type Module = {
	new: (Size: number, MaxDepth: number,StartPosition: Vector3) -> HashOctree,
	InsertObjects: (HashOctree: HashOctree, Objects: { Object }) -> (),
	QueryBox: (HashOctree: HashOctree, Position: Vector3, Size: Vector3) -> {Object},
	QuerySphere: (HashOctree : HashOctree,Position : Vector3,Radius : number) -> {Object},
	VisualizeOctree: (HashOctree : HashOctree) -> ()
}

local SuffixToOrder = {
	Vector3.new(-1,-1,-1),--0
	Vector3.new(-1,-1,1), --1
	Vector3.new(-1,1,-1), --2
	Vector3.new(-1,1,1),  --3
	Vector3.new(1,-1,-1), --4
	Vector3.new(1,-1,1),  --5
	Vector3.new(1,1,-1),  --6
	Vector3.new(1,1,1),   --7
}

local Dot = Vector3.new().Dot
local SubdivideThreshold = 10

local HashOctreeModule: Module = {} :: Module

local function IsPositionInBox(Position: Vector3, MinBounds : Vector3, MaxBounds : Vector3) : boolean
	return Position.X >= MinBounds.X and Position.X <= MaxBounds.X
		and Position.Y >= MinBounds.Y and Position.Y <= MaxBounds.Y
		and Position.Z >= MinBounds.Z and Position.Z <= MaxBounds.Z
end

local function DetectBoxOverlap(MinBounds1,MaxBounds1,MinBounds2,MaxBounds2) : boolean	
	return MinBounds1.X < MaxBounds2.X and MaxBounds1.X > MinBounds2.X and 
		MinBounds1.Y < MaxBounds2.Y and MaxBounds1.Y > MinBounds2.Y and 
		MinBounds1.Z < MaxBounds2.Z and MaxBounds1.Z > MinBounds2.Z
end

local function MagnitudeSquared(Position : Vector3) : number
	return (Position.X * Position.X) + (Position.Y * Position.Y)  + (Position.Z * Position.Z)
end

local function DetectBoxAndSphereOverlap(MinBounds : Vector3,MaxBounds : Vector3,SphereCenter : Vector3,RadiusSquared : number) : boolean
	local ClosestPoint = SphereCenter:Max(MinBounds):Min(MaxBounds)
	local Distance = MagnitudeSquared(SphereCenter - ClosestPoint)

	return Distance <= RadiusSquared
end

local function Subdivide(HashOctree : HashOctree,Node : number)
	local ShiftedNode = Node * 8

	for i = 0,7 do
		HashOctree.Nodes[ShiftedNode + i] = {}
	end
end

local function GetNodePositionAndSize(HashOctree : HashOctree,Node : number) : (Vector3,Vector3)
	local NumberLength = math.max(32-bit32.countlz(Node), 0) - 1
	local Position = HashOctree.StartPosition
	local HalfSize = HashOctree.Size / 4
	HalfSize = Vector3.new(HalfSize,HalfSize,HalfSize)

	for Index = 1,NumberLength,3 do
		local Suffix = bit32.extract(Node,NumberLength - Index - 2,3)

		Position = Position + (HalfSize * SuffixToOrder[Suffix + 1])

		Index += 3
		HalfSize = HalfSize / 2
	end

	return HashOctree.StartPosition + Position,HalfSize * 2
end

local function ReassignObjects(HashOctree : HashOctree,Node : number,NodePosition : Vector3)
	Subdivide(HashOctree,Node)

	local NodeTable = HashOctree.Nodes[Node]
	local ShiftedNode = Node * 8

	for i = 1,#NodeTable do
		local Object = NodeTable[i]
		local Position = Object.Position
		local Suffix = 0

		if Position.X > NodePosition.X then
			Suffix += 4
		end

		if Position.Y > NodePosition.Y then
			Suffix += 2
		end

		if Position.Z > NodePosition.Z then
			Suffix += 1
		end

		table.insert(HashOctree.Nodes[ShiftedNode + Suffix],Object)
	end

	table.clear(NodeTable)
end

function HashOctreeModule.new(Size : number,MaxDepth : number,StartPosition : Vector3) : HashOctree
	local newHashOctree = {
		MaxDepth = MaxDepth,
		Size = Size,
		Nodes = {{}},
		StartPosition = StartPosition,
	}

	return newHashOctree
end

function HashOctreeModule.InsertObjects(HashOctree : HashOctree,Objects : {{Position : Vector3}}) --fix
	local QuarterSize = HashOctree.Size / 4
	local Size = Vector3.new(QuarterSize,QuarterSize,QuarterSize)
	local Depth = 0
	local NodePosition = HashOctree.StartPosition
	local ChosenNode = 1
	local MaxDepth = HashOctree.MaxDepth
	
	for _,Object in Objects do
		local Position = Object.Position

		while true do
			local Suffix = 0

			if Position.X > NodePosition.X then
				Suffix += 4
			end

			if Position.Y > NodePosition.Y then
				Suffix += 2
			end

			if Position.Z > NodePosition.Z then
				Suffix += 1
			end
						
			local NextNode = ChosenNode * 8 + Suffix
						
			if HashOctree.Nodes[NextNode] == nil then
				local ChosenNodeTable = HashOctree.Nodes[ChosenNode]

				table.insert(ChosenNodeTable,Object)

				if #ChosenNodeTable > SubdivideThreshold and Depth < MaxDepth then
					ReassignObjects(HashOctree,ChosenNode,NodePosition)
				end

				break
			end
			
			NodePosition = NodePosition + (Size * SuffixToOrder[Suffix + 1])
			
			Size = Size / 2
			ChosenNode = NextNode
			Depth = Depth + 1
		end

		Size = QuarterSize
		Depth = 0
		NodePosition = HashOctree.StartPosition
		ChosenNode = 1
	end
end

function HashOctreeModule.QueryBox(HashOctree : HashOctree,Position : Vector3,Size : Vector3) : {Object}
	local MinBound = Position - (Size / 2)
	local MaxBound = Position + (Size / 2)
	local ChosenNodes = {1}
	local Nodes = HashOctree.Nodes
	local GottenObjects = {}

	while #ChosenNodes > 0 do
		local Node = table.remove(ChosenNodes)
		local NodeTable = Nodes[Node]
		local NodePosition,NodeSize = GetNodePositionAndSize(HashOctree,Node)
		if not DetectBoxOverlap(MinBound,MaxBound,NodePosition - NodeSize,NodePosition + NodeSize) then continue end
				
		local ShifterNumber = Node * 8

		for HashSuffix = 0,7 do
			local NextNode = ShifterNumber + HashSuffix

			if Nodes[NextNode] == nil then
				if #NodeTable > 0 then
					for _,Object in NodeTable do
						if not IsPositionInBox(Object.Position,MinBound,MaxBound) then continue end

						table.insert(GottenObjects,Object)
					end
				end				

				break
			end

			table.insert(ChosenNodes,NextNode)
		end
	end

	return GottenObjects
end

function HashOctreeModule.QuerySphere(HashOctree : HashOctree,Position : Vector3,Radius : number) : {Object}
	local ChosenNodes = {1}
	local Nodes = HashOctree.Nodes
	local GottenObjects = {}
	Radius *= Radius
	
	while #ChosenNodes > 0 do
		local Node = table.remove(ChosenNodes)
		local NodeTable = Nodes[Node]
		local NodePosition,NodeSize = GetNodePositionAndSize(HashOctree,Node)
		
		if not DetectBoxAndSphereOverlap(NodePosition - NodeSize,NodePosition + NodeSize,Position,Radius) then continue end
				
		local ShifterNumber = Node * 8
				
		for HashSuffix = 0,7 do
			local NextNode = ShifterNumber + HashSuffix
			
			
			if Nodes[NextNode] == nil then
				if #NodeTable > 0 then
					for _,Object in NodeTable do
						local SubtractedPositions = Position - Object.Position
						
						if Dot(SubtractedPositions,SubtractedPositions,SubtractedPositions) <= Radius then 
							table.insert(GottenObjects,Object)
						end
					end
				end				
				
				break
			end
			
			table.insert(ChosenNodes,NextNode)
		end
	end

	return GottenObjects
end

local function MakeVisualisePart(Size, MaxBound, Suffix)
	local MiddlePosition = MaxBound

	local VisualizePart = Instance.new("Part")
	VisualizePart.Parent = workspace
	VisualizePart.Position = MiddlePosition
	VisualizePart.Size = Vector3.new(Size,Size,Size)
	VisualizePart.Anchored = true
	VisualizePart.Transparency = 1
	VisualizePart.Name = Suffix

	local SelectionBox = Instance.new("SelectionBox")
	SelectionBox.Parent = VisualizePart
	SelectionBox.Adornee = VisualizePart
end

function HashOctreeModule.VisualizeOctree(HashOctree : HashOctree)
	local UnvisualisedNodes = {{1,Size = HashOctree.Size}}

	while #UnvisualisedNodes > 0 do
		local Node = table.remove(UnvisualisedNodes)
		local NodePosition = GetNodePositionAndSize(HashOctree,Node[1])

		MakeVisualisePart(Node.Size,NodePosition,Node[1])

		for i = 0,7 do
			local HashIndex = Node[1] * 8 + i

			if HashOctree.Nodes[HashIndex] == nil then continue end

			table.insert(UnvisualisedNodes,{HashIndex, Size = Node.Size / 2})
		end
	end
end

return HashOctreeModule
