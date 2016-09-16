
myDict=Dict{AbstractString, Int}()
myDict["Hi"] = 37
myDict["ho"] = 23
print(barplot(myDict))
myPlot=barplot(["Please","don't","crash","my","friend"], [10,24,30,13,7])
barplot!(myPlot, "and", 5)
print(myPlot)
barplot!(myPlot, ["just", "dont", "!"], [2, 49, 15])
@test_throws DimensionMismatch barplot!(myPlot, ["just", "dont", "!"], [2, 49])
print(myPlot)
print(barplot([5,4,3,2,1], [10,24,30,13,7]))
print(barplot([5,4,3,2,1], [0,0,0,0,0]))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13]))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:none))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:solid))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:dashed))
print(barplot([:Please,:dont,:crash,:dude], [1,1,1,1000000], color=:red))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10, margin=0))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10, margin=20))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=1))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,0], width=100))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,0], title="C'mon man, keep on going!"))
print(barplot([:Please,:dont,:crash,:dude], [10,24,1,0], title="No lab", labels = false))
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,-1,1,1])
@test_throws DimensionMismatch barplot([:Please,:dont,:crash,:dude], [10,1,1])
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,24,1,0], margin=-1)
print(barplot([:Please,:dont,:crash,:dude], [1.,.7,.1,.6], width=10))

x = [-1.,2, 3, 7]
y = [1.,2, 9, 4]
print(lineplot(x, y))
x = [1.,2, 3, 7]
y = [1.,2, -1, 4]
print(lineplot(x, y))
x = [1,2, 3, 7]
y = [1,2, -1, 4]
@test_throws DimensionMismatch barplot(x, [10,1,1])
@test_throws DimensionMismatch lineplot(x, [10,1,1])
print(lineplot(1:10, 1:10))
print(lineplot(x, y))
@test_throws ArgumentError lineplot(x, y, margin=-1)
print(lineplot(x, y, width=50, height=10))
print(lineplot(x, y, width=100, height=10))
print(lineplot(x, y, width=90, height=40))
print(lineplot(x, y, width=50, height=5, margin = 0))
print(lineplot(x, y, width=10, height=20, margin = 20))
print(lineplot(x, y, width=5, height=5))
print(lineplot(x, y, width=50, height=10, title="Hello world", border=:none))
print(lineplot(x, y, width=50, height=10, title="Hello world", border=:dashed))
print(lineplot(x, y, width=50, height=10, title="Hello world", border=:solid))
print(lineplot(x, y, width=50, height=10, title="Hello world", border=:bold))
print(lineplot(x, y, width=50, height=10, title="Hello world", border=:dotted))
print(lineplot(x, y, width=50, height=10, border=:dotted))
x = [-1.,2, 3, 700000]
y = [1.,2, 9, 4000000]
print(lineplot(x, y))
print(lineplot(x, y, width=5, height=5))
@test_throws ArgumentError scatterplot(x, y, margin=-1)
x = [1.,2, 3, 7]
y = [1.,2, -1, 4]
print(scatterplot(x, y))
x = [1,2, 3, 7]
y = [1,2, -1, 4]
print(scatterplot(x, y))
x = [1.,2, 3, 7]
y = [1,2, -1, 4]
myplot = scatterplot(x)
scatterplot!(myplot, y)
print(myplot)
myplot = scatterplot(x, y)
scatterplot!(myplot, x, y)
print(myplot)
print(scatterplot(x*.001+1.1, y))
print(lineplot(x, y*20+1000))
print(lineplot(x+1000, -y))

myplot = lineplot(collect(1:10))
lineplot!(myplot, collect(1:10))
myplot = lineplot(1:10, collect(1:10))
myplot = lineplot(collect(1:10), 1:10)
myplot = lineplot(1:10, 1:10)
lineplot!(myplot, collect(1:10), 1:10)
lineplot!(myplot, 1:10, collect(1:10))
lineplot!(myplot, 1:10, 1:10)
print(myplot)
print(lineplot([sin, cos]))
print(lineplot(sin))
print(lineplot(sin, 1:.5:10))
print(lineplot(sin, 1:.5:10, labels = false))
print(lineplot(sin, [1., 1.5, 2, 2.5, 3, 3.5, 4]))
print(lineplot(sin, [1, 2, 3, 4]))
print(lineplot(sin, 1, 4))
print(lineplot([sin, cos], 1, 4))
print(lineplot([sin, cos], 1, 4, canvas = BlockCanvas))
print(lineplot([sin, cos], 1, 4, canvas = AsciiCanvas))
print(lineplot([sin, cos], 1, 4, canvas = DotCanvas))

x = [1,2, 4, 7, 8]
y = [1,3, 4, 2, 7]
print(stairs(x, y))
y = [1,3, 4, 2, 7000]
print(stairs(x, y))

#x=rand(100000)
#y=rand(100000)
#@time stairs(x, y)
#@time scatterplot(x, y)
#@time lineplot(x, y)

canvas = BrailleCanvas(40, 10, # number of columns and rows
                       origin_x = 0., origin_y = 0., # position in virtual space
                       width = 1., height = 1.) # size of the virtual space
lines!(canvas, 0., 0., 1., 1., :blue)
points!(canvas, rand(50), rand(50), :red)
points!(canvas, rand(50), rand(50), color = :red)
lines!(canvas, 0., 1., .5, 0., :yellow)
points!(canvas, 1., 1.)
lines!(canvas, [1.,2], [2.,1])


