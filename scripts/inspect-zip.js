const fs = require('fs');
const path = process.argv[2];
const buf = fs.readFileSync(path);
const sig = Buffer.from([0x50, 0x4b, 0x03, 0x04]);
let pos = 0;
let count = 0;
let hasBackslash = false;
let hasForwardslash = false;
const samples = [];
while ((pos = buf.indexOf(sig, pos)) !== -1) {
  const nameLen = buf.readUInt16LE(pos + 26);
  const extraLen = buf.readUInt16LE(pos + 28);
  const name = buf.slice(pos + 30, pos + 30 + nameLen).toString('utf8');
  if (name.indexOf('\\') !== -1) hasBackslash = true;
  if (name.indexOf('/') !== -1) hasForwardslash = true;
  if (samples.length < 6) samples.push(name);
  count++;
  pos += 30 + nameLen + extraLen;
}
console.log('Entries:', count);
console.log('Has backslash in any entry name:', hasBackslash);
console.log('Has forward slash in any entry name:', hasForwardslash);
console.log('Sample paths:');
samples.forEach(s => console.log('  ' + JSON.stringify(s)));
