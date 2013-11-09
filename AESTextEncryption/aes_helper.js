function iiAESEncrypt(text, key) {
  return CryptoJS.AES.encrypt(text, key).toString();
}

function iiAESDecrypt(text, key) {
  return CryptoJS.AES.decrypt(text, key).toString(CryptoJS.enc.Utf8);
}