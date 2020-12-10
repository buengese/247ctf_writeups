### The Secret Lock (moderate)

Are we back to web challenges? This time it's JavaScript we're dealing with but just because it's easy to read doesn't mean that this challenge is easy.

We are given a website that implements a combination lock with lots of digets. The relevant function is this:
```
onChange() {
    this.code = this.getCode();
    this.flag = this.checkFlag(this.code);
	this.dom.status.textContent = this.flag;
}

getCode() {
	let flag = {};
    for (let i = 0, len = this.dom.rows.length; i < len; i++) {
        flag[i] = this.dom.rows[i].querySelector('.is-selected .text').textContent;
    }
    return flag;
}

checkFlag(flag){
    let result = "LOCKED"
	this.dom.lock.classList.remove('verified');
    if (Object.keys(flag).length == 40 && ((flag[37] - flag[37]) * flag[15] == 0) && ((flag[3] + flag[31]) ^ (flag[29] + flag[8]) == 234) && ((flag[32] - flag[12]) * flag[9] == -2332) && ((flag[24] - flag[27] + flag[13]) ^ flag[6] == 114) && ((flag[38] - flag[15]) * flag[33] == 800) && ((flag[34] - flag[21]) * flag[26] == 98) && ((flag[29] + flag[0]) ^ (flag[8] + flag[38]) == 248) && ((flag[21] * flag[18]) ^ (flag[7] - flag[15]) == 2694) && ((flag[28] * flag[23]) ^ (flag[19] - flag[5]) == -9813) && ((flag[34] + flag[30]) ^ (flag[37] + flag[6]) == 72) && ((flag[23] - flag[22]) * flag[12] == 4950) && ((flag[9] * flag[28]) ^ (flag[20] - flag[11]) == 5143) && ((flag[2] * flag[22]) ^ (flag[37] - flag[0]) == 2759) && ((flag[26] - flag[12]) * flag[3] == -3350) && ((flag[35] * flag[0]) ^ (flag[23] - flag[21]) == 2698) && ((flag[20] + flag[31]) ^ (flag[5] + flag[10]) == 22) && ((flag[31] * flag[19]) ^ (flag[1] - flag[2]) == -2655) && ((flag[38] - flag[14]) * flag[18] == 55) && ((flag[29] - flag[19] + flag[10]) ^ flag[2] == 93) && ((flag[13] - flag[25] + flag[30]) ^ flag[29] == 13) && ((flag[35] + flag[33]) ^ (flag[26] + flag[21]) == 249) && ((flag[17] + flag[24]) ^ (flag[34] + flag[1]) == 253) && ((flag[32] - flag[35] + flag[19]) ^ flag[1] == 0) && ((flag[22] - flag[11] + flag[3]) ^ flag[31] == 113) && ((flag[19] - flag[0]) * flag[13] == 108) && ((flag[19] - flag[17]) * flag[14] == -2475) && ((flag[31] - flag[35] + flag[16]) ^ flag[19] == 84) && ((flag[24] * flag[27]) ^ (flag[35] - flag[17]) == -5792) && ((flag[11] * flag[35]) ^ (flag[15] - flag[28]) == -2845) && ((flag[18] - flag[19] + flag[31]) ^ flag[5] == 112) && ((flag[20] - flag[6]) * flag[10] == -3933) && ((flag[39] - flag[33]) * flag[6] == 3075) && ((flag[22] + flag[1]) ^ (flag[39] + flag[14]) == 211) && ((flag[37] * flag[24]) ^ (flag[12] - flag[39]) == -5726) && ((flag[29] + flag[3]) ^ (flag[8] + flag[11]) == 195) && ((flag[26] * flag[7]) ^ (flag[10] - flag[17]) == -2375) && ((flag[11] - flag[12]) * flag[12] == -4653) && ((flag[13] * flag[5]) ^ (flag[12] - flag[25]) == 3829) && ((flag[24] * flag[0]) ^ (flag[13] - flag[23]) == -2829) && ((flag[17] + flag[12]) ^ (flag[8] + flag[14]) == 170) && ((flag[38] + flag[23]) ^ (flag[11] + flag[1]) == 245) && ((flag[22] + flag[5]) ^ (flag[21] + flag[24]) == 19) && ((flag[35] - flag[8] + flag[21]) ^ flag[30] == 85) && ((flag[18] - flag[31] + flag[28]) ^ flag[29] == 0) && ((flag[30] * flag[35]) ^ (flag[27] - flag[29]) == 5501) && ((flag[8] - flag[30] + flag[16]) ^ flag[36] == 81) && ((flag[13] * flag[18]) ^ (flag[35] - flag[38]) == -2971) && ((flag[27] - flag[14]) * flag[39] == 5875) && ((flag[34] - flag[33]) * flag[6] == -6027) && ((flag[38] * flag[1]) ^ (flag[20] - flag[10]) == -2915) && ((flag[1] - flag[1]) * flag[3] == 0) && ((flag[36] - flag[20]) * flag[8] == 2640) && ((flag[23] - flag[11] + flag[17]) ^ flag[33] == 246) && ((flag[13] - flag[38]) * flag[0] == -100) && ((flag[28] - flag[14]) * flag[31] == 2142) && ((flag[26] + flag[15]) ^ (flag[13] + flag[31]) == 8) && ((flag[36] - flag[15]) * flag[17] == 5238) && ((flag[16] - flag[30]) * flag[33] == 0) && ((flag[2] - flag[20] + flag[13]) ^ flag[6] == 76) && ((flag[10] - flag[14] + flag[31]) ^ flag[13] == 3) && ((flag[0] * flag[10]) ^ (flag[14] - flag[31]) == 2854) && ((flag[28] - flag[34] + flag[14]) ^ flag[14] == 82) && ((flag[28] - flag[25]) * flag[1] == 2444) && ((flag[34] - flag[12]) * flag[25] == -2400) && ((flag[28] * flag[38]) ^ (flag[17] - flag[4]) == 5429) && ((flag[21] - flag[21] + flag[26]) ^ flag[23] == 84) && ((flag[9] - flag[4] + flag[18]) ^ flag[35] == 47) && ((flag[28] - flag[21] + flag[1]) ^ flag[33] == 0) && ((flag[24] - flag[25] + flag[22]) ^ flag[0] == 8) && ((flag[28] - flag[25]) * flag[12] == 4653) && ((flag[1] * flag[15]) ^ (flag[10] - flag[8]) == 2498) && ((flag[5] * flag[7]) ^ (flag[15] - flag[34]) == -3429) && ((flag[8] * flag[3]) ^ (flag[23] - flag[22]) == 3671) && ((flag[25] - flag[33]) * flag[11] == -2600) && ((flag[21] + flag[12]) ^ (flag[37] + flag[28]) == 81) && ((flag[30] + flag[33]) ^ (flag[34] + flag[14]) == 162) && ((flag[6] - flag[25]) * flag[8] == 4015) && ((flag[24] - flag[7] + flag[12]) ^ flag[7] == 90) && ((flag[18] * flag[12]) ^ (flag[8] - flag[4]) == -5466) && ((flag[32] * flag[7]) ^ (flag[32] - flag[27]) == -2730) && ((flag[32] * flag[34]) ^ (flag[29] - flag[16]) == 2804) && ((flag[25] * flag[22]) ^ (flag[28] - flag[39]) == -2542) && ((flag[8] - flag[15]) * flag[6] == 861) && ((flag[20] + flag[18]) ^ (flag[25] + flag[36]) == 245) && ((flag[5] - flag[28] + flag[14]) ^ flag[39] == 97) && ((flag[30] * flag[11]) ^ (flag[16] - flag[11]) == 5216) && ((flag[11] + flag[18]) ^ (flag[7] + flag[9]) == 13) && ((flag[9] - flag[2]) * flag[30] == -200) && ((flag[12] + flag[37]) ^ (flag[9] + flag[4]) == 78) && ((flag[10] - flag[37]) * flag[38] == -2408) && ((flag[5] * flag[19]) ^ (flag[20] - flag[21]) == 3645) && ((flag[27] * flag[29]) ^ (flag[39] - flag[21]) == 10354) && ((flag[15] * flag[32]) ^ (flag[7] - flag[22]) == -2642) && ((flag[1] - flag[3] + flag[24]) ^ flag[31] == 25) && ((flag[13] - flag[0]) * flag[30] == 400) && ((flag[18] - flag[15] + flag[36]) ^ flag[28] == 12) && ((flag[34] + flag[21]) ^ (flag[12] + flag[37]) == 163) && ((flag[36] - flag[33]) * flag[14] == 110) && ((flag[2] - flag[3]) * flag[3] == -804) && ((flag[35] - flag[27] + flag[22]) ^ flag[4] == 80) && ((flag[10] + flag[9]) ^ (flag[17] + flag[2]) == 246) && ((flag[25] * flag[4]) ^ (flag[27] - flag[23]) == 4201) && ((flag[32] * flag[19]) ^ (flag[3] - flag[25]) == 2877) && ((flag[37] - flag[14]) * flag[23] == 4545) && ((flag[32] + flag[13]) ^ (flag[31] + flag[32]) == 7) && ((flag[11] - flag[25]) * flag[39] == 250) && ((flag[17] + flag[31]) ^ (flag[6] + flag[9]) == 36) && ((flag[4] + flag[27]) ^ (flag[2] + flag[31]) == 208) && ((flag[6] + flag[7]) ^ (flag[26] + flag[21]) == 206) && ((flag[19] + flag[25]) ^ (flag[22] + flag[10]) == 10) && ((flag[34] + flag[2]) ^ (flag[8] + flag[26]) == 2) && ((flag[7] + flag[5]) ^ (flag[12] + flag[14]) == 237) && ((flag[1] - flag[13]) * flag[38] == -112) && ((flag[0] - flag[19] + flag[16]) ^ flag[0] == 80) && ((flag[31] + flag[36]) ^ (flag[3] + flag[2]) == 227) && ((flag[32] - flag[3] + flag[26]) ^ flag[4] == 113) && ((flag[3] * flag[6]) ^ (flag[16] - flag[27]) == -8241) && ((flag[24] + flag[15]) ^ (flag[2] + flag[30]) == 242) && ((flag[11] + flag[21]) ^ (flag[31] + flag[20]) == 12) && ((flag[9] - flag[26] + flag[23]) ^ flag[30] == 13)) {
	  result = "";
      for (var idx in flag) {
	    result += (String.fromCharCode(flag[idx]));
	  }
	  this.dom.lock.classList.add('verified');
    }
    return result;
  }

}

```

