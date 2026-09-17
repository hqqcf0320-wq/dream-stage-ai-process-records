// Run with Node.js after installing gltf-validator via the local glTF-Transform toolchain.
const fs = require('node:fs');
const path = require('node:path');
const validator = require('../.tools/gltf/node_modules/gltf-validator');
(async () => {
  const reports = {};
  for (const name of ['room', 'bear', 'grandpa']) {
    const file = path.resolve('game/assets', name + '.glb');
    const report = await validator.validateBytes(new Uint8Array(fs.readFileSync(file)), {uri: file});
    reports[name] = report;
    console.log(name, JSON.stringify({errors: report.issues.numErrors, warnings: report.issues.numWarnings, info: report.issues.numInfos, codes: [...new Set(report.issues.messages.map(m => m.code))]}));
    if (report.issues.numErrors) process.exitCode = 1;
  }
  fs.writeFileSync('.tools/asset-validation.json', JSON.stringify(reports, null, 2));
})();
