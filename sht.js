var fs = require("fs");
var input = fs.readFileSync(0).toString();
var msg = JSON.parse(input)
msg.data.composerData = JSON.parse(msg.data.composerData)
console.log(JSON.stringify(msg, null, 2))
