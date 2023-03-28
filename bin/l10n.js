#!/usr/bin/env node

const fs = require("fs");
const execSync = require("child_process").execSync;

const args = process.argv.slice(2);

const msgPath = execSync(`fd messages_en.json ${args[0]}`).toString().split('\n')[0];
if (!msgPath) {
  process.exit(0);
}

const msg = JSON.parse(fs.readFileSync(msgPath));

var content = fs.readFileSync(0).toString();

for (const [lineNo, line] of content.split("\n").entries()) {
  for (const m of line.matchAll(/["']([\w\.]*)["']/g)) {
    const key = m[1];
    if (msg[key]) {
      console.log(
        `${lineNo + 1}:${m.index + 1}:${m.index + key.length + 1} en: ${msg[key]}`
      );
    }
  }
}
