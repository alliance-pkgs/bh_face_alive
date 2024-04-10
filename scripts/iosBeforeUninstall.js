'use strict';

const fs = require('fs');
const path = require('path');

module.exports = async context => {
  try {
    await removeHtmlFile();
    console.log('bh_face_alive - afterPluginUninstall -> removeHtmlFile successful.');
  } catch (error) {
    console.log('bh_face_alive - beforePluginUninstall -> removeHtmlFile error:' + error instanceof Object ? JSON.stringify(error) : error);
  }
}

function removeHtmlFile() {
  const target = path.join(__dirname, '../../../www/bh_face_alive.html');

  fs.unlink(target, function (err) {
    if (err && err.code == 'ENOENT') {
      console.log(target + " doesn't exist");
    } else if (err) {
      console.log('Error occurred while trying to remove file - ' + target);
    } else {
      console.log(target + ' removed');
    }
  });
}