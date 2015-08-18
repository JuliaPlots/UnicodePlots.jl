
barplot(["Please","don't","crash","my","friend"], [10,24,30,13,7])
barplot([5,4,3,2,1], [10,24,30,13,7])
barplot([5,4,3,2,1], [0,0,0,0,0])
barplot([:Please,:dont,:crash,:dude], [10,24,1,13])
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:none)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:solid)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], border=:dashed)
barplot([:Please,:dont,:crash,:dude], [1,1,1,1000000], color=:red)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10, margin=0)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=10, margin=20)
barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=1)
barplot([:Please,:dont,:crash,:dude], [10,24,1,0], width=100)
barplot([:Please,:dont,:crash,:dude], [10,24,1,0], title="C'mon man, keep on going!")
barplot([:Please,:dont,:crash,:dude], [10,24,1,0], title="No lab", labels = false)
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=0)
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,24,1,13], width=-1)
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,-1,1,1])
@test_throws DimensionMismatch barplot([:Please,:dont,:crash,:dude], [10,1,1])
@test_throws ArgumentError barplot([:Please,:dont,:crash,:dude], [10,24,1,0], margin=-1)
barplot([:Please,:dont,:crash,:dude], [1.,.7,.1,.6], width=10)

testD = if VERSION < v"0.4-"
  ["Something"=>10, "other"=>32, "than"=>1, "before"=>20]
else
  Dict("Something"=>10, "other"=>32, "than"=>1, "before"=>20)
end
barplot(testD)
barplot(testD,width=70)


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
print(scatterplot(x, y))
print(lineplot(x, y))

print(lineplot(sin, 1:.5:10))
print(lineplot(sin, 1:.5:10, labels = false))
print(lineplot(sin, [1., 1.5, 2, 2.5, 3, 3.5, 4]))
print(lineplot(sin, [1, 2, 3, 4]))

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
                       plotOriginX = 0., plotOriginY = 0., # position in virtual space
                       plotWidth = 1., plotHeight = 1.) # size of the virtual space
drawLine!(canvas, 0., 0., 1., 1., :blue)
setPoint!(canvas, rand(50), rand(50), :red)
setPoint!(canvas, rand(50), rand(50), color = :red)
drawLine!(canvas, 0., 1., .5, 0., :yellow)

drawLine!(canvas, 0., 0., .9, 9999., :yellow)
drawLine!(canvas, 0., 0., 1., 1., color = :blue)
drawLine!(canvas, .3, .7, 1., 0., :red)
drawLine!(canvas, 0., 2., .5, 0., :yellow)
show(STDOUT, canvas)
myPlot = Plot(canvas, title="testtitle")
for i in 1:10
  annotate!(myPlot, :l, i, "$i")
  annotate!(myPlot, :r, i, "$i")
end
annotate!(myPlot, :l, 5, ":l  5")
annotate!(myPlot, :r, 5, "5  :r")
annotate!(myPlot, :bl, ":bl")
annotate!(myPlot, :br, ":br")
annotate!(myPlot, :tl, ":tl")
annotate!(myPlot, :tr, ":tr")
drawLine!(myPlot, 0., 1., 1., 0., :blue)
setPoint!(myPlot, rand(10), rand(10))
setPixel!(myPlot, 1, 1)
setPixel!(myPlot, 1, 1, :green)
setPixel!(myPlot, 1, 1, color=:green)
setTitle!(myPlot, "setTitle!(plot, title)")
show(STDOUT, myPlot)

x = [1,2, 4, 7, 8]
y = [1,3, 4, 2, 7]
myPlot = stairs(x, y)
print(myPlot)
stairs!(myPlot, x- .2, y + 1.5)
print(myPlot)

myPlot = lineplot(sin, 1:.5:10, color=:blue, labels = false)
print(myPlot)
lineplot!(myPlot, cos, 1:.5:10, color=:red)
print(myPlot)
