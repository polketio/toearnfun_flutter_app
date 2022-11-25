
import { ApiPromise, Keyring, WsProvider } from '@polkadot/api';
import { KeyringPair } from '@polkadot/keyring/types';
import { u64 } from "@polkadot/types-codec";
import vfe from "../src/service/vfe";


describe('polket-node module: `VFE` unit test', () => {

    let wsProvider: WsProvider;
    let api: ApiPromise;
    let keyring: Keyring;
    let user: KeyringPair;

    // Some mnemonic phrase
    const PHRASE = 'hello pencil unit ivory silk accuse army nation misery creek digital juice';

    beforeAll(async () => {
        // Construct
        wsProvider = new WsProvider('wss://testnet-node.polket.io');
        api = await ApiPromise.create({ provider: wsProvider });
        // Create a keyring instance
        keyring = new Keyring({ type: 'sr25519' });
        // Add an account, straight mnemonic
        user = keyring.addFromUri(PHRASE);

    });

    afterAll(async () => {
        // close connection
        await api.disconnect();
    });

    test('generate account unit test', async () => {
        const { nonce, data: balance } = await api.query.system.account(user.address);
        console.log(`user address: ${user.address}`);
        console.log(`user balance: ${balance.free}`);

    });

    test('query devices unit test', async () => {
        //get a registered status of device
        const devices = await api.query.vfe.devices.entries();
        devices.forEach(([k, m]) => {
            const device = m.toHuman();
            console.log('device:', device);

        });
    });

    test('producer register unit test', async () => {
        const unsub = await api.tx.vfe.producerRegister()
            .signAndSend(user, (result) => {
                console.log(`Current status is ${result.status}`);
                if (result.dispatchError) {
                    console.log(`dispatchError is ${result.dispatchError.toString()}`);
                }

                if (result.status.isInBlock) {
                    console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
                } else if (result.status.isFinalized) {
                    console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
                    unsub();
                }
            });

        await sleep(20000);
    });

    test('bind device for registered status unit test', async () => {

        let pubKey = '0x0339d3e6e837d675ce77e85d708caf89ddcdbf53c8e510775c9cb9ec06282475a0';
        let signature = '0x403e0f3312237f13eaf6b4c92da199732ce411607fb05b5a01a3e60dbe98988a5f2fa5511c4fead2c3427cd81c7c3970cfcd2046b6700ea57a9ddf3b558c060a';
        let nonce = 1;
        let itemId = null;

        const unsub = await api.tx.vfe.bindDevice(pubKey, signature, nonce, itemId)
            .signAndSend(user, (result) => {
                console.log(`Current status is ${result.status}`);
                if (result.dispatchError) {
                    console.log(`dispatchError is ${result.dispatchError.toString()}`);
                }

                if (result.status.isInBlock) {
                    console.log(`Transaction included at blockHash ${result.status.asInBlock}`);
                } else if (result.status.isFinalized) {
                    console.log(`Transaction finalized at blockHash ${result.status.asFinalized}`);
                    unsub();
                }
            });

        await sleep(12000);
    });

    test('query VFE items unit test', async () => {
        const userAddr = '5Ejq3y9rnwEzPLJjNd8qZHapjHt3c2LmV6j9V7Vh7cfUikLU';
        const items = await api.query.vfeUniques.account.keys<[any, any, any]>(userAddr, 1);
        items.map(({ args: [,, itemId] }) => {
            console.log(`itemId: ${itemId}`);
        });
    });

    test('query VFE detail unit test', async () => {
        const userAddr = '5Ejq3y9rnwEzPLJjNd8qZHapjHt3c2LmV6j9V7Vh7cfUikLU';
        const brandId = 1;
        const details = await vfe.getVFEDetailsByAddress(api, userAddr, brandId);
        // const items = await api.query.vfeUniques.account.keys<[any, any, any]>(userAddr, 1);
        // const ids = items.map(({ args: [, brandId, itemId] }) => [brandId, itemId]);
        // const details = await api.query.vfe.vfeDetails.multi(ids);

        details.forEach((detail) => {
            console.log(`detail: ${detail}`);
        });
    });
});


const sleep = (ms) => new Promise(r => setTimeout(r, ms));

