'use strict';

const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const copyFile = promisify(fs.copyFile);

module.exports = async context => {
  try {
    await copyHtmlFile();
    console.log('bh_face_alive - afterPluginInstall -> copyHtmlFile successful.');
  } catch (error) {
    console.log('bh_face_alive - afterPluginInstall -> copyHtmlFile error:' + error instanceof Object ? JSON.stringify(error) : error);
  }
}

function copyHtmlFile() {
  const target = path.join(__dirname, '../../../www/bh_face_alive.html');
  const source = path.join(__dirname, '../src/ios/bh_face_alive.html');
  return copyFile(source, target);
}