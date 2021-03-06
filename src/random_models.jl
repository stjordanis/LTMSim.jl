"""
    Models for random hypergraphs
        * random model
        * k-uniform model
        * d-uniform model
        * preferential-attachment
"""


"""
    randomH(nVertices, nEdges)

Generate a *random* hypergraph without any structural constraints.

**The Algorithm**
Given two integer parameters *nVertices* and *nEdges* (the number of nodes and hyperedges, respectively),
the algorithm computes - for each hyperedge *he={1,...,m}* -
a random number *s ϵ [1, n]* (i.e. the hyperedge size).
Then, the algorithm selects uniformly at random *s* vertices from *V* to be added in *he*.
"""
function randomH(nVertices, nEdges)
    mx = Matrix{Union{Nothing,Bool}}(nothing, nVertices,nEdges)
    for e in 1:size(mx,2)
        nv = rand(1:size(mx,1))
        mx[sample(1:size(mx,1), nv;replace=false), e] .= true
    end

    h = Hypergraph(mx)
    if all(length.(h.v2he) .> 0)
        return h
    else
        return randomH(nVertices, nEdges)
    end
end


"""
    randomHkuniform(nVertices, nEdges, k)

Generates a *k*-uniform hypergraph, i.e. an hypergraph where each hyperedge has size *k*.

**The Algorithm**
The algorithm proceeds as the *randomH*, forcing the size of each hyperedge equal to *k*.
"""
function randomHkuniform(nVertices, nEdges, k)
    mx = Matrix{Union{Nothing,Bool}}(nothing, nVertices,nEdges)
    for e in 1:size(mx,2)
        nv = k#rand(1:size(mx,1))#rand(2:5)
        mx[sample(1:size(mx,1), nv;replace=false), e] .= true
    end

    h = Hypergraph(mx)
    if all(length.(h.v2he) .> 0)
        return h
    else
        return randomH(nVertices, nEdges)
    end
end


"""
    randomHduniform(nVertices, nEdges, d)

Generates a *d*-uniform hypergraph, where each node has degree *d*.

**The Algorithm**
The algorithm exploits the *k*-uniform approach described for the *randomHkuniform* method
to build a *d*-uniform hypergraph *H* having *nVertices* nodes and *nEdges* edges.
It returns the hypergraph H⃰ dual of *H*.
"""
function randomHduniform(nVertices, nEdges, d)
    mx = Matrix{Union{Nothing,Bool}}(nothing, nVertices,nEdges)

    for v in 1:size(mx,1)
        ne = d
        mx[v, sample(1:size(mx,2), ne;replace=false)] .= true
    end

    h = Hypergraph(mx)
    if all(length.(h.v2he) .> 0)
        return h
    else
        return randomH(nVertices, nEdges)
    end
end


"""
    randomHpreferential(nVertices, p)

Generate a hypergraph with a preferential attachment rule between nodes, as presented in
*Avin, C., Lotker, Z., and Peleg, D.Random preferential attachment hyper-graphs.Computer Science 23(2015).*

**The Algorithm**
The algorithm starts with a random graph with 5 nodes and 5 edges.
It iteratively adds a node or a edge, according to a given parameter *p*,
which defines the probability of creating a new node or a new hyperedge.

More in detail, the connections with the new node/hyperedge are generated according to
a preferential attachment policy.
"""
function randomHpreferential(nVertices, p)
    H₀ = randomH(10,10)
    H = H₀
    while nhv(H) < nVertices
        r = rand()
        y = rand(1:nhv(H))
        Y = Dict{Int,Bool}()
        if r < p
            #add a vertex
            v = SimpleHypergraphs.add_vertex!(H)
            push!(Y,v=>true)
            for v in nextNodes(H,y-1)
                push!(Y,v)
            end
        else
            for v in nextNodes(H,y)
                push!(Y,v)
            end
        end
            #add a hyperedge
            SimpleHypergraphs.add_hyperedge!(H, vertices=Y)
    end
    H
end


function nextNodes(h,size)
    nodes = Dict{Int, Bool}()

    ids = collect(1:nhv(h))
    degrees = length.(h.v2he)

    for s=1:size
        psum = collect(1:length(ids))

        psum[1] = degrees[ids[1]]
        for j=2:length(ids)
            psum[j] = psum[j-1] + degrees[ids[j]]
        end

        number = rand(1:psum[length(psum)])
        bucket = -1
        index=1
        for i=1:length(psum)
            if number <= psum[i]
                bucket = ids[i]
                index = i
                break
            end
        end

        push!(nodes, bucket=>true)
        deleteat!(ids, index)
    end
    nodes
end