The parameter passed to `checkFlag()` is a dictionary like object with 40 entries. 
```
{0: "0", 1: "0", 2: "0", 3: "0", 4: "0", 5: "0", 6: "0", 7: "0", 8: "0", 9: "0", 10: "0", 11: "0", 12: "0", 13: "0", 14: "0", 15: "0", 16: "0", 17: "0", 18: "0", 19: "0", 20: "0", 21: "0", 22: "0", 23: "0", 24: "0", 25: "0", 26: "0", 27: "0", 28: "0", 29: "0", 30: "0", 31: "0", 32: "0", 33: "0", 34: "0", 35: "0", 36: "0", 37: "0", 38: "0", 39: "0"}
```
The problem is the HUGE if condition in `checkFlag()` this paramter has to satify. We somehow have to work backwards from this condition. We can probably assume a few things

* the flag is 40 chracters long (obviously)
* the first 7 characters are `247CTF{` and the last character is `}`
* all other chracters are ascii so the values must be btween 48 and 57 (numbers), 65 and 90 (lowercase) or 97 and 122 uppercase.

Luckily there is a solver for these kind of expressions. It's called z3 is kinda commonly used in ctf's. We'll just add all the conditions from the huge if.
```
from z3 import *

s = Solver()
flag = []
for i in range(40):
    flag.append(BitVec(f'flag[{i}]', 8))

s.add((flag[37] - flag[37]) * flag[15] == 0)
s.add((flag[3] + flag[31]) ^ (flag[29] + flag[8]) == 234)
s.add((flag[32] - flag[12]) * flag[9] == -2332)
[...]
s.add((flag[9] - flag[26] + flag[23]) ^ flag[30] == 13)
```
We'll also add the `247CTF{}` part we allready know is correct.
```
s.add(flag[0] == 50)
s.add(flag[1] == 52)
s.add(flag[2] == 55)
s.add(flag[3] == 67)
s.add(flag[4] == 84)
s.add(flag[5] == 70)
s.add(flag[6] == 123)
s.add(flag[39] == 125)
```
Then we can easily get our flag.
```
print(s.check())
model = s.model()

for x in flag:
    print(chr(model[x].as_long()), end="")
```
