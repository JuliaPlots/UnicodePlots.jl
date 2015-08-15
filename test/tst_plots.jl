
barplot(["Please","don't","crash","my","friend"], [10,24,30,13,7])
barplot([5,4,3,2,1], [10,24,30,13,7])
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
lineplot(x, y)
x = [1.,2, 3, 7]
y = [1.,2, -1, 4]
lineplot(x, y)
x = [1,2, 3, 7]
y = [1,2, -1, 4]
lineplot(x, y)
lineplot(x, y, width=50, height=10)
lineplot(x, y, width=100, height=10)
lineplot(x, y, width=90, height=40)
lineplot(x, y, width=50, height=5, margin = 0)
lineplot(x, y, width=10, height=20, margin = 20)
lineplot(x, y, width=5, height=5)
lineplot(x, y, width=50, height=10, title="Hello world", border=:none)
lineplot(x, y, width=50, height=10, title="Hello world", border=:dashed)
lineplot(x, y, width=50, height=10, title="Hello world", border=:solid)
lineplot(x, y, width=50, height=10, title="Hello world", border=:bold)
lineplot(x, y, width=50, height=10, title="Hello world", border=:dotted)
lineplot(x, y, width=50, height=10, border=:dotted)
x = [-1.,2, 3, 700000]
y = [1.,2, 9, 4000000]
lineplot(x, y)
lineplot(x, y, width=5, height=5)
x = [1.,2, 3, 7]
y = [1.,2, -1, 4]
scatterplot(x, y)
x = [1,2, 3, 7]
y = [1,2, -1, 4]
scatterplot(x, y)
x = [1.,2, 3, 7]
y = [1,2, -1, 4]
scatterplot(x, y)
lineplot(x, y)

lineplot(sin, 1:.5:10)
lineplot(sin, 1:.5:10, labels = false)
lineplot(sin, [1., 1.5, 2, 2.5, 3, 3.5, 4])
lineplot(sin, [1, 2, 3, 4])
