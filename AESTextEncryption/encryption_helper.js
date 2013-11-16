function iiAESEncrypt(text, key) {
  try {
    return CryptoJS.AES.encrypt(text, key).toString();
  }
  catch(err) {
    return '';
  }
}

function iiAESDecrypt(text, key) {
  try {
    return CryptoJS.AES.decrypt(text, key).toString(CryptoJS.enc.Utf8);
  }
  catch(err) {
    return '';
  }
}