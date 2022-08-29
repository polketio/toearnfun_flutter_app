/**
 * HelloWorld.test.ts
 */


import keyring from "../src/service/keyring";

const testKeystore =
    '{"pubKey":"0xcc597bd2e7eda5094d6aa462523b629a502db6cc71a6ae0e9b158d9e42c6c462","mnemonic":"welcome clinic duck mom connect heart poet admit vendor robot group vacuum","rawSeed":"","address":"15cwMLiH57HvrqBfMYpt5AgGrb5SAUKx7XQUcHnBSs2DAsGt","encoded":"taoH2SolrO8UhraK1JxuNW9AcMMPY5UXMTJjlcpuyEEAgAAAAQAAAAgAAADdvrSwzB9yIFQ7ZCHQoQQV93zLhlAiZlits1CX2hFNm3/zPjYW63U7NzoF76UU4hUvyUTmrvT/K37v0zQ1eFrXwXvc2fmKFJ17qSR2oDvHfuCb+ruCsSrx/UsGtNLbzyCiomVYGMvRh/EzHEfBQO4jGaDi4Sq5++8QE2vuDUTePF8WsVSb5L9N30SFuNQ1YiTH7XBRG9zQhQTofLl0","encoding":{"content":["pkcs8","sr25519"],"type":["scrypt","xsalsa20-poly1305"],"version":"3"},"meta":{}}';


test('hello world test', async () => {
    console.log("init keys from json");
    const initialAcc = await keyring.initKeys([JSON.parse(testKeystore)], [0, 2]);
});
