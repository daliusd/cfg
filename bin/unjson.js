var fs = require("fs");
var input = fs.readFileSync(0).toString();
var msg = JSON.parse(input)
console.log(msg)