lines!(canvas, 0., 0., .9, 9999., :yellow)
lines!(canvas, 0., 0., 1., 1., color = :blue)
lines!(canvas, .3, .7, 1., 0., :red)
lines!(canvas, 0., 2., .5, 0., :yellow)
print(canvas)
show(STDOUT, canvas)
myPlot = Plot(canvas, title="testtitle")
annotate!(myPlot, :l, ":l auto", :red)
for i in 1:10
  annotate!(myPlot, :l, i, "$i", color=:green)
  annotate!(myPlot, :r, i, "$i", :yellow)
end
print(scatterplot([1],[1]))
@test_throws ArgumentError annotate!(myPlot, :bl, 5, ":l  5", :red)
@test_throws ArgumentError annotate!(myPlot, :d, ":l auto", :red)
annotate!(myPlot, :l, 5, ":l  5", :red)
annotate!(myPlot, :r, 5, "5  :r", color=:red)
annotate!(myPlot, :bl, ":bl", :blue)
annotate!(myPlot, :b, ":b", :green)
annotate!(myPlot, :br, ":br", :magenta)
annotate!(myPlot, :tl, ":tl", :cyan)
annotate!(myPlot, :tr, ":tr")
annotate!(myPlot, :t, ":t", :yellow)
lines!(myPlot, 0., 1., 1., 0., :blue)
lines!(myPlot, 0., 1., 1., 0., color=:blue)
points!(myPlot, rand(10), rand(10))
pixel!(myPlot, 1, 1)
pixel!(myPlot, 1, 1, :green)
pixel!(myPlot, 1, 1, color=:green)

ttl = "title!(plot, text)"
title!(myPlot, ttl)
@test title(myPlot) == ttl

xlab = "xlabel!(plot, text)"
xlabel!(myPlot, xlab)
@test xlabel(myPlot) == xlab

ylab = "ylabel!(plot, text)"
ylabel!(myPlot, ylab)
@test ylabel(myPlot) == ylab

show(STDOUT, myPlot)

x = [1,2, 4, 7, 8]
y = [1,3, 4, 2, 7]
myPlot = stairs(x, y, style=:pre)
print(myPlot)
myPlot = stairs(x, y)
print(myPlot)
stairs!(myPlot, x- .2, y + 1.5)
print(myPlot)

@test_throws ArgumentError lineplot(sin, 1:.5:12, color=:blue, ylim=[-1.,1., 2.])
myPlot = lineplot(sin, 1:.5:12, color=:blue, ylim=[-1.,1.])
print(myPlot)
lineplot!(myPlot, cos, 1:.5:10, color=:red)
print(myPlot)
myPlot = lineplot(sin, 1:.5:12, color=:blue, ylim=[-1,1], xlim=[-1.,5.])
print(myPlot)

x = [1,2, 4, 7, 8]
y = [1,3, 4, 2, 7]
myPlot = stairs(x, y, width = 10, padding = 3)
annotate!(myPlot, :tl, "Hello")
annotate!(myPlot, :t, "how are")
annotate!(myPlot, :tr, "you?")
annotate!(myPlot, :bl, "Hello")
annotate!(myPlot, :b, "how are")
annotate!(myPlot, :br, "you?")
print(myPlot)
lineplot!(myPlot, 1, .5)
print(myPlot)

print(histogram(randn(1000), bins=10, title="Histogram"))
print(histogram(rand(1000), bins=5, title="Histogram"))
print(histogram(rand(1000), title="Histogram"))
print(histogram(rand(1000)*0.001, title="Histogram"))
print(histogram(rand(800) * 10000 - 115000, title="Histogram"))

print(spy(sprand(10,10,.15)))
print(spy(sprand(5,10,.15), width = 5))
print(spy(sprand(5,5,.15), height = 5))
print(spy(sprand(10,10,.15), color=:green))
print(spy(sprand(2000,200,.01), color=:green))
print(spy(sprand(200,2000,.01), color=:green))
print(spy(sprand(1000,10,.01), color=:green))
print(spy(sprand(10,1000,.01), color=:green))
print(spy(full(sprand(10,100,.15))))

x1, y1 = rand(500)*10, rand(500)*10
x2, y2 = rand(1000)*5+1, rand(1000)*5+1
canvas = BrailleCanvas(40, 10,
                       origin_x = 0., origin_y = 0.,
                       width = 10., height = 10.)
points!(canvas, x1, y1, color = :red)
points!(canvas, x1, y1, :red)
points!(canvas, x2, y2, :blue)
show(canvas)
myPlot = densityplot(x1,y1, color = :red)
points!(myPlot, x2, y2, :blue)
show(myPlot)
myPlot = densityplot(randn(1000), randn(1000), color = :blue)
densityplot!(myPlot, randn(1000) + 2, randn(1000) + 2, color = :red)
print(myPlot)

x = rand(100); y = rand(100)
print(scatterplot(x, y, xlim=[minimum(x), maximum(x)], ylim=[minimum(y), maximum(y)]))

x = rand(100) * 1000; y = rand(100) * 1000
print(scatterplot(x, y, xlim=[minimum(x), maximum(x)], ylim=[minimum(y), maximum(y)]))

d = collect(Date(2000,1,1):Date(2000,1,31))
v = collect(linspace(20, 200, 31))
print(lineplot(d,v, height = 5))

miny = -1.2796649117521434e218
maxy = -miny
println(scatterplot([1],[miny],xlim=[1,1],ylim=[miny,maxy],title="Don't you crash on me!"))
