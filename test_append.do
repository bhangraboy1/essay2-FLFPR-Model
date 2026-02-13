global outputpath "/Users/ashbelur/Documents/ash belur/BIGPROJECTS/phd/STATA/NSSO/essay2-FLFPR-Model/"

clear all

input id height
1 130
2 140
3 160
end
save "${outputpath}original", replace

clear all
input id height weight
4 125 65
5 135 76
6 145 87
end
save "${outputpath}new1", replace

use "${outputpath}new1"

append using "${outputpath}original"
save "${outputpath}combined", replace

clear all
input id height weight
7 127 65
8 137 76
9 147 87
end
save "${outputpath}new2", replace

append using "${outputpath}combined"
save "${outputpath}combined", replace


list
