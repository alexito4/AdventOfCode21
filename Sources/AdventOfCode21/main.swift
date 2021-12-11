print("START")

do {
    let day = day11
    print("RUN")
//    try run(day.part1, .real)//.debug()
//    try run(day.part2, .example).debug()
    try run(day)
} catch {}

/*
 swift run -c release AdventOfCode21 run --disable-cutoff true --max-size 150 --cycles 3 array
 swift run -c release AdventOfCode21 render array chart.png --max-size 150
 open chart.png
 */
// day6Benchmark()

// let fish = [3,4,3,1,2]
// _ = simulateOneRef(fish, for: 500)
