'use strict';
 
var exec = require('cordova/exec');
 
var BH_Face_Alive = {
 
  bh_face_alive: function(args, success, error) {
    return exec(success, error, 'BH_Face_AliveOCPlugin', 'bh_face_alive', args);
  },

  encode: function(args,success,error){
  	return exec(success,error,'BH_Face_AliveOCPlugin','encode',args)
  }
 
};
 
module.exports = BH_Face_Alive;
