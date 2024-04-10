var exec = require('cordova/exec');

exports.coolMethod = function(arg0, success, error) {
    exec(success, error, "BH_Face_Alive", "coolMethod", [arg0]);
};

// bh_face_alive 调用活体检测接口
exports.bh_face_alive = function(arg0, success, error) {
	exec(success, error, "BH_Face_Alive", "bh_face_alive", arg0);
}

// 调用压图片接口
exports.encode = function(arg0, success, error) {
	exec(success, error, "BH_Face_Alive", "encode", arg0);
}
