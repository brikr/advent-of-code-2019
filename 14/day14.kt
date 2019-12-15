import java.io.File
import kotlin.collections.HashMap
import kotlin.math.ceil

fun main() {
  val stoichMap = HashMap<String, StoichRelation>()
  File("input.txt").forEachLine { line ->
    val (left, right) = line.split(" => ")

    val inMats = left.split(", ").map<String, Materials> { mat ->
      val (amt, name) = mat.split(" ")
      Materials(name, amt.toLong())
    }

    val (amt, name) = right.split(" ")
    val outMats = Materials(name, amt.toLong())

    stoichMap[name] = StoichRelation(inMats, outMats)
  }

  val part1 = oreNeededForNFuel(stoichMap, 1)
  println("Part 1: $part1")

  // Binary search until we find the fuel amount that requires the most ore but is still less than 1 trillion
  val target = 1000000000000
  var hi: Long = target
  var lo: Long = 2
  while (hi >= lo) {
    val guess = lo + (hi - lo) / 2
    val result = oreNeededForNFuel(stoichMap, guess)
    if (result > target) {
      val oneLower = oreNeededForNFuel(stoichMap, guess - 1)
      if (oneLower < target) {
        println("Part 2: $guess")
        break
      }
      hi = guess - 1
    } else if (result < target) {
      val oneHigher = oreNeededForNFuel(stoichMap, guess + 1)
      if (oneHigher > target) {
        println("Part 2: $guess")
        break
      }
      lo = guess + 1
    } else {
      println("Part 2: $guess")
      break
    }
  }
}

fun oreNeededForNFuel(stoichMap: Map<String, StoichRelation>, n: Long, verbose: Boolean = false): Long {
  val matsNeeded = stoichMap["FUEL"]!!.inMats.map { mats ->
    mats.name to mats.amt * n
  }.toMap().toMutableMap().withDefault { 0 }
  val leftovers = HashMap<String, Long>().withDefault { 0 }
  while (true) {
    if (verbose) {
      println("Mats Needed: $matsNeeded; Leftovers: $leftovers")
    }
    // Pull the first inMat that we can expand upon
    val currMatName = matsNeeded.keys.find { it != "ORE" }
    if (currMatName == null) {
      val oreNeeded = matsNeeded["ORE"]!!
      return oreNeeded
    }
    val currMatAmt = matsNeeded.remove(currMatName)!!
    val currMatLeftoversAmt = leftovers.getValue(currMatName)
    // Find out how to make that mat and how many times we'll needed to perform that recipe, considering leftovers
    val stoichForCurr = stoichMap[currMatName]!!
    var timesNeeded = ceil((currMatAmt.toDouble() / stoichForCurr.outMats.amt.toDouble())).toLong()
    val timesNeededUsingLeftovers =
      ceil(((currMatAmt - currMatLeftoversAmt).toDouble() / stoichForCurr.outMats.amt.toDouble())).toLong()

    if (timesNeededUsingLeftovers < timesNeeded) {
      // We can use leftovers. Decrement leftovers count and update timesNeeded
      val usedFromLeftovers = currMatAmt - stoichForCurr.outMats.amt * timesNeededUsingLeftovers
      leftovers[currMatName] = currMatLeftoversAmt - usedFromLeftovers
      timesNeeded = timesNeededUsingLeftovers
    }

    // Update leftovers
    val leftoverAmt = (stoichForCurr.outMats.amt * timesNeeded) - currMatAmt
    if (leftoverAmt > 0) {
      val amt = leftovers.getValue(currMatName)
      leftovers[currMatName] = amt + leftoverAmt
    }

    if (verbose) {
      println(
        "Making ${Materials(
          currMatName,
          currMatAmt
        )}: Performed $stoichForCurr $timesNeeded times with $leftoverAmt leftover"
      )
    }

    // Add the subcomponents to matsNeeded multiplied by timesNeeded, and keep track of our leftovers
    stoichForCurr.inMats.forEach { mat ->
      val amt = matsNeeded.getValue(mat.name)
      matsNeeded[mat.name] = amt + mat.amt * timesNeeded
    }
  }
}

data class StoichRelation(val inMats: List<Materials>, val outMats: Materials)
data class Materials(val name: String, val amt: Long) {
  override fun toString() : String = "(${amt}x $name)"
}
